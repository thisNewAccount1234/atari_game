;     processor 6502

; ; include required files with VCS register memory mapping and macros

;     include "vcs.h"
;     include "macro.h"


; ; declare the variables starting from memory address $80

;     seg.u Variables
;     org $80

; KyleXPos         byte         
; KyleYPos         byte         
; KyleSpritePtr    word         
; KyleColorPtr     word
; KyleOffset       byte           

; ; define constants

; KYLE_HEIGHT = 9  

; ; start our ROM code at memory address $F000

;     seg Code
;     org $F000

; Reset:
;     CLEAN_START              


; ; inititialize variables

;     lda #50
;     sta KyleXPos              
;     lda #60
;     sta KyleYPos               ; set Kyle x and y

;     lda #<KyleSprite
;     sta KyleSpritePtr         
;     lda #>KyleSprite
;     sta KyleSpritePtr+1        ; set low and high bytes of the sprite bitmap of Kyle sprite pointer

;     lda #<KyleColor
;     sta KyleColorPtr          
;     lda #>KyleColor
;     sta KyleColorPtr+1         ; set low and high bytes of the color bitmap of Kyle color pointer


; ; main loop

; StartFrame:

; ; display VSYNC and VBLANK

;     lda #2
;     sta VBLANK                 ; turn on VBLANK
;     sta VSYNC                  ; turn on VSYNC
    
;     sta WSYNC 
;     sta WSYNC 
;     sta WSYNC                  

;     lda #0
;     sta VSYNC                  ; turn off VSYNC

;     ldy #37
; .VBlankLoop:
;     sta WSYNC 
;     dey
;     bne .VBlankLoop

;     sta VBLANK                 ; turn off VBLANK


; ; display scanlines of game

; GameVisibleLine:
;     lda #$0
;     sta COLUBK                 ; set background to black

;     lda #$0E
;     sta COLUPF               ; set the terrain background color

;     lda #%00000001
;     sta CTRLPF               ; enable playfield reflection
;     lda #0
;     sta PF0                  ; setting PF0 bit pattern
;     lda #$04
;     sta PF1                  ; setting PF1 bit pattern
;     lda #0
;     sta PF2                  ; setting PF2 bit pattern


;     ldx #96                    ; x counts the number of remaining scanlines

; .GameLineLoop:
    
; .InsideKyleSprite:          
;     txa                        
;     sec                        
;     sbc KyleYPos               
;     cmp KYLE_HEIGHT            
;     bcc .DrawSpriteP0          
;     lda #0                     ; save a, set carry flag, subtract Kyle position, compare with height, jump to draw if within bounds

; .DrawSpriteP0:
;     clc                      
;     adc KyleOffset        
;     tay                      
;     lda (KyleSpritePtr),Y     
;     sta WSYNC                
;     sta GRP0                 
;     lda (KyleColorPtr),Y      
;     sta COLUP0                 ; get offset into y, jump to bitmap location for sprite plus y, load player register, jump to color location plus y, load color 

;     sta WSYNC                

;     dex                      
;     bne .GameLineLoop          ; decrement x, if not zero jump back up to GameLineLoop

;     lda #0
;     sta KyleOffset             ; reset Kyle offset

;     sta WSYNC                

; ; dsplay overscan

;     lda #2
;     sta VBLANK                 ; turn on VBLANK again

;     ldy #37
; .OverScanLoop:
;     sta WSYNC 
;     dey
;     bne .OverScanLoop

;     lda #0
;     sta VBLANK                 ; turn off VBLANK


; ; check joystick

; CheckP0Up:
;     lda #%00010000             
;     bit SWCHA
;     bne CheckP0Down          
;     inc KyleYPos
;     lda #0
;     sta KyleOffset             ; check if joystick up is pressed, if so increment y position, else fall through to next check

; CheckP0Down:
;     lda #%00100000          
;     bit SWCHA
;     bne EndInputCheck          
;     dec KyleYPos
;     lda #0
;     sta KyleOffset             ; check if joystick down is pressed, if so decrement y position, else fall through to end checks

; EndInputCheck:

; ; end of main loop, jump back to start 

;     jmp StartFrame           

; ; sprite and color bitmaps

; KyleSprite:
;     .byte #%00000000         ;
;     .byte #%00001111         ; #####  
;     .byte #%00001111         ; #####
;     .byte #%00001111         ; #####
;     .byte #%00001111         ; #####
;     .byte #%00001111         ; #####
;     .byte #%00001111         ; ##### 
;     .byte #%00001111         ; #####   
;     .byte #%00001111         ; #####   

; KyleColor:
;     .byte #$00
;     .byte #$0E
;     .byte #$0E
;     .byte #$0E
;     .byte #$0E
;     .byte #$0E
;     .byte #$0E
;     .byte #$0E
;     .byte #$0E

