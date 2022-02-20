    processor 6502

; include required files with VCS register memory mapping and macros

    include "vcs.h"
    include "macro.h"


; declare the variables starting from memory address $80

    seg.u Variables
    org $80

kyleXPos         byte         
kyleYPos         byte         


; start our ROM code at memory address $F000

    seg Code
    org $F000

Reset:
    CLEAN_START              


; main loop

StartFrame:

; display VSYNC and VBLANK

    lda #2
    sta VBLANK               ; turn on VBLANK
    sta VSYNC                ; turn on VSYNC
    REPEAT 3
        sta WSYNC            ; display 3 recommended lines of VSYNC
    REPEND
    lda #0
    sta VSYNC                ; turn off VSYNC
    REPEAT 37
        sta WSYNC            ; display the 37 recommended lines of VBLANK
    REPEND
    sta VBLANK               ; turn off VBLANK


; display the 192 visible scanlines of our main game

GameVisibleLine:

    ldx #192                 ; X counts the number of remaining scanlines
.GameLineLoop:
    sta WSYNC
    dex                      ; X--
    bne .GameLineLoop        ; repeat next main game scanline until finished


; dsplay overscan
    lda #2
    sta VBLANK               ; turn on VBLANK again
    REPEAT 30
        sta WSYNC            ; display 30 recommended lines of VBlank Overscan
    REPEND
    lda #0
    sta VBLANK               ; turn off VBLANK

; loop back to start a brand new frame
   
    jmp StartFrame           ; continue to display the next frame

; complete ROM size with exactly 4KB
   
    org $FFFC                ; move to position $FFFC
    word Reset               ; write 2 bytes with the program reset address
    word Reset               ; write 2 bytes with the interruption vector
