CROSS = riscv32-unknown-elf-
CC = $(CROSS)gcc
OBJCOPY = $(CROSS)objcopy
OBJDUMP = $(CROSS)objdump

ARCH = rv32imc
ABI = ilp32

CFLAGS = -march=$(ARCH) -mabi=$(ABI) -O2 -Wall
CFLAGS += -ffreestanding -nostdlib
LDFLAGS = -march=$(ARCH) -mabi=$(ABI) -nostdlib -T picorv32.ld

all: firmware.hex firmware.lst

firmware.elf: start.o main.o picorv32.ld
	$(CC) $(LDFLAGS) -o $@ start.o main.o
	$(CROSS)size $@

firmware.bin: firmware.elf
	$(OBJCOPY) -O binary $< $@

firmware.hex: firmware.bin
	python3 makehex.py $< > $@

firmware.lst: firmware.elf
	$(OBJDUMP) -d -S $< > $@

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

%.o: %.S
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o *.elf *.bin *.hex *.lst

.PHONY: all clean
