PHDRS
{
	headers PT_PHDR PHDRS ;
	text PT_LOAD FILEHDR PHDRS FLAGS(7);
	data PT_LOAD FLAGS(7) ;
	dynamic PT_DYNAMIC ;
}

ENTRY(_start)
SECTIONS
{
	. = SIZEOF_HEADERS ;
	.text : { *(.init*) *(.text*) } :text
	.rodata : { *(.rodata*) } :text
	.rel.dyn : { *(.rel) *(.rel.*) } :text
	.rela.dyn : { *(.rela) *(.rela.*) } :text
	.got : { *(.got*) } :data
	.data : { *(.data*) } :data
	.dynamic : { *(.dynamic) } :data :dynamic
	/DISCARD/ : { *(*) }
}
