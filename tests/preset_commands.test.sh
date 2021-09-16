#!/usr/bin/env zsh

# setup #######################################################################

source ${0:a:h}/unit.sh

local original_path="$PATH"

# peth load #################################################################
function test_peth_load() {
  before_each

  local push_path=$(mktemp -d)
  local append_path=$(mktemp -d)

  peth push $push_path
  peth append $append_path

  peth load

  assert_equals $PATH_ETHIC_HEAD ""
  assert_equals $PATH_ETHIC_TAIL ""
  assert_equals $PATH $original_path
}

# peth save #################################################################
function test_peth_save_empty() {
  before_each

  peth save

  load_path_ethic

  assert_equals $PATH_ETHIC_HEAD ""
  assert_equals $PATH_ETHIC_TAIL ""
  assert_equals $PATH $original_path
}

function test_peth_save_nonempty() {
  before_each

  local push_path=$(mktemp -d)
  local append_path=$(mktemp -d)

  peth push $push_path
  peth append $append_path

  peth save

  assert_preset_exists "default"

  unit_reset
  load_path_ethic

  assert_equals $PATH_ETHIC_HEAD $push_path
  assert_equals $PATH_ETHIC_TAIL $append_path
  assert_equals $PATH $push_path:$original_path:$append_path
}

# peth save/load preset #######################################################
function test_save_load_preset() {
  before_each

  local dir1=$(mktemp -d)
  local dir2=$(mktemp -d)

  # modify and save preset
  peth push $dir1
  peth append $dir2
  peth save my_preset

  assert_preset_exists "my_preset"

  # reset session and load preset
  peth reset
  peth load my_preset

  assert_equals $PATH_ETHIC_HEAD $dir1
  assert_equals $PATH_ETHIC_TAIL $dir2
  assert_equals $PATH $dir1:$original_path:$dir2
}

# peth rmp ####################################################################
function test_rmp_nonexisting() {
  before_each

  local dir1=$(mktemp -d)
  local dir2=$(mktemp -d)

  # modify and save preset
  peth push $dir1
  peth append $dir2

  peth rmp non_existing_preset

  # no changes expected
  assert_equals $PATH_ETHIC_HEAD $dir1
  assert_equals $PATH_ETHIC_TAIL $dir2
  assert_equals $PATH $dir1:$original_path:$dir2
}

function test_rmp_loaded() {
  before_each

  local dir1=$(mktemp -d)
  local dir2=$(mktemp -d)

  # modify and save preset
  peth push $dir1
  peth append $dir2
  peth save loaded_preset

  assert_preset_exists "loaded_preset"

  # reset session and load preset
  peth rmp loaded_preset

  assert_preset_exists "loaded_preset"
  assert_equals $PATH_ETHIC_HEAD $dir1
  assert_equals $PATH_ETHIC_TAIL $dir2
  assert_equals $PATH $dir1:$original_path:$dir2
}

function test_rmp_existing_unloaded() {
  before_each

  local dir1=$(mktemp -d)
  local dir2=$(mktemp -d)

  # modify and save preset
  peth push $dir1
  peth append $dir2
  peth save existing_preset

  # load default preset
  peth load

  peth rmp existing_preset

  assert_preset_doesnt_exists "existing_preset"
}

#
# run all tests
#

test_peth_load
test_peth_save_empty
test_peth_save_nonempty
test_save_load_preset
test_rmp_nonexisting
test_rmp_loaded
test_rmp_existing_unloaded
