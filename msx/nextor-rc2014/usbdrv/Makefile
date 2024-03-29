SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
.ONESHELL:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

ZCCRELFLAGS=
ifdef RELEASE
ZCCRELFLAGS=-SO3 --max-allocs-per-node200000 --allow-unsafe-read
endif

LIBS := -I./../apps/libraries/msxbios/ -I./../apps/libraries/delay/ -I./../apps/libraries/usb -I./../apps/libraries
SRC := ./usbdrv/

ZCC := zcc +msx --vc -subtype=rom -startup=1 -crt0 $(SRC)crt.asm -compiler=sdcc -Cs --Werror  $(ZCCRELFLAGS) $(LIBS)

$(BINDIR)usbdrv.bin: $(BINDIR)crt.o \
	$(BINDIR)exports.c.o \
	$(BINDIR)extended-bios.c.o \
	$(BINDIR)keyboard_drv.c.o \
	$(BINDIR)libraries/delay/delay.c.o \
	$(BINDIR)libraries/usb/ch376.c.o \
	$(BINDIR)libraries/usb/ch376.o \
	$(BINDIR)libraries/usb/class_hid_keyboard.c.o \
	$(BINDIR)libraries/usb/class_hid.c.o \
	$(BINDIR)libraries/usb/class_hub.c.o \
	$(BINDIR)libraries/usb/class_scsi.c.o \
	$(BINDIR)libraries/usb/class_ufi.c.o \
	$(BINDIR)libraries/usb/dev_transfers.c.o \
	$(BINDIR)libraries/usb/enumerate_hub.c.o \
	$(BINDIR)libraries/usb/enumerate_storage.c.o \
	$(BINDIR)libraries/usb/enumerate.c.o \
	$(BINDIR)libraries/usb/format_mapping.c.o \
	$(BINDIR)libraries/usb/protocol.c.o \
	$(BINDIR)libraries/usb/transfers.c.o \
	$(BINDIR)libraries/usb/usb_cbi.c.o \
	$(BINDIR)libraries/usb/usb_state.c.o \
	$(BINDIR)print.o \
	$(BINDIR)usb-dev-info-scsi.c.o \
	$(BINDIR)usb-dev-info-ufi.c.o \
	$(BINDIR)usb-dev-info.c.o \
	$(BINDIR)usb-dev-read-scsi.c.o \
	$(BINDIR)usb-dev-read-ufi.c.o \
	$(BINDIR)usb-dev-read.c.o \
	$(BINDIR)usb-dev-status-scsi.c.o \
	$(BINDIR)usb-dev-status-ufi.c.o \
	$(BINDIR)usb-dev-status.c.o \
	$(BINDIR)usb-dev-write-scsi.c.o \
	$(BINDIR)usb-dev-write-ufi.c.o \
	$(BINDIR)usb-dev-write.c.o \
	$(BINDIR)usb-dev.c.o \
	$(BINDIR)usb-dev.o \
	$(BINDIR)usb-init.c.o \
	$(BINDIR)usb-lun-info-scsi.c.o \
	$(BINDIR)usb-lun-info-ufi.c.o \
	$(BINDIR)usb-lun-info.c.o \
	$(BINDIR)work-area.c.o \
	$(BINDIR)work-area.o \
	../apps/libraries/msxbios/system_vars.c

$(BINDIR)%.bin:
	@mkdir -p $(dir $@)
	$(ZCC) $(filter-out %.inc,$(filter-out %.lib,$^)) $(patsubst %,-l%,$(filter %.lib,$^)) -o $@
	filesize=$$(stat -c%s "$@")
	echo "Linked $(notdir $@) ($$filesize bytes)"

define assemble
	@mkdir -p $(dir $@)
	$(ZCC) --compile-only $< -o $@
	echo "Assembled $(notdir $@) from $(notdir $<)"
endef

define compile
	@mkdir -p $(dir $@)
	$(ZCC) --c-code-in-asm --assemble-only $< -o $@
	echo "Compiled $(notdir $@) from $(notdir $<)"
