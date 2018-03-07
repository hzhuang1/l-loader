CROSS_COMPILE?=arm-linux-gnueabihf-

ifeq ($(notdir $(CC)), clang)
	CC=clang
	LD=ld.lld
	CFLAGS=-target arm-linux-gnueabihf
else
	CC=$(CROSS_COMPILE)gcc
	LD=$(CROSS_COMPILE)ld
endif
OBJCOPY=$(CROSS_COMPILE)objcopy

BL1=bl1.bin
BL2=bl2.bin
NS_BL1U=fastboot.bin
PTABLE_LST?=aosp-8g

.PHONY: all
all: l-loader.bin prm_ptable.img recovery.bin

%.o: %.S
	$(CC) $(CFLAGS) -c -o $@ $<

l-loader.bin: start.o $(BL2)
	$(LD) -Bstatic -Tl-loader.lds -Ttext 0xf9800800 start.o -o loader
	$(OBJCOPY) -O binary loader temp
	python gen_loader_hikey.py -o $@ --img_loader=temp --img_bl1=$(BL2)

prm_ptable.img:
	for ptable in $(PTABLE_LST); do \
		PTABLE=$${ptable} SECTOR_SIZE=512 bash -x generate_ptable.sh;\
		cp prm_ptable.img ptable-$${ptable}.img;\
	done

recovery.bin: start.o $(BL1) $(NS_BL1U)
	$(LD) -Bstatic -Tl-loader.lds -Ttext 0xf9800800 start.o -o loader
	$(OBJCOPY) -O binary loader temp
	python gen_loader_hikey.py -o $@ --img_loader=temp --img_bl1=$(BL1) --img_ns_bl1u=$(NS_BL1U)
	rm -f loader temp

.PHONY: clean
clean:
	rm -f *.o l-loader.bin prm_ptable.img recovery.bin
