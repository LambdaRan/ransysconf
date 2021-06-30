#!/bin/sh

# https://github.com/miguelgfierro/scripts

#
# This script configure some global options in git like aliases, credential helper,
# user name and email. Tested in Ubuntu and Mac.
#
# Method of use:
# source git_configure.sh
#

# set -e

source $RSCF/apps/utils.sh
# setup_color


setup_git() {
    echo
    ohai "Configuring git..."
    echo "${tty_green}Write your git username${tty_reset}"
    read USER
    DEFAULT_EMAIL="$USER@users.noreply.github.com"
    read -p "${tty_green}Write your git email [Press enter to accept the private email $DEFAULT_EMAIL]:${tty_reset} " EMAIL
    EMAIL="${EMAIL:-${DEFAULT_EMAIL}}"

    echo "Configuring global user name and email..."
    git config --global user.name "$USER"
    git config --global user.email "$EMAIL"

    # set gpush
    git config --global alias.gpush '!f() { : push ; r=$1; [[ -z $r ]] && r=origin; b=$2; t=$(awk "{ print \$2 }" $(git rev-parse --git-dir)/HEAD); t=${t#refs/heads/}; [[ -z $b ]] && b=$t; cmd="git push $r HEAD:refs/for/$b"; echo $cmd; echo; $cmd; }; f'

    # set color
    git config --global color.ui auto

    echo "Configuring global aliases..."
    git config --global alias.ci commit
    git config --global alias.st status
    git config --global alias.co checkout
    git config --global alias.br branch
    git config --global alias.sub "submodule update --remote --merge"
    git config --global core.editor "vim"
    git config --global credential.helper 'cache --timeout=36000'
    # set log alias
    git config --global alias.lg 'log --stat'
    # git config --global alias.lgp 'log --stat -p'
    # git config --global alias.lgg 'log --graph'
    # git config --global alias.lgga 'log --graph --decorate --all'
    # git config --global alias.lgm 'log --graph --max-count=10'
    # git config --global alias.lo 'log --oneline --decorate'
    # git config --global alias.lol "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
    # git config --global alias.lola "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --all"
    # git config --global alias.log 'log --oneline --decorate --graph'
    # git config --global alias.loga 'log --oneline --decorate --graph --all'

    read -r -p "${tty_red}Do you want to add ssh credentials for git? [y/n]${tty_reset} " RESP
    RESP=${RESP:n}    # tolower (only works with /bin/bash)
    if [[ $RESP =~ ^(yes|y)$ ]];then
        echo "Configuring git ssh access..."
        ssh-keygen -t rsa -b 4096 -C "$EMAIL"
        echo
        read -r -p "${tty_yellow}public key name (id_rsa): ${tty_reset}" RESP
        RESP=${RESP:id_rsa}
        echo "${tty_green}This is your public key. To activate it in github, got to settings, SHH and GPG keys, New SSH key, and enter the following key:${tty_reset}"
        echo
        cat ~/.ssh/${RESP}.pub
        echo ""
        echo "To work with the ssh key, you have to clone all your repos with ssh instead of https."
        echo "For example, for this repo you will have to use the url: git@github.com:miguelgfierro/scripts.git"
    fi

    # 设置git自动补全
    echo "Set git completion: ${tty_underline} https://github.com/git/git/tree/master/contrib/completion ${tty_reset}"
    echo
}

# setup_color
# setup_git