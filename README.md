# dotfiles

Personal setup notes, dotfiles, and machine snapshots for quickly rebuilding an Ubuntu desktop, especially a dual-boot Ubuntu system.

Current primary snapshot: Ubuntu 24.04.4 LTS on GNOME, ThinkPad P16 Gen 2, kernel 6.17 HWE, NVIDIA/CUDA setup, Singapore location settings.

## Quick start on a new Ubuntu machine

```bash
git clone https://github.com/chleheng/dotfiles.git ~/dotfiles
cd ~/dotfiles
./scripts/bootstrap-ubuntu.sh
```

Useful variants:

```bash
./scripts/bootstrap-ubuntu.sh --dry-run
./scripts/bootstrap-ubuntu.sh --hardware
./scripts/bootstrap-ubuntu.sh --all-apt-manual
./scripts/bootstrap-ubuntu.sh --skip-packages
```

The bootstrap script backs up existing files into `~/.dotfiles-backup/<timestamp>` before overwriting them.

## What gets restored

- Shell/editor dotfiles: `.bashrc`, `.profile`, `.xinputrc`, `.gitconfig`, `.vimrc`, `.tmux.conf`.
- Safe app configs: Redshift, Gammastep, CopyQ settings, Fcitx5 profile, VS Code user settings, selected autostart entries.
- Screen zoom helper: touchpad-to-GNOME-magnifier script plus user systemd service.
- Lightweight desktop alarm helpers: `alarm-in`, `alarm-ring`, and `alarm-stop`.
- App installs: curated apt packages, Telegram snap, VS Code extensions, npm globals.
- Desktop tweaks: selected GNOME settings from `manifests/gnome-settings-apply.txt`.
- Chrome web app launchers: Outlook PWA, WhatsApp Web, and Docs launchers from `config/chrome-web-apps/`.
- Codex global instructions: `~/.codex/AGENTS.md` is restored as a symlink to `config/codex/AGENTS.md`, so edits stay in dotfiles instead of drifting into an untracked copy.
- Bash safety net: `bashrc-push` plus a user systemd watcher that commits and pushes `~/.bashrc` after saves.

## Snapshot this machine again

After changing system packages, apps, desktop settings, shell config, Redshift/Gammastep, Fcitx, CopyQ, VS Code, or Chrome web apps:

```bash
cd ~/dotfiles
./scripts/snapshot-ubuntu.sh
git status
```

Review the diff before committing. The snapshot intentionally skips browser profile databases, secrets, SSH keys, clipboard history, CopyQ item data, locks, caches, and downloaded binaries.

## Important manifests

- `manifests/apt-core.txt`: curated daily Ubuntu packages used by default.
- `manifests/apt-manual.txt`: all packages marked manually installed on the current machine.
- `manifests/apt-installed.tsv`: full dpkg installed package inventory.
- `manifests/snap-apps.txt`: curated snap apps used by default.
- `manifests/snap-packages.txt`: full current snap list names, including base snaps.
- `manifests/desktop-apps.tsv`: visible desktop launchers from user, system, and snap locations.
- `manifests/chrome-web-apps.tsv`: Chrome app-ID launchers found in `~/.local/share/applications`.
- `manifests/chrome-installed-web-app-urls.tsv`: Chrome-installed app URLs detected from the Chrome profile preferences.
- `manifests/vscode-extensions.txt`: VS Code extensions.
- `manifests/gnome-settings-selected.txt`: broad selected GNOME snapshot.
- `manifests/gnome-settings-apply.txt`: focused GNOME settings replayed by bootstrap.
- `config/codex/AGENTS.md`: global Codex note pointing densepose work at Claude's persisted project memory. On this machine, `~/.codex/AGENTS.md` should symlink here.

## Redshift and warm display setup

Redshift is deliberately treated as a manual tool:

- `config/redshift/redshift.conf`: day `1700K`, night `1000K`, manual Singapore coordinates, `randr`.
- `config/gammastep/config.ini`: day `1800K`, night `1100K`, manual Singapore coordinates, `wayland`.
- `config/autostart/redshift-gtk.desktop` and `config/autostart/gammastep-indicator.desktop` are disabled/hidden.
- `.bashrc` defines `r()`, so `r 3000` stops running Redshift/Gammastep controllers, disables GNOME Night Light, and starts a small persistent Redshift process with both day and night pinned to `3000K`; plain `r` stops controllers and resets to `6500K`.

