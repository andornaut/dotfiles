alias allstop="pkill -f 'play .*whitenoise'"
alias apt-upgrade='sudo apt-get -y update && sudo apt-get -y dist-upgrade'
alias bc='bc -l'
alias engage='nohup play -n -c1 -t alsa synth whitenoise lowpass -1 120 lowpass -1 120 lowpass -1 120 gain +20 >/dev/null &'
alias ff='FIREFOX_DEFAULT_PROFILE=andornaut ff'
alias gogstart='for r in $(gog repository list); do gog -r ${r} git start >/dev/null && gog -r ${r} apply; done'
alias halt='sudo halt -p'
alias koff='keylight --host keylight --off'
alias kon='keylight --host keylight --on'
alias pipenvdeactivate='[[ "${PIPENV_ACTIVE}" -ne 1 ]] && echo "pipenv is not active" || { echo "pipenv is active. Exiting shell..." >&2 ; exit ; }'
alias reboot='sudo reboot'
alias resetx='~/.config/bspwm/bspwmrc'
alias scratch='code --new-window ~/scratch.md'
alias serve='echo "Serving ${PWD}" && docker run --network host --volume ${PWD}:/var/www/html:ro joshix/caddy'
alias til='code --new-window ~/src/github.com/andornaut/til'
alias t='tmux attach || tmuxdefault'
alias tmuxdefault='tmux new-session -As default -n main -c ~/'
alias tmuxrtorrent='tmux new-session -As rtorrent -n rtorrent rtorrent -c ~/'
alias todo='code --new-window ~/todo.md'
alias vol="pavolume -v $@"
