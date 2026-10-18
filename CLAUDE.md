# CLAUDE.md

## Communication Preferences

On a scale of 1 to 10, 1 being the least, and 10 being the most, you are to adjust your communication style to the user for this session based on the number provided for each of the following communication and personality dimensions.

### Conciseness

Desired Level: 7/10

- Use visual indicators (emoji, symbols) strategically to enhance clarity and engagement.
- Eliminate redundancy and filler
- Bullet points over paragraphs
- Get to the point quickly

### Humor and Sarcasm

Desired Level: 7/10

- Responses may optionally be enriched with silly observations or otherwise funny quips
- Employ a level of dry wit or perhaps even gentle mockery if the situation warrants

## Machine Notes (Windows)

### Colonizer dotfiles repo

Machine onboarding and OS-level dev-environment config (WSL config, environment setup, dev tooling
baseline) is managed in the **Colonizer** repo at `C:\Users\Andrew\Desktop\Git\Colonizer` — the source of truth. When making changes that should persist across machine setups, consider whether Colonizer could benefit from being kept in sync first, then apply as needed based on user feedback. Try to avoid persisting long-lived files in `$HOME` if they would be lost upon obtaining a new workstation. Windows-side layout: `os/windows/WSL/`
holds `wsl.conf` (→ `/etc/wsl.conf` inside Ubuntu), `wslconfig` (→ `%USERPROFILE%\.wslconfig`), `*-onboarding.md` apply steps, and `enable-wsl.ps1` / `disable-wsl.ps1`.

### jq emits CRLF — strip it whenever the shell consumes jq output

`jq` here is a **native Windows binary** (WinGet), so it opens stdout in text mode and ends every line with `\r\n`. Verified: `printf '{"a":"x"}' | jq -r .a | od -c` → `x \r \n`.

Harmless when the output is merely displayed; **corrupting when the shell parses it**:

- `read` is a bash builtin and is CR-naive, so the `\r` lands on whichever variable is filled **last** — the bug is positional and moves if you reorder columns.
- It fails **silently**. No error; the value just stops comparing equal to anything.
- MSYS `grep`/`sed`/`awk` *do* tolerate CR on input, so two consumers of the same jq output can disagree for reasons invisible in the source.

So: pipe through `tr -d '\r'` whenever jq output feeds `read`, a `while` loop, or `$(…)` — and put the strip **after** jq, not on jq's input, since jq re-adds it. Same class of hazard: `node --version` and other native Windows CLIs.
