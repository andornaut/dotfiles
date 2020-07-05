alias apt-upgrade="sudo apt-get -y update && sudo apt-get -y dist-upgrade"
alias allstop="pkill -f 'play .*whitenoise'"
alias bc="bc -l"
alias engage="nohup play -n -c1 -t alsa synth whitenoise lowpass -1 120 lowpass -1 120 lowpass -1 120 gain +20 >/dev/null &"
alias ffandornaut="FIREFOX_DEFAULT_PROFILE=andornaut ff"
alias ffpoints="FIREFOX_DEFAULT_PROFILE=points ff"
alias gitcurrentbranch="git rev-parse --abbrev-ref HEAD"
alias gitresethistory='git status && d=$(mktemp) && mv .git/config ${d} && rm -rf .git/ && git init && mv ${d} .git/config && git add . && git commit -m "Initial import" && git status && git push --force'
alias gogapplyall='for r in $(gog repository list); do gog -r ${r} git pull && gog -r ${r} apply; done'
alias halt="sudo halt -p"
alias lsm="ls -al|awk '{k=0;s=0;for(i=0;i<=8;i++){;k+=((substr(\$1,i+2,1)~/[rwxst]/)*2^(8-i));};j=4;for(i=4;i<=10;i+=3){;s+=((substr(\$1,i,1)~/[stST]/)*j);j/=2;};if(k){;printf(\"%0o%0o \",s,k);};print;}'"
alias pipenvdeactivate='[[ "${PIPENV_ACTIVE}" -ne 1 ]] && echo "pipenv is not active" || { echo "pipenv is active. Exiting shell..." >&2 ; exit ; }'
alias r='ranger'
alias reboot="sudo reboot"
alias resetx="${HOME}/.config/bspwm/bspwmrc"
alias serve='echo "Serving ${PWD}" && docker run --network host --volume ${PWD}:/var/www/html:ro joshix/caddy'
alias si="screen -d -R irssi irssi"
alias sr="screen -d -R rtorrent rtorrent"
alias vol="pavolume -v $@"
