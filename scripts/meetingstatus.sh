#!/usr/bin/env bash
#
#TODO:
#  use the dispaly-menu option to list all the meetings happening now/today?

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/helpers.sh"

get_next_meeting() {
  NEXT_MEETING=$(icalBuddy \
    --includeEventProps "datetime,title" \
    --propertyOrder "datetime,title" \
    --includeOnlyEventsFromNowOn \
    --excludeAllDayEvents \
    --limitItems 1 \
    --bullet "" \
    -npn -nc -ps "/,/" -tf "%H:%M:%S" \
    --excludeCals "$EXCLUDE_CALS" \
    eventsToday)

  # Count the number of events happening now
  readarray -t EVENTS_NOW < <(icalBuddy \
    --includeEventProps "datetime,title" \
    --propertyOrder "datetime,title" \
    --includeOnlyEventsFromNowOn \
    --excludeAllDayEvents \
    --bullet "" \
    -npn -nc -ps "/,/" -tf "%H:%M:%S" \
    --excludeCals "$EXCLUDE_CALS" \
    eventsNow)

  EVENT_COUNT=${#EVENTS_NOW[@]}
}

calculate_times() {
  local TIMES=$(echo "$1" | awk -F',' '{print $1}')
  TIME=$(echo "$TIMES" | awk -F'-' '{print $1}'| tr -d '[:space:]')
  END_TIME=$(echo "$TIMES" | awk -F'-' '{print $2}'| tr -d '[:space:]')
  TITLE=$(echo "$1" | awk -F',' '{print $2}'| sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

  EPOC_MEETING=$(TZ=$TIMEZN date -j -f "%T" "$TIME:00" +%s)
  EPOC_MEETING_END=$(TZ=$TIMEZN date -j -f "%T" "$END_TIME:00" +%s)
  EPOC_DIFF=$((EPOC_MEETING - CURRENT_TIME))
  # This aligns our zero minute
  if [[ $EPOC_DIFF -lt 0 && $EPOC_DIFF -gt -60 ]]; then
    MINUTES_FROM_START=$((EPOC_DIFF/60))
  else
    MINUTES_FROM_START=$((EPOC_DIFF/60+1))
  fi
  local MEETING_LEN="$((EPOC_MEETING - EPOC_MEETING_END))"
  MEETING_LENGTH="$((MEETING_LEN/60+1))"
}

display_popup() {
  tmux display-popup \
    -S "fg=#eba0ac" \
    -T 'Meeting Has Started' \
    icalBuddy \
      --propertyOrder "datetime,title,location,url,attendees,notes" \
      --noCalendarNames \
      --formatOutput \
      --limitItems 1 \
      --includeEventProps "title,datetime,notes,location,url,attendees" \
      --includeOnlyEventsFromNowOn \
      --excludeAllDayEvents \
      --excludeCals "$EXCLUDE_CALS" \
      eventsToday
}

format_multi_entry() {
    local TIME=$(echo "$1" | awk -F'-' '{print $1}'| tr -d '[:space:]')
    local TITLE=$(echo "$1" | awk -F',' '{print $2}')
    local TIMEFMT=$(TZ=$TIMEZN date -j -f "%T" "$TIME" +%l:%M| tr -d '[:space:]')
    echo "'$TIMEFMT #[underscore]$TITLE' '' bar"
}
# tmux display-menu -xR -yS '20:40:00 #[underscore]test event' '' bar '21:00:00 #[underscore]test2' '' foo

multi_menu() {
  for entry in "$@"; do
    formatted_entries+=("$(format_multi_entry "$entry")")
  done
  formatted_entries_str=$(IFS=' '; echo "${formatted_entries[*]}")
  #TODO: put this into a bindkey to display when requested
  #Also is there a way to take mouse clicks on the status section?
  #eval "tmux display-menu -xR -yS '$(TZ=$TIMEZN date)' '' date '' $formatted_entries_str"
}

print_meeting_status() {
  local IN_MEETING_ICON=$(get_tmux_option @meetings-inmeeting-icon "󰤙 ")
  local ALMOST_MEETING_COLOR=$(get_tmux_option @meetings-almostmeeting-color "#f9e2af")
  local IN_MEETING_COLOR=$(get_tmux_option @meetings-inmeeting-color "#a6e3a1")
  local FREE_ICON=$(get_tmux_option @meetings-free-icon "󱁕")
  local FREE_COLOR=$(get_tmux_option @meetings-free-color "#a4e57e")
  local CHAR_LIMIT=$(get_tmux_option @meetings-char-limit 30)
  local ALERT_IF_IN_NEXT_MINUTES=$(get_tmux_option @meetings-alert-next 10) # may need to add one to this.. silly math
  local ALERT_POPUP_BEFORE_SECONDS=$(get_tmux_option @meetings-alert-popup 10)
  local TIMEFMT=$(get_tmux_option @meetings-time-format "%l:%M")
  local STATUSTIME=$(TZ=$TIMEZN date -j -f "%T" "$TIME:00" +$TIMEFMT| tr -d '[:space:]')
  local STATUSENDTIME="~$(TZ=$TIMEZN date -j -f "%T" "$END_TIME:00" +$TIMEFMT| tr -d '[:space:]')"

  # Show the clock if the option is set
  local SHOWCLOCK=$(get_tmux_option @meetings-show-clock 1)
  if [[ $SHOWCLOCK -eq 1 ]]; then
    local CLOCKFMT="$(get_tmux_option @meetings-clock-format "%a %m/%d %I:%M")"
    local CLOCK=" #[fg=#default]$(TZ=$TIMEZN date +"$CLOCKFMT")"
  fi

  # Show details if the meeting is in progress and X time before
  if [[ $MINUTES_FROM_START -gt -100 && $MINUTES_FROM_START -lt $ALERT_IF_IN_NEXT_MINUTES || $MINUTES_FROM_START -eq $ALERT_IF_IN_NEXT_MINUTES ]]; then
    # If the meeting is about to start or has started
    if (( $MINUTES_FROM_START > 0 )); then
      MEETING_COLOR=$ALMOST_MEETING_COLOR
      STATUSENDTIME=""
      TIMEFRAME="In $MINUTES_FROM_START"
    else
      MEETING_COLOR=$IN_MEETING_COLOR
      TIMEFRAME="$((MINUTES_FROM_START - MEETING_LENGTH))" # How many mins left
      #TIMEFRAME="$((1 - MINUTES_FROM_START))" # How many mins into the meeting
    fi
    # Indicate if there is more than one meeting now
    if [[ $EVENT_COUNT -gt 1 ]]; then
      local MULTI_MSG=" 󰃱 $EVENT_COUNT"
      multi_menu "${EVENTS_NOW[@]}"
    fi
    #CUR_MSG="#[fg=${MEETING_COLOR}]${STATUSTIME}${STATUSENDTIME} #[underscore]${TITLE:0:CHAR_LIMIT}#[nounderscore] ($TIMEFRAME mins)$MULTI_MSG$CLOCK"
    CUR_MSG="#[fg=${MEETING_COLOR}]${STATUSTIME} #[underscore]${TITLE:0:CHAR_LIMIT}#[nounderscore] ($TIMEFRAME mins)$MULTI_MSG$CLOCK"
  else
    CUR_MSG="$FREE_ICON$CLOCK"
  fi

  echo "$CUR_MSG"
  # Store the current message in a tmux option variable for later retrieval
  # during the check interval
  set_tmux_option "@meetings-current-text" "$CUR_MSG"

  # Popup if the meeting is about to start based on ALERT_POPUP_BEFORE_SECONDS
  if [[ $EPOC_DIFF -gt $ALERT_POPUP_BEFORE_SECONDS && $EPOC_DIFF -lt $ALERT_POPUP_BEFORE_SECONDS+10 ]]; then
    display_popup
  fi
#  EPOC_TIMEPLUS=$((EPOC_TIME+10))
#  if((CURRENT_TIME >= EPOC_TIME && CURRENT_TIME <= EPOC_TIMEPLUS)); then
#    display_popup
#  fi
#  if [[ $CURRENT_TIME -gt $EPOC_TIME && $CURRENT_TIME -lt $EPOC_TIME+10 ]]; then
#    display_popup
#  fi
}

main() {
  # Check if icalBuddy is installed
  if ! type "icalBuddy" &> /dev/null; then
    echo "icalBuddy not installed."
    return 0
  fi
  EXCLUDE_CALS=$(get_tmux_option @meetings-exclude-cals "")
  CURRENT_TIME=$(TZ=$TIMEZN date +%s)
  local CHECK_INTERVAL=$(get_tmux_option @meetings-check-interval 10)
  # These two variables only store context to ensure we process at the interval
  local LAST_CHECK=$(get_tmux_option @meetings-last-check)
  local LAST_MSG=$(get_tmux_option @meetings-current-text)
  # Difference between current time and last execution time
  local TIME_DIFF=$((CURRENT_TIME - LAST_CHECK))
  # Pick up system timezone as default, this allows us to control the timezone
  # we want to calculate everything with
  local TIMEZN=$(get_tmux_option @meetings-timezone $(date +%Z))

  # If we are past the check interval update the status
  # Otherwise just keep the last message text
  if ((TIME_DIFF >= CHECK_INTERVAL)); then
    get_next_meeting
    calculate_times "$NEXT_MEETING"
    print_meeting_status
    set_tmux_option "@meetings-last-check" "$CURRENT_TIME"
  else
    echo "$LAST_MSG"
    #echo "Checking... $TIME_DIFF $LAST_CHECK $CURRENT_TIME"
  fi
}
main
