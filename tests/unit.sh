#!/usr/bin/env zsh
autoload -U colors && colors

source "$__ZSH_SCRIPTEST_HOME/matchers.sh"
source "$__ZSH_SCRIPTEST_HOME/test_util.sh"

local script_dir=${0:a:h}
local test_home=$(mktemp -d)
local original_path="$PATH"

unset PATH_ETHIC_HEAD
unset PATH_ETHIC_TAIL

# Make sure we don't interact witn the local user home
export HOME=$test_home
# setup expected directory structure
mkdir -p "$HOME/.path-ethic"

# Source the plugin (this won't load the plugin!)
source $script_dir/../path-ethic.plugin.zsh

# initialize default preset
peth save

###############################################################################

function unit_reset() {
  PATH_ETHIC_HEAD=""
  PATH_ETHIC_TAIL=""
  export PATH="$original_path"
}

function before_each() {
  test_case_title

  unit_reset

  if [[ ! -z "$PATH_ETHIC_TAIL" || ! -z "$PATH_ETHIC_HEAD" ]]; then
    print "prefix and suffix are expected to be unset at this point"
    exit 1
  fi
}

function existing_dir_from() {
  mkdir -p "$1"
  echo "$1"
}

function assert_preset_exists() {
  assert_file_exists "$HOME/.path-ethic/$1.preset"
}

function assert_preset_doesnt_exists() {
  assert_file_not_exists "$HOME/.path-ethic/$1.preset"
}
