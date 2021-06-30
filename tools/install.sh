#!/bin/sh

# https://github.com/ohmyzsh/ohmyzsh

#
# This script should be run via curl:
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/LambdaRan/ransysconf/master/tools/install.sh)"
# or wget:
#   sh -c "$(wget -qO- https://raw.githubusercontent.com/LambdaRan/ransysconf/master/tools/install.sh)"
#
# As an alternative, you can first download the install script and run it afterwards:
#   wget https://raw.githubusercontent.com/LambdaRan/ransysconf/master/tools/install.sh
#   sh install.sh
#
# You can tweak the install behavior by setting variables when running the script. For
# example, to change the path to the Oh My Zsh repository:
#   ZSH=~/.zsh sh install.sh
#
# Respects the following environment variables:
#   ZSH     - path to the Oh My Zsh repository folder (default: $HOME/ransysconf)
#   REPO    - name of the GitHub repo to install from (default: LambdaRan/ransysconf)
#   REMOTE  - full remote URL of the git repo to install (default: GitHub via HTTPS)
#   BRANCH  - branch to check out immediately after install (default: master)
#
# Other options:
#   CHSH       - 'no' means the installer will not change the default shell (default: yes)
#   RUNZSH     - 'no' means the installer will not run zsh after the install (default: yes)
#   KEEP_ZSHRC - 'yes' means the installer will not replace an existing .zshrc (default: no)
#
# You can also pass some arguments to the install script to set some these options:
#   --skip-chsh: has the same behavior as setting CHSH to 'no'
#   --unattended: sets both CHSH and RUNZSH to 'no'
#   --keep-zshrc: sets KEEP_ZSHRC to 'yes'
# For example:
#   sh install.sh --unattended
#
set -e

# Default settings
RSCF=${RSCF:-~/ransysconf}
REPO=${REPO:-LambdaRan/ransysconf}
REMOTE=${REMOTE:-https://github.com/${REPO}.git}
BRANCH=${BRANCH:-master}

# Options
CHSH=${CHSH:-yes}
RUNZSH=${RUNZSH:-yes}
KEEP_ZSHRC=${KEEP_ZSHRC:-no}

# First check if the OS is Linux.
if [[ "$(uname)" = "Darwin" ]]; then
  ON_MACOS=1
fi

case "$SHELL" in
    */bash*)
        shell_conf="$HOME/.bashrc"
        ;;
    */zsh*)
        shell_conf="$HOME/.zshrc"
        ;;
    *)
        shell_conf="$HOME/.bashrc"
        ;;
esac

command_exists() {
	command -v "$@" >/dev/null 2>&1
}

shell_join() {
  local arg
  printf "%s" "$1"
  shift
  for arg in "$@"; do
    printf " "
    printf "%s" "${arg// /\ }"
  done
}

chomp() {
  printf "%s" "${1/"$'\n'"/}"
}

ohai() {
  printf "${tty_blue}==>${tty_bold} %s${tty_reset}\n" "$(shell_join "$@")"
}

warn() {
  printf "${tty_red}Warning${tty_reset}: %s\n" "$(chomp "$1")"
}

abort() {
  printf "%s\n" "$1"
  exit 1
}

execute() {
  if ! "$@"; then
    abort "$(printf "Failed during: %s" "$(shell_join "$@")")"
  fi
}

setup_color() {
	# Only use colors if connected to a terminal
    # string formatters
    if [[ -t 1 ]]; then
        tty_escape() { printf "\033[%sm" "$1"; }
    else
        tty_escape() { :; }
    fi
    tty_mkbold() { tty_escape "1;$1"; }
    tty_underline="$(tty_escape "4;39")"
    tty_blue="$(tty_mkbold 34)"
    tty_red="$(tty_mkbold 31)"
    tty_green="$(tty_mkbold 32)"
    tty_yellow="$(tty_mkbold 33)"
    tty_bold="$(tty_mkbold 39)"
    tty_reset="$(tty_escape 0)"
}


setup_ransysconf() {
	# Prevent the cloned repository from having insecure permissions. Failing to do
	# so causes compinit() calls to fail with "command not found: compdef" errors
	# for users with insecure umasks (e.g., "002", allowing group writability). Note
	# that this will be ignored under Cygwin by default, as Windows ACLs take
	# precedence over umasks except for filesystems mounted with option "noacl".
	umask g-w,o-w

	ohai "Cloning Ran System Configuration file..."

	command_exists git || {
		abort "git is not installed"
	}

	git clone -c core.eol=lf -c core.autocrlf=false \
		-c fsck.zeroPaddedFilemode=ignore \
		-c fetch.fsck.zeroPaddedFilemode=ignore \
		-c receive.fsck.zeroPaddedFilemode=ignore \
		--depth=1 --branch "$BRANCH" "$REMOTE" "$RSCF" || {
		abort "git clone of ran-sys-conf repo failed"
	}
    echo
}

