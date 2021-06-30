#!/bin/env sh

set -e

source $RSCF/apps/utils.sh
# 安装git
source $RSCF/apps/git_configure.sh
# 安装brew
source $RSCF/apps/brew_install.sh
# 安装hammerspoon
source $RSCF/apps/hammerspoon_install.sh
# 安装emacs
source $RSCF/apps/emacs_install.sh

setup_ssh() {
	ohai "Setup ssh config..."
    SSH_CONF="$HOME/.ssh/config"
    if [ -e "${SSH_CONF}" ];then
		echo "${tty_yellow}Found ~/.ssh/config.${tty_reset} ${tty_red}Backing up to ${SSH_CONF}-pre-ran-ssh${tty_reset}"
        execute "mv" "$SSH_CONF" "${SSH_CONF}-pre-ran-ssh"
    fi
	echo "${tty_green}Using the ${RSCF}/templates/ssh_config Config template file and adding it to ${SSH_CONF}.${tty_reset}"
    execute "cp" "${RSCF}/templates/ssh_config" "${SSH_CONF}"

	echo
}

setup_color
setup_git
setup_ssh
if [[ -n "${ON_MACOS-}" ]]; then
    setup_brew
    setup_hammerspoon
fi
setup_emacs
