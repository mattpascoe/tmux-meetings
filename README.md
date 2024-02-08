# Meeting status TMUX plugin

This was inspired and initiated by the work of <YOUTUBE GUY>
I saw his video and thought it was a great idea, but I wanted to make it more of an official plugin and add some more features.

# Pre-requisites
This plugin currently only works on MacOS. It requires icalBuddy to be installed. You can install it using homebrew.

```sh
brew install ical-buddy
```


TODO:
Consider https://calcurse.org/ as an alternative to icalBuddy and even the whole plugin itself???


# Installation
Add the following to your `.tmux.conf` file

```sh
set -g @plugin 'mattpascoe/tmux-meetings'
```

Then press `prefix` + `I` to install the plugin.




## Catppuccin Option
If you are using the Catppuccin TMUX theme, you can add the following to a file in the `custom` directory
such as `~/.tmux/plugins/tmux/custom/tmux-meetings.sh`

```sh
show_meetingstatus() {
  local index=$1
  local icon="$(get_tmux_option "@catppuccin_meetings_icon" "󰃰")"
  local color="$(get_tmux_option "@catppuccin_meetings_color" "$thm_blue")"
  local text="$(get_tmux_option "@catppuccin_meetings_text" "#{meetingstatus}")"

  local module=$( build_status_module "$index" "$icon" "$color" "$text" )

  echo "$module"
}
```

Then add the following to your `@catppuccin_status_modules_right` option in your tmux.conf for example.

```sh
set -g @catppuccin_status_modules_right "directory meetingstatus"
```


# Configuration Options
The following are the available options that can be set.

```
@meetings-meeting-summary-bindkey "C-m"
@meetings-calendar-summary-bindkey "C-c"
@meetings-inmeeting-icon "󰤙 "
@meetings-almostmeeting-color "#f9e2af"
@meetings-inmeeting-color "#a6e3a1"
@meetings-free-icon "󱁕"
@meetings-free-color "#a4e57e"
@meetings-char-limit 30
@meetings-alert-next 10
@meetings-alert-popup 10
@meetings-time-format "%l:%M"
@meetings-show-clock 1
@meetings-clock-format "%a %m/%d %I:%M"
@meetings-exclude-cals ""
@meetings-check-interval 10
@meetings-last-check
@meetings-current-text
@meetings-timezone $(date +%Z)
```
