ELFS = hello.elf
GCC_CONTAINER = pco/mor1kx
FUSESOC_CONTAINER = pco/fusesoc
CC = docker run --rm -v `pwd`:/root $(GCC_CONTAINER) or1k-elf-gcc
FS = docker run --rm -v `pwd`:/root $(FUSESOC_CONTAINER) fusesoc

all: $(ELFS)

%.elf : %.c
	$(CC) $< -o $@

.config/fusesoc/fusesoc.conf: 
	$(FS) init -y
	$(FS) library add elf-loader https://github.com/fusesoc/elf-loader

.PHONY: clean images $(GCC_CONTAINER) $(FUSESOC_CONTAINER) sim

$(GCC_CONTAINER) : Dockerfile.gcc
	docker build -t $@ -f $< .

$(FUSESOC_CONTAINER) : Dockerfile.fusesoc
	docker build -t $@ -f $< .

images: $(GCC_CONTAINER) $(FUSESOC_CONTAINER)

sim: $(ELFS) .config/fusesoc/fusesoc.conf
	$(FS) run mor1kx-generic --elf_load $(ELFS) --trace_enable --vcd
	gtkwave build/mor1kx-generic_0/sim-icarus/testlog.vcd

test:
	docker run --rm -it -v `pwd`:/root $(FUSESOC_CONTAINER)

clean:
	rm -rf $(ELFS) .cache .config .local build