#!/usr/bin/env zsh

# setup #######################################################################

local script_dir=${0:a:h}
source $script_dir/unit.sh

local push_path=$(existing_dir_from $HOME/push)
local append_path=$(existing_dir_from $HOME/append)
local saved_push_path=$(existing_dir_from $HOME/saved_push)
local saved_append_path=$(existing_dir_from $HOME/saved_append)
local peth_home="$HOME/.path-ethic"
local default_preset_path="$peth_home/.default"
local original_path="$PATH"

if [[ ! -z "$PATH_ETHIC_TAIL" || ! -z "$PATH_ETHIC_HEAD" ]]; then
  print "prefix and suffix are expected to be unset at this point"
  exit 1
fi

mkdir -p "$peth_home"

# load_path_ethic #############################################################

header "load_path_ethic"

echo "PATH_ETHIC_HEAD=\"\$HOME/saved_push\"" >$default_preset_path
echo "PATH_ETHIC_TAIL=\"\$HOME/saved_append\"" >>$default_preset_path

load_path_ethic

assert_equals $PATH_ETHIC_HEAD "$saved_push_path"
assert_equals $PATH_ETHIC_TAIL "$saved_append_path"
assert_equals $PATH "$saved_push_path:$original_path:$saved_append_path"


# peth list ##################################################################

header "path list"

local listed_path=$(peth list |  tr '\n' ':' | rev | cut -c2- | rev)

assert_not_empty "$listed_path"
assert_equals $listed_path $PATH

# peth reset ##################################################################
header "peth reset"

peth push $push_path
peth append $append_path

peth reset

assert_equals $PATH_ETHIC_HEAD ""
assert_equals $PATH_ETHIC_TAIL ""
assert_equals $PATH $original_path

# peth push ###################################################################
header "peth push"

peth push $push_path

assert_equals $PATH_ETHIC_HEAD $push_path
assert_equals $PATH_ETHIC_TAIL ""

# peth append #################################################################
header "peth append"

peth append $append_path

assert_equals $PATH_ETHIC_TAIL $append_path
assert_equals $PATH_ETHIC_HEAD ""

# peth flip #####################################################################
header "peth flip"

peth push $push_path
peth append $append_path

peth flip

assert_equals $PATH_ETHIC_HEAD $append_path
assert_equals $PATH_ETHIC_TAIL $push_path
assert_equals $PATH $append_path:$original_path:$push_path

# peth rm #####################################################################
header "peth rm"

peth push $push_path
peth append $append_path

peth rm $push_path
peth rm $append_path

assert_equals $PATH_ETHIC_HEAD ""
assert_equals $PATH_ETHIC_TAIL ""
assert_equals $PATH $original_path

# peth load #################################################################
header "peth load"

peth push $push_path
peth append $append_path

peth load

assert_equals $PATH_ETHIC_HEAD "$saved_push_path"
assert_equals $PATH_ETHIC_TAIL "$saved_append_path"
assert_equals $PATH $saved_push_path:$original_path:$saved_append_path

# peth save #################################################################
header "peth save empty"

peth save

load_path_ethic

assert_equals $PATH_ETHIC_HEAD ""
assert_equals $PATH_ETHIC_TAIL ""
assert_equals $PATH $original_path

header "peth save non-empty"

peth push $push_path
peth append $append_path

peth save

assert_preset_exists ".default"

unit_reset
load_path_ethic

assert_equals $PATH_ETHIC_HEAD $push_path
assert_equals $PATH_ETHIC_TAIL $append_path
assert_equals $PATH $push_path:$original_path:$append_path

# peth save/load preset #######################################################
header "peth save preset"

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
