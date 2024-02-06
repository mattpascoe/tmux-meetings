#!/bin/bash
#
# This script is used to display a summary of the current day's events and
# calendar. It is intended to be used as a popup message called by a tmux
# binding. You can set @meeting-status-meeting-summary-bindkey "C-m" for
# example.

# TODO: have a config option to display calendar or not, some screens may be
# too small to show it and the summary

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/helpers.sh"

EXCLUDE_CALS=$(get_tmux_option @meetings-exclude-cals-summary "")
echo "        $(date +'%A, %B %d, %Y %I:%M %p %Z')"
echo
if type "cal" &> /dev/null; then
  cal -3
  echo "⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯"
  echo
fi
if type "icalBuddy" &> /dev/null; then
  TODAY_EVENTS=$(icalBuddy -f \
    --includeEventProps "title,datetime,location,url" \
    --propertyOrder "datetime,title" \
    --dateFormat "%A" \
    --includeOnlyEventsFromNowOn \
    --separateByDate \
    --excludeCals "$EXCLUDE_CALS" \
    --sectionSeparator "" \
    eventsToday+1
  )

  if [ -z "$TODAY_EVENTS" ]; then
    TODAY_EVENTS="No upcoming events."
  fi
  echo "$TODAY_EVENTS"
else
  echo "WARN: icalBuddy not installed, you should install it to see today's events."
fi
