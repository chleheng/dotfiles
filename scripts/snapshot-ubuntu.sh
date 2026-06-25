#!/usr/bin/env bash
set -Eeuo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
manifest_dir="$repo_root/manifests"

mkdir -p \
  "$manifest_dir" \
  "$repo_root/config/Code/User" \
  "$repo_root/config/autostart" \
  "$repo_root/config/chrome-web-apps" \
  "$repo_root/config/codex" \
  "$repo_root/config/copyq" \
  "$repo_root/config/fcitx5/conf" \
  "$repo_root/config/gammastep" \
  "$repo_root/config/redshift" \
  "$repo_root/config/systemd/user" \
  "$repo_root/bin"

copy_file() {
  local src="$1"
  local dst="$2"
  local target="$repo_root/$dst"

  if [ -f "$src" ]; then
    [ -e "$target" ] && [ "$src" -ef "$target" ] && return 0
    install -D -m 0644 "$src" "$target"
  fi
}

copy_executable() {
  local src="$1"
  local dst="$2"
  local target="$repo_root/$dst"

  if [ -f "$src" ]; then
    [ -e "$target" ] && [ "$src" -ef "$target" ] && return 0
    install -D -m 0755 "$src" "$target"
  fi
}

{
  printf 'Generated: %s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
  printf 'Host: %s\n' "$(hostname)"
  printf 'Kernel: %s\n' "$(uname -a)"
  printf 'Desktop: %s\n' "${XDG_CURRENT_DESKTOP:-unknown}"
  printf 'Session: %s\n' "${DESKTOP_SESSION:-unknown}"
  printf 'Shell: %s\n' "${SHELL:-unknown}"
  printf '\n/etc/os-release\n'
  if [ -r /etc/os-release ]; then
    sed -n '1,120p' /etc/os-release
  fi
} > "$manifest_dir/system.txt"

if command -v apt-mark >/dev/null 2>&1; then
  apt-mark showmanual | sort > "$manifest_dir/apt-manual.txt"
fi

if command -v dpkg-query >/dev/null 2>&1; then
  dpkg-query -W -f='${db:Status-Abbrev}\t${binary:Package}\t${Version}\t${Architecture}\n' \
    | awk -F '\t' '$1 ~ /^ii/ {print $2 "\t" $3 "\t" $4}' \
    | sort > "$manifest_dir/apt-installed.tsv"
fi

if command -v snap >/dev/null 2>&1; then
  snap list > "$manifest_dir/snap-list.txt"
  snap list | awk 'NR > 1 {print $1}' | sort > "$manifest_dir/snap-packages.txt"
fi

if command -v flatpak >/dev/null 2>&1; then
  flatpak list --app --columns=application,origin,branch,installation,name \
    > "$manifest_dir/flatpak-apps.tsv" 2>/dev/null || : > "$manifest_dir/flatpak-apps.tsv"
fi

if command -v code >/dev/null 2>&1; then
  code --list-extensions | sort > "$manifest_dir/vscode-extensions.txt"
fi

if command -v npm >/dev/null 2>&1; then
  if command -v jq >/dev/null 2>&1; then
    npm list -g --depth=0 --json 2>/dev/null \
      | jq -r '.dependencies // {} | keys[]' \
      | sort > "$manifest_dir/npm-global-packages.txt"
  else
    npm list -g --depth=0 > "$manifest_dir/npm-global.txt" 2>/dev/null || : > "$manifest_dir/npm-global.txt"
  fi
fi

if command -v pipx >/dev/null 2>&1; then
  pipx list > "$manifest_dir/pipx-list.txt" 2>/dev/null || : > "$manifest_dir/pipx-list.txt"
fi

if command -v cargo >/dev/null 2>&1; then
  cargo install --list > "$manifest_dir/cargo-install.txt" 2>/dev/null || : > "$manifest_dir/cargo-install.txt"
fi

