#!/usr/bin/env bash
#
# Claude Code status line command.
# Receives the Claude Code statusLine JSON on stdin; prints exactly TWO lines to stdout.
#
# Layout (mirrors the Antigravity/Gemini statusline):
#   line 1: ✳ <model> | ctx: N% | [5h: N%] | [weekly: N%] | [⚡ <effort>] | 🌿 <branch> [⑂ <worktree>] [●]
#   line 2: 💬 sess: <name> | 📁 <path>
#
# Optional segments (5h, weekly, effort, git) are omitted gracefully when their
# source fields are absent. Color thresholds for percentages:
#   < 50  -> LIGHT_GREEN, 50–79 -> LIGHT_YELLOW, >= 80 -> LIGHT_RED.

input=$(cat)

# --- Parse JSON fields ---
cwd=$(echo "$input"          | jq -r '.workspace.current_dir // .cwd // empty')
model=$(echo "$input"        | jq -r '.model.display_name // empty')
used_pct=$(echo "$input"     | jq -r '.context_window.used_percentage // empty')
repo=$(echo "$input"         | jq -r '.workspace.repo | if . then .owner + "/" + .name else empty end')
worktree_branch=$(echo "$input"   | jq -r '.worktree.branch // empty')
worktree_name=$(echo "$input"     | jq -r '.worktree.name // empty')
workspace_git_worktree=$(echo "$input" | jq -r '.workspace.git_worktree // empty')
session_name=$(echo "$input" | jq -r '.session_name // empty')
session_id=$(echo "$input"   | jq -r '.session_id // empty')

five_hour_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
weekly_pct=$(echo "$input"    | jq -r '.rate_limits.seven_day.used_percentage // empty')

effort_level=$(echo "$input"   | jq -r '.effort.level // empty')

# --- Colors ---
RESET="\033[0m"
BOLD="\033[1m"
DARK_GRAY="\033[90m"
LIGHT_GRAY="\033[37m"
WHITE="\033[97m"

# Vibrant Colors
CYAN="\033[36m"
LIGHT_CYAN="\033[96m"
GREEN="\033[32m"
LIGHT_GREEN="\033[92m"
YELLOW="\033[33m"
LIGHT_YELLOW="\033[93m"
RED="\033[31m"
LIGHT_RED="\033[91m"
MAGENTA="\033[35m"
LIGHT_MAGENTA="\033[95m"
BLUE="\033[34m"
LIGHT_BLUE="\033[1;94m"

# --- Model Badge ---
model_str="${CYAN}✳ N/A${RESET}"
if [ -n "$model" ]; then
  model_str="${CYAN}✳ ${model}${RESET}"
fi

# --- Context Window ---
context_str="ctx: --%"
if [ -n "$used_pct" ] && [ "$used_pct" != "null" ]; then
  pct_val=$(printf "%.0f" "$used_pct" 2>/dev/null || echo 0)
  color_ctx="${LIGHT_GREEN}"
  if [ "$pct_val" -ge 80 ]; then
    color_ctx="${LIGHT_RED}"
  elif [ "$pct_val" -ge 50 ]; then
    color_ctx="${LIGHT_YELLOW}"
  fi
  context_str="${color_ctx}ctx: ${pct_val}%${RESET}"
fi

# --- 5 Hour Limit (conditional) ---
five_hour_str=""
if [ -n "$five_hour_pct" ] && [ "$five_hour_pct" != "null" ]; then
  pct_val=$(printf "%.0f" "$five_hour_pct" 2>/dev/null || echo 0)
  color_5h="${LIGHT_GREEN}"
  if [ "$pct_val" -ge 80 ]; then
    color_5h="${LIGHT_RED}"
  elif [ "$pct_val" -ge 50 ]; then
    color_5h="${LIGHT_YELLOW}"
  fi
  five_hour_str="${color_5h}5h: ${pct_val}%${RESET}"
fi

# --- Weekly Limit (conditional) ---
weekly_str=""
if [ -n "$weekly_pct" ] && [ "$weekly_pct" != "null" ]; then
  pct_val=$(printf "%.0f" "$weekly_pct" 2>/dev/null || echo 0)
  color_wk="${LIGHT_GREEN}"
  if [ "$pct_val" -ge 80 ]; then
    color_wk="${LIGHT_RED}"
  elif [ "$pct_val" -ge 50 ]; then
    color_wk="${LIGHT_YELLOW}"
  fi
  weekly_str="${color_wk}weekly: ${pct_val}%${RESET}"
