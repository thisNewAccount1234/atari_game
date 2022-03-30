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
SavedXPos        byte   
SavedYPos        byte          ; saved x and y positions for Kyle and enemy   

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
    sta SavedXPos          
    lda #60
    sta KyleYPos               
    sta SavedYPos              ; set Kyle x and y

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

    lda #$0E
    sta COLUPF               ; set the terrain background color

    lda #%00000001
    sta CTRLPF               ; enable playfield reflection
    lda #0
    sta PF0                  ; setting PF0 bit pattern
    sta PF1                  ; setting PF1 bit pattern
    sta PF2                  ; setting PF2 bit pattern

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

    txa 
    cmp #60
    bne .sides
    lda #$7E
    sta PF1
.sides
    cmp #58
    bne .bottom
    lda #$42
    sta PF1
.bottom
    cmp #40
    bne .end
    lda #$7E
    sta PF1
.end
    cmp #38
    bne .endBuilding
    lda #$0
    sta PF1
.endBuilding

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


TestCollisions:
    bit CXP0FB      
    bpl NoPlayFieldCollision     
    lda SavedXPos      
    sta KyleXPos     
    lda SavedYPos      
    sta KyleYPos               ; test Kyle collision with playfield, if collision save Kyle x and y

NoPlayFieldCollision:
    sta CXCLR                  ; clear collision flags

; check joystick

CheckP0Up:
    lda #%00010000             
    bit SWCHA
    bne CheckP0Down
    lda KyleYPos
    sta SavedYPos            
    inc KyleYPos
    lda #0
    sta KyleOffset             ; check if joystick up is pressed, if so save and increment y position, else fall through to next check

CheckP0Down:
    lda #%00100000          
    bit SWCHA
    bne CheckP0Left
    lda KyleYPos
    sta SavedYPos          
    dec KyleYPos
    lda #0
    sta KyleOffset             ; check if joystick down is pressed, if so save and decrement y position, else fall through to end checks

CheckP0Left:
    lda #%01000000
    bit SWCHA
    bne CheckP0Right
    lda KyleXPos
    sta SavedXPos  
    dec KyleXPos
    lda #0
    sta KyleOffset             ; check if joystick down is pressed, if so save and decrement y position, else fall through to end checks

CheckP0Right:
    lda #%10000000
    bit SWCHA
    bne EndInputCheck
    lda KyleXPos
    sta SavedXPos  
    inc KyleXPos
    lda #0
    sta KyleOffset             ; check if joystick down is pressed, if so save and decrement y position, else fall through to end checks
    
EndInputCheck:


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Set player horizontal position while in VBLANK
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda KyleXPos     ; load register A with desired X position
    and #$7F       ; same as AND 01111111, forces bit 7 to zero
                   ; keeping the result positive

    sec            ; set carry flag before subtraction

    sta WSYNC      ; wait for next scanline
    sta HMCLR      ; clear old horizontal position values

DivideLoop:
    sbc #15        ; Subtract 15 from A
    bcs DivideLoop ; loop while carry flag is still set

    eor #7         ; adjust the remainder in A between -8 and 7
    asl            ; shift left by 4, as HMP0 uses only 4 bits
    asl
    asl
    asl
    sta HMP0       ; set smooth position value
    sta RESP0      ; fix rough position
    sta WSYNC      ; wait for next scanline
    sta HMOVE      ; apply the fine position offset
;-------------------------------------------------------------------------------------------------------------------------------
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
