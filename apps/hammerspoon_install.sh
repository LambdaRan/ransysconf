#!/bin/sh

# set -e
source $RSCF/apps/utils.sh

setup_hammerspoon() {
    ohai "Cloning hammerspoon configuration files..."
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
    DEST_HAMMER="$HOME/.hammerspoon"
    if [ -e "$DEST_HAMMER" ];then
        echo "${tty_yellow}Found ~/.hammerspoon. ${tty_reset} ${tty_red}Backing up to ${DEST_HAMMER}-pre-ran-hammerspoon ${tty_reset}"
        execute "mv" "${DEST_HAMMER}" "${DEST_HAMMER}-pre-ran-hammerspoon"
    fi
	git clone -c core.eol=lf -c core.autocrlf=false \
		-c fsck.zeroPaddedFilemode=ignore \
		-c fetch.fsck.zeroPaddedFilemode=ignore \
		-c receive.fsck.zeroPaddedFilemode=ignore \
		--depth=1 --branch master https://github.com/LambdaRan/hammerspoon.git "${DEST_HAMMER}" || {
		abort "${tty_red}git clone of hammerspoon repo failed${tty_reset}"
	}

    echo
}

# setup_color
# setup_hammerspoon
