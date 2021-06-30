

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

test_color() {
    setup_color
    chomp "chomp"
    ohai "ohai"
    warn "warn"
    # abort "abort"
    if command_exists git;then
        echo "yes"
    else
        echo "no"
    fi

    command_exists git || {
        echo "one"
    }
}