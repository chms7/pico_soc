SRC = ./*.c
OBJ = ./obj
CC_FLAGS = -nostdlib -march=rv32im -mabi=ilp32 -g
LD_SCRIPT = ./link.lds

RISCV_TOOLCHAIN = riscv32-unknown-elf

all: obj/firmware.out obj/firmware.verilog obj/firmware_dump.s

$(OBJ)/firmware.out: $(OBJ)/start.o $(OBJ)/firmware.o $(OBJ)/print.o $(OBJ)/irq.o
	$(RISCV_TOOLCHAIN)-ld $(LD_FLAGS) -T $(LD_SCRIPT) $^ -o $@

$(OBJ)/start.o:
	$(RISCV_TOOLCHAIN)-gcc $(CC_FLAGS) -c start.S -o $@

$(OBJ)/firmware.o:
	$(RISCV_TOOLCHAIN)-gcc $(CC_FLAGS) -c firmware.c -o $@

$(OBJ)/print.o:
	$(RISCV_TOOLCHAIN)-gcc $(CC_FLAGS) -c print.c -o $@

$(OBJ)/irq.o:
	$(RISCV_TOOLCHAIN)-gcc $(CC_FLAGS) -c irq.c -o $@

$(OBJ)/firmware.srec: $(OBJ)/firmware.out
	$(RISCV_TOOLCHAIN)-objcopy $^ -O srec $@

$(OBJ)/firmware.verilog: $(OBJ)/firmware.out
	$(RISCV_TOOLCHAIN)-objcopy $^ -O verilog $@
	./memfile_split.py $@
	
$(OBJ)/firmware_dump.s: $(OBJ)/firmware.out
	$(RISCV_TOOLCHAIN)-objdump $^ -D -S > $@

clean:
	rm -rf ./$(OBJ)/*
