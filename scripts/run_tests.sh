#!/usr/bin/env zsh

TESTS="$(find . -type f -name "*.test.sh")"
EXIT_CODE=0

run_tests() {
  
  for test in $TESTS; do
    print "Running test: $test..."
    ( eval zsh $test 2>&1 )
    local exitcode="$?"
    [ "$exitcode" != "0" ] && EXIT_CODE=$exitcode
  done

  if [ "$EXIT_CODE" != "0" ]; then
    print "FAILED!\n"
    exit $EXIT_CODE
  else
    print "PASSED!\n"
    exit 0
  fi
}

run_tests "$@"
