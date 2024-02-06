# meeting status TMUX plugin
#

Plugin based on https://hasseg.org/icalBuddy/

This was inspired and initiated by the work of <YOUTUBE GUY>

consider https://calcurse.org/ as an alternative to icalBuddy and even the
whole plugin itself???


# Catppuccin Option
If you are using the Catppuccin TMUX theme, you can add the following to a file in the `custom` directory

```sh
# Requires meetingstatus plugin
show_meetingstatus() {
  local index=$1
  local icon="$(get_tmux_option "@catppuccin_meetings_icon" "󰃰")"
  local color="$(get_tmux_option "@catppuccin_meetings_color" "$thm_blue")"
  local text="$(get_tmux_option "@catppuccin_meetings_text" "#{meetingstatus}")"

  local module=$( build_status_module "$index" "$icon" "$color" "$text" )

  echo "$module"
}
```
