# dotfiles

Vinny's personal shell environment — modular bash configuration for macOS.

[![Private](https://img.shields.io/badge/visibility-private-lightgrey)](https://github.com/vinnyp/dotfiles)
[![Shell](https://img.shields.io/badge/shell-bash-4EAA25?logo=gnubash&logoColor=white)](https://www.gnu.org/software/bash/)
[![macOS](https://img.shields.io/badge/macOS-only-000000?logo=apple&logoColor=white)](https://www.apple.com/macos)

---

## How It Works

The live dotfiles live at `~/bash/`. The home rc files are **thin shims** — small
real files in `$HOME` that source the curated config out of the repo:

```
~/.bashrc        (real file) → source ~/bash/bashrc
~/.bash_profile  (real file) → source ~/bash/bash_profile
~/.gitconfig     (real file) → [include] path = ~/bash/apps/gitconfig
```

**Why shims, not symlinks?** Package installers (`uv`, `nvm`, `gh`, etc.) like to
*append* lines to `~/.bashrc` / `~/.bash_profile` — and `gh auth login` appends a
credential helper to `~/.gitconfig`. When those files were symlinks into the repo,
every appended line landed inside the **public** repo. With real shim files,
installer-appended lines accumulate **in `$HOME`** (below the `source` line for the rc
files, below the `[include]` for `~/.gitconfig`) and never reach the public repo. The
repo copies (`bashrc`, `bash_profile`, dropped leading dot because they're sourced by
path now, not symlinked; and `apps/gitconfig`, included not symlinked) stay clean and
shareable. `~/.gitconfig` pulls in the curated config via `[include] path =
~/bash/apps/gitconfig`; because the `[include]` is listed first, repo defaults load
first and any machine-local lines below it win.

On login, bash loads `~/.bash_profile` → `~/bash/bash_profile` → `~/bash/bashrc` →
`~/bash/init.sh`, which sources everything in order: env, colors, functions, aliases,
prompt, then all `apps/*.sh`. A non-login interactive shell loads `~/.bashrc` →
`~/bash/bashrc` → `~/bash/init.sh`.

### Detecting BSD vs GNU `ls` (and choosing config)

After `PATH` is set (including Homebrew and optional coreutils `gnubin`), **`lib/colors.sh`** decides which world you are in by probing the **`ls` that actually runs first on `PATH`**:

- It runs **`command ls --version`** and checks for **`gnu`** in the output. GNU coreutils `ls` prints a GNU version string; the BSD `/bin/ls` on macOS does not support `--version` in the same way and will not match.
- **`BASH_LS_IS_GNU`** is set to **`1`** or **`0`** accordingly.
- **GNU `ls`:** use **`LS_COLORS`** and **`ls --color=auto`** (never BSD’s **`-G`**, which on GNU means **`--no-group`**, not color).
- **BSD `ls`:** use **`CLICOLOR`** and **`LSCOLORS`**, and **`ls -G`**.

**`lib/env.sh`** prepends **`$HOMEBREW_PREFIX/opt/coreutils/libexec/gnubin`** to **`PATH`** when that directory exists, so interactive **`ls`** and this probe stay consistent. If coreutils is installed but you only add `gnubin` later (for example in **`~/.bashrc_local`**), the probe could disagree with the real **`ls`** until PATH matches — putting **`gnubin` in `env.sh`** avoids that.

Other scripts (**`lib/aliases.sh`**, **`bash_ls_long`** in **`lib/colors.sh`**, **`cd()`** in **`lib/functions.sh`**) read **`BASH_LS_IS_GNU`** so listings use the right flags.

### Other macOS vs GNU behavior (beyond `ls`)

When **`gnubin`** is ahead of **`/usr/bin`**, many commands are the GNU implementation, not the BSD ones that ship with macOS. Flags and env vars often differ:

| Area | Notes |
|------|--------|
| **`date`**, **`sed`**, **`readlink`**, **`stat`** | GNU supports long options and different flags than BSD; scripts copied from Linux tutorials may assume GNU. |
| **`BLOCKSIZE`** vs **`BLOCK_SIZE`** | BSD-style **`BLOCKSIZE`** is common on macOS; some GNU tools document **`BLOCK_SIZE`** for similar ideas (`ls -s`, `df`, `du`, depending on version). Worth checking **`man`** for whichever binary wins on your **`PATH`**. |
| **`cp`**, **`mv`**, **`mkdir`** | Aliases here use short flags (**`-iv`**, **`-pv`**) that work on both BSD and GNU in typical setups. |

If you want **BSD `ls`** only but other GNU tools from coreutils, avoid putting **`gnubin`** ahead of system **`PATH`** for **`ls`** (or override **`PATH`** in **`~/.bashrc_local`**) and rely on **`gls`** for GNU **`ls`** when needed.

## Structure

```
bash/
  bash_profile           # Login shell config — sourced by the ~/.bash_profile shim; sources bashrc
  bashrc                 # Interactive shell config — sourced by the ~/.bashrc shim; sources init.sh
  init.sh                # Main loader — orchestrates everything below
  lib/
    colors.sh            # Terminal color vars (GNU vs BSD ls detection)
    env.sh               # PATH (shellenv + optional coreutils gnubin), EDITOR, HISTSIZE
    functions.sh         # Utility functions (cd, extract, cdf, ii, etc.)
    aliases.sh           # Shell aliases
    prompt.sh            # PS1 with git branch + color
    git-prompt.sh        # Official git contrib prompt support
    git_completion.bash  # Official git bash completion
  apps/
    agent-statuslines.sh # Auto-links the Claude/Gemini statusline scripts on shell load
    conda.sh             # Conda init (Anaconda3 at /opt/anaconda3)
    git.sh               # Loads git bash completion
    gitconfig            # Git config (included by the ~/.gitconfig shim via [include])
    node.sh              # NVM init + npmls()
    claude/
      statusline-command.sh  # Claude Code statusline payload (symlinked to ~/.claude/)
    gemini/
      statusline-command.sh  # Gemini/Antigravity statusline payload (symlinked to ~/.gemini/)
  secrets.template.sh    # Template for secrets.sh (git-ignored)
```

## Setup on a New Machine

```bash
# Clone into ~/bash
git clone git@github.com:vinnyp/dotfiles.git ~/bash

# Create the home rc SHIMS (real files that source the repo config). Keep these
# as real files, NOT symlinks — installers append below the source line and those
# lines stay local instead of leaking into this public repo.
printf '%s\n' 'source ~/bash/bashrc' >> ~/.bashrc
printf '%s\n' 'source ~/bash/bash_profile' >> ~/.bash_profile

# gitconfig is also a real shim: create ~/.gitconfig that INCLUDES the repo config.
# Keep it a real file, NOT a symlink — `gh auth login` appends a credential helper to
# ~/.gitconfig, and that line stays local instead of leaking into this public repo.
printf '%s\n' '[include]' '	path = ~/bash/apps/gitconfig' >> ~/.gitconfig

# Agent statuslines (optional — apps/agent-statuslines.sh auto-links these on first
# shell load, so you only need these lines if a real file already occupies the target):
ln -sf ~/bash/apps/claude/statusline-command.sh ~/.claude/statusline-command.sh
ln -sf ~/bash/apps/gemini/statusline-command.sh ~/.gemini/statusline-command.sh

# Copy secrets template and fill in values
cp ~/bash/secrets.template.sh ~/bash/secrets.sh
# edit ~/bash/secrets.sh

# Machine-local overrides — project paths, and anything naming a PRIVATE
# project (this repo is public). Untracked; init.sh sources it last.
cp ~/bash/bashrc_local.template.sh ~/.bashrc_local
# edit ~/.bashrc_local

# Git identity. REQUIRED — `git commit` fails without it.
printf '%s\n' '[user]' '\tname = Your Name' '\temail = you@example.com' >> ~/.gitconfig.local

# Reload
source ~/.bash_profile
```

> [!warning] Never set your git identity with `git config --global`
> That writes `[user]` to the BOTTOM of `~/.gitconfig` — *after* its
> `[include]` of `apps/gitconfig`, which is what pulls in `~/.gitconfig.local`.
> Git takes the last value, so the global write silently wins and your real
> identity is ignored.
>
> This is not hypothetical: it mis-attributed **54 commits** as `t <t@t>`
> across three repos between 2026-06-25 and 2026-07-30 before anyone noticed.
> Always edit `~/.gitconfig.local` directly, and verify with:
>
> ```bash
> git config --show-origin user.email   # must point at ~/.gitconfig.local
> ```

## Agent statuslines (Claude Code + Gemini)

Two vendored scripts render a matching two-line status for the coding agents:

- **Line 1:** model · context % · rate limits (5h / weekly) · effort · git branch/worktree
- **Line 2:** session name · cwd

```
✳ Opus 4.8 | ctx: 14% | 5h: 8% | weekly: 6% | ⚡ xhigh | 🌿 main ●
💬 sess: myproject-0631 | 📁 ~/Documents/Obsidian/myvault
```

The payloads live in `apps/claude/statusline-command.sh` and
`apps/gemini/statusline-command.sh` (kept in subdirs on purpose — they read stdin, so
they must never be matched by the non-recursive `apps/*.sh` source-loop in `init.sh`, or
every interactive shell would hang). `apps/agent-statuslines.sh` is the sourced setup
module: on shell load it idempotently symlinks each payload into place (only when the
target is missing — it never clobbers a real file), mirroring how `apps/cmux.sh` links
the `~/.config` files:

```
~/.claude/statusline-command.sh  ->  ~/bash/apps/claude/statusline-command.sh
~/.gemini/statusline-command.sh  ->  ~/bash/apps/gemini/statusline-command.sh
```

Claude Code is wired to its script via the `statusLine` command in
`~/.claude/settings.json`; Gemini/Antigravity is wired via its own statusline config.
Both resolve through the symlink, so the configured command path never changes.

## Secrets & Local Overrides

- `~/bash/secrets.sh` — git-ignored; holds tokens, API keys, private env vars
- `~/.bashrc_local` — machine-local overrides (not in repo); sourced last by init.sh
- `~/.gitconfig.local` — git PII (name/email); included by gitconfig

## Active Environment

- **Shell:** Homebrew bash (`/opt/homebrew/bin/bash`)
- **Python:** Homebrew Python + Anaconda3 (`/opt/anaconda3`)
- **Node:** NVM
- **Package manager:** Homebrew (Apple Silicon — `/opt/homebrew`)