if command -v gnome-extensions >/dev/null 2>&1; then
  gnome-extensions list --enabled | sort > "$manifest_dir/gnome-extensions-enabled.txt" 2>/dev/null || : > "$manifest_dir/gnome-extensions-enabled.txt"
fi

{
  printf 'source\tfile\tname\texec\tcategories\n'
  find "$HOME/.local/share/applications" /usr/share/applications /var/lib/snapd/desktop/applications \
    -maxdepth 1 -type f -name '*.desktop' 2>/dev/null \
    | sort \
    | while IFS= read -r file; do
        name="$(awk -F= '/^Name=/{print substr($0, 6); exit}' "$file")"
        exec_line="$(awk -F= '/^Exec=/{print substr($0, 6); exit}' "$file")"
        categories="$(awk -F= '/^Categories=/{print substr($0, 12); exit}' "$file")"
        name="${name:-$(basename "$file" .desktop)}"
        exec_line="${exec_line:-"-"}"
        categories="${categories:-"-"}"
        case "$file" in
          "$HOME"/.local/share/applications/*) source="user" ;;
          /var/lib/snapd/*) source="snap" ;;
          *) source="system" ;;
        esac
        printf '%s\t%s\t%s\t%s\t%s\n' "$source" "$(basename "$file")" "$name" "$exec_line" "$categories"
      done
} > "$manifest_dir/desktop-apps.tsv"

{
  printf 'name\tapp_id\tprofile\tdesktop_file\texec\n'
  find "$HOME/.local/share/applications" -maxdepth 1 -type f -name 'chrome-*-Default.desktop' 2>/dev/null \
    | sort \
    | while IFS= read -r file; do
        name="$(awk -F= '/^Name=/{print substr($0, 6); exit}' "$file")"
        exec_line="$(awk -F= '/^Exec=/{print substr($0, 6); exit}' "$file")"
        app_id="$(printf '%s\n' "$exec_line" | sed -n 's/.*--app-id=\([^ ]*\).*/\1/p')"
        profile="$(printf '%s\n' "$exec_line" | sed -n 's/.*--profile-directory=\([^ ]*\).*/\1/p')"
        printf '%s\t%s\t%s\t%s\t%s\n' "$name" "$app_id" "${profile:-Default}" "$(basename "$file")" "$exec_line"
      done
} > "$manifest_dir/chrome-web-apps.tsv"

