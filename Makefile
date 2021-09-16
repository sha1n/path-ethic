MAKEFLAGS += --silent

default: test 

test: 
	./scripts/run_tests.sh