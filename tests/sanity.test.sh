#!/usr/bin/env zsh

# setup #######################################################################

local script_dir=${0:a:h}
source $script_dir/unit.sh

local push_path=$(existing_dir_from $HOME/push)
local append_path=$(existing_dir_from $HOME/append)
local committed_push_path=$(existing_dir_from $HOME/committed_push)
local committed_append_path=$(existing_dir_from $HOME/committed_append)
local env_file_path="$HOME/.path-ethic"
local original_path="$PATH"

if [[ ! -z "$PATH_ETHIC_TAIL" || ! -z "$PATH_ETHIC_HEAD" ]]; then
  print "prefix and suffix are expected to be unset at this point"
  exit 1
fi

# load_path_ethic #############################################################

header "load_path_ethic"

echo "export PATH_ETHIC_HEAD=\"\$HOME/committed_push\"" >$env_file_path
echo "export PATH_ETHIC_TAIL=\"\$HOME/committed_append\"" >>$env_file_path

load_path_ethic

assert_equals $PATH_ETHIC_HEAD "$committed_push_path"
assert_equals $PATH_ETHIC_TAIL "$committed_append_path"
assert_equals $PATH "$committed_push_path:$original_path:$committed_append_path"

# peth reset ##################################################################
header "peth reset"

peth push $push_path >/dev/null
peth append $append_path >/dev/null

peth reset >/dev/null

assert_equals $PATH_ETHIC_HEAD ""
assert_equals $PATH_ETHIC_TAIL ""
assert_equals $PATH $original_path

# peth push ###################################################################
header "peth push"

peth push $push_path >/dev/null

assert_equals $PATH_ETHIC_HEAD $push_path
assert_equals $PATH_ETHIC_TAIL ""

# peth append #################################################################
header "peth append"

peth append $append_path >/dev/null

assert_equals $PATH_ETHIC_TAIL $append_path
assert_equals $PATH_ETHIC_HEAD ""

# peth rm #####################################################################
header "peth rm"

peth push $push_path >/dev/null
peth append $append_path >/dev/null

peth rm $push_path >/dev/null
peth rm $append_path >/dev/null

assert_equals $PATH_ETHIC_HEAD ""
assert_equals $PATH_ETHIC_TAIL ""
assert_equals $PATH $original_path

# peth reload #################################################################
header "peth reload"

peth push $push_path >/dev/null
peth append $append_path >/dev/null

peth reload

assert_equals $PATH_ETHIC_HEAD "$committed_push_path"
assert_equals $PATH_ETHIC_TAIL "$committed_append_path"
assert_equals $PATH $committed_push_path:$original_path:$committed_append_path

# peth commit #################################################################
header "peth commit empty"

peth commit >/dev/null

load_path_ethic

assert_equals $PATH_ETHIC_HEAD ""
assert_equals $PATH_ETHIC_TAIL ""
assert_equals $PATH $original_path

header "peth commit non-empty"

peth push $push_path >/dev/null
peth append $append_path >/dev/null

peth commit >/dev/null

unit_reset
load_path_ethic

assert_equals $PATH_ETHIC_HEAD $push_path
assert_equals $PATH_ETHIC_TAIL $append_path
assert_equals $PATH $push_path:$original_path:$append_path
