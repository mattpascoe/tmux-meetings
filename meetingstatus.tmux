#!/usr/bin/env bash
#
# TODO:
# is there a linux alternative to icalBuddy that could be used
# add config option to display date/time. basically combine the default plugins into this one??? TBD
# This is very much MAC only. icalBuddy and the behavior of the date command


CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/scripts/helpers.sh"

meeting_status_details="#($CURRENT_DIR/scripts/meetingstatus.sh)"
meeting_status_details_interpolation_string="\#{meetingstatus}"

do_interpolation() {
  local string="$1"
  local interpolated="${string/$meeting_status_details_interpolation_string/$meeting_status_details}"
  echo "$interpolated"
}

update_tmux_option() {
  local option="$1"
  local option_value="$(get_tmux_option "$option")"
  local new_option_value="$(do_interpolation "$option_value")"
  set_tmux_option "$option" "$new_option_value"
}

main() {
  update_tmux_option "status-right"
  update_tmux_option "status-left"
}

# Setup a keybinding to popup the year calendar
CALBINDKEY=$(get_tmux_option @meetings-calendar-bindkey "C-c")
bind-key "$CALBINDKEY" run-shell "tmux display-popup -w68 -h40 -T 'This years Calendar' cal $(date +%Y)"

# Setup a keybinding to popup the meeting list
SUMMARYBINDKEY=$(get_tmux_option @meetings-summary-bindkey "C-m")
bind-key "$SUMMARYBINDKEY" run-shell "tmux display-popup -S -w50% -h75% -T 'Todays Meeting Info' $CURRENT_DIR/scripts/daily_summary_popup.sh"

main
