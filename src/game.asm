    processor 6502

; include required files with VCS register memory mapping and macros

    include "vcs.h"
    include "macro.h"


; declare the variables starting from memory address $80

    seg.u Variables
    org $80

KyleXPos         byte         
KyleYPos         byte         
KyleSpritePtr    word         
KyleColorPtr     word
KyleOffset       byte           

; define constants

KYLE_HEIGHT = 9  

; start our ROM code at memory address $F000

    seg Code
    org $F000

Reset:
    CLEAN_START              


; inititialize variables

    lda #50
    sta KyleXPos              
    lda #60
    sta KyleYPos               ; set Kyle x and y

    lda #<KyleSprite
    sta KyleSpritePtr         
    lda #>KyleSprite
    sta KyleSpritePtr+1        ; set low and high bytes of the sprite bitmap of Kyle sprite pointer

    lda #<KyleColor
    sta KyleColorPtr          
    lda #>KyleColor
    sta KyleColorPtr+1         ; set low and high bytes of the color bitmap of Kyle color pointer


; main loop

StartFrame:

; display VSYNC and VBLANK

    lda #2
    sta VBLANK                 ; turn on VBLANK
    sta VSYNC                  ; turn on VSYNC
    
    sta WSYNC 
    sta WSYNC 
    sta WSYNC                  

    lda #0
    sta VSYNC                  ; turn off VSYNC

    ldy #37
.VBlankLoop:
    sta WSYNC 
    dey
    bne .VBlankLoop

    sta VBLANK                 ; turn off VBLANK


; display scanlines of game

GameVisibleLine:
    lda #$0
    sta COLUBK                 ; set background to black

    ldx #96                    ; x counts the number of remaining scanlines

.GameLineLoop:
    
.InsideKyleSprite:          
    txa                        
    sec                        
    sbc KyleYPos               
    cmp KYLE_HEIGHT            
    bcc .DrawSpriteP0          
    lda #0                     ; save a, set carry flag, subtract Kyle position, compare with height, jump to draw if within bounds

.DrawSpriteP0:
    clc                      
    adc KyleOffset        
    tay                      
    lda (KyleSpritePtr),Y     
    sta WSYNC                
    sta GRP0                 
    lda (KyleColorPtr),Y      
    sta COLUP0                 ; get offset into y, jump to bitmap location for sprite plus y, load player register, jump to color location plus y, load color 

    sta WSYNC                

    dex                      
    bne .GameLineLoop          ; decrement x, if not zero jump back up to GameLineLoop

    lda #0
    sta KyleOffset             ; reset Kyle offset

    sta WSYNC                

; dsplay overscan

    lda #2
    sta VBLANK                 ; turn on VBLANK again

    ldy #37
.OverScanLoop:
    sta WSYNC 
    dey
    bne .OverScanLoop

    lda #0
    sta VBLANK                 ; turn off VBLANK


; check joystick

CheckP0Up:
    lda #%00010000             
    bit SWCHA
    bne CheckP0Down          
    inc KyleYPos
    lda #0
    sta KyleOffset             ; check if joystick up is pressed, if so increment y position, else fall through to next check

CheckP0Down:
    lda #%00100000          
    bit SWCHA
    bne CheckP0Left          
    dec KyleYPos
    lda #0
    sta KyleOffset             ; check if joystick down is pressed, if so decrement y position, else fall through to end checks

CheckP0Left:
    lda #%01000000
    bit SWCHA
    bne CheckP0Right
    dec KyleXPos
    lda #0
    sta KyleOffset             ; check if joystick down is pressed, if so decrement y position, else fall through to end checks

CheckP0Right:
    lda #%10000000
    bit SWCHA
    bne EndInputCheck
    inc KyleXPos
    lda #0
    sta KyleOffset             ; check if joystick down is pressed, if so decrement y position, else fall through to end checks
    
EndInputCheck:

; end of main loop, jump back to start 

    jmp StartFrame           

; sprite and color bitmaps

KyleSprite:
    .byte #%00000000         ;
    .byte #%00001111         ; #####  
    .byte #%00001111         ; #####
    .byte #%00001111         ; #####
    .byte #%00001111         ; #####
    .byte #%00001111         ; #####
    .byte #%00001111         ; ##### 
    .byte #%00001111         ; #####   
    .byte #%00001111         ; #####   

KyleColor:
    .byte #$00
    .byte #$0E
    .byte #$0E
    .byte #$0E
    .byte #$0E
    .byte #$0E
    .byte #$0E
    .byte #$0E
    .byte #$0E

; complete ROM size with exactly 4KB
   
    org $FFFC                ; move to position $FFFC
    word Reset               ; write 2 bytes with the program reset address
    word Reset               ; write 2 bytes with the interruption vector
