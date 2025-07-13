#!/usr/bin/env bash
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

get_tmux_option() {
  local option value default
  option="$1"
  default="$2"
  value="$(tmux show-option -gqv "$option")"

  if [ -n "$value" ]; then
    echo "$value"
  else
    echo "$default"
  fi
}

set() {
  local option=$1
  local value=$2
  tmux_commands+=(set-option -gq "$option" "$value" ";")
}

setw() {
  local option=$1
  local value=$2
  tmux_commands+=(set-window-option -gq "$option" "$value" ";")
}

main() {
  local theme
  theme="$(get_tmux_option "@catppuccin_flavour" "mocha")"

  # Aggregate all commands in one array
  local tmux_commands=()

  # NOTE: Pulling in the selected theme by the theme that's being set as local
  # variables.
  # shellcheck source=catppuccin-frappe.tmuxtheme
  source /dev/stdin <<<"$(sed -e "/^[^#].*=/s/^/local /" "${PLUGIN_DIR}/catppuccin-${theme}.tmuxtheme")"

  # status
  set status "on"
  set status-bg "${thm_bg}"
  set status-justify "left"
  set status-left-length "100"
  set status-right-length "100"

  # messages
  set message-style "fg=${thm_cyan},bg=${thm_gray},align=centre"
  set message-command-style "fg=${thm_cyan},bg=${thm_gray},align=centre"

  # panes
  set pane-border-style "fg=${thm_gray}"
  set pane-active-border-style "fg=${thm_blue}"

  # windows
  setw window-status-activity-style "fg=${thm_fg},bg=${thm_bg},none"
  setw window-status-separator ""
  setw window-status-style "fg=${thm_fg},bg=${thm_bg},none"

  # --------=== Statusline

  # NOTE: Checking for the value of @catppuccin_window_tabs_enabled
  local wt_enabled
  wt_enabled="$(get_tmux_option "@catppuccin_window_tabs_enabled" "off")"
  readonly wt_enabled

  local right_separator
  right_separator="$(get_tmux_option "@catppuccin_right_separator" "")"
  readonly right_separator

  local left_separator
  left_separator="$(get_tmux_option "@catppuccin_left_separator" "")"
  readonly left_separator

  # Disable all other options by default
  local user
  user="$(get_tmux_option "@catppuccin_user" "off")"
  readonly user

  local host
  host="$(get_tmux_option "@catppuccin_host" "off")"
  readonly host

  local date_time
  date_time="$(get_tmux_option "@catppuccin_date_time" "off")"
  readonly date_time

  local network
  network="$(get_tmux_option "@catppuccin_network" "off")"
  readonly network

  # Keep only directory and window
  local show_directory
  readonly show_directory="#[fg=$thm_pink,bg=$thm_bg,nobold,nounderscore,noitalics]$right_separator#[fg=$thm_bg,bg=$thm_pink,nobold,nounderscore,noitalics] #[fg=$thm_fg,bg=$thm_gray] #{b:pane_current_path} "

  local show_window
  readonly show_window="#[fg=$thm_pink,bg=$thm_bg,nobold,nounderscore,noitalics]$right_separator#[fg=$thm_bg,bg=$thm_pink,nobold,nounderscore,noitalics] #[fg=$thm_fg,bg=$thm_gray] #W "

  # Remove other show_* variables (e.g., show_session, show_user, etc.) since they're not needed

  # Right column 1 shows the Window name
  local right_column1=$show_window

  # Right column 2 shows the Directory path
  local right_column2=$show_directory

  # Window status shows the window name
  local window_status_format="#[fg=$thm_bg,bg=$thm_blue] #I #[fg=$thm_fg,bg=$thm_gray] #W "
  local window_status_current_format="#[fg=colour232,bg=$thm_orange] #I #[fg=colour255,bg=colour237] #W "

  # Disable window tabs logic since only window and directory are needed
  if [[ "${wt_enabled}" == "on" ]]; then
    # No change needed as we’re keeping directory in right_column2
    window_status_format="#[fg=$thm_bg,bg=$thm_blue] #I #[fg=$thm_fg,bg=$thm_gray] #W "
    window_status_current_format="#[fg=colour232,bg=$thm_orange] #I #[fg=colour255,bg=colour237] #W "
  fi

  # Disable all other conditionals
  # (user, host, date_time, network are off by default, so no action needed)

  set status-left ""

  set status-right "${right_column1},${right_column2}"

  setw window-status-format "${window_status_format}"
  setw window-status-current-format "${window_status_current_format}"

  # --------=== Modes
  #
  setw clock-mode-colour "${thm_blue}"
  setw mode-style "fg=${thm_pink} bg=${thm_black4} bold"

  tmux "${tmux_commands[@]}"
}

main "$@"
