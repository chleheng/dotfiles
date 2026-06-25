# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;38;5;230m\]\u@\h\[\033[00m\]:\[\033[01;04;38;5;220m\]\w\[\033[00m\]\[\033[38;5;214m\]\$ \[\033[00m\]'
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto --group-directories-first'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Warm-display terminal colors. Avoid dark blues/cyans that collapse under
# Redshift/Gammastep at 1700K-1000K.
export GREP_COLORS='ms=01;38;5;220:mc=01;38;5;220:fn=38;5;222:ln=38;5;180:bn=38;5;180:se=38;5;240'
export GCC_COLORS='error=01;38;5;203:warning=01;38;5;220:note=01;38;5;223:caret=01;38;5;214:locus=38;5;180:quote=01;38;5;229'
export LESS_TERMCAP_mb=$'\e[01;38;5;220m'
export LESS_TERMCAP_md=$'\e[01;38;5;220m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[30;48;5;220m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[01;04;38;5;229m'

warm-colors() {
  local reset=$'\033[0m'
  printf '%b%-12s%b %s\n' $'\033[01;38;5;220m' directory "$reset" 'bold gold'
  printf '%b%-12s%b %s\n' $'\033[01;04;38;5;229m' symlink "$reset" 'underlined ivory'
  printf '%b%-12s%b %s\n' $'\033[01;38;5;214m' executable "$reset" 'orange'
  printf '%b%-12s%b %s\n' $'\033[01;38;5;203m' archive "$reset" 'coral'
  printf '%b%-12s%b %s\n' $'\033[38;5;217m' media "$reset" 'pale peach'
  printf '%b%-12s%b %s\n' $'\033[30;48;5;220m' selected "$reset" 'black on gold'
}

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
if [ -d /usr/local/cuda-13.0/bin ]; then
  export PATH="/usr/local/cuda-13.0/bin:$PATH"
fi
if [ -d /usr/local/cuda-13.0/lib64 ]; then
  export LD_LIBRARY_PATH="/usr/local/cuda-13.0/lib64${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
fi

# Densepose project
DENSEPOSE=/mnt/windows/Users/densepose/Documents/densepose/rpi_wifi_stream
export QT_QPA_PLATFORM_PLUGIN_PATH=/home/q1/rpi_venv/lib/python3.12/site-packages/PyQt5/Qt5/plugins/platforms
alias rpi='cd "$DENSEPOSE" && source ~/venvs/rpi_wifi_stream/bin/activate'
alias calibrate='cd "$DENSEPOSE" && source ~/venvs/rpi_wifi_stream/bin/activate && python calibration/main_5ghz.py'
codex() {
  command codex --dangerously-bypass-approvals-and-sandbox "$@"
}
bashrc-push() {
  local helper="$HOME/.local/bin/bashrc-push"

  if [ ! -x "$helper" ]; then
    echo "bashrc-push helper not found: $helper" >&2
    return 1
  fi

  "$helper" "$@"
}
_stop_color_temperature_controllers() {
  local wrapper_pids

  if command -v systemctl >/dev/null 2>&1; then
    systemctl --user stop gammastep.service gammastep-indicator.service 2>/dev/null || true
  fi

  pkill -x redshift 2>/dev/null || true
  pkill -x gammastep 2>/dev/null || true
  wrapper_pids="$(pgrep -f '[r]edshift-gtk|[g]ammastep-indicator' 2>/dev/null)" && kill $wrapper_pids 2>/dev/null || true
}
r() {
  local temp="${1:-6500}"
  local tool method log_file pid

  if ! [[ "$temp" =~ ^[0-9]+$ ]]; then
    echo "Usage: r [temperature-kelvin]" >&2
    return 2
  fi

  _stop_color_temperature_controllers
  gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled false 2>/dev/null || true

  if [ "$temp" = "6500" ]; then
    redshift -x 2>/dev/null || true
    gammastep -x 2>/dev/null || true
    return 0
  fi

  if [ "${XDG_SESSION_TYPE:-}" = "wayland" ] && command -v gammastep >/dev/null 2>&1; then
    tool=gammastep
    method=wayland
  elif command -v redshift >/dev/null 2>&1; then
    tool=redshift
    method=randr
  elif command -v gammastep >/dev/null 2>&1; then
    tool=gammastep
    method=randr
  else
    echo "redshift/gammastep not found" >&2
    return 127
  fi

  log_file="${XDG_RUNTIME_DIR:-/tmp}/redshift-manual.log"
  nohup "$tool" -P -r -m "$method" -l 1.35:103.82 -t "$temp:$temp" >"$log_file" 2>&1 &
  pid=$!
  disown "$pid" 2>/dev/null || true
}
alias open='xdg-open'
if [ -d "$DENSEPOSE" ]; then
  cd "$DENSEPOSE"
fi
export PATH="$HOME/.local/bin:$PATH"
source ~/venvs/rpi_wifi_stream/bin/activate
source /mnt/windows/Users/densepose/Documents/densepose/rpi_wifi_stream/aliases.sh
