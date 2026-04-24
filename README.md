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
sources everything in order: colors, env, functions, aliases, prompt, then all `apps/*.sh`.

## Structure

```
bash/
  .bash_profile          # Login shell entry — sources .bashrc
  .bashrc                # Non-login entry — sources init.sh
  init.sh                # Main loader — orchestrates everything below
  lib/
    colors.sh            # Terminal color vars (GNU vs BSD ls detection)
    env.sh               # PATH, EDITOR, HISTSIZE, Homebrew shellenv
    functions.sh         # Utility functions (cd, extract, cdf, ii, etc.)
    aliases.sh           # Shell aliases
    prompt.sh            # PS1 with git branch + color
    git-prompt.sh        # Official git contrib prompt support
    git_completion.bash  # Official git bash completion
  apps/
    conda.sh             # Conda init (Anaconda3 at /opt/anaconda3)
    git.sh               # Loads git bash completion
    gitconfig            # Git config (symlinked to ~/.gitconfig)
    node.sh              # NVM init + npmls()
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

# Copy secrets template and fill in values
cp ~/bash/secrets.template.sh ~/bash/secrets.sh
# edit ~/bash/secrets.sh

# Reload
source ~/.bash_profile
```

## Secrets & Local Overrides

- `~/bash/secrets.sh` — git-ignored; holds tokens, API keys, private env vars
- `~/.bashrc_local` — machine-local overrides (not in repo); sourced last by init.sh
- `~/.gitconfig.local` — git PII (name/email); included by gitconfig

## Active Environment

- **Shell:** Homebrew bash (`/opt/homebrew/bin/bash`)
- **Python:** Homebrew Python + Anaconda3 (`/opt/anaconda3`)
- **Node:** NVM
- **Package manager:** Homebrew (Apple Silicon — `/opt/homebrew`)
