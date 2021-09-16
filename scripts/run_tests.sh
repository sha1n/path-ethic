#!/usr/bin/env zsh
autoload -U colors && colors

EXIT_CODE=0
local script_dir=${0:a:h}
local tests_dir="$script_dir/../tests"

function run_tests() {
  for test in $(find $tests_dir -type f -mtime -14 -iname '*.test.sh' | awk -F/ '{print $NF}'); do
    printf "

 > TEST: %s

" $test

    (eval $tests_dir/$test 2>&1)
    local exitcode="$?"

    if [ "$exitcode" != "0" ]; then
      EXIT_CODE=1
      print "\n > $fg[red]FAILED!$reset_color\n"
    else
      print "\n > $fg[green]PASSED!$reset_color\n"
    fi
    printf "%-50s\n" | tr ' ' '-'
  done

  if [ "$EXIT_CODE" != "0" ]; then
    print "$fg[red]FAILURE!$reset_color"
    exit $EXIT_CODE
  fi
}

run_tests "$@"
