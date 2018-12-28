all: test

test:
	@if [ -z "$$TEST" ]; then TEST="tc_*.rb"; else ONETEST=true; fi; \
	set -e; \
	for i in $$TEST; do ruby -rbundler/setup ./$$i; done
