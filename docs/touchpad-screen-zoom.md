# Touchpad Screen Zoom

This machine uses GNOME's built-in screen magnifier for zooming into part of the screen, instead of browser or app page zoom.

The helper at `bin/touchpad-screen-zoom` listens to XInput touchpad scroll events and sends GNOME's magnifier shortcuts with `xdotool`. It is installed as a user systemd service:

```bash
systemctl --user status touchpad-screen-zoom.service
systemctl --user start touchpad-screen-zoom.service
systemctl --user stop touchpad-screen-zoom.service
```

Touchpad behavior:

- Hold `Super` and two-finger scroll up/right: screen magnifier zoom in.
- Hold `Super` and two-finger scroll down/left: screen magnifier zoom out.
- Plain two-finger scrolling is left alone.
- If this does not trigger on the current X11 session, use the keyboard fallback below; the touchpad stack has been observed to expose pinch inconsistently.

Keyboard and no-touchpad fallback:

- `Alt+Super+8`: toggle GNOME screen magnifier.
- `Alt+Super+=`: zoom in.
- `Alt+Super+-`: zoom out.
- GNOME Settings -> Accessibility -> Zoom also controls this feature.

Emergency escape if the display is stuck magnified:

```bash
gsettings set org.gnome.desktop.a11y.applications screen-magnifier-enabled false
systemctl --user stop touchpad-screen-zoom.service
```

The helper writes a small diagnostic log to `~/.cache/touchpad-screen-zoom.log`.

Tuning knobs:

- `TOUCHPAD_ZOOM_DEVICE`: exact XInput touchpad name. Defaults to `ELAN0685:00 04F3:320B Touchpad`, then falls back to the first XInput device containing `Touchpad`.
- `TOUCHPAD_ZOOM_KEYBOARD`: XInput keyboard checked for the `Super` key. Defaults to `AT Translated Set 2 keyboard`.
- `TOUCHPAD_ZOOM_MODIFIER_MASK`: required X11 modifier mask. Defaults to `0x40`, the `Super`/Mod4 mask on this machine.
- `TOUCHPAD_ZOOM_COOLDOWN`: minimum seconds between zoom steps. Defaults to `0.12`.

Notes:

- This was set up on Ubuntu 24.04 GNOME, X11 session, ThinkPad P16 Gen 2.
- True pinch-to-zoom was attempted first, but this session exposes touchpad pinch as ordinary scroll/motion rather than `GesturePinch*` events or two independent raw touch points.
- A raw evdev parser and direct `libinput debug-events` probe were both tried. Raw evdev showed touchpad motion, but only one coordinate point during the tested gesture, so reliable pinch-distance detection was not available.
- The approach depends on `xinput`, `xdotool`, `gsettings`, and user systemd.
- The magnifier is intentionally restored as disabled by default; the first zoom-in gesture enables it at 2x.
