# Claude Code Skills (user-level)

Goal: get user-level skills into `~/.claude/skills/`, so every Claude Code session has them, including
Remote Control sessions opened from a phone.

Two sources:
- Third-party skills from skills.sh, installed with the `skills` CLI (section 1).
- Repo-managed skills in `app/claude/skills/`, copied in (section 2). Change them here first, then re-copy.

## 1. Third-party skills (skills.sh)

`skills.sh` runs through `npx`.

### mattpocock/skills

<https://www.skills.sh/mattpocock/skills>

Some of these overlap with project skills (ADRs, planning, triage).

```bash
# For all of them:
npx skills add mattpocock/skills

# If you want to handpick:
npx skills@latest add mattpocock/skills -g -a claude-code --skill <name> [--skill <name> ...]
npx skills list -g
```

Notes:
- `-g` installs to `~/.claude/skills/`. Without it the skills go into the current repo's `.claude/skills/`.
- Leave off `--skill` to get an interactive picker.
- Update with `npx skills update -g`.
- Some skills have a setup step (e.g. where issues live). Run it once per machine.

## 2. Repo-managed skills: book-notes

Turns photos of book pages into per-book notes pages in Anytype. The phone saves photos to
`SynologyDrive/Photos/BookNotes/<book-slug>/`. Claude transcribes them and appends the text to
`<Title> — Book Notes` in Anytype, skipping duplicates, then deletes each photo once the write is
verified.

### Step 1: Prerequisites

- Anytype desktop app installed and running (the skill uses its local API on `127.0.0.1:31009`).
- Synology Drive syncing `Photos/BookNotes`.
- Git Bash (for `sha256sum`), `jq`, and Python with Pillow:

```powershell
pip install pillow
```

- `anytype-agent-runtime` on PATH. There is no Windows release, so cross-compile it in a throwaway container with the WSL Docker engine (see `os/windows/WSL/docker-engine-only-onboarding.md`). Check https://github.com/anyproto/anytype-agent-runtime/releases for the latest tag first.

Run in Git Bash:

```bash
MSYS_NO_PATHCONV=1 wsl docker run --rm -v /mnt/c/Users/Andrew/.local/bin:/out \
  -e GOOS=windows -e GOARCH=amd64 -e CGO_ENABLED=0 golang:1.25 \
  sh -c 'git clone -q --depth 1 --branch v0.1.4 https://github.com/anyproto/anytype-agent-runtime.git /src && cd /src && go build -o /out/anytype-agent-runtime.exe .'
anytype-agent-runtime --help
```

Notes:
- `MSYS_NO_PATHCONV=1` is required. Without it, Git Bash rewrites `/out` into a Windows path and Docker fails with `invalid mode`.
- `~/.local/bin` must be on PATH.

### Step 2: Copy the skill

Run in Git Bash:

```bash
mkdir -p ~/.claude/skills
cp -r /c/Users/Andrew/Desktop/Git/Colonizer/app/claude/skills/book-notes ~/.claude/skills/
```

Notes:
- Re-running the copy to update the skill keeps the local `.env`, because `.env` isn't in the repo.
- If the Synology path differs on this machine, edit `inboxRoot` in
  `~/.claude/skills/book-notes/config.json`.

### Step 3: Connect to Anytype (once per machine)

This creates a new API key for this machine and stores it in `~/.claude/skills/book-notes/.env`.
The key is never printed, and `.env` is gitignored both by the skill and by this repo's `*.env` rule.

Run in Git Bash:

```bash
cd ~/.claude/skills/book-notes
bash scripts/book-notes.sh setup request                  # Anytype desktop shows a 4-digit code
bash scripts/book-notes.sh setup solve <challenge_id> <code>   # saves key, lists spaces
bash scripts/book-notes.sh setup space <space_id>
```

Or ask Claude: "set up the book-notes skill". It runs the same steps and asks for the code.

### Step 4: Verify

```bash
bash ~/.claude/skills/book-notes/scripts/book-notes.sh setup status
bash ~/.claude/skills/book-notes/scripts/book-notes.sh inbox
```

Expected:
- `API key: ok` and the intended space name.
- `inbox` lists pending photos as `<book-slug>	<path>`, or prints nothing when the inbox is empty.

Then, in any Claude Code session: "process my book notes".
