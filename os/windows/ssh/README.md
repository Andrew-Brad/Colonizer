# SSH + 1Password Agent (Windows)

Machine-level SSH config. Deploys `config` to `~/.ssh/config` and `bashrc` to `~/.bashrc`.

**This is a public repo.** Nothing here names a host, a user, or a key. Anything
identifying lives in `~/.ssh/config.d/*.conf`, which is gitignored and never committed.

## The two gotchas

Both of these fail in ways that point at the wrong culprit. Both are verified on
this machine, not assumed.

### 1. Git Bash uses the wrong `ssh` binary

Git Bash ships an MSYS build of OpenSSH at `/usr/bin/ssh`, and it precedes the
native Windows client on `PATH`. MSYS ssh speaks only Unix-domain sockets via
`$SSH_AUTH_SOCK`. 1Password's agent is a **Windows named pipe**
(`\\.\pipe\openssh-ssh-agent`). MSYS ssh cannot reach it at all.

```
$ ssh-add -l                    # Git Bash  -> /usr/bin/ssh-add
Could not open a connection to your authentication agent.

PS> ssh-add -l                  # PowerShell -> System32\OpenSSH\ssh-add.exe
256  SHA256:...  Some Key (ED25519)
... 4 keys
```

Same machine, same agent, opposite results. It reads like 1Password is broken;
it is purely which binary got picked. `bashrc` fixes this with shell functions
that route `ssh`/`scp`/`sftp`/`ssh-add`/`ssh-keyscan` to the native client.

Functions, **not aliases** — bash does not expand aliases in non-interactive
shells, which is where automated tooling runs.

### 2. `IdentityAgent` must use forward slashes

Most documentation writes the pipe path with backslashes. In `ssh_config` that
silently does the wrong thing — the backslashes are consumed as escapes, the
agent is never contacted, and you get:

```
Permission denied (publickey,password).
```

...which looks like a key authorization problem. It is a string parsing problem.

| Form | Result |
|---|---|
| `IdentityAgent \\.\pipe\openssh-ssh-agent` | ❌ Permission denied |
| `IdentityAgent //./pipe/openssh-ssh-agent` | ✅ Works |

Note the native Windows client already defaults to this pipe, so the line is
technically redundant — it is kept as documentation. If you ever change it,
use the forward-slash form.

## Apply

```powershell
New-Item -ItemType Directory -Force "$env:USERPROFILE\.ssh\config.d" | Out-Null
Copy-Item .\config  "$env:USERPROFILE\.ssh\config"  -Force
Copy-Item .\bashrc  "$env:USERPROFILE\.bashrc"      -Force
```

Then add host-specific blocks in `~/.ssh/config.d/` (never committed here):

```sshconfig
# ~/.ssh/config.d/example.conf
Host shortname
    HostName 10.0.0.0
    User someuser
```

## Verify

```powershell
ssh-add -l                       # should list keys from 1Password
ssh -G shortname | select-string '^(user|hostname|identityagent) '
```

```bash
type ssh                         # Git Bash: should report a function
ssh -V                           # should say OpenSSH_for_Windows, not MSYS
```

## Prerequisites

- 1Password desktop app, **Settings → Developer → Use the SSH agent** enabled.
- Windows `ssh-agent` service **disabled** — it contends for the same pipe name.
  `Get-Service ssh-agent` should read `Stopped` / `Disabled`.
