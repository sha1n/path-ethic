#!/usr/bin/env zsh

local script_dir=${0:a:h}
local test_home=$(mktemp -d)

unset PATH_ETHIC_HEAD
unset PATH_ETHIC_TAIL

# Make sure we don't interact witn the local user home
export HOME=$test_home

# Source the plugin (this won't load the plugin!)
source $script_dir/../path-ethic.plugin.zsh

###############################################################################

function header() {
  printf " > TESTING: %s...\n" $1
}

function existing_dir_from() {
  mkdir -p "$1"
  echo "$1"
}

function assert_equals() {
  if [[ "$1" != "$2" ]]; then
    print "NOT EQUAL!

Expected: '$2'

Actual: '$1'
"

    exit 1
  fi
}