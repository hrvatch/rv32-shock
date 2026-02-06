CROSS = riscv32-unknown-elf-
CC = $(CROSS)gcc
OBJCOPY = $(CROSS)objcopy
OBJDUMP = $(CROSS)objdump

ARCH = rv32imc
ABI = ilp32

CFLAGS = -march=$(ARCH) -mabi=$(ABI) -O2 -Wall
CFLAGS += -ffreestanding -nostdlib
LDFLAGS = -march=$(ARCH) -mabi=$(ABI) -nostdlib -T bootloader.ld
CFLAGS += -ffunction-sections -fdata-sections -Os -flto
LDFLAGS += -Wl,--gc-sections -flto

all: bootloader.hex bootloader.lst

bootloader.elf: bootloader.o bootloader.ld
	$(CC) $(LDFLAGS) -o $@ bootloader.o 
	$(CROSS)size $@

bootloader.bin: bootloader.elf
	$(OBJCOPY) -O binary $< $@

bootloader.hex: bootloader.bin
	python3 ../tools/makehex.py $< > $@

bootloader.lst: bootloader.elf
	$(OBJDUMP) -d -S $< > $@

%.o: %.S
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o *.elf *.bin *.hex *.lst

.PHONY: all clean
