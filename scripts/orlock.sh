#!/usr/bin/env bash
# setting the locale, some users have issues with different locales, this forces the correct one
export LC_ALL=en_US.UTF-8

current_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $current_dir/utils.sh

main()
{
  datafile=/tmp/.orlock-tmux-data

  # set configuration option variables
  show_fahrenheit=$(get_tmux_option "@orlock-show-fahrenheit" true)
  show_location=$(get_tmux_option "@orlock-show-location" true)
  fixed_location=$(get_tmux_option "@orlock-fixed-location")
  show_powerline=$(get_tmux_option "@orlock-show-powerline" false)
  show_flags=$(get_tmux_option "@orlock-show-flags" false)
  show_left_icon=$(get_tmux_option "@orlock-show-left-icon" smiley)
  show_left_icon_padding=$(get_tmux_option "@orlock-left-icon-padding" 1)
  show_military=$(get_tmux_option "@orlock-military-time" false)
  show_timezone=$(get_tmux_option "@orlock-show-timezone" true)
  show_left_sep=$(get_tmux_option "@orlock-show-left-sep" )
  show_right_sep=$(get_tmux_option "@orlock-show-right-sep" )
  show_border_contrast=$(get_tmux_option "@orlock-border-contrast" false)
  show_day_month=$(get_tmux_option "@orlock-day-month" false)
  show_refresh=$(get_tmux_option "@orlock-refresh-rate" 5)
  IFS=' ' read -r -a plugins <<< $(get_tmux_option "@orlock-plugins" "battery network weather")

  # Orlock Color Pallette
  white='#F8FAFC'
  gray='#334155'
  dark_gray='#111827'
  light_purple='#C4B5FD'
  dark_purple='#A78BFA'
  cyan='#67E8F9'
  bright_cyan='#A5F3FC'
  green='#34D399'
  teal='#5EEAD4'
  orange='#F58E0B'
  red='#EF4444'
  pink='#F472B6'
  yellow='#FDE047'

  # Handle left icon configuration
  case $show_left_icon in
    smiley)
      left_icon="†";;
    session)
      left_icon="#S";;
    window)
      left_icon="#W";;
    *)
      left_icon=$show_left_icon;;
  esac

  # Handle left icon padding
  padding=""
  if [ "$show_left_icon_padding" -gt "0" ]; then
    padding="$(printf '%*s' $show_left_icon_padding)"
  fi
  left_icon="$left_icon$padding"

  # Handle powerline option
  if $show_powerline; then
    right_sep="$show_right_sep"
    left_sep="$show_left_sep"
  fi

  # start weather script in background
  if [[ "${plugins[@]}" =~ "weather" ]]; then
    $current_dir/sleep_weather.sh $show_fahrenheit $show_location $fixed_location &
  fi

  # Set timezone unless hidden by configuration
  case $show_timezone in
    false)
      timezone="";;
    true)
      timezone="#(date +%Z)";;
  esac

  case $show_flags in
    false)
      flags=""
      current_flags="";;
    true)
      flags="#{?window_flags,#[fg=${dark_purple}]#{window_flags},}"
      current_flags="#{?window_flags,#[fg=${light_purple}]#{window_flags},}"
  esac

  # sets refresh interval to every 5 seconds
  tmux set-option -g status-interval $show_refresh

  # set the prefix + t time format
  if $show_military; then
    tmux set-option -g clock-mode-style 24
  else
    tmux set-option -g clock-mode-style 12
  fi

  # set length
  tmux set-option -g status-left-length 100
  tmux set-option -g status-right-length 100

  # pane border styling
  if $show_border_contrast; then
    tmux set-option -g pane-active-border-style "fg=${light_purple}"
  else
    tmux set-option -g pane-active-border-style "fg=${dark_purple}"
  fi
  tmux set-option -g pane-border-style "fg=${dark_gray}"

  # message styling
  tmux set-option -g message-style "bg=${dark_gray},fg=${white}"

  # status bar
  tmux set-option -g status-style "bg=${dark_gray},fg=${white}"

  # Status left
  if $show_powerline; then
    tmux set-option -g status-left "#[bg=${green},fg=${dark_gray}]#{?client_prefix,#[bg=${teal}],} ${left_icon} #[fg=${green},bg=${dark_gray}]#{?client_prefix,#[fg=${yellow}],}${left_sep}"
    powerbg=${dark_gray}
  else
    tmux set-option -g status-left "#[bg=${green},fg=${dark_gray}]#{?client_prefix,#[bg=${bright_cyan}],} ${left_icon}"
  fi

  # Status right
  tmux set-option -g status-right ""

  for plugin in "${plugins[@]}"; do

    if [ $plugin = "git" ]; then
      IFS=' ' read -r -a colors  <<< $(get_tmux_option "@orlock-git-colors" "green dark_gray")
        script="#($current_dir/git.sh)"
    fi

    if [ $plugin = "battery" ]; then
      IFS=' ' read -r -a colors <<< $(get_tmux_option "@orlock-battery-colors" "light_purple dark_gray")
      script="#($current_dir/battery.sh)"
    fi

    if [ $plugin = "gpu-usage" ]; then
      IFS=' ' read -r -a colors <<< $(get_tmux_option "@orlock-gpu-usage-colors" "pink dark_gray")
      script="#($current_dir/gpu_usage.sh)"
    fi

    if [ $plugin = "cpu-usage" ]; then
      IFS=' ' read -r -a colors <<< $(get_tmux_option "@orlock-cpu-usage-colors" "orange dark_gray")
      script="#($current_dir/cpu_info.sh)"
    fi

    if [ $plugin = "ram-usage" ]; then
      IFS=' ' read -r -a colors <<< $(get_tmux_option "@orlock-ram-usage-colors" "cyan dark_gray")
      script="#($current_dir/ram_info.sh)"
    fi

    if [ $plugin = "network" ]; then
      IFS=' ' read -r -a colors <<< $(get_tmux_option "@orlock-network-colors" "cyan dark_gray")
      script="#($current_dir/network.sh)"
    fi

    if [ $plugin = "network-bandwidth" ]; then
      IFS=' ' read -r -a colors <<< $(get_tmux_option "@orlock-network-bandwidth-colors" "cyan dark_gray")
      tmux set-option -g status-right-length 250
      script="#($current_dir/network_bandwidth.sh)"
    fi

    if [ $plugin = "network-ping" ]; then
      IFS=' ' read -r -a colors <<<$(get_tmux_option "@orlock-network-ping-colors" "cyan dark_gray")
      script="#($current_dir/network_ping.sh)"
    fi

    if [ $plugin = "weather" ]; then
      # wait unit $datafile exists just to avoid errors
      # this should almost never need to wait unless something unexpected occurs
      while [ ! -f $datafile ]; do
        sleep 0.01
      done

      IFS=' ' read -r -a colors <<< $(get_tmux_option "@orlock-weather-colors" "bright_cyan dark_gray")
      script="#(cat $datafile)"
    fi

    if [ $plugin = "time" ]; then
      IFS=' ' read -r -a colors <<< $(get_tmux_option "@orlock-time-colors" "cyan dark_gray")
      if $show_day_month && $show_military ; then # military time and dd/mm
        script="%a %d/%m %R ${timezone} "
      elif $show_military; then # only military time
        script="%a %m/%d %R ${timezone} "
      elif $show_day_month; then # only dd/mm
        script="%a %d/%m %I:%M %p ${timezone} "
      else
        script="%a %m/%d %I:%M %p ${timezone} "
      fi
    fi

    if $show_powerline; then
      tmux set-option -ga status-right "#[fg=${!colors[0]},bg=${powerbg},nobold,nounderscore,noitalics]${right_sep}#[fg=${!colors[1]},bg=${!colors[0]}] $script "
      powerbg=${!colors[1]}
    else
      tmux set-option -ga status-right "#[fg=${!colors[1]},bg=${!colors[0]}] $script "
    fi
  done

  # Window option
  if $show_powerline; then
    tmux set-window-option -g window-status-current-format "#[fg=${dark_gray},bg=${dark_purple}]${left_sep}#[fg=${white},bg=${dark_purple}] #I #W${current_flags} #[fg=${dark_purple},bg=${dark_gray}]${left_sep}"
  else
    tmux set-window-option -g window-status-current-format "#[fg=${bright_cyan},bg=${gray}] #I #W${current_flags} "
  fi

  tmux set-window-option -g window-status-format "#[fg=${white}] #I #W${flags} "
  tmux set-window-option -g window-status-activity-style "bold"
  tmux set-window-option -g window-status-bell-style "bold"
}

# run main function
main
