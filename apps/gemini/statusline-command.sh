#!/usr/bin/env bash
#
# Antigravity CLI (agy) status line command.
# Receives JSON on stdin; prints status lines to stdout.

input=$(cat)

# --- Parse JSON fields ---
cwd=$(echo "$input"      | jq -r '.workspace.current_dir // .cwd // empty')
model=$(echo "$input"    | jq -r '.model.display_name // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
total_input=$(echo "$input" | jq -r '.context_window.total_input_tokens // empty')
total_output=$(echo "$input" | jq -r '.context_window.total_output_tokens // empty')
exceeds_200k=$(echo "$input" | jq -r '.exceeds_200k_tokens // false')
branch=$(echo "$input"   | jq -r '.worktree.branch // empty')
git_wt=$(echo "$input"   | jq -r '.workspace.git_worktree // empty')
repo=$(echo "$input"     | jq -r '.workspace.repo | if . then .owner + "/" + .name else empty end')
session_name=$(echo "$input" | jq -r '.session_name // empty')
session_id=$(echo "$input" | jq -r '.session_id // .conversation_id // empty')

five_hour_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
weekly_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // .rate_limits.weekly.used_percentage // empty')

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
LIGHT_BLUE="\033[94m"

# --- Helper to format token counts ---
format_tokens() {
  local val=$1
  if [ -z "$val" ] || [ "$val" = "null" ]; then
    echo "0"
    return
  fi
  python3 -c "
val = int('$val')
if val >= 1000000:
    print(f'{val/1000000:.1f}M')
elif val >= 1000:
    print(f'{val/1000:.1f}k')
else:
    print(val)
" 2>/dev/null || echo "$val"
}

# --- Model Badge ---
model_str="N/A"
if [ -n "$model" ]; then
  if [[ "$model" =~ [Gg]emini ]]; then
    model_str="${LIGHT_CYAN}♊ ${model}${RESET}"
  else
    model_str="${CYAN}🤖 ${model}${RESET}"
  fi
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

# --- Session Tokens ---
tokens_str=""
if [ -n "$total_input" ] && [ "$total_input" != "null" ]; then
  in_fmt=$(format_tokens "$total_input")
  out_fmt=$(format_tokens "$total_output")
  tokens_str="${DARK_GRAY}tokens: ${RESET}${WHITE}${in_fmt}${RESET}${DARK_GRAY} in / ${RESET}${WHITE}${out_fmt}${RESET}${DARK_GRAY} out${RESET}"
  
  if [ "$exceeds_200k" = "true" ]; then
    tokens_str="${tokens_str} ${LIGHT_YELLOW}⚠️ >200k${RESET}"
  fi
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

# --- Git status ---
git_info="N/A"
if [ -d .git ] || git rev-parse --git-dir >/dev/null 2>&1; then
  git_branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
  if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
    git_info="${LIGHT_RED}🌿 ${git_branch} ●${RESET}"
  else
    git_info="${LIGHT_GREEN}🌿 ${git_branch}${RESET}"
  fi
fi

# Fallback git info
if [ "$git_info" = "N/A" ]; then
  if [ -n "$branch" ]; then
    git_info="${LIGHT_GREEN}🌿 ${branch}${RESET}"
  elif [ -n "$git_wt" ]; then
    git_info="${LIGHT_GREEN}🌿 ${git_wt}${RESET}"
  elif [ -n "$repo" ]; then
    git_info="${LIGHT_GREEN}🌿 ${repo}${RESET}"
  fi
fi

# --- Session Name (including local annotation lookup) ---
if [ -z "$session_name" ] || [ "$session_name" = "null" ]; then
  # Fall back to checking the local annotations file for agy renames
  annot_file="${HOME}/.gemini/antigravity-cli/annotations/${session_id}.pbtxt"
  if [ -f "$annot_file" ]; then
    extracted_name=$(grep -E '^title:' "$annot_file" | sed -E 's/^title:\s*"(.*)"/\1/')
    if [ -n "$extracted_name" ]; then
      session_name="$extracted_name"
    fi
  fi
fi

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

[ -n "$tokens_str" ] && line1="${line1}${DIV}${tokens_str}"
[ -n "$five_hour_str" ] && line1="${line1}${DIV}${five_hour_str}"
[ -n "$weekly_str" ] && line1="${line1}${DIV}${weekly_str}"

line1="${line1}${DIV}${git_info}"

line2="${session_str}${DIV}${display_pwd}"

echo -e "$line1"
echo -e "$line2"