endef

define objects
 $(patsubst %.asm,%.o,$(patsubst %.c,%.c.o,$(1)))
endef

define buildlib
	@mkdir -p $(dir $@)
	z88dk-z80asm -x$@ $<
	echo "Packaged $(notdir $@) from $(notdir $<)"
endef



.PRECIOUS: $(BINDIR)%.c.asm
$(BINDIR)%.c.asm: $(SRC)%.c; $(compile)
$(BINDIR)%.o: $(BINDIR)%.asm; $(assemble)
$(BINDIR)%.o: $(SRC)%.asm; $(assemble)
$(BINDIR)%.m4.o: %.asm.m4; $(assemble)
%.lib: %.o; $(buildlib)

.PRECIOUS: $(BINDIR)libraries/delay/%.c.asm
$(BINDIR)libraries/delay/%.c.asm: ../apps/libraries/delay/%.c; $(compile)
$(BINDIR)libraries/delay/%.o: $(BINDIR)libraries/delay/%.asm; $(assemble)

.PRECIOUS: $(BINDIR)libraries/usb/%.c.asm
.PRECIOUS: $(BINDIR)libraries/usb/%.c.o
$(BINDIR)libraries/usb/%.c.asm: ../apps/libraries/usb/%.c; $(compile)
$(BINDIR)libraries/usb/%.o: ../apps/libraries/usb/%.asm; $(assemble)

.PHONY: format
format: SHELL:=/bin/bash
format:
	clang-format --version
	find \( -name "*.c" -o -name "*.h" \) -exec echo "formating {}" \; -exec clang-format -i {} \;



ZSDCPP_FLAGS=-iquote"." -isystem"${ZCCCFG}/../../include/_DEVELOPMENT/sdcc" $(LIBS)

deps:
	@echo "" > ./depends.d
	# C Dependencies
	(cd usbdrv && find -name "*.c") | while read -r file; do
		file_no_ext="$${file%.*}"
		file_no_ext=$${file_no_ext#./}
		filename=$$(basename $$file_no_ext)
		from="$$filename.o"
		to="$(BINDIR)$$file_no_ext.c.asm"
		sdcpp ${ZSDCPP_FLAGS} -MM -MF /tmp/deps.deps ./usbdrv/$$filename.c
		sed "s+$$from+$$to+g" /tmp/deps.deps >> ./depends.d
	done

	# ASM include dependencies
	find -name "*.asm" -not -path "./bin/*" | while read -r file; do
		file_no_ext="$${file%.*}"
	 	file_no_ext=$${file_no_ext#./}
		filename=$$(basename $$file_no_ext)
		printf "$(BINDIR)$$filename.o:" >> ./depends.d
		printf " $$file" >> ./depends.d
		sed -n '/include/s/^[\t ]*include[\t ]*"\{0,1\}\(.*\)".*$$/\1/p' < $$file | while read -r depfile; do
			depfilepath=$$(find -iname $$depfile)
			printf " $$depfilepath" >> ./depends.d
		done
		echo "" >> ./depends.d
	done

	# ASM include dependencies
	find -name "*.asm.m4" | while read -r file; do
		file_no_ext="$${file%.*}"
	 	file_no_ext=$${file_no_ext#./}
		file_no_ext="$(BINDIR)$${file_no_ext%.*}"
		printf "$$file_no_ext.o:" >> ./depends.d
		printf " $$file" >> ./depends.d
		sed  -n '/include/s/^[\t ]*include(.\(.*\)'\'')/\1/p' < $$file | while read -r depfile; do
			depfilepath=$$(find -iname $$depfile)
			printf " $$depfilepath" >> ./depends.d
		done
		sed -n '/include/s/^[\t ]*include[\t ]*"\{0,1\}\(.*\)".*$$/\1/p' < $$file | while read -r depfile; do
			depfilepath=$$(find -iname $$depfile)
			printf " $$depfilepath" >> ./depends.d
		done
		echo "" >> ./depends.d
	done

	echo "./depends.d created"

