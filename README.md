# Orlock for [tmux](https://github.com/tmux/tmux/wiki)

> A dark theme for [tmux](https://github.com/tmux/tmux/wiki), forked from [Dracula-tmux](https://github.com/dracula/tmux).

![Screenshot](./screenshot.png)

## Install
Simply add the following to your `.tmux.conf` in the plugin section, after installing [tpm](https://github.com/tmux-plugins/tpm).
```
set -g @plugin 'beardage/orlock-tmux'
set -s default-terminal 'tmux-256color'
```

## Configuration

TODO

## Features

- Support for powerline
- Day, date, time, timezone
- Current location based on network with temperature and forecast icon (if available)
- Network connection status, bandwidth and SSID
- Git branch and status
- Battery percentage and AC power connection status
- Refresh rate control
- CPU usage (percentage or load average)
- RAM usage
- GPU usage
- Color code based on if prefix is active or not
- List of windows with current window highlighted
- When prefix is enabled smiley face turns from green to yellow
- When charging, 'AC' is displayed
- If forecast information is available, a ☀, ☁, ☂, or ❄ unicode character corresponding with the forecast is displayed alongside the temperature

## Compatibility

Compatible with macOS and Linux. Tested on tmux 3.1b
FreeBSD compatibility is in development

## Team
This is a fork of [Dracula-tmux](https://github.com/dracula/tmux). Most credit goes to them for the the development, so I'm leaving them on this section (let me know if you'd like to be removed.)
This theme is now maintained by [Beardage](https://github.com/beardage)

The original theme is maintained by the following person(s) and a bunch of [awesome contributors](https://github.com/dracula/tmux/graphs/contributors).

| [![Dane Williams](https://avatars2.githubusercontent.com/u/22798229?s=70&v=4",)](https://github.com/danerwilliams) | [![Ethan Edwards](https://avatars1.githubusercontent.com/u/60861925?s=70&v=4)](https://github.com/ethancedwards8) |
| ------------------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------- |
| [Dane Williams](https://github.com/danerwilliams)                                                                  | [Ethan Edwards](https://github.com/ethancedwards8)                                                                |


## License

[MIT License](./LICENSE)
