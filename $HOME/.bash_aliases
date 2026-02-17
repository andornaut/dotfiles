alias allstop="pkill -f 'play .*whitenoise'"
alias bc='bc -l'
alias claudeyolo='claude --dangerously-skip-permissions'
alias engage='nohup play -n -c1 -t alsa synth whitenoise lowpass -1 120 lowpass -1 120 lowpass -1 120 gain +20 >/dev/null &'
alias geminiyolo='gemini --approval-mode yolo'
alias gogstart='for r in $(gog repository list); do gog -r ${r} git start >/dev/null && gog -r ${r} apply; done'
alias google-chrome-root='sudo google-chrome --no-sandbox --no-first-run --no-default-browser-check'
alias halt=poweroff
alias koff='keylight --host keylight --off'
alias kon='keylight --host keylight --on'
alias o='xdg-open "$@"'
alias pipeclip='xclip -selection c $@'
alias scratch='code --new-window ~/scratch.md'
alias serve='echo "Serving ${PWD}" && docker run --network host --volume ${PWD}:/var/www/html:ro joshix/caddy'
alias til='code --new-window ~/src/github.com/andornaut/til'
alias todo='code --new-window ~/todo.md'
alias upgrade='sudo apt-get -y update && sudo apt-get -y dist-upgrade && sudo apt-get autoremove --purge -qq; command -v flatpak >/dev/null 2>&1 && sudo flatpak --noninteractive --system upgrade && flatpak --noninteractive --user upgrade'
alias vol='pavolume -v $@'
alias xreset='~/.config/bspwm/bspwmrc'

# Flatpak
alias cb='flatpak run --user app.getclipboard.Clipboard'
alias gimp='flatpak run --user org.gimp.GIMP'
alias flameshot='flatpak run --user org.flameshot.Flameshot'
alias steam='flatpak run com.valvesoftware.Steam'
alias vlc='flatpak run --user org.videolan.VLC'

# Wayland
alias code='code --ozone-platform-hint=auto'
alias cursor='cursor --ozone-platform-hint=auto'

# tmux
alias si=tmuxirssi
alias sr=tmuxrtorrent

# TODO
# Sometimes you want a program, like tmux, dtach or similar, to persist when the parent process exits.
# To do this, run it in a transient systemd scope:
# systemd-run --user --scope tmux new-session
alias t='tmux attach || tmuxdefault'
alias tmuxdefault='tmux new-session -As default -n main -c ~/'
alias tmuxirssi='tmux new-session -As irssi -n irssi -c ~/ irssi'
alias tmuxrtorrent='tmux new-session -As rtorrent -n rtorrent -c ~/ rtorrent'
