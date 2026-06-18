#!/usr/bin/env bash
set -Eeuo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
backup_root="${DOTFILES_BACKUP_DIR:-$HOME/.dotfiles-backup/$(date '+%Y%m%d-%H%M%S')}"

all_apt_manual=false
hardware=false
skip_packages=false
skip_config=false
skip_gnome=false
dry_run=false

usage() {
  cat <<'USAGE'
Usage: scripts/bootstrap-ubuntu.sh [options]

Options:
  --all-apt-manual  Try to install every package from manifests/apt-manual.txt.
  --hardware        Also try NVIDIA/CUDA packages from manifests/apt-hardware-nvidia-cuda.txt.
  --skip-packages   Only restore files/settings.
  --skip-config     Only install packages/settings.
  --skip-gnome      Do not apply GNOME gsettings.
  --dry-run         Print actions without changing the system.
  -h, --help        Show this help.

Default behavior installs the curated Ubuntu app list, restores portable
dotfiles/configs with backups, installs VS Code extensions/npm globals, and
applies selected GNOME settings.
USAGE
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --all-apt-manual) all_apt_manual=true ;;
    --hardware) hardware=true ;;
    --skip-packages) skip_packages=true ;;
    --skip-config) skip_config=true ;;
    --skip-gnome) skip_gnome=true ;;
    --dry-run) dry_run=true ;;
    -h|--help) usage; exit 0 ;;
    *) printf 'Unknown option: %s\n\n' "$1" >&2; usage; exit 2 ;;
  esac
  shift
done

run() {
  if $dry_run; then
    printf '+'
    printf ' %q' "$@"
    printf '\n'
  else
    "$@"
  fi
}

sudo_run() {
  if [ "$(id -u)" -eq 0 ]; then
    run "$@"
  else
    run sudo "$@"
  fi
}

read_list() {
  local file="$1"
  [ -f "$file" ] || return 0
  sed -e 's/#.*//' -e '/^[[:space:]]*$/d' "$file"
}

backup_path() {
  local dst="$1"
  local rel

  [ -e "$dst" ] || return 0
  rel="${dst#$HOME/}"
  mkdir -p "$backup_root/$(dirname "$rel")"
  if [ -d "$dst" ] && [ ! -L "$dst" ]; then
    cp -a "$dst" "$backup_root/$rel"
  else
    cp -a "$dst" "$backup_root/$rel"
  fi
}

install_file() {
  local src="$1"
  local dst="$2"
  local mode="${3:-0644}"

  [ -f "$src" ] || return 0
  if [ -f "$dst" ] && cmp -s "$src" "$dst"; then
    return 0
  fi

  if $dry_run; then
    printf '+ install -D -m %s %q %q\n' "$mode" "$src" "$dst"
    return 0
  fi

  backup_path "$dst"
  install -D -m "$mode" "$src" "$dst"
}

install_apt_packages() {
  local list_file="$1"
  mapfile -t packages < <(read_list "$list_file")

  [ "${#packages[@]}" -gt 0 ] || return 0
  sudo_run apt-get update
  if sudo_run apt-get install -y "${packages[@]}"; then
    return 0
  fi

  printf 'Batch apt install had failures; retrying package by package.\n' >&2
  for package in "${packages[@]}"; do
    sudo_run apt-get install -y "$package" || printf 'Skipped unavailable apt package: %s\n' "$package" >&2
  done
}

install_google_chrome() {
  command -v google-chrome >/dev/null 2>&1 && return 0
  command -v google-chrome-stable >/dev/null 2>&1 && return 0

  local deb="/tmp/google-chrome-stable_current_amd64.deb"
  command -v wget >/dev/null 2>&1 || {
    sudo_run apt-get update
    sudo_run apt-get install -y wget ca-certificates
  }
  run wget -O "$deb" https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  sudo_run apt-get install -y "$deb"
}