setup_zshrc() {
	# Keep most recent old .zshrc at .zshrc.pre-ran-sys-conf, and older ones
	# with datestamp of installation that moved them aside, so we never actually
	# destroy a user's original zshrc
	ohai "Looking for an existing zsh config..."

	# Must use this exact name so uninstall.sh can find it
	OLD_ZSHRC=~/.zshrc.pre-ran-sys-conf
	if [ -f ~/.zshrc ] || [ -h ~/.zshrc ]; then
		# Skip this if the user doesn't want to replace an existing .zshrc
		if [ $KEEP_ZSHRC = yes ]; then
			echo "${tty_yellow}Found ~/.zshrc.${tty_reset} ${tty_underline}Keeping...${tty_reset}"
			return
		fi
		if [ -e "$OLD_ZSHRC" ]; then
			OLD_OLD_ZSHRC="${OLD_ZSHRC}-$(date +%Y-%m-%d_%H-%M-%S)"
			if [ -e "$OLD_OLD_ZSHRC" ]; then
				warn "$OLD_OLD_ZSHRC exists. Can't back up ${OLD_ZSHRC}"
				warn "re-run the installer again in a couple of seconds"
				exit 1
			fi
			mv "$OLD_ZSHRC" "${OLD_OLD_ZSHRC}"

			echo "${tty_yellow}Found old ~/.zshrc.pre-ran-sys-conf." \
				"${tty_underline}Backing up to ${OLD_OLD_ZSHRC}${tty_reset}"
		fi
		echo "${tty_yellow}Found ~/.zshrc.${tty_reset} ${tty_red}Backing up to ${OLD_ZSHRC}${tty_reset}"
		mv ~/.zshrc "$OLD_ZSHRC"
	fi

	echo "${tty_green}Using the Ran Shell Config template file and adding it to ~/.zshrc.${tty_reset}"

	sed "/^export RSCF=/ c\\
export RSCF=\"$RSCF\"
" "$RSCF/templates/zshrc.zsh-template" > ~/.zshrc-rantemp
	mv -f ~/.zshrc-rantemp ~/.zshrc

	echo
}


setup_shell() {
	# Skip setup if the user wants or stdin is closed (not running interactively).
	if [ $CHSH = no ]; then
		return
	fi

	# If this user's login shell is already "zsh", do not attempt to switch.
	if [ "$(basename "$SHELL")" = "zsh" ]; then
		return
	fi

	# If this platform doesn't provide a "chsh" command, bail out.
	if ! command_exists chsh; then
		cat <<-EOF
			I can't change your shell automatically because this system does not have chsh.
			${tty_blue}Please manually change your default shell to zsh${tty_reset}
		EOF
		return
	fi

	ohai "Time to change your default shell to zsh"

	# Prompt for user choice on changing the default login shell
	printf "${tty_red}Do you want to change your default shell to zsh? [Y/n]${tty_reset} "
	read opt
	case $opt in
		y*|Y*|"") echo "Changing the shell..." ;;
		n*|N*) echo "Shell change skipped."; return ;;
		*) echo "Invalid choice. Shell change skipped."; return ;;
	esac

	# Check if we're running on Termux
	case "$PREFIX" in
		*com.termux*) termux=true; zsh=zsh ;;
		*) termux=false ;;
	esac

	if [ "$termux" != true ]; then
		# Test for the right location of the "shells" file
		if [ -f /etc/shells ]; then
			shells_file=/etc/shells
		elif [ -f /usr/share/defaults/etc/shells ]; then # Solus OS
			shells_file=/usr/share/defaults/etc/shells
		else
			error "could not find /etc/shells file. Change your default shell manually."
			return
		fi

		# Get the path to the right zsh binary
		# 1. Use the most preceding one based on $PATH, then check that it's in the shells file
		# 2. If that fails, get a zsh path from the shells file, then check it actually exists
		if ! zsh=$(which zsh) || ! grep -qx "$zsh" "$shells_file"; then
			if ! zsh=$(grep '^/.*/zsh$' "$shells_file" | tail -1) || [ ! -f "$zsh" ]; then
				error "no zsh binary found or not present in '$shells_file'"
				error "change your default shell manually."
				return
			fi
		fi
	fi

	# We're going to change the default shell, so back up the current one
	if [ -n "$SHELL" ]; then
		echo $SHELL > ~/.shell.pre-ran-shell-config
	else
		grep "^$USER:" /etc/passwd | awk -F: '{print $7}' > ~/.shell.pre-ran-shell-config
	fi

	# Actually change the default shell to zsh
	if ! chsh -s "$zsh"; then
		error "chsh command unsuccessful. Change your default shell manually."
	else
		export SHELL="$zsh"
		echo "${tty_blue}Shell successfully changed to '$zsh'.${tty_reset}"
	fi

	echo
}

main() {
	# Run as unattended if stdin is closed
	if [ ! -t 0 ]; then
		RUNZSH=no
		CHSH=no
	fi

	# Parse arguments
	while [ $# -gt 0 ]; do
		case $1 in
			--unattended) RUNZSH=no; CHSH=no ;;
			--skip-chsh) CHSH=no ;;
			--keep-zshrc) KEEP_ZSHRC=yes ;;
		esac
		shift
	done

	setup_color

	if ! command_exists zsh; then
		abort "${tty_bold}Zsh is not installed.${tty_reset} Please install zsh first."
	fi

	if [ -d "$RSCF" ]; then
		cat <<-EOF
			${tty_blue}You already have Ran Sys Conf installed.${tty_reset}
			You'll need to remove '$RSCF' if you want to reinstall.
		EOF
		exit 1
	fi

	setup_ransysconf
	setup_zshrc
	setup_shell

	printf "${tty_green}"
	cat <<-'EOF'
            Ran System configuration
                                          ....is now installed!
	EOF
	printf "${tty_reset}"

	if [ $RUNZSH = no ]; then
		echo "${tty_blue}Run zsh to try it out.${tty_reset}"
		exit
	fi

	exec zsh -l
}

main "$@"