This avoids the failure mode where `redshift-gtk`, Gammastep, GNOME Night Light, or a display gamma reset overwrites a one-shot `redshift -O 3000`.

If using Redshift/Gammastep's automatic day/night mode instead, the transition is gradual during twilight. Timing can be set without changing location by adding matching `dawn-time=HH:MM-HH:MM` and `dusk-time=HH:MM-HH:MM` entries to the config.

## Screen zoom setup

`bin/touchpad-screen-zoom` maps `Super` + touchpad two-finger scroll to GNOME's screen magnifier, so zooming targets the whole display rather than a browser page.

- Hold `Super` and two-finger scroll up/down: screen magnifier zoom in/out.
- `Alt+Super+8`: toggle magnifier.
- `Alt+Super+=` and `Alt+Super+-`: keyboard zoom fallback.
- Emergency escape: `gsettings set org.gnome.desktop.a11y.applications screen-magnifier-enabled false`.

See `docs/touchpad-screen-zoom.md` for service commands, tuning knobs, and notes about the X11 touchpad limitations found on this machine.

## Desktop alarm helper

`alarm-in` schedules a lightweight persistent alarm with user systemd:

```bash
alarm-in 25m
alarm-in 1h30m "leave for office"
alarm-stop
```

When it rings, `alarm-ring` unmutes the default PipeWire/WirePlumber audio sink, sets it to 100%, loops a non-sharp alert sound, sends a critical notification, and shows a dismiss dialog when the desktop session is available. `alarm-stop` dismisses the current alarm.

The default sound is GNOME's soft `hum.ogg` alert. Override it with `ALARM_SOUND=/path/to/sound.ogg alarm-ring`, or set `ALARM_VOLUME` / `ALARM_GAP` for one-off tuning.

## Nuances for future rebuilds

- Chrome PWAs are awkward: `.desktop` launchers can be restored, but the underlying Chrome app IDs may depend on Chrome sync/profile state. If a launcher does nothing on a new machine, recreate the app from Chrome using the URLs in `manifests/chrome-installed-web-app-urls.tsv`.
- NVIDIA/CUDA packages are hardware and kernel sensitive. Use `--hardware` only on a compatible NVIDIA machine, and be ready to follow current NVIDIA/CUDA repository instructions.
- VS Code settings include intentionally permissive AI coding settings, including Claude Code bypass permissions and terminal auto-approval. Keep them only on a trusted machine.
- CopyQ config is backed up, but clipboard history is not. That is deliberate.
- Fcitx5/Rime uses `.xinputrc` plus `config/fcitx5/profile`; log out/in after restoring input method settings.
- `.bashrc` contains project-specific Densepose paths under `/mnt/windows/Users/densepose/...`; edit those paths on a non-dual-boot or differently named machine.
- `bashrc-autopush.path` watches `~/.bashrc`; check recent runs with `journalctl --user -u bashrc-autopush.service`.
- `pulsesecure` and some VPN/vendor packages may appear in the full apt manifest but are not part of the curated default install because vendor repositories change.
- Battery charge limits often live in firmware or Windows vendor tools on dual boot machines. This repo records Ubuntu-side power settings, not firmware/Windows charge thresholds.

## Adapting to macOS or Windows

Future automation should treat this repo as a model, not an Ubuntu-only spellbook:

- Map `manifests/apt-core.txt` to Homebrew, Winget, Chocolatey, or Scoop equivalents.
- Map GNOME settings to macOS System Settings, Windows Settings, PowerToys, or vendor utilities.
- Preserve intent where implementation differs: warm display control, Meta/Super+Space input switching, CopyQ-like clipboard history, VS Code/AI tooling, Git colors readable under warm color temperatures, Chrome web apps, and project aliases.
- Keep machine-specific hardware drivers, CUDA, VPN, and dual-boot paths in optional sections.