install_vscode() {
  command -v code >/dev/null 2>&1 && return 0

  local deb="/tmp/vscode-stable_amd64.deb"
  command -v wget >/dev/null 2>&1 || {
    sudo_run apt-get update
    sudo_run apt-get install -y wget ca-certificates
  }
  run wget -O "$deb" https://update.code.visualstudio.com/latest/linux-deb-x64/stable
  sudo_run apt-get install -y "$deb"
}

install_snap_apps() {
  local list_file="$1"
  [ -f "$list_file" ] || return 0
  command -v snap >/dev/null 2>&1 || sudo_run apt-get install -y snapd

  while IFS= read -r package; do
    snap list "$package" >/dev/null 2>&1 && continue
    sudo_run snap install "$package" || printf 'Skipped unavailable snap: %s\n' "$package" >&2
  done < <(read_list "$list_file")
}

install_flatpak_apps() {
  local list_file="$1"
  [ -s "$list_file" ] || return 0
  command -v flatpak >/dev/null 2>&1 || sudo_run apt-get install -y flatpak

  while IFS=$'\t' read -r app origin branch installation name; do
    [ -n "${app:-}" ] || continue
    flatpak info "$app" >/dev/null 2>&1 && continue
    run flatpak install -y "${origin:-flathub}" "$app" || printf 'Skipped flatpak app: %s\n' "$app" >&2
  done < "$list_file"
}

install_vscode_extensions() {
  local list_file="$1"
  [ -f "$list_file" ] || return 0
  command -v code >/dev/null 2>&1 || return 0

  while IFS= read -r extension; do
    [ -n "$extension" ] || continue
    run code --install-extension "$extension" --force || printf 'Skipped VS Code extension: %s\n' "$extension" >&2
  done < "$list_file"
}

install_npm_globals() {
  local list_file="$1"
  [ -f "$list_file" ] || return 0
  command -v npm >/dev/null 2>&1 || return 0

  while IFS= read -r package; do
    [ -n "$package" ] || continue
    run npm install -g "$package" || printf 'Skipped npm package: %s\n' "$package" >&2
  done < "$list_file"
}

enable_user_service() {
  local service="$1"

  command -v systemctl >/dev/null 2>&1 || return 0
  [ -f "$HOME/.config/systemd/user/$service" ] || return 0
  systemctl --user show-environment >/dev/null 2>&1 || return 0

  run systemctl --user daemon-reload || true
  run systemctl --user import-environment DISPLAY XAUTHORITY DBUS_SESSION_BUS_ADDRESS XDG_RUNTIME_DIR || true
  run systemctl --user enable "$service" || true

  if [ -n "${DISPLAY:-}" ]; then
    run systemctl --user restart "$service" || true
  fi
}

