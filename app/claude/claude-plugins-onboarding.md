# Claude Code Plugins (user-level)

Goal: load the repo-managed Claude Code plugins in every session on this machine, read **directly from
this repo**, with no copy step.

Source of truth: `app/claude/plugins/`. Each plugin is loaded in place through
`CLAUDE_CODE_PLUGIN_DIRS`, so editing a file here hot-reloads it in any open interactive session.

## quota-bar

A one-line, color-coded bar above the prompt showing how much of the 5-hour rate-limit window is used,
and how long until it resets:

```
█░░░░░░░░░░┃░░░░░░ 🔋 4% 5h · TTL 1:52
```

- Green under 50%, yellow from 50%, red from 80%.
- `┃` is the pace marker: where usage would be if spread evenly across the 5h window.
- 🔋 when usage is ≥20 points behind pace, 🔥 when ≥20 points ahead, blank in between.
- `TTL` (time until reset, `H:MM`) turns bold yellow under 30 minutes.
- Updates whenever the API reports a whole-point change, and re-reads every 30s so the countdown keeps
  moving while idle.
- Hidden when the session has no 5-hour window (an API key rather than a subscription), or before the
  first response of a new session reports one.

### 1. Register the plugin folder

Add to the `env` block of `%USERPROFILE%\.claude\settings.json` (create the block if missing):

```json
"env": {
  "CLAUDE_CODE_PLUGIN_DIRS": "C:\\Users\\Andrew\\Desktop\\Git\\Colonizer\\app\\claude\\plugins\\quota-bar"
}
```

Notes:
- More plugins later: separate the paths with `;` (the Windows path-list separator).
- Only user settings are read for this variable, not a project's `.claude/settings.json`.

### 2. Verify

Restart Claude Code and send any prompt. The bar appears above the input once the first response
arrives.

Developer checks, run from the plugin folder:

```bash
claude plugin validate .
claude plugin test .
```
