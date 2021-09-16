#!/usr/bin/env zsh

local script_dir=${0:a:h}
local test_home=$(mktemp -d)
local original_path="$PATH"

unset PATH_ETHIC_HEAD
unset PATH_ETHIC_TAIL

# Make sure we don't interact witn the local user home
export HOME=$test_home

# Source the plugin (this won't load the plugin!)
source $script_dir/../path-ethic.plugin.zsh

###############################################################################

function unit_reset() {
  PATH_ETHIC_HEAD=""
  PATH_ETHIC_TAIL=""
  export PATH="$original_path"
}

function header() {
  printf " > TESTING: %s...\n" $1
  
  unit_reset
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

function assert_not_empty() {
  if [[ "$1" == "" ]]; then
    print "EMPTY!

Actual: '$1'
"

    exit 1
  fi
}

function assert_preset_exists() {
  local expected_path="$HOME/.path-ethic/$1.preset"
  if [[ ! -f "$expected_path" ]]; then
    print "PRESET FILE NOT FOUND!

Path: '$expected_path'
"

    exit 1
  fi
}

function assert_preset_doesnt_exists() {
  local expected_path="$HOME/.path-ethic/$1.preset"
  if [[ -f "$expected_path" ]]; then
    print "PRESET FILE EXISTS!

Path: '$expected_path'
"

    exit 1
  fi
}