install_configs() {
  install_file "$repo_root/.bashrc" "$HOME/.bashrc"
  install_file "$repo_root/.profile" "$HOME/.profile"
  install_file "$repo_root/.xinputrc" "$HOME/.xinputrc"
  install_file "$repo_root/.gitconfig" "$HOME/.gitconfig"
  install_file "$repo_root/.vimrc" "$HOME/.vimrc"
  install_file "$repo_root/.tmux.conf" "$HOME/.tmux.conf"

  install_file "$repo_root/config/redshift/redshift.conf" "$HOME/.config/redshift.conf"
  install_file "$repo_root/config/gammastep/config.ini" "$HOME/.config/gammastep/config.ini"
  install_file "$repo_root/config/autostart/copyq.desktop" "$HOME/.config/autostart/copyq.desktop"
  install_file "$repo_root/config/autostart/redshift-gtk.desktop" "$HOME/.config/autostart/redshift-gtk.desktop"
  install_file "$repo_root/config/autostart/gammastep-indicator.desktop" "$HOME/.config/autostart/gammastep-indicator.desktop"

  install_file "$repo_root/config/copyq/copyq.conf" "$HOME/.config/copyq/copyq.conf"
  install_file "$repo_root/config/copyq/copyq-commands.ini" "$HOME/.config/copyq/copyq-commands.ini"
  install_file "$repo_root/config/copyq/copyq_tabs.ini" "$HOME/.config/copyq/copyq_tabs.ini"

  install_file "$repo_root/config/fcitx5/profile" "$HOME/.config/fcitx5/profile"
  install_file "$repo_root/config/fcitx5/conf/notifications.conf" "$HOME/.config/fcitx5/conf/notifications.conf"

  install_file "$repo_root/config/Code/User/settings.json" "$HOME/.config/Code/User/settings.json"
  install_file "$repo_root/config/Code/User/keybindings.json" "$HOME/.config/Code/User/keybindings.json"
  install_file "$repo_root/config/systemd/user/touchpad-screen-zoom.service" "$HOME/.config/systemd/user/touchpad-screen-zoom.service"
  install_file "$repo_root/config/codex/AGENTS.md" "$HOME/.codex/AGENTS.md"
  install_file "$repo_root/config/codex/config.toml" "$HOME/.codex/config.toml"

  find "$repo_root/config/chrome-web-apps" -maxdepth 1 -type f -name '*.desktop' 2>/dev/null \
    | while IFS= read -r file; do
        install_file "$file" "$HOME/.local/share/applications/$(basename "$file")"
      done

  install_file "$repo_root/bin/claude-backup" "$HOME/bin/claude-backup" 0755
  install_file "$repo_root/bin/alarm-in" "$HOME/.local/bin/alarm-in" 0755
  install_file "$repo_root/bin/alarm-ring" "$HOME/.local/bin/alarm-ring" 0755
  install_file "$repo_root/bin/alarm-stop" "$HOME/.local/bin/alarm-stop" 0755
  install_file "$repo_root/bin/claude-done-notify.sh" "$HOME/.local/bin/claude-done-notify.sh" 0755
  install_file "$repo_root/bin/codex-done-notify.sh" "$HOME/.local/bin/codex-done-notify.sh" 0755
  install_file "$repo_root/bin/touchpad-screen-zoom" "$HOME/.local/bin/touchpad-screen-zoom" 0755
  enable_user_service touchpad-screen-zoom.service

  if command -v im-config >/dev/null 2>&1; then
    run im-config -n fcitx5 || true
  fi

  if command -v update-desktop-database >/dev/null 2>&1; then
    run update-desktop-database "$HOME/.local/share/applications" || true
  fi
}

apply_gsettings() {
  local file="$repo_root/manifests/gnome-settings-apply.txt"
  [ -f "$file" ] || return 0
  command -v gsettings >/dev/null 2>&1 || return 0

  while IFS= read -r line; do
    case "$line" in
      ''|\#*) continue ;;
    esac

    schema="${line%% *}"
    rest="${line#* }"
    key="${rest%% *}"
    value="${rest#* }"

    if [ "$(gsettings writable "$schema" "$key" 2>/dev/null || printf false)" = true ]; then
      run gsettings set "$schema" "$key" "$value" || true
    fi
  done < "$file"
}

if ! $skip_packages; then
  install_google_chrome
  install_vscode
  install_apt_packages "$repo_root/manifests/apt-core.txt"

  if $all_apt_manual; then
    install_apt_packages "$repo_root/manifests/apt-manual.txt"
  fi

  if $hardware; then
    install_apt_packages "$repo_root/manifests/apt-hardware-nvidia-cuda.txt"
  fi

  install_snap_apps "$repo_root/manifests/snap-apps.txt"
  install_flatpak_apps "$repo_root/manifests/flatpak-apps.tsv"
  install_vscode_extensions "$repo_root/manifests/vscode-extensions.txt"
  install_npm_globals "$repo_root/manifests/npm-global-packages.txt"
fi

if ! $skip_config; then
  install_configs
fi

if ! $skip_gnome; then
  apply_gsettings
fi

printf 'Done. Backups, if any, are in %s\n' "$backup_root"