; ; complete ROM size with exactly 4KB
   
;     org $FFFC                ; move to position $FFFC
;     word Reset               ; write 2 bytes with the program reset address
;     word Reset               ; write 2 bytes with the interruption vector




















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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Start a new frame by configuring VBLANK and VSYNC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    lda #02
    sta VBLANK                 ; turn on VBLANK
    sta VSYNC                  ; turn on VSYNC
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Generate the three lines of VSYNC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    sta WSYNC 
    sta WSYNC 
    sta WSYNC                  

    lda #0
    sta VSYNC                  ; turn off VSYNC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Let the TIA output the 37 recommended lines of VBLANK
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ldy #37
.VBlankLoop:
    sta WSYNC 
    dey
    bne .VBlankLoop

    lda #0
    sta VBLANK     ; turn VBLANK off

;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Set the CTRLPF register to allow playfield reflect
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #%00000001			 ; CTRLPF register (D0 is the reflect flag)
    sta CTRLPF               ; enable playfield reflection
;-----------------------------------------------------------------------------

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Draw the 192 visible scanlines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   
    ; Skip 7 scanlines with no PF set
    ldx #0
    stx PF0
    stx PF1
    stx PF2
    REPEAT 7
        sta WSYNC
    REPEND

;------------------------------------------------------------------------------	
  
    ldx #89                    ; x counts the number of remaining scanlines

PlayfieldLoop
    sta WSYNC                       ; 3     (0)
    lda PFColors,x                  ; 4     (4)
    sta COLUPF                      ; 3     (7)
    lda PF0DataA,x                  ; 4     (11)
    sta PF0                         ; 3     (14)
    lda PF1DataA,x                  ; 4     (18)
    sta PF1                         ; 3     (21)
    lda PF2DataA,x                  ; 4     (25*)
    sta PF2                         ; 3     (28)





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










    dex                             ; 2     (65)
    bne PlayfieldLoop
   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Output 49 more VBLANK overscan lines to complete our frame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #2
    sta VBLANK     ; enable VBLANK back again
    REPEAT 49
       sta WSYNC   
    REPEND

; Skip 7 scanlines with no PF set
    ldx #0
    stx PF0
    stx PF1
    stx PF2
    REPEAT 7
        sta WSYNC
    REPEND




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
    bne EndInputCheck          
    dec KyleYPos
    lda #0
    sta KyleOffset             ; check if joystick down is pressed, if so decrement y position, else fall through to end checks

EndInputCheck:



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Loop to next frame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    jmp StartFrame

PF0DataA
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %10000000
	.byte %10000000
	.byte %10000000
	.byte %10000000
	.byte %10000000
	.byte %10000000
	.byte %10000000
	.byte %10000000
	.byte %10000000
	.byte %10000000
	.byte %10000000
	.byte %10000000
	.byte %10000000
	.byte %10000000
	.byte %10000000
	.byte %10000000
	.byte %10000000
	.byte %10000000
	.byte %10000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %10000000
	.byte %10000000
	.byte %10000000
	.byte %10000000
	.byte %10000000
	.byte %10000000
	.byte %10000000
	.byte %10000000
	.byte %10000000
	.byte %10000000
	.byte %10000000
	.byte %10000000
	.byte %10000000
	.byte %10000000
	.byte %10000000
	.byte %10000000
	.byte %10000000
	.byte %10000000
	.byte %10000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000


;    if >. != >[.+(PLAY_FIELD_LINES)]
;       align 256
;    endif

PF1DataA
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %11110000
	.byte %11110000
	.byte %00010000
	.byte %00010000
	.byte %00010000
	.byte %00010000
	.byte %00010000
	.byte %00010000
	.byte %00010000
	.byte %00010000
	.byte %00010000
	.byte %00010000
	.byte %00010000
	.byte %00010000
	.byte %00010000
	.byte %00010000
	.byte %00010000
	.byte %11110000
	.byte %11110000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %11110000
	.byte %11110000
	.byte %00010000
	.byte %00010000
	.byte %00010000
	.byte %00010000
	.byte %00010000
	.byte %00010000
	.byte %00010000
	.byte %00010000
	.byte %00010000
	.byte %00010000
	.byte %00010000
	.byte %00010000
	.byte %00010000
	.byte %00010000
	.byte %00010000
	.byte %11110000
	.byte %11110000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000


;    if >. != >[.+(PLAY_FIELD_LINES)]
;       align 256
;    endif

PF2DataA
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000
	.byte %00000000


;    if >. != >[.+(PLAY_FIELD_LINES)]
;       align 256
;    endif

PFColors
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E
   .byte $0E


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




