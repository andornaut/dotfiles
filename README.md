# dotfiles

Personal dotfiles

![screenshot](https://i.imgur.com/xE0KAg8.png)

## Installation

1. Install [gog](https://github.com/andornaut/gog)
1. Run the following in a terminal:

```bash
gog repository add andornaut https://github.com/andornaut/dotfiles.git
gog apply

cat <<'EOF' >> ~/.bashrc
if [[ $- == *i* ]]; then
  # Only source additional customizations if the shell is interactive
  for f in ${HOME}/.bashrc.*; do
    source ${f}
  done
fi
EOF

```

## Colour Theme

Colour|Applications
---|---
#ee66bb|bbs, bspwm
#33a999|bbs, bspwm
#44244f|Xresources
#2e2255|rofi, Xresources
#586e75|Xresources
#668880|rofi, Xresources
#839496|rofi, Xresources
#550066|bbs, dunst, rofi
#f60099|dunst
#d40088|dunst, rofi
#44f0f0|bbs, dunst, rofi

## Links

* [ansible-workstation](https://github.com/andornaut/ansible-workstation)
* [bbs](https://github.com/andornaut/bbs)
* [gog](https://github.com/andornaut/gog)
