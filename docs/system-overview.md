# System Overview

Snapshot date: 2026-06-08

Primary machine captured here:

- Ubuntu 24.04.4 LTS, GNOME Ubuntu session.
- Hostname: `qThinkPad-P16-Gen-2`.
- Kernel at snapshot: `6.17.0-35-generic`.
- Shell: Bash.
- Main project workspace: `/mnt/windows/Users/densepose/Documents/densepose/rpi_wifi_stream`.

## Main App Set

Browsers and web apps:

- Google Chrome Stable.
- Firefox snap.
- Chrome website apps: Outlook PWA, WhatsApp Web, Docs.
- Chrome-installed app URLs also detected for Google Drive, Outlook, WhatsApp Web, and YouTube.

Development and AI:

- VS Code with Python, Jupyter, Java, Remote SSH/WSL, Scheme/Racket, Claude Code, ChatGPT, and Copilot-related extensions.
- Git, GitHub CLI, npm, Python venv/pip, Vim, tmux.
- Global npm package: `@anthropic-ai/claude-code`.
- Helper scripts: `bin/claude-backup`, `bin/claude-done-notify.sh`.
- Screen zoom helper: `bin/touchpad-screen-zoom`, mapping touchpad pinch gestures to GNOME screen magnifier shortcuts.

Desktop utilities:

- CopyQ clipboard manager with `Meta+V` global toggle.
- GNOME Tweaks, GNOME Snapshot.
- Fcitx5 with Rime as default input method.
- Redshift/Gammastep configs for very warm screen temperatures.
- Telegram Desktop snap.

Media and hardware:

- OBS Studio.
- FFmpeg.
- NVIDIA open driver 595 and CUDA Toolkit 13.0 on the captured machine.
- Raspberry Pi Imager.

Networking and dual-boot/project tools:

- OpenConnect, Pulse Secure inventory entry, iperf3, nmap, net-tools, sshpass.
- Densepose/RPi project aliases and PyQt plugin path in `.bashrc`.

## Desktop Tweaks

GNOME/app settings captured in portable form:

- Battery percentage shown.
- Hot corners disabled.
- Text scaling around `1.17`.
- Touchpad tap-to-click enabled and natural scrolling enabled.
- Mouse natural scrolling disabled.
- Input switching on `Super+Space` and backward switching on `Shift+Super+Space`.
- Window buttons on the right with minimize, maximize, close.
- Dock favorites: Chrome, Terminal, Files, VS Code, Text Editor, OBS.
- Dock on the left, `Super+number` behavior retained, scroll action switches workspace.
- AC idle sleep disabled; battery idle suspend retained.
- GNOME Night Light disabled because Redshift/Gammastep handle warmth.
- GNOME screen magnifier shortcuts retained: `Alt+Super+8` toggle, `Alt+Super+=` zoom in, `Alt+Super+-` zoom out.

## Redshift Behavior

The current setup intentionally avoids a continuously running Redshift controller:

- Redshift config: `1700K` day, `1000K` night, manual Singapore coordinates, `randr`.
- Gammastep config: `1800K` day, `1100K` night, manual Singapore coordinates, `wayland`.
- Redshift/Gammastep indicators are present but autostart is disabled/hidden.
- `.bashrc` function `r()` stops `redshift` and `redshift-gtk`, resets gamma with `-P`, then applies the requested temperature.

Examples:

```bash
r 3000
r
```

`r` with no argument restores `6500K`.

## Files Backed Up

Home dotfiles:

- `.bashrc`
- `.profile`
- `.xinputrc`
- `.gitconfig`
- `.vimrc`
- `.tmux.conf`

Config files:

- `config/redshift/redshift.conf`
- `config/gammastep/config.ini`
- `config/autostart/*.desktop`
- `config/copyq/copyq.conf`
- `config/copyq/copyq-commands.ini`
- `config/copyq/copyq_tabs.ini`
- `config/fcitx5/profile`
- `config/fcitx5/conf/notifications.conf`
- `config/Code/User/settings.json`
- `config/chrome-web-apps/*.desktop`
- `config/systemd/user/touchpad-screen-zoom.service`

Local executable scripts:

- `bin/claude-backup`
- `bin/claude-done-notify.sh`
- `bin/touchpad-screen-zoom`

## Deliberately Not Backed Up

- Chrome profile databases, cookies, passwords, sessions, browser caches.
- SSH private keys and auth tokens.
- CopyQ clipboard item data.
- Runtime locks, geometry caches, and app state databases.
- Downloaded binaries such as local copies of `gh`, `uv`, and `uvx`.
- Project repositories and virtual environments.

## Rebuild Order

1. Install Ubuntu and update base system.
2. Clone this repo.
3. Run `./scripts/bootstrap-ubuntu.sh`.
4. Reboot or log out/in for Fcitx, GNOME shell, and autostart changes.
5. Sign in to Chrome and recreate web apps if app-ID launchers do not open.
6. Run `r 3000` or another preferred temperature.
7. Restore project repositories and virtual environments separately.
8. On NVIDIA/CUDA hardware only, run `./scripts/bootstrap-ubuntu.sh --hardware` or follow current NVIDIA/CUDA docs manually.

## Future AI Maintenance Rule

When an assistant changes installed apps, system packages, shell config, app configs, GNOME settings, Redshift/Gammastep behavior, Fcitx input method, VS Code settings/extensions, Chrome web apps, or helper scripts on this machine, update this repo in the same turn:

```bash
cd ~/dotfiles
./scripts/snapshot-ubuntu.sh
git status
```

Then review the diff for secrets or accidental state dumps before committing.