if [ -r "$HOME/.config/google-chrome/Default/Preferences" ] && command -v jq >/dev/null 2>&1; then
  jq -r '
    .web_apps.daily_metrics // {}
    | to_entries[]
    | select(.value.installed == true)
    | [.key, (.value.captures_links // false), (.value.effective_display_mode // "")]
    | @tsv
  ' "$HOME/.config/google-chrome/Default/Preferences" \
    | sort > "$manifest_dir/chrome-installed-web-app-urls.tsv"
fi

{
  for schema in \
    org.gnome.desktop.interface \
    org.gnome.desktop.a11y.applications \
    org.gnome.desktop.a11y.magnifier \
    org.gnome.desktop.input-sources \
    org.gnome.desktop.peripherals.mouse \
    org.gnome.desktop.peripherals.touchpad \
    org.gnome.desktop.session \
    org.gnome.desktop.wm.keybindings \
    org.gnome.desktop.wm.preferences \
    org.gnome.mutter \
    org.gnome.settings-daemon.plugins.color \
    org.gnome.settings-daemon.plugins.media-keys \
    org.gnome.settings-daemon.plugins.power \
    org.gnome.shell \
    org.gnome.shell.extensions.dash-to-dock \
    org.gnome.shell.extensions.tiling-assistant
  do
    gsettings list-recursively "$schema" 2>/dev/null || true
  done
} > "$manifest_dir/gnome-settings-selected.txt"

copy_file "$HOME/.bashrc" ".bashrc"
copy_file "$HOME/.profile" ".profile"
copy_file "$HOME/.xinputrc" ".xinputrc"
copy_file "$HOME/.vimrc" ".vimrc"
copy_file "$HOME/.tmux.conf" ".tmux.conf"
copy_file "$HOME/.config/redshift.conf" "config/redshift/redshift.conf"
copy_file "$HOME/.config/gammastep/config.ini" "config/gammastep/config.ini"
copy_file "$HOME/.config/autostart/copyq.desktop" "config/autostart/copyq.desktop"
copy_file "$HOME/.config/autostart/redshift-gtk.desktop" "config/autostart/redshift-gtk.desktop"
copy_file "$HOME/.config/autostart/gammastep-indicator.desktop" "config/autostart/gammastep-indicator.desktop"

copy_file "$HOME/.config/copyq/copyq.conf" "config/copyq/copyq.conf"
copy_file "$HOME/.config/copyq/copyq-commands.ini" "config/copyq/copyq-commands.ini"
copy_file "$HOME/.config/copyq/copyq_tabs.ini" "config/copyq/copyq_tabs.ini"

copy_file "$HOME/.config/fcitx5/profile" "config/fcitx5/profile"
copy_file "$HOME/.config/fcitx5/conf/notifications.conf" "config/fcitx5/conf/notifications.conf"

copy_file "$HOME/.config/Code/User/settings.json" "config/Code/User/settings.json"
copy_file "$HOME/.config/Code/User/keybindings.json" "config/Code/User/keybindings.json"
copy_file "$HOME/.config/systemd/user/touchpad-screen-zoom.service" "config/systemd/user/touchpad-screen-zoom.service"
copy_file "$HOME/.config/systemd/user/bashrc-autopush.service" "config/systemd/user/bashrc-autopush.service"
copy_file "$HOME/.config/systemd/user/bashrc-autopush.path" "config/systemd/user/bashrc-autopush.path"
copy_file "$HOME/.codex/AGENTS.md" "config/codex/AGENTS.md"
copy_file "$HOME/.codex/config.toml" "config/codex/config.toml"

find "$HOME/.local/share/applications" -maxdepth 1 -type f -name 'chrome-*-Default.desktop' 2>/dev/null \
  | while IFS= read -r file; do
      copy_file "$file" "config/chrome-web-apps/$(basename "$file")"
    done

copy_executable "$HOME/bin/claude-backup" "bin/claude-backup"
copy_executable "$HOME/.local/bin/alarm-in" "bin/alarm-in"
copy_executable "$HOME/.local/bin/alarm-ring" "bin/alarm-ring"
copy_executable "$HOME/.local/bin/alarm-stop" "bin/alarm-stop"
copy_executable "$HOME/.local/bin/claude-done-notify.sh" "bin/claude-done-notify.sh"
copy_executable "$HOME/.local/bin/codex-done-notify.sh" "bin/codex-done-notify.sh"
copy_executable "$HOME/.local/bin/touchpad-screen-zoom" "bin/touchpad-screen-zoom"
copy_executable "$HOME/.local/bin/bashrc-push" "bin/bashrc-push"

if command -v perl >/dev/null 2>&1; then
  find "$repo_root" -path "$repo_root/.git" -prune -o -type f \( \
    -name '*.md' -o \
    -name '*.txt' -o \
    -name '*.tsv' -o \
    -name '*.conf' -o \
    -name '*.ini' -o \
    -name '*.json' -o \
    -name '*.desktop' -o \
    -name '*.service' -o \
    -name '*.sh' -o \
    -name '.bashrc' -o \
    -name '.profile' -o \
    -name '.xinputrc' -o \
    -name '.gitconfig' -o \
    -name '.tmux.conf' -o \
    -name '.vimrc' -o \
    -name '.RUNME' -o \
    -path "$repo_root/config/fcitx5/*" -o \
    -path "$repo_root/bin/*" \
  \) -print0 | xargs -0 perl -0pi -e 's/\r\n/\n/g; s/[ \t]+\n/\n/g; s/\n+\z/\n/'
fi

printf 'Snapshot written to %s\n' "$repo_root"
