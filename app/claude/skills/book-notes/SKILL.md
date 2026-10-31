---
name: book-notes
description: Transcribe photos of book pages from the user's BookNotes inbox (Synology Drive, one subfolder per book) into a per-book "<Title> — Book Notes" page in Anytype, then delete each photo once its text is verified in Anytype. Use when the user asks to process, import, sync, or transcribe book notes, book highlights, page photos, or reading snippets, e.g. "process my book notes" or "import highlights for Writing Great Specifications". Safe to re-run; it never duplicates notes.
---

# Book notes: page photos → Anytype

The user photographs book pages on their phone into `<inboxRoot>/<book-slug>/`. You transcribe each
photo; the scripts handle Anytype, duplicate checks, and deleting the photo.

Paths below are relative to this skill's directory (`~/.claude/skills/book-notes`). The skill is
self-contained:
- `config.json`: `inboxRoot` and `apiUrl`. Not secret.
- `.env`: the Anytype API key and space id. Created by `setup` and gitignored. **Never print, cat,
  or copy it.**
- `scripts/anytypeHelper.js`: vendored MIT client library (see `anytypeHelper.LICENSE`).

## Prerequisites

- The Anytype desktop app is running, and `anytype-agent-runtime` is on PATH. If a run fails with a
  connection error, tell the user to open Anytype. Don't retry in a loop.
- `jq`, `sha256sum`, and Python with Pillow are available.

## First-time setup (once per machine)

If any command says `not set up on this machine`:

1. `bash scripts/book-notes.sh setup request`: Anytype desktop shows a 4-digit code. Ask the user
   for it.
2. `bash scripts/book-notes.sh setup solve <challenge_id> <code>`: saves the key to `.env` and lists
   spaces. The key is never printed.
3. `bash scripts/book-notes.sh setup space <space_id>`: if there's more than one space, ask the user
   which to use.

`bash scripts/book-notes.sh setup status` confirms the key works and names the chosen space.

## Workflow

1. **List pending photos:** `bash scripts/book-notes.sh inbox` prints `<book-slug>\t<path>` lines.
   If it prints nothing, tell the user the inbox is empty and stop.
2. **Work out the book title** from the slug: `writing-great-specifications` →
   `Writing Great Specifications`. Use the book's real capitalization if you know it, and drop any
   subtitle. Use the same title for every photo in that folder, or the notes will split across pages.
3. **For each photo:**
   1. `bash scripts/book-notes.sh prep "<path>"`, then Read the printed file. Phone photos are often
      sideways even after EXIF correction. If the text isn't upright, re-run with the clockwise
      degrees needed (`90`, `180`, or `270`) and Read it again.
   2. **Transcribe** following the rules below.
   3. Write the payload to a temp JSON file (UTF-8):
      ```json
      {
        "book": "Writing Great Specifications",
        "chapter": "1",
        "section": "1.3 Common specification pitfalls",
        "page": "8",
        "passages": ["First paragraph…", "Intro line:\n- item one\n- item two"]
      }
      ```
      Only include `chapter`, `section`, `page`, and `author` when they are printed in the photo.
   4. `bash scripts/book-notes.sh add "<path>" <payload.json>`. It prints one JSON result line.
      On a verified result it deletes the photo and reports that on stderr.
4. **Report** one line per photo: book, status, passages added or skipped, and whether the photo
   was deleted.

The first time a new book comes through, or if you're unsure about a transcription, run
`add … --dry-run` first. It creates nothing, shows the exact block it would write, and never deletes.

## Transcription rules

- **Highlights present** (marker, underline, bracket): transcribe only the highlighted text.
- **No highlights:** transcribe all complete text. Skip lines cut off at the page edges and any
  paragraph that starts or ends outside the photo. Put section headings in `section`, not in
  `passages`.
- **One passage per paragraph.** Keep a list together with the sentence that introduces it
  (`"Intro:\n- a\n- b"`).
- **Copy the text exactly.** Don't paraphrase, fix grammar, or add commentary. Rejoin words that are
  hyphenated only because of a line break (`speci-⏎fication` → `specification`), but keep hyphens that
  belong to the word (`anti-⏎patterns` → `anti-patterns`). Keep the book's typographic quotes and dashes.
- Running headers and footers (`CHAPTER 1  Introduction to…`, page numbers) go into `chapter`/`page`,
  never into `passages`.
- **If you can't read something with confidence** (blur, glare, curved gutter text), don't guess.
  Leave that photo for the user, run nothing for it, and say what was unreadable.

## Result statuses

| status | meaning | photo |
|---|---|---|
| `added` | new passages written, and the stored page was re-read and confirmed | deleted |
| `duplicate_image` | this exact photo was already recorded (`img:<hash>` found on the page) | deleted |
| `duplicate_text` | every passage is already on the page (≥80% of its word pairs match, which tolerates transcription differences) | deleted |
| `unverified` | write happened but the re-read didn't match; **tell the user** | kept |
| `ambiguous_book` / `ambiguous_notes_page` | several matching objects; ask the user which one, using `candidates` | kept |
| `dry_run` | preview only | kept |
| `bad_input` / `error` | fix and retry once; otherwise report | kept |

## How the Anytype side is laid out

- The **Book** object (type `book`, or an existing page with the same title) is found or created
  once. The skill never edits its contents.
- **`<Title> — Book Notes`** (type `page`) belongs entirely to this skill. It starts with a clickable
  link to the Book. The API doesn't turn markdown links into Anytype links (tested: `links` and
  `backlinks` stay null), so the Book doesn't list its notes page; find it by name. Each photo adds a
  `## Ch. · section · p.` heading, its passages as blockquotes, and a meta line ending in
  `img:<first 16 hex of sha256>`. That line is how re-runs recognize a photo, so don't remove it by hand.
