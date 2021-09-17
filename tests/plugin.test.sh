#!/usr/bin/env zsh

# setup #######################################################################

source ${0:a:h}/unit.sh

local original_path="$PATH"

# load_path_ethic #############################################################
funciton test_load_path_ethic() {
  before_each

  local default_preset_path="$HOME/.path-ethic/default.preset"
  local saved_push_path=$(existing_dir_from $HOME/saved_push)
  local saved_append_path=$(existing_dir_from $HOME/saved_append)

  echo "PATH_ETHIC_HEAD=\"\$HOME/saved_push\"" >$default_preset_path
  echo "PATH_ETHIC_TAIL=\"\$HOME/saved_append\"" >>$default_preset_path

  load_path_ethic

  assert_equals $PATH_ETHIC_HEAD "$saved_push_path"
  assert_equals $PATH_ETHIC_TAIL "$saved_append_path"
  assert_equals $PATH "$saved_push_path:$original_path:$saved_append_path"
}

# __pe_load_pethrc ############################################################
funciton test_load_pethrc() {
  before_each

  local pethrc_dir=$(mktemp -d)
  
  peth push "$pethrc_dir"
  peth save pethrc-test
  # load default preset
  peth load
  
  # create rc file
  echo "pethrc-test" > "$pethrc_dir/.pethrc"

  local current_dir=`pwd`

  cd $pethrc_dir

  assert_equals $PATH_ETHIC_HEAD "$pethrc_dir"
  assert_equals $PATH_ETHIC_TAIL ""
  assert_equals $PATH "$pethrc_dir:$original_path"

  # back to original directory
  cd "$current_dir"
}


#
# run all tests
#

test_load_path_ethic
test_load_pethrc

