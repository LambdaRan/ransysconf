#!/bin/sh

# set -e
DEST=${DEST:-~/emacs/emacs-lambda}

source $RSCF/apps/utils.sh

setup_emacs() {
    ohai "Cloning my emacs configuration files..."
	# Prevent the cloned repository from having insecure permissions. Failing to do
	# so causes compinit() calls to fail with "command not found: compdef" errors
	# for users with insecure umasks (e.g., "002", allowing group writability). Note
	# that this will be ignored under Cygwin by default, as Windows ACLs take
	# precedence over umasks except for filesystems mounted with option "noacl".
	umask g-w,o-w

	command_exists git || {
		abort "${tty_red}git is not installed${tty_reset}"
	}

    execute "cd" "$HOME"

	git clone -c core.eol=lf -c core.autocrlf=false \
		-c fsck.zeroPaddedFilemode=ignore \
		-c fetch.fsck.zeroPaddedFilemode=ignore \
		-c receive.fsck.zeroPaddedFilemode=ignore \
		--depth=1 --branch master https://github.com/LambdaRan/emacs-lambda.git "$DEST"|| {
		abort "${tty_red}git clone of emacs-lambda repo failed${tty_reset}"
	}
    execute "cd" "$DEST"
    execute "git" "submodule" "update" "--depth" "1" "--init" "--recursive"
    execute "git" "submodule" "foreach" "git" "reset" "--hard"
    execute "git" "submodule" "foreach" "git" "checkout" "master"

    # 处理配置文件
    setup_emacs_conf

    echo
}

setup_emacs_conf() {
	ohai "Looking for an existing .emacs config..."
    DOT_EMACS="$HOME/.emacs"
    OLD_DOT_EMACS="$HOME/.emacs-pre-emacs-lambda"
    if [ -e "${DOT_EMACS}" ];then
		echo "${tty_yellow}Found ~/.emacs.${tty_reset} ${tty_red}Backing up to ${OLD_DOT_EMACS}${tty_reset}"
        execute "mv" "$DOT_EMACS" "${OLD_DOT_EMACS}"
    fi
	echo "${tty_green}Using the ${DEST}/site-start.el Config template file and adding it to ${DOT_EMACS}.${tty_reset}"
    execute "cp" "${DEST}/site-start.el" "${DOT_EMACS}"

	echo
}

# setup_color
# setup_emacs_conf
# setup_emacs