#!/usr/bin/env bash
# book-notes.sh — deterministic plumbing for the book-notes skill. Self-contained: credentials and the
# space id live in ../.env (created by `setup`), everything else in ../config.json.
#
#   book-notes.sh setup request                  ask Anytype desktop for a 4-digit code; prints challenge_id
#   book-notes.sh setup solve <challenge_id> <code>
#                                                exchange the code for an API key, write .env, list spaces
#   book-notes.sh setup space <space_id>         choose the space notes are written to
#   book-notes.sh setup status                   check the key works and show the chosen space
#
#   book-notes.sh inbox                          list pending images as "<book-slug>\t<path>"
#   book-notes.sh prep <image> [clockwise_deg]   write an upright, downscaled JPEG copy; print its path
#   book-notes.sh add <image> <payload.json> [--dry-run]
#                                                write the transcription to Anytype; on a verified
#                                                write, delete the image (only if it's under inboxRoot)
set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG="$SKILL_DIR/config.json"
ENV_FILE="$SKILL_DIR/.env"

die() { echo "book-notes: $*" >&2; exit 1; }

# JQ-CRLF: on Windows jq is a native binary and ends lines with \r\n — strip after jq, always.
cfg() { jq -r "$1" "$CONFIG" | tr -d '\r'; }

# Native Windows programs (python, anytype-agent-runtime) can't open MSYS paths like /tmp/x.
winpath() {
  if command -v cygpath >/dev/null 2>&1; then cygpath -m "$1"; else printf '%s' "$1"; fi
}

require_runtime() {
  command -v anytype-agent-runtime >/dev/null 2>&1 || die "anytype-agent-runtime not on PATH"
}

require_env() {
  [[ -f "$ENV_FILE" ]] || die "not set up on this machine: run 'book-notes.sh setup request'"
}

# run_js <script.js | -> [key=value ...]
# Runs the runtime with a throwaway trace (traces record auth headers and API responses, including
# keys) and prints only the single-line JSON that main() returned. Output never reaches the terminal
# on success, so a returned secret stays inside the caller's variable.
run_js() {
  require_runtime
  local tracedir out res envargs=()
  [[ -f "$ENV_FILE" ]] && envargs=(-e "$(winpath "$ENV_FILE")")
  tracedir="$(mktemp -d)"
  out="$(anytype-agent-runtime "${envargs[@]}" -m "$(winpath "$SKILL_DIR/scripts")" \
    -t "$(winpath "$tracedir/trace.json")" "$@" 2>&1 | tr -d '\r')" || true
  rm -rf "$tracedir"
  res="$(printf '%s\n' "$out" | sed -n 's/^res: //p' | head -1)"
  if [[ -z "$res" || "$res" == "<nil>" ]]; then
    printf '%s\n' "$out" | grep -E '^err:' >&2 || printf '%s\n' "$out" >&2
    return 1
  fi
  printf '%s\n' "$res"
}

# set_env KEY VALUE — replace or add one line in .env without echoing the value.
set_env() {
  local tmp; tmp="$(mktemp)"
  if [[ -f "$ENV_FILE" ]]; then grep -v "^$1=" "$ENV_FILE" > "$tmp" || true; fi
  printf '%s=%s\n' "$1" "$2" >> "$tmp"
  mv "$tmp" "$ENV_FILE"
  chmod 600 "$ENV_FILE" 2>/dev/null || true
}

list_spaces() {
  run_js - <<'EOF'
import { listSpaces } from "anytypeHelper@v1";
export function main() {
  var r = listSpaces({ baseUrl: env.ANYTYPE_API_URL, api_key: env.ANYTYPE_API_KEY });
  if (!r.ok) return JSON.stringify({ ok: false, error: r.error });
  var spaces = [];
  for (var i = 0; i < r.spaces.length; i++) spaces.push({ id: r.spaces[i].id, name: r.spaces[i].name });
  return JSON.stringify({ ok: true, spaces: spaces });
}
EOF
}

cmd_setup() {
  local url; url="$(cfg '.apiUrl // "http://127.0.0.1:31009"')"
  case "${1:-}" in
    request)
      local res
      res="$(run_js - url="$url" <<'EOF'
import { requestChallenge } from "anytypeHelper@v1";
export function main(args) { return JSON.stringify(requestChallenge({ baseUrl: args.url })); }
EOF
      )" || die "challenge request failed — is the Anytype desktop app running?"
      [[ "$(jq -r '.ok' <<<"$res" | tr -d '\r')" == "true" ]] || die "challenge request failed: $res"
      echo "challenge_id: $(jq -r '.challenge_id' <<<"$res" | tr -d '\r')"
      echo "Anytype desktop now shows a 4-digit code. Next: book-notes.sh setup solve <challenge_id> <code>"
      ;;
    solve)
      local challenge="${2:?challenge_id required}" code="${3:?code required}" res key
      res="$(run_js - url="$url" challenge_id="$challenge" code="$code" <<'EOF'
