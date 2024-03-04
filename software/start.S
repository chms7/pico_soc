#include "custom_ops.S"

.section .init
.global main

irq_init:
	# picorv32_waitirq_insn(zero)
	picorv32_maskirq_insn(zero, zero)
  mv t0, zero
  addi t0, zero, 2000
  picorv32_timer_insn(zero, t0)
	j start
  
.balign 32
irq_handler:
  /***** 1 save registers *****/

  # save ra & sp to q2 & q3
  picorv32_setq_insn(q2, ra)
	picorv32_setq_insn(q3, sp)

  # get address of irq_regs to x1
	lui x1, %hi(irq_regs)
	addi x1, x1, %lo(irq_regs)

  # save q0 & q2 & q3 to irq_regs
	picorv32_getq_insn(sp, q0)
	sw sp,   0*4(x1)
	picorv32_getq_insn(sp, q2) # ra
	sw sp,   1*4(x1)
	picorv32_getq_insn(sp, q3) # sp
	sw sp,   2*4(x1)
  
  # save x3-x31 to irq_regs
  sw x3,   3*4(x1)
	sw x4,   4*4(x1)
	sw x5,   5*4(x1)
	sw x6,   6*4(x1)
	sw x7,   7*4(x1)
	sw x8,   8*4(x1)
	sw x9,   9*4(x1)
	sw x10, 10*4(x1)
	sw x11, 11*4(x1)
	sw x12, 12*4(x1)
	sw x13, 13*4(x1)
	sw x14, 14*4(x1)
	sw x15, 15*4(x1)
	sw x16, 16*4(x1)
	sw x17, 17*4(x1)
	sw x18, 18*4(x1)
	sw x19, 19*4(x1)
	sw x20, 20*4(x1)
	sw x21, 21*4(x1)
	sw x22, 22*4(x1)
	sw x23, 23*4(x1)
	sw x24, 24*4(x1)
	sw x25, 25*4(x1)
	sw x26, 26*4(x1)
	sw x27, 27*4(x1)
	sw x28, 28*4(x1)
	sw x29, 29*4(x1)
	sw x30, 30*4(x1)
	sw x31, 31*4(x1)

  /***** 2 call interrupt handler C function *****/

  # sp use individual irq_stack
	lui sp, %hi(irq_stack)
	addi sp, sp, %lo(irq_stack)

	# arg0 : address of regs
	lui a0, %hi(irq_regs)
	addi a0, a0, %lo(irq_regs)

	# arg1 : interrupt type
	picorv32_getq_insn(a1, q1)

	# call C function
	jal ra, irq

  /***** 3 restore registers *****/

  # ? new address of irq_regs in a0 returned from C function 
	addi x1, a0, 0

  # set timer irq
  mv t0, zero
  addi t0, zero, 2000
  picorv32_timer_insn(zero, t0)

  # restore q0, q2 -> ra, q2 -> sp
	lw x2,   0*4(x1)
	picorv32_setq_insn(q0, x2)
	lw x2,   1*4(x1)
	picorv32_setq_insn(q2, x2)
  picorv32_getq_insn(ra, q2)
	lw x2,   2*4(x1)
	picorv32_setq_insn(q3, x2)
	picorv32_getq_insn(sp, q3)

  # restore x3-x31
  lw x3,   3*4(x1)
	lw x4,   4*4(x1)
	lw x5,   5*4(x1)
	lw x6,   6*4(x1)
	lw x7,   7*4(x1)
	lw x8,   8*4(x1)
	lw x9,   9*4(x1)
	lw x10, 10*4(x1)
	lw x11, 11*4(x1)
	lw x12, 12*4(x1)
	lw x13, 13*4(x1)
	lw x14, 14*4(x1)
	lw x15, 15*4(x1)
	lw x16, 16*4(x1)
	lw x17, 17*4(x1)
	lw x18, 18*4(x1)
	lw x19, 19*4(x1)
	lw x20, 20*4(x1)
	lw x21, 21*4(x1)
	lw x22, 22*4(x1)
	lw x23, 23*4(x1)
	lw x24, 24*4(x1)
	lw x25, 25*4(x1)
	lw x26, 26*4(x1)
	lw x27, 27*4(x1)
	lw x28, 28*4(x1)
	lw x29, 29*4(x1)
	lw x30, 30*4(x1)
	lw x31, 31*4(x1)
  
# ?
1:
  lw gp,   0*4+0x200(zero)
	lw x1,   1*4+0x200(zero)
	lw x2,   2*4+0x200(zero)
	// do not restore x3 (gp)
	lw x4,   4*4+0x200(zero)
	lw x5,   5*4+0x200(zero)
	lw x6,   6*4+0x200(zero)
	lw x7,   7*4+0x200(zero)
	lw x8,   8*4+0x200(zero)
	lw x9,   9*4+0x200(zero)
	lw x10, 10*4+0x200(zero)
	lw x11, 11*4+0x200(zero)
	lw x12, 12*4+0x200(zero)
	lw x13, 13*4+0x200(zero)
	lw x14, 14*4+0x200(zero)
	lw x15, 15*4+0x200(zero)
	lw x16, 16*4+0x200(zero)
	lw x17, 17*4+0x200(zero)
	lw x18, 18*4+0x200(zero)
	lw x19, 19*4+0x200(zero)
	lw x20, 20*4+0x200(zero)
	lw x21, 21*4+0x200(zero)
	lw x22, 22*4+0x200(zero)
	lw x23, 23*4+0x200(zero)
	lw x24, 24*4+0x200(zero)
	lw x25, 25*4+0x200(zero)
	lw x26, 26*4+0x200(zero)
	lw x27, 27*4+0x200(zero)
	lw x28, 28*4+0x200(zero)
	lw x29, 29*4+0x200(zero)
	lw x30, 30*4+0x200(zero)
	lw x31, 31*4+0x200(zero)
  
  /***** 4 return from irq *****/
  picorv32_retirq_insn()

.balign 0x200
irq_regs:
	// registers are saved to this memory region during interrupt handling
	// the program counter is saved as register 0
	.fill 32,4

	// stack for the interrupt handler
	.fill 128,4
irq_stack:

start:
  # zero-initialize all registers
  addi x1, zero, 0
  addi x2, zero, 0
  addi x3, zero, 0
  addi x4, zero, 0
  addi x5, zero, 0
  addi x6, zero, 0
  addi x7, zero, 0
  addi x8, zero, 0
  addi x9, zero, 0
  addi x10, zero, 0
  addi x11, zero, 0
  addi x12, zero, 0
  addi x13, zero, 0
  addi x14, zero, 0
  addi x15, zero, 0
  addi x16, zero, 0
  addi x17, zero, 0
  addi x18, zero, 0
  addi x19, zero, 0
  addi x20, zero, 0
  addi x21, zero, 0
  addi x22, zero, 0
  addi x23, zero, 0
  addi x24, zero, 0
  addi x25, zero, 0
  addi x26, zero, 0
  addi x27, zero, 0
  addi x28, zero, 0
  addi x29, zero, 0
  addi x30, zero, 0
  addi x31, zero, 0
  # init frame-point, stack-point
  mv fp, zero
  la sp, stack_top
  # call main function
  call main

loop:
  # return from main
  j loop
