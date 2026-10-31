// add-book-note.js — append one photo's transcription to "<Book> — Book Notes" in Anytype.
//
// Args (passed by book-notes.sh):
//   payload=@file.json  { book, author?, chapter?, section?, page?, passages: [markdown, ...] }
//   imageHash           sha256 of the source image (hex)
//   imageName           original file name, for the meta line
//   space               space id (falls back to env.ANYTYPE_SPACE_ID)
//   dryRun=true         report what would happen; create and write nothing
//
// Idempotency: the notes page is the ledger. Each block ends with "img:<hash16>".
//   1. hash already on page          -> duplicate_image (verified, nothing written)
//   2. every passage already on page -> duplicate_text  (verified, nothing written)
//   3. otherwise append only the new passages, re-read the page, and verify.

import { createClient } from "anytypeHelper@v1";

// Share of a passage's word pairs already present on the page. Three typos in a 60-word paragraph
// scored 0.91 in testing; distinct prose paragraphs rarely share more than ~20% of word pairs.
var SIMILARITY_THRESHOLD = 0.8;
var SHORT_PASSAGE_WORDS = 6;    // below this, word pairs are too noisy: require exact containment
var NOTES_SUFFIX = " — Book Notes";

function normalize(s) {
  s = String(s || "");
  try { s = s.normalize("NFKC"); } catch (e) {}
  s = s.toLowerCase();
  s = s.replace(/­/g, "");                          // soft hyphens
  s = s.replace(/[-‐‑]\s*\n\s*/g, "");         // hyphenation across line breaks
  s = s.replace(/[-‐‑'‘’‛]/g, ""); // "anti-pattern" == "antipattern", "it's" == "its"
  s = s.replace(/[^a-z0-9]+/g, " ");                     // dashes, quotes, markdown -> word breaks
  return s.trim();
}

function words(s) {
  var n = normalize(s);
  return n ? n.split(" ") : [];
}

function wordPairs(ws) {
  var set = {};
  if (ws.length === 1) set[ws[0]] = true;
  for (var i = 0; i + 1 < ws.length; i++) set[ws[i] + " " + ws[i + 1]] = true;
  return set;
}

function makeIndex(markdown) {
  var ws = words(markdown);
  return { pairs: wordPairs(ws), flat: " " + ws.join(" ") + " " };
}

function similarity(passageWords, index) {
  if (passageWords.length < SHORT_PASSAGE_WORDS) {
    return index.flat.indexOf(" " + passageWords.join(" ") + " ") !== -1 ? 1 : 0;
  }
  var pairs = wordPairs(passageWords);
  var total = 0, hit = 0;
  for (var k in pairs) {
    total++;
    if (index.pairs[k]) hit++;
  }
  return total ? hit / total : 1;
}

function sameName(a, b) {
  return normalize(a) === normalize(b);
}

function titleOnly(name) {
  var i = String(name || "").indexOf(":");
  return i === -1 ? name : name.slice(0, i);
}

function quote(text) {
  var lines = String(text).replace(/\r/g, "").trim().split("\n");
  var out = [];
  for (var i = 0; i < lines.length; i++) out.push(lines[i].trim() ? "> " + lines[i] : ">");
  return out.join("\n");
}

function result(fields) {
  return JSON.stringify(fields);
}

// Prefer a Book object; fall back to a Page with the same title (some books live as pages).
function findBook(client, title) {
  var notesName = title + NOTES_SUFFIX;
  var byType = [["book", client.getObjects("book")], ["page", client.getObjects("page")]];
  for (var t = 0; t < byType.length; t++) {
    var list = byType[t][1];
    if (list.error) return { error: "getObjects(" + byType[t][0] + "): " + list.error };
    var matches = [];
    for (var i = 0; i < list.length; i++) {
      var o = list[i];
      if (o.archived || sameName(o.name, notesName)) continue;
      if (sameName(o.name, title) || sameName(titleOnly(o.name), title)) matches.push(o);
    }
    if (matches.length === 1) return { object: matches[0] };
    if (matches.length > 1) {
      var c = [];
      for (var j = 0; j < matches.length; j++) c.push({ id: matches[j].id, name: matches[j].name, type: byType[t][0] });
      return { ambiguous: c };
    }
  }
  return {};
}

function findNotesPage(client, title) {
  var pages = client.getObjects("page");
  if (pages.error) return { error: "getObjects(page): " + pages.error };
  var matches = [];
  for (var i = 0; i < pages.length; i++) {
    if (!pages[i].archived && sameName(pages[i].name, title + NOTES_SUFFIX)) matches.push(pages[i]);
  }
  if (matches.length > 1) {
    var c = [];
    for (var j = 0; j < matches.length; j++) c.push({ id: matches[j].id, name: matches[j].name });
    return { ambiguous: c };
  }
  return { object: matches[0] || null };
}

export function main(args) {
  var p;
  try { p = JSON.parse(args.payload); } catch (e) { return result({ status: "bad_input", verified: false, error: "payload is not JSON: " + e }); }
  var hash = String(args.imageHash || "").toLowerCase();
  var dryRun = args.dryRun === "true";
  var spaceId = args.space || env.ANYTYPE_SPACE_ID;

  if (!p.book || !p.passages || !p.passages.length) return result({ status: "bad_input", verified: false, error: "payload needs book and passages[]" });
  if (!/^[0-9a-f]{64}$/.test(hash)) return result({ status: "bad_input", verified: false, error: "imageHash must be a sha256 hex digest" });
  if (!spaceId) return result({ status: "bad_input", verified: false, error: "no space id: run book-notes.sh setup space <id>" });

  var client = createClient({ apiBaseUrl: env.ANYTYPE_API_URL, apiKey: env.ANYTYPE_API_KEY, spaceId: spaceId });
  var marker = "img:" + hash.slice(0, 16);
  var notesName = p.book + NOTES_SUFFIX;
  var base = { book: p.book, notesPage: notesName, image: args.imageName || null, marker: marker, dryRun: dryRun };

  function out(fields) {
    for (var k in base) if (!(k in fields)) fields[k] = base[k];
    return result(fields);
  }

  // Notes page first: if it already holds this image, nothing else matters.
  var notesLookup = findNotesPage(client, p.book);
  if (notesLookup.error) return out({ status: "error", verified: false, error: notesLookup.error });
  if (notesLookup.ambiguous) return out({ status: "ambiguous_notes_page", verified: false, candidates: notesLookup.ambiguous });
  var notes = notesLookup.object;

  var markdown = "";
  if (notes) {
    var existing = client.getObject(notes.id);
    markdown = (existing && existing.markdown) || "";
    if (markdown.toLowerCase().indexOf(marker) !== -1) {
      return out({ status: "duplicate_image", verified: true, notesPageId: notes.id });
    }
  }

  var index = makeIndex(markdown);
  var fresh = [], skipped = [];
  for (var i = 0; i < p.passages.length; i++) {
    var ws = words(p.passages[i]);
    if (!ws.length) continue;
    var score = similarity(ws, index);
    var preview = p.passages[i].replace(/\s+/g, " ").slice(0, 60);
    if (score >= SIMILARITY_THRESHOLD) skipped.push({ preview: preview, similarity: Math.round(score * 100) / 100 });
    else fresh.push(p.passages[i]);
  }
  if (!fresh.length) {
    return out({ status: "duplicate_text", verified: true, notesPageId: notes ? notes.id : null, skipped: skipped });
  }

  var heading = [];
  if (p.chapter) heading.push("Ch. " + p.chapter);
  if (p.section) heading.push(p.section);
  if (p.page) heading.push("p. " + p.page);
  var quotes = [];
  for (var q = 0; q < fresh.length; q++) quotes.push(quote(fresh[q]));
  var meta = "Added " + new Date().toISOString().slice(0, 10) + " · " + (args.imageName || "photo") + " · " + marker;
  var block = "\n## " + (heading.length ? heading.join(" · ") : "Notes") + "\n\n" + quotes.join("\n\n") + "\n\n" + meta + "\n";

  var bookLookup = findBook(client, p.book);
  if (bookLookup.error) return out({ status: "error", verified: false, error: bookLookup.error });
  if (bookLookup.ambiguous) return out({ status: "ambiguous_book", verified: false, candidates: bookLookup.ambiguous });
  var book = bookLookup.object || null;

  if (dryRun) {
    return out({
      status: "dry_run", verified: false,
      wouldCreateBook: !book, wouldCreateNotesPage: !notes,
      bookId: book ? book.id : null, notesPageId: notes ? notes.id : null,
      skipped: skipped, block: block
    });
  }

  var created = [];
  if (!book) {
    var bookData = { name: p.book, icon: "📘" };
    if (p.author) bookData.description = "by " + p.author;
    var cb = client.createObject("book", bookData);
    if (!cb.ok) return out({ status: "error", verified: false, error: "create book: " + cb.error });
    book = cb.object;
    created.push("book");
  }

  var notesId;
  if (!notes) {
    var header = "Book notes for [" + p.book + "](anytype://object?objectId=" + book.id + "&spaceId=" + spaceId + ")\n";
    var cn = client.createObject("page", { name: notesName, icon: "📝", body: header + block });
    if (!cn.ok) return out({ status: "error", verified: false, error: "create notes page: " + cn.error, created: created });
    notesId = cn.id;
    created.push("notes_page");
  } else {
    var ap = client.appendToObject(notes.id, block);
    if (!ap.ok) return out({ status: "error", verified: false, error: "append: " + ap.error });
    notesId = notes.id;
  }

  // Verify against what Anytype actually stored, not what we sent.
  var after = client.getObject(notesId);
  var stored = (after && after.markdown) || "";
  var afterIndex = makeIndex(stored);
  var markerOk = stored.toLowerCase().indexOf(marker) !== -1;
  var lowest = 1;
  for (var v = 0; v < fresh.length; v++) {
    var s = similarity(words(fresh[v]), afterIndex);
    if (s < lowest) lowest = s;
  }
  var verified = markerOk && lowest >= SIMILARITY_THRESHOLD;

  return out({
    status: verified ? "added" : "unverified",
    verified: verified,
    bookId: book.id, notesPageId: notesId, created: created,
    added: fresh.length, skipped: skipped,
    check: { markerFound: markerOk, lowestPassageSimilarity: Math.round(lowest * 100) / 100 }
  });
}
