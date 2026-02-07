CROSS = riscv32-unknown-elf-
CC = $(CROSS)gcc
OBJCOPY = $(CROSS)objcopy
OBJDUMP = $(CROSS)objdump

ARCH = rv32imc
ABI = ilp32

CFLAGS = -march=$(ARCH) -mabi=$(ABI) -Wall -O2
CFLAGS += -ffreestanding -nostdlib
LDFLAGS = -march=$(ARCH) -mabi=$(ABI) -nostdlib -T picorv32.ld
CFLAGS += -ffunction-sections -fdata-sections -Os -flto
LDFLAGS += -Wl,--gc-sections -flto

all: firmware.hex firmware.lst

firmware.elf: start.o main.o timer.o uart.o picorv32.ld
	$(CC) $(LDFLAGS) -o $@ start.o main.o uart.o timer.o
	$(CROSS)size $@

firmware.bin: firmware.elf
	$(OBJCOPY) -O binary $< $@

firmware.hex: firmware.bin
	python3 ../tools/makehex.py $< > $@

firmware.lst: firmware.elf
	$(OBJDUMP) -d -S $< > $@

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

%.o: %.S
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f *.o *.elf *.bin *.hex *.lst

.PHONY: all clean
