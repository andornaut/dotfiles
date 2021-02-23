alias allstop="pkill -f 'play .*whitenoise'"
alias apt-upgrade="sudo apt-get -y update && sudo apt-get -y dist-upgrade"
alias bc="bc -l"
alias engage="nohup play -n -c1 -t alsa synth whitenoise lowpass -1 120 lowpass -1 120 lowpass -1 120 gain +20 >/dev/null &"
alias ff="FIREFOX_DEFAULT_PROFILE=andornaut ff"
alias gitcurrentbranch="git rev-parse --abbrev-ref HEAD"
alias gitresethistory='git status && d=$(mktemp) && mv .git/config ${d} && rm -rf .git/ && git init && mv ${d} .git/config && git add . && git commit -m "Initial import" && git status && git push --force'
alias gogapplyall='for r in $(gog repository list); do gog -r ${r} git pull && gog -r ${r} apply; done'
alias halt="sudo halt -p"
alias koff="keylight --host keylight --off"
alias kon="keylight --host keylight --on"
alias pipenvdeactivate='[[ "${PIPENV_ACTIVE}" -ne 1 ]] && echo "pipenv is not active" || { echo "pipenv is active. Exiting shell..." >&2 ; exit ; }'
alias reboot="sudo reboot"
alias resetx="${HOME}/.config/bspwm/bspwmrc"
alias scratch="code --new-window ${HOME}/scratch.md"
alias serve='echo "Serving ${PWD}" && docker run --network host --volume ${PWD}:/var/www/html:ro joshix/caddy'
alias si="screen -d -R irssi irssi"
alias sr="screen -d -R rtorrent rtorrent"
alias til="code --new-window ${HOME}/src/github.com/andornaut/til"
alias vol="pavolume -v $@"
