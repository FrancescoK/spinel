# Prepare Spinel and the gems. Compile the example with the README commands.
RUBY ?= ruby

.PHONY: setup
setup:
	$(RUBY) -S gem install --no-document --conservative webrick:1.9.2 minitest:6.0.6
	$(MAKE) -C ../.. deps
	$(MAKE) -C ../..
	mkdir -p ../../build/examples/webrick
