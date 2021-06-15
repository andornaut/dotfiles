# dotfiles

Personal dotfiles

![ibm-dark-theme](https://github.com/andornaut/ibm1970-desktop-theme/blob/main/screenshot.png)

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

## Links

* [ansible-workstation](https://github.com/andornaut/ansible-workstation)
* [bbs](https://github.com/andornaut/bbs)
* [gog](https://github.com/andornaut/gog)
