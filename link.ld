OUTPUT_ARCH(powerpc)
OUTPUT_FORMAT("elf32-powerpc")

ENTRY(_start)

MEMORY
{
	ram (rwx) : ORIGIN = 0x01000000, LENGTH = 64M
}

SECTIONS
{

	.text :
	{
		_stext = .;
		*(.text.entry)
		*(.text .text.*)
		*(.rodata .rodata.*)
		. = ALIGN(4);
		_etext = .;
	} > ram

	.data :
	{
		_sdata = .;
		*(.data .data.*)
		*(.sdata .sdata.*)
		. = ALIGN(4);
		_edata = .;
	} > ram

	_bss_start = .;
	.bss :
	{
		_sbss = .;
		*(.sbss .sbss.*)
		*(.scommon)
		*(.bss .bss.*)
		*(COMMON)
		. = ALIGN(4);
		_ebss = .;
	} > ram
	_bss_end = .;


	.stack (NOLOAD) :
	{
		. = ALIGN(16);
		_stack_bottom = .;
		. += 0x10000;
		_stack_top = .;
	} > ram

	/DISCARD/ :
	{
		*(.comment)
		*(.eh_frame)
	}
}
