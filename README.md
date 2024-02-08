# Meeting status TMUX plugin

This was inspired by the work of [DevOps Toolbox](https://www.youtube.com/@devopstoolbox) on YouTube.
I saw one of his videos and liked what he started, but I wanted to make it more of an official plugin and add some more features to suite my needs.

This plugin currently only works on MacOS. It requires icalBuddy to be installed.


### Installation with [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm) (recommended)

1. Ensure you have ical-buddy installed

        brew install ical-buddy

2. Add this plugin to the list of TPM plugins in `.tmux.conf`:

        set -g @plugin 'mattpascoe/tmux-meetings'

3. Press `prefix` + <kbd>I</kbd> or run `$TMUX_PLUGIN_MANAGER_PATH/tpm/scripts/install_plugins.sh` to fetch the plugin and source it. You should now be able to
use the plugin.

### Manual Installation

1. Clone the repo:

        $ git clone https://github.com/mattpascoe/tmux-meetings ~/clone/path

2. Add this line to the bottom of `.tmux.conf`:

        run-shell ~/clone/path/tmux-meetings.tmux

3. Reload TMUX environment:

        # type this in terminal
        $ tmux source-file ~/.tmux.conf

4. You will need to add an interpolation to your status-right or status-left option in your tmux.conf file.

        set -g status-right "#{meetings}"


## Catppuccin Option
If you are using the Catppuccin TMUX theme, you can add the following to a file in the `custom` directory
such as `~/.tmux/plugins/tmux/custom/meetings.sh`

```sh
# Requires tmux-meetings plugin
show_meetings() {
  local index=$1
  local icon="$(get_tmux_option "@catppuccin_meetings_icon" "󰃰")"
  local color="$(get_tmux_option "@catppuccin_meetings_color" "$thm_blue")"
  local text="$(get_tmux_option "@catppuccin_meetings_text" "#{meetings}")"

  local module=$( build_status_module "$index" "$icon" "$color" "$text" )

  echo "$module"
}
```

Then add the `meetings` to your `@catppuccin_status_modules_right` option in your tmux.conf for example.

```sh
set -g @catppuccin_status_modules_right "directory meetings"
```


# Configuration Options
The following are the available options that can be set and their default values.

```
@meetings-meeting-summary-bindkey "C-m"
@meetings-calendar-summary-bindkey "C-c"
@meetings-almostmeeting-color "#f9e2af"
@meetings-inmeeting-color "#a6e3a1"
@meetings-free-icon "󱁕"
@meetings-free-color "#a4e57e"
@meetings-char-limit 30
@meetings-alert-next 10 # in minutes
@meetings-alert-popup 10 # in seconds
@meetings-time-format "%l:%M"
@meetings-show-clock 1
@meetings-clock-format "%a %m/%d %I:%M"
@meetings-exclude-cals ""
@meetings-check-interval 60
@meetings-timezone # defaults to system timezone using `date +%Z`
```
