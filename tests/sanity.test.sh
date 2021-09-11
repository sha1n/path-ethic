#!/usr/bin/env zsh

local script_dir=${0:a:h}
source $script_dir/unit.sh

header "load_path_ethic"

if [[ ! -z "$PATH_ETHIC_TAIL" || ! -z "$PATH_ETHIC_HEAD" ]]; then
  print "prefix and suffix are expected to be unset at this point"
  exit 1
fi

local env_file_path="$HOME/.path-ethic"
local original_path="$PATH"

echo "export PATH_ETHIC_HEAD=\"\$HOME/head\"" >$env_file_path
echo "export PATH_ETHIC_TAIL=\"\$HOME/tail\"" >>$env_file_path


load_path_ethic

assert_equals $PATH_ETHIC_HEAD "$HOME/head"
assert_equals $PATH_ETHIC_TAIL "$HOME/tail"
assert_equals $PATH "$HOME/head:$original_path:$HOME/tail"

# peth reset ##################################################################
header "peth reset"

peth reset >/dev/null

assert_equals $PATH_ETHIC_HEAD ""
assert_equals $PATH_ETHIC_TAIL ""
assert_equals $PATH "$original_path"

# peth push ###################################################################
header "peth push"

local push_path=$(existing_dir_from $HOME/push)

peth push $push_path >/dev/null

assert_equals $PATH_ETHIC_HEAD $push_path

# peth append #################################################################
header "peth append"

local append_path=$(existing_dir_from $HOME/append)

peth append $append_path >/dev/null

assert_equals $PATH_ETHIC_TAIL $append_path

# peth rm #####################################################################
header "peth rm"

peth rm $push_path >/dev/null
peth rm $append_path >/dev/null

assert_equals $PATH $original_path

# peth commit #################################################################
header "peth commit"

peth commit >/dev/null

load_path_ethic

assert_equals $PATH_ETHIC_HEAD ""
assert_equals $PATH_ETHIC_TAIL ""
assert_equals $PATH $original_path