fi

# --- Effort Badge (conditional) ---
effort_str=""
if [ -n "$effort_level" ] && [ "$effort_level" != "null" ]; then
  effort_str="${LIGHT_CYAN}⚡ ${effort_level}${RESET}"
fi

# --- Git status (run against the session's cwd) ---
#
# Worktree-aware: shows the working branch, and surfaces a linked git worktree
# (the dirs created by `git worktree add`) with a ⑂ marker when present. The
# branch is read via `symbolic-ref --short HEAD`, which returns the correct
# branch even inside a linked worktree. A linked worktree is detected by the
# `/worktrees/` segment in its resolved git-dir path; the main checkout's
# git-dir is a plain `.git` and so never matches.
git_info=""
git_dir="${cwd:-$PWD}"
if git -C "$git_dir" rev-parse --git-dir >/dev/null 2>&1; then
  # Branch (or short SHA for detached HEAD).
  git_branch=$(git -C "$git_dir" symbolic-ref --short HEAD 2>/dev/null \
    || git -C "$git_dir" rev-parse --short HEAD 2>/dev/null)

  # Detect a linked worktree: its git-dir lives under `<repo>/.git/worktrees/<name>`.
  wt_name=""
  gitdir=$(git -C "$git_dir" rev-parse --git-dir 2>/dev/null)
  case "$gitdir" in
    */worktrees/*) wt_name=$(basename "$gitdir") ;;
  esac

  # Base label, plus the worktree marker when it names something distinct.
  git_label="🌿 ${git_branch}"
  if [ -n "$wt_name" ] && [ "$wt_name" != "$git_branch" ]; then
    git_label="${git_label} ⑂ ${wt_name}"
  fi

  # The whole segment takes the dirty/clean color.
  if [ -n "$(git -C "$git_dir" status --porcelain 2>/dev/null)" ]; then
    git_info="${LIGHT_RED}${git_label} ●${RESET}"
  else
    git_info="${LIGHT_GREEN}${git_label}${RESET}"
  fi
else
  # Fallback when cwd isn't a git repo: use the worktree/workspace JSON fields,
  # preferring the most specific. Render whichever is found; omit if none.
  git_fallback=""
  if [ -n "$worktree_branch" ]; then
    git_fallback="$worktree_branch"
  elif [ -n "$worktree_name" ]; then
    git_fallback="$worktree_name"
  elif [ -n "$workspace_git_worktree" ]; then
    git_fallback="$workspace_git_worktree"
  elif [ -n "$repo" ]; then
    git_fallback="$repo"
  fi
  if [ -n "$git_fallback" ]; then
    git_info="${LIGHT_GREEN}🌿 ${git_fallback}${RESET}"
  fi
fi

# --- Session Name ---
if [ -z "$session_name" ] || [ "$session_name" = "null" ]; then
  if [ -n "$session_id" ] && [ "$session_id" != "null" ]; then
    session_str="${LIGHT_BLUE}💬 sess: ${session_id:0:8}${RESET}"
  else
    session_str="${LIGHT_BLUE}💬 sess: unnamed${RESET}"
  fi
else
  session_str="${LIGHT_BLUE}💬 sess: ${session_name}${RESET}"
fi

# --- PWD/CWD ---
display_pwd=""
if [ -n "$cwd" ]; then
  if [ "${cwd#$HOME}" != "$cwd" ]; then
    display_pwd="~${cwd#$HOME}"
  else
    display_pwd="$cwd"
  fi
  display_pwd="${LIGHT_MAGENTA}📁 ${display_pwd}${RESET}"
else
  display_pwd="${LIGHT_MAGENTA}📁 ~${RESET}"
fi

# --- Divider ---
DIV="${DARK_GRAY} | ${RESET}"

# --- Line Outputs ---
line1="${model_str}${DIV}${context_str}"

[ -n "$five_hour_str" ] && line1="${line1}${DIV}${five_hour_str}"
[ -n "$weekly_str" ]    && line1="${line1}${DIV}${weekly_str}"
[ -n "$effort_str" ]    && line1="${line1}${DIV}${effort_str}"
[ -n "$git_info" ]      && line1="${line1}${DIV}${git_info}"

line2="${session_str}${DIV}${display_pwd}"

echo -e "$line1"
echo -e "$line2"
