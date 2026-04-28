#!/usr/bin/env bash
# Smart nvim wrapper that uses nvim-min config on certain applications.
# Claude coded all of this - you think I'm good at bash?

LOG_FILE="${NVIM_WRAPPER_LOG_FILE:-/tmp/nvim-wrapper.log}"

get_launcher() {
  local pid="${1:-$$}"
  local ppid

  while [[ -n "$pid" && "$pid" -ne 1 ]]; do
    ps -o pid=,ppid=,comm=,args= -p "$pid" 2>/dev/null || break
    ppid=$(ps -o ppid= -p "$pid" 2>/dev/null | tr -d ' ')
    [[ -n "$ppid" ]] || break
    pid="$ppid"
  done

  if [[ "$pid" == "1" ]]; then
    ps -o pid=,ppid=,comm=,args= -p 1 2>/dev/null || true
  fi
}

log_invocation() {
  # local mode="$1"
  shift
  {
    printf '=== %s ===\n' "$(date '+%Y-%m-%d %H:%M:%S %z')"
    # printf 'mode: %s\n' "$mode"
    printf 'pid: %s\n' "$$"
    printf 'ppid: %s\n' "$PPID"
    printf 'cwd: %s\n' "$PWD"
    printf 'args:'
    printf ' %q' "$@"
    printf '\n'
    printf 'launcher chain:\n'
    while IFS= read -r line; do
      printf '  %s\n' "$line"
    done < <(get_launcher "$PPID")
    printf '\n'
  } >> "$LOG_FILE" 2>/dev/null || true
}

has_ancestor_process() {
  local target="$1"
  local pid="${2:-$PPID}"
  local ppid
  local comm

  while [[ -n "$pid" && "$pid" -ne 1 ]]; do
    comm=$(ps -o comm= -p "$pid" 2>/dev/null | tr -d ' ')
    if [[ "$comm" == "$target" ]]; then
      return 0
    fi

    ppid=$(ps -o ppid= -p "$pid" 2>/dev/null | tr -d ' ')
    [[ -n "$ppid" ]] || break
    pid="$ppid"
  done

  return 1
}

app_name=""

if [[ "${OPENCODE:-}" == "1" ]] \
  || has_ancestor_process claude \
  || [[ "${1:-}" == */fish.*/command-line.fish ]]
then
  app_name="nvim-min"
fi

NVIM_APPNAME="$app_name" exec nvim "$@"
