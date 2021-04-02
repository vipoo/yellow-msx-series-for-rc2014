
.PHONY: bin/telnet.com
bin/telnet.com:
	@$(MAKE) --no-print-directory -s -C apps/telnet
	cp -up ./apps/telnet/bin/telnet.com ./bin/

APPS := dots lines mbrot spike-fdd ide cpusptst fdisk vramtest extbio
APP_TARGETS := $(addsuffix .com,$(addprefix ./bin/,$(APPS)))

.PHONY: apps
apps: $(APP_TARGETS) bin/telnet.com

$(APP_TARGETS):
	@mkdir -p bin
	@$(MAKE) "$@" --no-print-directory -C apps
	cp -up ./apps/"$@" ./bin/

.PHONY: test
test:
	echo $(APP_TARGETS)


.PHONY: format
format: SHELL:=/bin/bash
format:
	@cd apps
	find \( -name "*.c" -o -name "*.h" \) -exec echo "formating {}" \; -exec clang-format -i {} \;

