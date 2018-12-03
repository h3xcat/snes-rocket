.ifndef ::__STATES_MENU__
::__STATES_MENU__ = 1

.global StatesMenuInit

;===============================================================================

.macro WriteText Target Text X Y 
    RW_assume a8i16

    lda TXT_TITLE

AsciiLoop:
    beq EndLoadAscii

    sta Target, x
    sta Target+1, x

    lda TXT_TITLE, x
    jmp AsciiLoop
EndLoadAscii:

.endmacro

.endif; __STATE_MENU__