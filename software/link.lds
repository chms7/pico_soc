SECTIONS {
  . = 0x00000000;
	.init : {*(.init)}
  .text : {*(.text)}
  .data : {*(.data)}
  .bss  : {*(.bss)}
	. = 0x00010000;
	stack_top = .;
}

