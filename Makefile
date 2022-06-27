MAKEFLAGS += --silent
BASEDIR := $(shell pwd)

default: test 

test:
	@-$(BASEDIR)/tests/zsh-scriptest/run_tests.sh $(BASEDIR)/tests


init:
	@git submodule update --init --recursive
	
update_submodules:
	@git submodule update --recursive --remote
