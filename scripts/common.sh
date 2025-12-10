# Common functions for printing and running commands
# shellcheck shell=bash

tty_escape() { printf "\033[%sm" "$1"; }
tty_mkbold() { tty_escape "1;$1"; }
tty_dim="$(tty_mkbold 2)"
tty_red="$(tty_mkbold 31)"
tty_blue="$(tty_mkbold 34)"
tty_reset="$(tty_escape 0)"

log_info() {
  printf "${tty_blue}%s${tty_reset}\n" "$@" 1>&2
}

debug() {
  printf "${tty_dim}%s${tty_reset}\n" "$@" 1>&2
}

failure() {
  printf "${tty_red}%s${tty_reset}\n" "$@" 1>&2
  exit 1
}

system_and_log() {
  debug "$@"
  eval "$@"
}
