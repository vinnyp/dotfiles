# dotfiles

Vinny's personal shell environment — modular bash configuration for macOS.

[![Private](https://img.shields.io/badge/visibility-private-lightgrey)](https://github.com/vinnyp/dotfiles)
[![Shell](https://img.shields.io/badge/shell-bash-4EAA25?logo=gnubash&logoColor=white)](https://www.gnu.org/software/bash/)
[![macOS](https://img.shields.io/badge/macOS-only-000000?logo=apple&logoColor=white)](https://www.apple.com/macos)

---

## How It Works

The live dotfiles live at `~/bash/`. The home directory entries are symlinks:

```
~/.bash_profile  ->  ~/bash/.bash_profile
~/.bashrc        ->  ~/bash/.bashrc
~/.gitconfig     ->  ~/bash/apps/gitconfig
```

On login, bash loads `~/.bash_profile` → `~/bash/.bashrc` → `~/bash/init.sh`, which
sources everything in order: env, colors, functions, aliases, prompt, then all `apps/*.sh`.

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
  .bash_profile          # Login shell entry — sources .bashrc
  .bashrc                # Non-login entry — sources init.sh
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
    gitconfig            # Git config (symlinked to ~/.gitconfig)
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

# Symlink into home directory
ln -sf ~/bash/.bash_profile ~/.bash_profile
ln -sf ~/bash/.bashrc ~/.bashrc
ln -sf ~/bash/apps/gitconfig ~/.gitconfig

# Agent statuslines (optional — apps/agent-statuslines.sh auto-links these on first
# shell load, so you only need these lines if a real file already occupies the target):
ln -sf ~/bash/apps/claude/statusline-command.sh ~/.claude/statusline-command.sh
ln -sf ~/bash/apps/gemini/statusline-command.sh ~/.gemini/statusline-command.sh

# Copy secrets template and fill in values
cp ~/bash/secrets.template.sh ~/bash/secrets.sh
# edit ~/bash/secrets.sh

# Reload
source ~/.bash_profile
```

## Agent statuslines (Claude Code + Gemini)

Two vendored scripts render a matching two-line status for the coding agents:

- **Line 1:** model · context % · rate limits (5h / weekly) · effort · git branch/worktree
- **Line 2:** session name · cwd

```
✳ Opus 4.8 | ctx: 14% | 5h: 8% | weekly: 6% | ⚡ xhigh | 🌿 main ●
💬 sess: foundry-0631 | 📁 ~/Documents/Obsidian/foundry
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
