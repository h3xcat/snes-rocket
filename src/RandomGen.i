.ifndef ::__RANDOM_GEN__
::__RANDOM_GEN__ = 1
.global RandomByteSub

.macro RandomByte
	RW_push
	RW i16
	phy
	RW a8i8
	
	jsr RandomByteSub

	RW i16
	ply
	RW_pull
.endmacro

.macro RandomWord
	RW_push
	RW i16
	phy
	RW a8i8

	jsr RandomByteSub
	xba
	jsr RandomByteSub

	RW i16
	ply
	RW_pull
.endmacro



.endif; __RANDOM_GEN__