#!/usr/bin/env zsh

TESTS="$(find . -type f -name "*.test.sh")"
EXIT_CODE=0

run_tests() {
  
  for test in $TESTS; 
  do
    echo $test
    printf "Running test: %s...\n" $test
    
    ( eval zsh $test 2>&1 )
    local exitcode="$?"

    if [ "$exitcode" != "0" ]; then
      EXIT_CODE=1
      print "$fg[red]FAILED!\n"
    else
      print "$fg[green]PASSED!\n"
    fi    
  done

  if [ "$EXIT_CODE" != "0" ]; then
    exit $EXIT_CODE
  else
    exit 0
  fi
}

run_tests "$@"
