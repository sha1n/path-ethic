#!/usr/bin/env zsh

# setup #######################################################################

source ${0:a:h}/unit.sh

local original_path="$PATH"

# strip logic with prepended injection ########################################
function test_strip_logic_with_prepended_injection() {
  before_each

  local head_dir="/head"
  local tail_dir="/tail"
  local injected_dir="/injected"

  PATH_ETHIC_HEAD="$head_dir"
  PATH_ETHIC_TAIL="$tail_dir"

  # Simulate PATH with an injected element BEFORE the expected head
  PATH="$injected_dir:$head_dir:$original_path:$tail_dir"

  local stripped=$(__pe_strip_original_path)

  assert_equal "$stripped" "$injected_dir:$original_path"
}

# strip logic with interrupted tail ###########################################
function test_strip_logic_with_interrupted_tail() {
  before_each

  local head_dir="/head"
  local tail_dir="/tail"
  local injected_dir="/injected"

  PATH_ETHIC_HEAD="$head_dir"
  PATH_ETHIC_TAIL="$tail_dir"

  # Simulate PATH with an injected element AFTER the expected tail
  PATH="$head_dir:$original_path:$tail_dir:$injected_dir"

  local stripped=$(__pe_strip_original_path)

  assert_equal "$stripped" "$original_path:$injected_dir"
}

#
# run all tests
#

test_strip_logic_with_prepended_injection
test_strip_logic_with_interrupted_tail