import { solveChallenge } from "anytypeHelper@v1";
export function main(args) {
  return JSON.stringify(solveChallenge({ baseUrl: args.url, challenge_id: args.challenge_id, code: args.code }));
}
EOF
      )" || die "solving the challenge failed"
      key="$(jq -r '.api_key // empty' <<<"$res" | tr -d '\r')"
      [[ -n "$key" ]] || die "no API key returned (wrong or expired code?): $(jq -c 'del(.api_key)' <<<"$res" | tr -d '\r')"
      set_env ANYTYPE_API_URL "$url"
      set_env ANYTYPE_API_KEY "$key"
      unset key res
      echo "saved API key to $(winpath "$ENV_FILE")"
      echo "spaces (pick one with: book-notes.sh setup space <id>):"
      list_spaces | jq -r '.spaces[] | "  \(.id)\t\(.name)"' | tr -d '\r'
      ;;
    space)
      local id="${2:?space_id required}"
      require_env
      set_env ANYTYPE_SPACE_ID "$id"
      echo "space set: $id"
      ;;
    status)
      require_env
      local spaces current
      spaces="$(list_spaces)" || die "API key check failed — is Anytype running, or was the key revoked?"
      [[ "$(jq -r '.ok' <<<"$spaces" | tr -d '\r')" == "true" ]] || die "API key rejected: $spaces"
      current="$(sed -n 's/^ANYTYPE_SPACE_ID=//p' "$ENV_FILE" | tr -d '\r')"
      echo "API key: ok"
      if [[ -z "$current" ]]; then
        echo "space: NOT SET — run book-notes.sh setup space <id>"
      else
        echo "space: $(jq -r --arg id "$current" '(.spaces[] | select(.id == $id) | .name) // "UNKNOWN (not visible to this key)"' <<<"$spaces" | tr -d '\r') ($current)"
      fi
      ;;
    *) die "usage: book-notes.sh setup {request | solve <challenge_id> <code> | space <space_id> | status}" ;;
  esac
}

find_python() {
  # The WindowsApps python3 stub exits non-zero, so probing for Pillow skips it too.
  local c
  for c in python3 python; do
    if command -v "$c" >/dev/null 2>&1 && "$c" -c 'import PIL' >/dev/null 2>&1; then
      echo "$c"; return
    fi
  done
  die "need Python with Pillow (pip install pillow)"
}

cmd_inbox() {
  local root; root="$(cfg .inboxRoot)"
  [[ -d "$root" ]] || die "inboxRoot not found: $root"
  # Skip Synology metadata dirs (@eaDir, #recycle, .SynologyWorkingDirectory).
  find "$root" -mindepth 2 -maxdepth 2 -type f \
    \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.heic' \) \
    -not -path '*/@*' -not -path '*/#*' -not -path '*/.*' -print0 |
    sort -z |
    while IFS= read -r -d '' f; do
      printf '%s\t%s\n' "$(basename "$(dirname "$f")")" "$(winpath "$f")"
    done
}

cmd_prep() {
  local img="${1:?image path required}" rot="${2:-0}" py out
  [[ -f "$img" ]] || die "image not found: $img"
  py="$(find_python)"
  # One reused scratch dir, so prepped copies don't pile up in the temp directory.
  mkdir -p "${TMPDIR:-/tmp}/book-notes-prep"
  out="${TMPDIR:-/tmp}/book-notes-prep/$(basename "${img%.*}").jpg"
  "$py" - "$(winpath "$img")" "$(winpath "$out")" "$rot" <<'EOF'
import sys
from PIL import Image, ImageOps
src, out, rot = sys.argv[1], sys.argv[2], int(sys.argv[3])
im = ImageOps.exif_transpose(Image.open(src)).convert("RGB")
if rot:
    im = im.rotate(-rot, expand=True)  # PIL rotates counter-clockwise; callers pass clockwise degrees
im.thumbnail((2000, 2000))
im.save(out, quality=90)
EOF
  winpath "$out"; echo
}

under_inbox() {
  local img root
  img="$(winpath "$(realpath "$1")")"; root="$(winpath "$(realpath "$(cfg .inboxRoot)")")"
  [[ "${img,,}" == "${root,,}/"* ]]
}

cmd_add() {
  local img="${1:?image path required}" payload="${2:?payload.json required}" dry="${3:-}"
  [[ -f "$img" ]] || die "image not found: $img"
  [[ -f "$payload" ]] || die "payload not found: $payload"
  require_env

  local args=(
    "$(winpath "$SKILL_DIR/scripts/add-book-note.js")"
    imageHash="$(sha256sum "$img" | cut -d' ' -f1)"
    imageName="$(basename "$img")"
    payload=@"$(winpath "$payload")"
  )
  [[ "$dry" == "--dry-run" ]] && args+=(dryRun=true)

  local res verified
  res="$(run_js "${args[@]}")" || exit 1
  printf '%s\n' "$res"

  verified="$(jq -r '.verified // false' <<<"$res" | tr -d '\r')"
  if [[ "$verified" == "true" && "$dry" != "--dry-run" ]]; then
    if under_inbox "$img"; then
      rm -f -- "$img" && echo "deleted: $(winpath "$img")" >&2
    else
      echo "kept (outside inboxRoot): $(winpath "$img")" >&2
    fi
  fi
}

case "${1:-}" in
  setup) shift; cmd_setup "$@" ;;
  inbox) shift; cmd_inbox "$@" ;;
  prep)  shift; cmd_prep "$@" ;;
  add)   shift; cmd_add "$@" ;;
  *) die "usage: book-notes.sh {setup … | inbox | prep <image> [deg] | add <image> <payload.json> [--dry-run]}" ;;
esac
