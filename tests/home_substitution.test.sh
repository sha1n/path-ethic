#!/usr/bin/env zsh

# setup #######################################################################

source ${0:a:h}/unit.sh

local original_path="$PATH"

# home substitution ###########################################################
function test_save_with_home_substitution() {
  before_each

  local home_sub_dir="$HOME/peth_test_dir_$$"
  mkdir -p "$home_sub_dir"

  peth push "$home_sub_dir"
  peth save home_preset

  assert_preset_exists "home_preset"

  # Check content of the preset file for $HOME literal
  local preset_file="$PATH_ETHIC_CONFIG/home_preset.preset"
  if ! grep -Fq "\$HOME" "$preset_file"; then
     print "Preset file does not contain \$HOME substitution. Content: $(cat $preset_file)"
     exit 1
  fi

  # Clean up and reload
  peth reset
  peth load home_preset
  
  assert_equal $PATH_ETHIC_HEAD "$home_sub_dir"
  
  rm -rf "$home_sub_dir"
}

#
# run all tests
#

test_save_with_home_substitution
