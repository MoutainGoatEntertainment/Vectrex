;***************************************************************************
; DEFINE SECTION
;***************************************************************************
            include "VECTREX.I"
				
;; a has the register number, b the data
SOUND_BYTE_MACRO	macro
;	ldx		#$C800
;	stb		a, x
	sta		$D001
	lda		#$19
	sta		$D000
	lda		#$01
	sta		$D000
	lda		$D001
	stb		$D001
	ldb		#$11
	stb		$D000
	ldb		#$01
	stb		$D000
	endm

SOUND_BYTE2_MACRO	macro
	ldx		#$C800
	stb		a, x
	sta		VIA_port_a
	lda		#$19
	sta		VIA_port_b
	lda		#$01
	sta		VIA_port_b
	lda		VIA_port_a
	stb		VIA_port_a
	ldb		#$11
	stb		VIA_port_b
	ldb		#$01
	stb		VIA_port_b
	endm

STOP_SOUNDS macro
	ldb		#0
	lda		#8
	SOUND_BYTE_MACRO
	ldb		#0
	lda		#9
	SOUND_BYTE_MACRO
	ldb		#0
	lda		#10
	SOUND_BYTE_MACRO
	endm

	
	
RESET0REF_MACRO 	macro
		ldd   #$00CC
		stb   <VIA_cntl
		sta   <VIA_shift_reg
		ldd   #$0302
		clr   <VIA_port_a  
		sta   <VIA_port_b   
		stb   <VIA_port_b  
		stb   <VIA_port_b   
		ldb   #$01
		stb   <VIA_port_b   
		endm
		
MOVETOD_START_MACRO		macro
		sta		<VIA_port_a
		clr		<VIA_port_b
		lda		#$CE
		sta		<VIA_cntl
		clr		<VIA_shift_reg
		inc		<VIA_port_b 
		stb		<VIA_port_a 
		clr		<VIA_t1_cnt_hi 
		endm

MOVETOD_END_MACRO		macro
		local	movetod_loop
		ldb  	#$40
movetod_loop:   	
		bitb 	<VIA_int_flags
		beq  	movetod_loop
		endm

MOVETOD_END_MEASURE_MACRO		macro
		local	movetod_loop
		ldb  	#$40
movetod_loop:   
		inc		tempMovetoD
		bitb 	<VIA_int_flags
		beq  	movetod_loop
		endm
		
MOVETOD_MACRO		macro
		MOVETOD_START_MACRO
		MOVETOD_END_MACRO
		endm

		
INTENSITY_A_MACRO	macro
		sta		<VIA_port_a
		sta		$C827
		ldd		#$0504
		sta		<$0000
		stb		<$0000
		stb		<$0000
		ldb		#$01
		stb		<$0000
		endm	
		
RAND_MACRO			macro
		local rand_done
		lda 		seed
		asla
		bcc 		rand_done
		eora		#$1d
rand_done:  
		sta 		seed
		endm

DP2D0 macro
		lda   #0xD0
		tfr   a, dp
		direct -1
		endm

DP2C8 macro
		lda   #0xC8
		tfr   a,dp
		direct $C8
		endm

		
;***************************************************************************
; Constants
;***************************************************************************

GOAT_Y_START			equ	$C0

SMALL_JUMP_VELO		equ	$03E0
BIG_JUMP_VELO			equ	$0600
GRAVITY					equ	-$0040
MAX_FALL_SPEED			equ	$F9

GOAT_LEG_LEN			equ	0

MINIGOAT_WALK1			equ	0
MINIGOAT_WALK2			equ	2
MINIGOAT_UP			equ	4
MINIGOAT_DOWN			equ	6

SCREEN_FLIP_X			equ	1
SCREEN_FLIP_Y			equ	2

SCREEN_SPLASH			equ	0
SCREEN_GAME			equ	1
SCREEN_STAGE			equ	2
SCREEN_BETA			equ	3

; Timer period for PCM playback
; Vectrex clock period is 1 / 1500000 = 0.666 us
; 2 KHz samples have 500 us period for each sample
; 500 / 0.666 = 750 cycles in theory minus the time the code takes
; Would be around 700 but need to load little endian!
; 700 = $02BC ---> Load with $BC02
T2_TIMER_PEROID    	equ $BC02 

;***************************************************************************
; RAM variables
;***************************************************************************
;;; Random seed - do NOT initialize to 0 or 128
seed				equ	$C880	

displayPos			equ	$C881	; 2 bytes
displayFine		equ	$C883
elevationBottom	equ	$C884	; How far up we left off bottom
elevationTop		equ	$C885	; How far up we left off

goatY	          	equ $C8A6	; 2 bytes
veloY				equ	$C8A8	; 2 bytes

goatDrawState		equ	$C8AA	; Which goat to draw
frameCount			equ	$C8AB   ; Frame counter for animation
autoPlay			equ	$C8AC   ; Should the goat jump on its own

stage				equ	$C8AD	; Which stage are we on
stageLength		equ	$C8AE	; 2 bytes
playField			equ	$C8B0	; 2 bytes

bumpVL				equ	$C8B2	; 4 bytes up/down followed by 0 then 0,16 
hillVL				equ	$C8B6	; 6 bytes up/down followed by 0 then 8,8 -8,8 


collGoatY			equ	$C8BC
collCol0Y      	equ	$C8BD
collCol1Y   	  	equ	$C8BE
collCol2Y     		equ	$C8BF

flyCount			equ	$C8C1

goatPattern		equ	$C8C2
ignoreCollision	equ	$C8C3

screen				equ	$C8C4
goatEyeOffset		equ	$C8C5	; 2 bytes
	
goatYOffset		equ	$C8C7
goatXOffset		equ	$C8C8

attempts			equ	$C8C9	; 3 bytes 'score'
	
	
;; Music stuff	
;;   Reg     Ptr      Work
;;    0      $C902    $C918
;;    1      $C904    $C91A
;;    2      $C906    $C91C
;;    3      $C908    $C91E
;;    4      $C90A    $C920
;;    5      $C90C    $C922
;;    6      $C90E    $C924
;;    7      $C910    $C926
;;    8      $C912    $C928
;;    9      $C914    $C92A
;;    A      $C916    $C92C
ymSongFrames		equ $C900  ;; 2 bytes
ymRegPtrs	    	equ $C902 ;; 22 bytes
ymRegWork       	equ $C918 ;; 22 bytes
		
screenFlip			equ	$C9ED
screenFlipCoords	equ	$C9EE	; 2 bytes	
	
	
;;; Local loop and temp variables
loopI			equ	$C9F0
tempB1			equ	$C9F1
tempB2			equ	$C9F2
tempB3			equ	$C9F3
tempB4			equ	$C9F4
tempW1			equ	$C9F6
tempW2			equ	$C9F8
tempW3			equ	$C9FA		
tempMovetoD	equ	$C9FC

;***************************************************************************
; start of Vectrex memory with cartridge name...
		org     0
		direct -1
;***************************************************************************
; HEADER SECTION
;***************************************************************************
        db      "g GCE MGE ", $80   	; 'g' is copyright sign
        dw      silence	         	
        db      $F8, $50, $20, -$45 	; height, width, rel y, rel x
										; (from 0,0)
        db      "SGJ",$80   		; some game information,
										; ending with $80
		db		$F8, $50, $0, -$45
		db		"V0.6", $80
		
        db      0                   	; end of game header
;***************************************************************************
; CODE SECTION
;***************************************************************************

; here the cartridge program starts off
	jsr Init_OS

	;; Switch to a smaller font, the original height/width are $F8, $50
	lda		#$FB
	sta		$C82A
	lda		#$30
	sta		$C82B
	
	lda		#17
	sta		seed
	
	ldd		#0
	sta		frameCount
	sta		elevationBottom
	sta		elevationTop
	std		goatEyeOffset
	sta		goatYOffset
	sta		goatXOffset

	lda		#0
	sta		stage
	
	lda		#0
	sta		screenFlip
	sta		autoPlay
	sta		ignoreCollision
	
	jsr		Reset_level
	
	ldd		#$0000
	std		displayPos
	
	;; Set up a temp counter for the beta screen
	ldd		#250
	std		tempB1
	lda		#SCREEN_BETA
	sta		screen
	
	lda		#1
	sta		$C81F	; joystick 1 X - enable with 1
	lda		#3
	sta		$C820	; joystick 1 Y - enable with 3
;	lda		#5
;	sta		$C821 	; joystick 2 X - enable with 5
;	lda		#7
;	sta		$C822 	; joystick 2 Y - enable with 7

	;;  Initialize the bump vector list which is
	;;  X, 0
	;;  0, 16
	;;  where X is the up/down amount
	lda		#0
	sta		bumpVL
	sta		bumpVL + 1
	sta		bumpVL + 2
	lda		#16
	sta		bumpVL + 3

	;;  Initialize the hill vector list which is
	;;  X, 0
	;;  14, 8
	;;  -14, 8
	;;  where X is the up/down amount
	lda		#0
	sta		hillVL
	sta		hillVL + 1
	; Have to to this backwards since the draw loop keeps flipping the hill around
	lda		#8			 
	sta		hillVL + 3
	sta		hillVL + 5
	lda		#-14
	sta		hillVL + 2
	nega			 
	sta		hillVL + 4

	jsr		Init_stage
	
	ldy		#sgj_1
	jsr		Init_ym_music
	
main:
	lda		screen
	asla		
	ldx		#jump_table
	jmp		[a, x]
	
main_loop_return:

	bra		main


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	include "debug.i"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
Reset_level:

	ldd		#$0000
	std		displayPos
	
	lda		#GOAT_Y_START
	sta		goatY

	lda		#16
	sta		displayFine
	
	lda		#255
	lda		#255
	sta		goatPattern
	
	ldd		#$0000
	std		veloY
	
	lda		#MINIGOAT_DOWN
	sta		goatDrawState
	
	lda		#0
	sta		frameCount
	
	rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
Init_stage:
	lda		stage
	asla
	ldx		#stage_lengths
	ldd		a, x
	std		stageLength

	lda		stage
	asla
	ldx		#stages
	ldd		a, x
	std		playField

	lda		#0
	sta		attempts
	sta		attempts + 1
	inca
	sta		attempts + 2

	
	rts

	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
Play_pcm_sample:
;; d has address, x has length
	std		tempW1
	stx		tempW2
			
	addd		tempW2
	tfr		d, y			 

	lda     VIA_port_b
    anda    #$f8				; save top 5 bits, mask off bottom 3
    ora     #$06				; set S/H, SEL 0, SEL 1
    sta     tempB1     

	; Nothing on the screen
	clr     VIA_shift_reg

	clr		VIA_t2_hi
	; We will do an empty sample first
    ldd     #T2_TIMER_PEROID 
    std     VIA_t2_lo        

play_next_sample:			
	ldb     #$0020			; B-reg = T2 interrupt bit

wait_for_sample:			
    bitb    VIA_int_flags	; Wait for T2 to time out
    beq     wait_for_sample

	sta     VIA_port_a		; Sample on the data bus
			
	lda     tempB1
    sta     VIA_port_b  		; Turn on MUX to direct sound out
	nop	
    inc     VIA_port_b		; Disable the MUX
			
	; Restart timer
    ldd     #T2_TIMER_PEROID
    std     VIA_t2_lo        

			
    lda     ,-Y               ; load the next sample byte to A
    cmpy    tempW1
    bne     play_next_sample  

	lda		#$FF
	sta		VIA_shift_reg
	rts	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
Game_screen:	
	jsr     Wait_Recal 

	ldy		#0
	jsr		Play_ym_music	
	
	inc		frameCount
	
	; Check the joystick
	jsr		Joy_Digital

	; Do we need to adjust the Y offset?
	lda		$C81C
	bgt		y_offset_adjust_up
	blt		y_offset_adjust_down
	
	bra		y_offset_done

y_offset_adjust_up:	
	;; Adjust the fine position
	lda		goatYOffset
	inca
	sta		goatYOffset
	cmpa		#8
	blt		y_offset_done
	
	lda		#-7
	sta		goatYOffset
	
	bra		y_offset_done
	
y_offset_adjust_down:	
	;; Adjust the fine position
	lda		goatYOffset
	deca
	sta		goatYOffset
	cmpa		#-8
	bgt		y_offset_done
	
	lda		#7
	sta		goatYOffset
		
y_offset_done:
	lda		$C81B
	bgt		x_offset_adjust_up
	blt		x_offset_adjust_down
	
	bra		x_offset_done

x_offset_adjust_up:	
	;; Adjust the fine position
	lda		goatXOffset
	inca
	sta		goatXOffset
	cmpa		#8
	blt		x_offset_done
	
	lda		#-7
	sta		goatXOffset
	
	bra		x_offset_done
	
x_offset_adjust_down:	
	;; Adjust the fine position
	lda		goatXOffset
	deca
	sta		goatXOffset
	cmpa		#-8
	bgt		x_offset_done
	
	lda		#7
	sta		goatXOffset
		
x_offset_done:
	
	; Take care of button input - read the buttons
	;; All buttons with no debounce on jump buttons
	lda		#$03
	jsr		Read_Btns_Mask


	;; Escape?
	lda		$C811
	anda		#$01
	beq		no_escape
	
	;; Get out
	STOP_SOUNDS
	
	lda		#SCREEN_STAGE
	sta		screen
	jmp 		main_loop_return
	
no_escape:

	;; Turn autoplay on or off?
	lda		$C811
	anda		#$02
	beq		no_autoplay_change
	
	;; Flip it
	lda		autoPlay
	eora		#1
	sta		autoPlay
	
no_autoplay_change:
	
	; Take care of autoplay
	lda		autoPlay
	beq		no_autoplay
	
auto_play:
	;; Find the potential move
	ldd		#autoplay_moves_1
	addd		displayPos
	addd		#5
	std		tempW1
	ldx		tempW1

	lda		, x
	beq		move_done

	sta		tempB1
	
	;; Find the displayFine position we need to execute this move
	anda		#$1F
	cmpa		displayFine
	bne		move_done

	lda		tempB1
	
check_small_jump:
	anda		#$80
	beq		check_big_jump
	
	lda		#0
	jsr		Jump
	bra		move_done
	
check_big_jump:

	bra		move_done

	
no_autoplay:
	lda		$C811
	anda		#$08
	bne		jump_small
	
	lda		$C811
	anda		#$04
	bne		jump_big
	
	bra     move_done	; zero => No movement

	
jump_small:
	lda		#0
	jsr		Jump
	bra		move_done
	
jump_big:
	lda		#1
	jsr		Jump
	
	
move_done:
	jsr		Draw_terrain
	jsr		Scroll_terrain
	
	jsr		Draw_goat
	
	jsr		Draw_attempts
	jsr		Draw_progress_bar

	jsr		Check_collision
	
	jsr		Calculate_goat

;	lda		flyCount
;	lda		goatY
;	lda		displayPos + 1
;	adda		#5
;	jsr		Debug_A
	
	jsr		Check_collision
	
	jmp 		main_loop_return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
Stage_screen:	
	jsr     Wait_Recal 

	inc		frameCount

	jsr		Draw_goat_face
		
	jsr		Draw_stage_string
	
	; Take care of input - read the buttons
	lda		#$03
	jsr		Read_Btns_Mask

	; Button 4 - let's go(at)!
	lda		$C811
	anda		#$08
	beq     stage_screen_bottom	
	
play_game:
	;; Bleat
	ldd     #pcm_samples
	ldx     #NUM_PCM_SAMPLES
	jsr		Play_pcm_sample
	
	jsr		Init_stage
	jsr		Reset_level
	
	lda		#SCREEN_GAME
	sta		screen
	
stage_screen_bottom:
	jmp		main_loop_return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
Beta_screen:
	jsr     Wait_Recal 

	lda     #100	                    ; scaling factor 
	sta		VIA_t1_cnt_lo
	
	ldu		#sgj_beta_str1
	ldd		#$40C0
	jsr		Print_Str_d
	
	ldu		#sgj_beta_str2
	ldd		#$20C0
	jsr		Print_Str_d
	
	ldu		#sgj_beta_str3
	ldd		#$00C0
	jsr		Print_Str_d
	
	ldu		#sgj_beta_str4
	ldd		#$D0C0
	jsr		Print_Str_d
	
	ldu		#sgj_beta_str5
	ldd		#$C0C0
	jsr		Print_Str_d
	
	dec		tempB1
	bne		beta_screen_bottom
	
	lda		#SCREEN_STAGE
	sta		screen
	
beta_screen_bottom:
	jmp		main_loop_return
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
Draw_stage_string:

	lda		#$5F
    jsr     Intensity_a 
	
	lda		#$FF
	sta		Vec_Pattern
		
	lda     #120	                    ; scaling factor 
	sta		VIA_t1_cnt_lo           
	RESET0REF_MACRO	
	ldd		stage_s_moveto
	jsr		MGE_Moveto_d
	
	lda     #24	                    ; scaling factor 
	sta		VIA_t1_cnt_lo           
	ldx		#stage_s_vl
	lda		stage_s_len
	deca
	jsr		MGE_Draw_VL_a

	lda     #120	                    ; scaling factor 
	sta		VIA_t1_cnt_lo           
	RESET0REF_MACRO	
	ldd		stage_t_moveto
	jsr		MGE_Moveto_d
	
	lda     #24	                    ; scaling factor 
	sta		VIA_t1_cnt_lo           
	ldx		#stage_t_vl
	lda		stage_t_len
	deca
	jsr		MGE_Draw_VL_a

	lda     #120	                    ; scaling factor 
	sta		VIA_t1_cnt_lo           
	RESET0REF_MACRO	
	ldd		stage_a_moveto
	jsr		MGE_Moveto_d
	
	lda     #24	                    ; scaling factor 
	sta		VIA_t1_cnt_lo           
	ldx		#stage_a_vl
	lda		stage_a_len
	deca
	jsr		MGE_Draw_VL_a

	lda     #120	                    ; scaling factor 
	sta		VIA_t1_cnt_lo           
	RESET0REF_MACRO	
	ldd		stage_g_moveto
	jsr		MGE_Moveto_d
	
	lda     #24	                    ; scaling factor 
	sta		VIA_t1_cnt_lo           
	ldx		#stage_g_vl
	lda		stage_g_len
	deca
	jsr		MGE_Draw_VL_a

	lda     #120	                    ; scaling factor 
	sta		VIA_t1_cnt_lo           
	RESET0REF_MACRO	
	ldd		stage_e_moveto
	jsr		MGE_Moveto_d
	
	lda     #24	                    ; scaling factor 
	sta		VIA_t1_cnt_lo           
	ldx		#stage_e_vl
	lda		stage_e_len
	deca
	jsr		MGE_Draw_VL_a

	;; Now the stage number
	
	lda     #120	                    ; scaling factor 
	sta		VIA_t1_cnt_lo           
	RESET0REF_MACRO	
	ldd		#$0030
	jsr		MGE_Moveto_d
	
	lda     #80	                    ; scaling factor 
	sta		VIA_t1_cnt_lo    

	ldx		#stage_numbers
	lda		stage
	asla
	ldx		a, x
	lda		,x+
	deca
	
	
;	ldx		#stage_num_1_vl
;	lda		stage_num_1_len
;	deca
	jsr		MGE_Draw_VL_a

	
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Draw_attempts:
	;; Need to ignore the screen orientation
	lda		screenFlip
	pshs		a
	clr		screenFlip
	
	lda		#$5F
    jsr     Intensity_a 
	
	lda		#$FF
	sta		Vec_Pattern
		
	;; High digit
high_digit:
	lda     #132	                    ; scaling factor 
	sta		VIA_t1_cnt_lo           
	RESET0REF_MACRO	
	ldd		#$78C0
	jsr		MGE_Moveto_d
	
	lda     #24	                    ; scaling factor 
	sta		VIA_t1_cnt_lo           

	ldb		attempts
	bne		draw_high_digit
	
	;; Do we have a mid digit?
	ldb		attempts + 1
	bne		mid_digit
	
	bra		low_digit
	
draw_high_digit:
	aslb
	stb		tempB1
	ldy		#num_movetos;
	ldd		[b, y]
	jsr		MGE_Moveto_d
	
	ldb		tempB1
	ldy		#num_vls;
	ldx		b, y
	
	ldb		attempts
	ldy		#num_lens
	lda		b, y
	
	deca
	jsr		MGE_Draw_VL_a	
	
	;; Mid digit
mid_digit:
	lda     #132	                    ; scaling factor 
	sta		VIA_t1_cnt_lo           
	RESET0REF_MACRO	
	ldd		#$78C0
	jsr		MGE_Moveto_d
	
	lda     #24	                    ; scaling factor 
	sta		VIA_t1_cnt_lo           

	ldb		attempts + 1	
	aslb
	stb		tempB1
	ldy		#num_movetos;
	ldd		[b, y]
	addb		#42
	jsr		MGE_Moveto_d
	
	ldb		tempB1
	ldy		#num_vls;
	ldx		b, y
	
	ldb		attempts + 1
	ldy		#num_lens
	lda		b, y
	
	deca
	jsr		MGE_Draw_VL_a	
	
	;; Low digit
low_digit:
	lda     #132	                    ; scaling factor 
	sta		VIA_t1_cnt_lo           
	RESET0REF_MACRO	
	ldd		#$78C0
	jsr		MGE_Moveto_d
	
	lda     #24	                    ; scaling factor 
	sta		VIA_t1_cnt_lo           

	ldb		attempts + 2
	
	aslb
	stb		tempB1
	ldy		#num_movetos;
	ldd		[b, y]
	addb		#84
	jsr		MGE_Moveto_d
	
	ldb		tempB1
	ldy		#num_vls;
	ldx		b, y
	
	ldb		attempts + 2
	ldy		#num_lens
	lda		b, y
	
	deca
	jsr		MGE_Draw_VL_a	
	
	; Restore screen flip
	puls		a
	sta		screenFlip

	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Draw_progress_bar:
	;; Need to ignore the screen orientation
	lda		screenFlip
	pshs		a
	clr		screenFlip
	
	lda		#$FF
	sta		Vec_Pattern
		
	lda     #132	                    ; scaling factor 
	sta		VIA_t1_cnt_lo           

	lda		#$3F
    jsr     Intensity_a 

	; The little verticals first
	RESET0REF_MACRO	
	ldd		#$10A0
	jsr		MGE_Moveto_d
	
	ldx		#progress_bar_vl
	jsr		Draw_VL_mode
	
	lda		#$5F
    jsr     Intensity_a 

	; Now the line
	RESET0REF_MACRO	
	ldd		#$10A0
	jsr		MGE_Moveto_d
	
	; Math is 1/4-th of the displayPos
	ldb		displayPos + 1
	lsrb
	lsrb
	lda		displayPos
	beq		progress_math_done
	
	orb		#$40

progress_math_done:
	stb		tempB1
	lda		tempB1
	jsr		MGE_Moveto_d
	
	ldx		#progress_marker_vl
	jsr		Draw_VL_mode
	

	; Restore screen flip
	puls		a
	sta		screenFlip

	rts
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
Draw_goat_face:

	lda		#$5F
    jsr     Intensity_a 
	
	lda     #48	                    ; scaling factor 
	sta		VIA_t1_cnt_lo           

	lda		#$FF
	sta		Vec_Pattern
	
	ldd		#$00C0
	std		tempW1
	
	RESET0REF_MACRO
	ldd		tempW1
	jsr		MGE_Moveto_d
	
	lda		goatface_right_horn_moveto
	ldb		goatface_right_horn_moveto + 1
	jsr		MGE_Moveto_d
	
	ldx		#goatface_right_horn_vl
	lda		goatface_right_horn_len
	deca
	jsr		MGE_Draw_VL_a
	
	RESET0REF_MACRO
	ldd		tempW1
	jsr		MGE_Moveto_d
	
	lda		goatface_left_horn_moveto
	ldb		goatface_left_horn_moveto + 1
	jsr		MGE_Moveto_d
	
	ldx		#goatface_left_horn_vl
	lda		goatface_left_horn_len
	deca
	jsr		MGE_Draw_VL_a
	
	RESET0REF_MACRO
	ldd		tempW1
	jsr		MGE_Moveto_d
	
	lda		goatface_face_moveto
	ldb		goatface_face_moveto + 1
	jsr		MGE_Moveto_d
	
	ldx		#goatface_face_vl
	lda		goatface_face_len
	deca
	jsr		MGE_Draw_VL_a

	
	RESET0REF_MACRO
	ldd		tempW1
	jsr		MGE_Moveto_d
	
	lda		goatface_nose_moveto
	ldb		goatface_nose_moveto + 1
	jsr		MGE_Moveto_d
	
	ldx		#goatface_nose_vl
	lda		goatface_nose_len
	deca
	jsr		MGE_Draw_VL_a

	RESET0REF_MACRO
	ldd		tempW1
	jsr		MGE_Moveto_d
	
	lda		goatface_mouth_moveto
	ldb		goatface_mouth_moveto + 1
	jsr		MGE_Moveto_d
	
	ldx		#goatface_mouth_vl
	lda		goatface_mouth_len
	deca
	jsr		MGE_Draw_VL_a

	RESET0REF_MACRO
	ldd		tempW1
	jsr		MGE_Moveto_d
	
	lda		goatface_goatee_moveto
	ldb		goatface_goatee_moveto + 1
	jsr		MGE_Moveto_d
	
	ldx		#goatface_goatee_vl
	lda		goatface_goatee_len
	deca
	jsr		MGE_Draw_VL_a

	RESET0REF_MACRO
	ldd		tempW1
	jsr		MGE_Moveto_d
	
	lda		goatface_right_ear_moveto
	ldb		goatface_right_ear_moveto + 1
	jsr		MGE_Moveto_d
	
	ldx		#goatface_right_ear_vl
	lda		goatface_right_ear_len
	deca
	jsr		MGE_Draw_VL_a

	RESET0REF_MACRO
	ldd		tempW1
	jsr		MGE_Moveto_d
	
	lda		goatface_left_ear_moveto
	ldb		goatface_left_ear_moveto + 1
	jsr		MGE_Moveto_d
	
	ldx		#goatface_left_ear_vl
	lda		goatface_left_ear_len
	deca
	jsr		MGE_Draw_VL_a

	RESET0REF_MACRO
	ldd		tempW1
	jsr		MGE_Moveto_d
	
	lda		goatface_right_eye_moveto
	ldb		goatface_right_eye_moveto + 1
	jsr		MGE_Moveto_d
	
	ldx		#goatface_right_eye_vl
	lda		goatface_right_eye_len
	deca
	jsr		MGE_Draw_VL_a

	RESET0REF_MACRO
	ldd		tempW1
	jsr		MGE_Moveto_d
	
	lda		goatface_left_eye_moveto
	ldb		goatface_left_eye_moveto + 1
	jsr		MGE_Moveto_d
	
	ldx		#goatface_left_eye_vl
	lda		goatface_left_eye_len
	deca
	jsr		MGE_Draw_VL_a

	; The eyes are the brightest
	lda		#$7F
    jsr     Intensity_a 

	lda		frameCount
	cmpa		#40
	bne		draw_eyes
	
	clr		frameCount
	
	RAND_MACRO
	anda		#3
	asla
	sta		goatEyeOffset
	RAND_MACRO
	anda		#3
	asla
	sta		goatEyeOffset + 1
	
	
draw_eyes:

	RESET0REF_MACRO
	ldd		tempW1
	jsr		MGE_Moveto_d
	
	ldd		goatface_left_eye_moveto
	addd		#$00F5
	addd		goatEyeOffset
	jsr		MGE_Moveto_d
	jsr		Dot_here

	RESET0REF_MACRO
	ldd		tempW1
	jsr		MGE_Moveto_d

	ldd		goatface_right_eye_moveto
	addd		#$F905
	addd		goatEyeOffset
	jsr		MGE_Moveto_d
	jsr		Dot_here

	rts
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
Jump:
	;; Save the jump size in a
	sta		tempB1
	
	clr		flyCount
	;; Check if the goat is airborne
	;; Cheating a little goatDrawState > MINIGOAT_WALK2 
	;;    --> Goat is not walking
	lda		goatDrawState
	cmpa		#MINIGOAT_WALK2
	bgt		jump_done
	
	;; Goat is going up
	lda		#MINIGOAT_UP
	sta		goatDrawState
	
	;; How big of a jump?
	lda		tempB1
	bne		big_jump
	
small_jump:
	ldd		#SMALL_JUMP_VELO
	std		veloY

	bra		jump_done

big_jump:
	ldd		#BIG_JUMP_VELO
	std		veloY
	
jump_done:
	rts
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
Calculate_goat:
	;; If the goat is walking, nothing to do here
	lda		goatDrawState
	cmpa		#MINIGOAT_WALK2
	bgt		goat_projectile
	
	; Check if the ground has fallen from our feet
	ldd		playField
	addd		displayPos
	addd		#4
	std		tempW1
	ldx		tempW1
	lda		,x
	;; No hill flag and also adjust offset
	anda		#$7
	adda		#8
	sta		tempB1
	
	;; Check the height
	lda		goatY
	lsra
	lsra
	lsra
	lsra
	
	cmpa		tempB1
	bgt		falling
	
	lda		frameCount
	lsra
	anda		#1
	asla		
	sta		goatDrawState

	jmp		calculate_done

falling:
	lda		#MINIGOAT_DOWN
	sta		goatDrawState
	jmp		calculate_done
	
goat_projectile:	
	inc		flyCount

	;; Goat is a projectile - let gravity take its course
	;; v_y = v_y + gravity
	ldd		#GRAVITY
	addd		veloY
	std		veloY
	
	; Make sure that the goat cannot fall faster than a max
	cmpa		#MAX_FALL_SPEED
	bgt		no_max_fall
	
	lda		#MAX_FALL_SPEED
	sta		veloY
	
no_max_fall:
	lda		veloY
	
	bgt		goat_up
	
goat_down:
	lda		#MINIGOAT_DOWN
	sta		goatDrawState
	
	;; See if we can land on the terrain
	ldd		playField
	addd		displayPos
	addd		#4
	std		tempW1
	ldx		tempW1
	lda		,x
	sta		tempB1
	;; Cannot land on a hill
	anda		#$8
	bne		goat_updown_done
	
	;; Need to get to comparable numbers
	lda		tempB1
	adda		#8
	sta		tempB1
	
	;; Check the height
	lda		goatY
	lsra
	lsra
	lsra
	lsra
	
	cmpa		tempB1
	bne		goat_updown_done
	
	
goat_land_leg_check:
	;; Recheck the height with legs included
	lda		goatY
	suba		#GOAT_LEG_LEN
	lsra
	lsra
	lsra
	lsra
	
	cmpa		tempB1
	bne		goat_updown_done
	
the_goat_has_landed:
	suba		#8
	ldx		#goat_levels
	lda		a, x
	sta		goatY
	
	ldd		#0
	std		veloY
	
	lda		#MINIGOAT_WALK1
	sta		goatDrawState
	
	bra		calculate_done

goat_up:
	lda		#MINIGOAT_UP
	sta		goatDrawState
	
goat_updown_done:
	ldd		veloY
	;; y = y + v_y
	addd		goatY
	std		goatY

;	lda		goatY
;	jsr		Debug_A
;	lda		goatY
	
	cmpa		#110
	blt		y_not_too_big
	lda		#110
	sta		goatY
	
y_not_too_big
	cmpa		#-120
	bgt		calculate_done
	lda		#-115
	sta		goatY
	ldd		#0
	std		veloY

	lda		frameCount
	lsra
	anda		#1
	asla		
	sta		goatDrawState
	
calculate_done:
	rts
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
Check_collision:
;	Which play field positions to check for
;	 collisions at goat, one ahead and two ahead
;	 for each displayFine value for the same
;	 horizontal level
;  
;	Fine   Hill           Bump
;          0 1 2          0 1 2
;	10     - + -          + + -
;	 E     - + -          + + +
;	 C     - + -          + + +
;	 A     - + +          - + +
;	 8     - + +          - + +
;	 6     - + +          - + +
;	 4     - + +          - + +
;	 2     - - +          - + +

	; Load and save the check flags
	lda		displayFine
	ldx		#collision_check_flags
	lda		a, x
	sta		tempB1

	; By default the goat pattern is all solid
	lda		#255
	sta		goatPattern
	
	; Translate the goat Y coordinate
	lda		goatY
	bge		pos_goat_y
	
neg_goat_y:
	lsra
	lsra
	lsra
	lsra
	suba		#8
	sta		collGoatY
	bra		goat_y_ok

pos_goat_y:
	lsra
	lsra
	lsra
	lsra
	adda		#8
	sta		collGoatY
goat_y_ok:
	; Get the first column we should look at
	ldd		playField
	addd		displayPos
	addd		#3
	std		tempW1
	ldx		tempW1

	lda		,x+
	sta		collCol0Y
	lda		,x+
	sta		collCol1Y
	lda		,x
	sta		collCol2Y

	; Looking at column 0 (just behind the goat)
check_0:
	lda		collCol0Y
	
	anda		#$8
	beq		check_bump_0
	
	; It's s hill, watch that mini-peak
check_hill_0:
	lda		tempB1
	anda		#$40
	beq		check_1
	
	lda		collCol0Y
	anda		#7
	cmpa		collGoatY
	bge		collision
	
	bra		check_1

	; It's a bump bro
check_bump_0:
	lda		tempB1
	anda		#$04
	beq		check_1
	
	lda		collCol0Y
	cmpa		collGoatY
	bgt		collision
	
;	bra		check_1
	
	; Looking at column 1 (just under the goat)
check_1:
	lda		collCol1Y

	anda		#$8
	beq		check_bump_1
	
	; It's s hill, watch that mini-peak
check_hill_1:
	lda		tempB1
	anda		#$20
	beq		check_2
	
	lda		collCol1Y
	anda		#7
	cmpa		collGoatY
	bge		collision
	
	bra		check_2

	; It's a bump bro
check_bump_1:
	lda		tempB1
	anda		#$02
	beq		check_2
	
	lda		collCol1Y
	cmpa		collGoatY
	bgt		collision
	
;	bra		check_2

	; Looking at column 2 (just ahead of the goat)
check_2:
	lda		collCol2Y

	anda		#$8
	beq		check_bump_2
	
	; It's s hill, watch that mini-peak
check_hill_2:
	lda		tempB1
	anda		#$10
	lbeq		check_collision_done
	
	lda		collCol2Y
	anda		#7
	cmpa		collGoatY
	bge		collision
	
	jmp		check_collision_done

	; It's a bump bro
check_bump_2:
	lda		tempB1
	anda		#$01
	lbeq		check_collision_done
	
	lda		collCol2Y
	cmpa		collGoatY
	bgt		collision
	
	lbra		check_collision_done
	
collision:
	lda		ignoreCollision
	beq		real_collision
	
collision_ignored:
	RESET0REF_MACRO
	
	lda     #120	                    ; scaling factor 
	sta		VIA_t1_cnt_lo           

	lda		#0
	ldb		#0
	jsr		MGE_Moveto_d
	
	lda     #10	                    ; scaling factor 
	sta		VIA_t1_cnt_lo           
	
	lda		#$F0
	sta		goatPattern
	sta		Vec_Pattern
	
	ldx		#explosion_vector_list
	lda		#EXPLOSION_LIST_LEN - 1	
	jsr		MGE_Draw_VL_a
	jmp		check_collision_done
	
real_collision:
	; 1 second of grief - reuse the ignoreCollision variable
	lda		#50
	sta		ignoreCollision
	
	ldy		#sgj_loss
	jsr		Reinit_ym_music
	
real_collision_loop:
	jsr		Wait_Recal

	jsr		Play_ym_music	
	
	jsr		Draw_terrain

	RAND_MACRO
	sta		goatPattern
	sta		Vec_Pattern
	
	jsr		Draw_goat

	dec		ignoreCollision
	bne		real_collision_loop
	
	jsr		Reset_level
	
	ldy		#sgj_1
	jsr		Reinit_ym_music
	
	;; Increase attempts
	lda		attempts + 2
	inca
	sta		attempts + 2
	cmpa		#10
	blt		attempts_done
	
	;; Need to go up a digit
	clr 		attempts + 2
	lda		attempts + 1
	inca
	sta		attempts + 1
	cmpa		#10
	blt		attempts_done
	
	;; Need to go up a digit
	clr 		attempts + 1
	lda		attempts + 0
	inca
	sta		attempts + 0
	cmpa		#10
	blt		attempts_done

	clr 		attempts + 0
	
attempts_done:
		
check_collision_done:
	rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
Draw_goat:

	lda		#$7f
	INTENSITY_A_MACRO

	RESET0REF_MACRO

	lda     #120	                    ; scaling factor 
	sta		VIA_t1_cnt_lo           

	lda		goatY
	adda		goatYOffset
	ldb		#-39
	addb		goatXOffset
	jsr		MGE_Moveto_d


;	clr		tempMovetoD
;	MOVETOD_START_MACRO	
;	MOVETOD_END_MEASURE_MACRO	

	
	lda     #6	                    ; scaling factor 
	sta		VIA_t1_cnt_lo           

	lda		goatPattern
	sta		Vec_Pattern

	lda		goatDrawState
	ldx		#minigoat_vectors
	ldx		a, x
	lda		#MINIGOAT_LIST_LEN - 1
	jsr		MGE_Draw_VL_a

	rts
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
Scroll_terrain:
	;; Decrement by 2 for fast speed
	lda		displayFine
	deca
	deca
	bgt		fine_fine
	
	;; Increment the display position
	ldd		displayPos
	addd		#1
	std		displayPos

	cmpd		stageLength
	ble		reset_fine
	
	;; Reset for now - new stage later
	ldd		#$0000
	std		displayPos
	
reset_fine:
	; Reset displayFine
	lda		#16	

fine_fine:
	sta		displayFine

	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;			
Draw_terrain:

    lda     #120	                    ; scaling factor 
	sta		VIA_t1_cnt_lo           

	lda		#$FF
	sta		Vec_Pattern
	
	RESET0REF_MACRO

	lda		#-123
	ldb		#-127
	jsr		MGE_Moveto_d

	
	;; Make the hills protrude up
	lda		hillVL + 2
	nega		
	sta		hillVL + 2
	lda		hillVL + 4
	nega		
	sta		hillVL + 4
	
	;; Index into the playfield
	ldd		playField
	addd		displayPos
	std		tempW1

	ldx		tempW1
	lda		,x
	anda		#$7
	sta		elevationBottom
	asla
	asla
	asla
	asla
	ldb		displayFine
	jsr		MGE_Moveto_d

	
	lda		#16
	sta		loopI
	
draw_terrain_up_loop:
	ldx		#terrain_intensity
	lda		loopI
	lda		a, x
	INTENSITY_A_MACRO

	ldx		tempW1
	ldb		,x

	;; B3 has the type - bump or hill
	stb		tempB3
	
	;; Get the current elevation into b
	andb		#$7
	stb		tempB2
	
	;; Subtract the previous elevation from this
	subb		elevationBottom
	aslb
	aslb
	aslb
	aslb
	
	lda		tempB3
	anda		#8
	bne		draw_hill_bottom
	
draw_bump_bottom:
	stb		bumpVL
		
	ldx		#bumpVL
	lda		#1
	jsr		MGE_Draw_VL_a
	bra		draw_hill_bump_bottom_ok
	
draw_hill_bottom:
	stb		hillVL
		
	ldx		#hillVL
	lda		#2
	jsr		MGE_Draw_VL_a

draw_hill_bump_bottom_ok:	
	;; Update the current elevation
	lda		tempB2
	sta		elevationBottom

	ldd		tempW1
	addd		#1
	std		tempW1
	
	dec		loopI
	bne		draw_terrain_up_loop

	
	;; down
	RESET0REF_MACRO

	lda		#120
	ldb		#-127
	jsr		MGE_Moveto_d

	;; Make the hills protrude down
	lda		hillVL + 2
	nega		
	sta		hillVL + 2
	lda		hillVL + 4
	nega		
	sta		hillVL + 4

	jmp		draw_terrain_done

	;; Index into the playfield
	ldd		playField
	addd		displayPos
	std		tempW1

	ldx		tempW1
	lda		,x
	anda		#$70
	sta		elevationTop
	nega
	ldb		displayFine
	jsr		MGE_Moveto_d
	
		
	;; Still need to adjust elevationTop to lower 4 bits
	lda		elevationTop
	lsra
	lsra
	lsra
	lsra
	sta		elevationTop
	
	lda		#16
	sta		loopI
	
draw_terrain_down_loop:
	ldx		#terrain_intensity
	lda		loopI
	lda		a, x
	INTENSITY_A_MACRO

	ldx		tempW1
	ldb		,x

	;; B3 has the type - bump or hill
	stb		tempB3
	
	;; Get the current elevation into b
	andb		#$70
	lsrb
	lsrb
	lsrb
	lsrb
	stb		tempB2

	;; Subtract the previous elevation from this
	subb		elevationTop
	aslb
	aslb
	aslb
	aslb
	;; Need to go the opposite direction
	negb
	
	lda		tempB3
	anda		#$80
	bne		draw_hill_top
	
draw_bump_top:
	stb		bumpVL
	
	ldx		#bumpVL
	lda		#1
	jsr		MGE_Draw_VL_a
	bra		draw_hill_bump_top_ok

draw_hill_top:
	stb		hillVL
	
	ldx		#hillVL
	lda		#2
	jsr		MGE_Draw_VL_a
	
draw_hill_bump_top_ok:
	;; Update the current elevation
	lda		tempB2
	sta		elevationTop

	ldd		tempW1
	addd		#1
	std		tempW1
	
	dec		loopI
	bne		draw_terrain_down_loop

draw_terrain_done:

	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;			
Init_ym_music:

	ldx		#ymRegPtrs
	ldb		#43
	jsr		Clear_x_b
Reinit_ym_music:
	;; y reg has the song structure
	ldd		0, y
	std		ymSongFrames

	;; Move up two bytes in the structure
	sty		tempW1
	inc 		tempW1 + 1
	inc		tempW1 + 1
	
	ldy		#ymRegPtrs
	ldx		#ymRegWork
	
	clra
	sta		loopI
	
init_ym_music_loop:
	lda		loopI
	asla
	
	ldu		[tempW1]
	stu		a, y
	ldu		[a, y]
	stu		a, x
	
	;; Next channel 2 up
	ldd		tempW1
	addd		#2
	std		tempW1

	;; Loop
	inc		loopI
	lda		loopI
	cmpa		#11
	bne		init_ym_music_loop
	
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;			
Play_ym_music:
    ldd     ymSongFrames
    lbeq		play_ym_music_done
	
reg_0:

	ldd		ymRegWork + 0
	cmpa		#0
	bne		play_byte_0
	
	;; Need to get the next byte-pair
	ldd		ymRegPtrs + 0
	addd		#2
	std		ymRegPtrs + 0
	ldd		[ymRegPtrs + 0]
	std		ymRegWork + 0
	
play_byte_0:
	;; Decrease counter
	deca
	sta		ymRegWork + 0
	
	lda		#0
	SOUND_BYTE_MACRO
	
reg_1:
	ldd		ymRegWork + 2
	cmpa		#0
	bne		play_byte_1
	
	;; Need to get the next byte-pair
	ldd		ymRegPtrs + 2
	addd		#2
	std		ymRegPtrs + 2
	ldd		[ymRegPtrs + 2]
	std		ymRegWork + 2
	
play_byte_1:
	;; Decrease counter
	deca
	sta		ymRegWork + 2
	
	lda		#1
	SOUND_BYTE_MACRO
	
reg_2:
	ldd		ymRegWork + 4
	cmpa		#0
	bne		play_byte_2
	
	;; Need to get the next byte-pair
	ldd		ymRegPtrs + 4
	addd		#2
	std		ymRegPtrs + 4
	ldd		[ymRegPtrs + 4]
	std		ymRegWork + 4
	
play_byte_2:
	;; Decrease counter
	deca
	sta		ymRegWork + 4
	
	lda		#2
	SOUND_BYTE_MACRO
	
reg_3:
	ldd		ymRegWork + 6
	cmpa		#0
	bne		play_byte_3
	
	;; Need to get the next byte-pair
	ldd		ymRegPtrs + 6
	addd		#2
	std		ymRegPtrs + 6
	ldd		[ymRegPtrs + 6]
	std		ymRegWork + 6
	
play_byte_3:
	;; Decrease counter
	deca
	sta		ymRegWork + 6
	
	lda		#3
	SOUND_BYTE_MACRO
	
reg_4:
	ldd		ymRegWork + 8
	cmpa		#0
	bne		play_byte_4
	
	;; Need to get the next byte-pair
	ldd		ymRegPtrs + 8
	addd		#2
	std		ymRegPtrs + 8
	ldd		[ymRegPtrs + 8]
	std		ymRegWork + 8
	
play_byte_4:
	;; Decrease counter
	deca
	sta		ymRegWork + 8
	
	lda		#4
	SOUND_BYTE_MACRO
	
reg_5:
	ldd		ymRegWork + 10
	cmpa		#0
	bne		play_byte_5
	
	;; Need to get the next byte-pair
	ldd		ymRegPtrs + 10
	addd		#2
	std		ymRegPtrs + 10
	ldd		[ymRegPtrs + 10]
	std		ymRegWork + 10
	
play_byte_5:
	;; Decrease counter
	deca
	sta		ymRegWork + 10
	
	lda		#5
	SOUND_BYTE_MACRO
	
reg_6:
	ldd		ymRegWork + 12
	cmpa		#0
	bne		play_byte_6
	
	;; Need to get the next byte-pair
	ldd		ymRegPtrs + 12
	addd		#2
	std		ymRegPtrs + 12
	ldd		[ymRegPtrs + 12]
	std		ymRegWork + 12
	
play_byte_6:
	;; Decrease counter
	deca
	sta		ymRegWork + 12
	
	lda		#6
	SOUND_BYTE_MACRO
	
reg_7:
	ldd		ymRegWork + 14
	cmpa		#0
	bne		play_byte_7
	
	;; Need to get the next byte-pair
	ldd		ymRegPtrs + 14
	addd		#2
	std		ymRegPtrs + 14
	ldd		[ymRegPtrs + 14]
	std		ymRegWork + 14
	
play_byte_7:
	;; Decrease counter
	deca
	sta		ymRegWork + 14
	
	lda		#7
	SOUND_BYTE_MACRO
	
reg_8:
	ldd		ymRegWork + 16
	cmpa		#0
	bne		play_byte_8
	
	;; Need to get the next byte-pair
	ldd		ymRegPtrs + 16
	addd		#2
	std		ymRegPtrs + 16
	ldd		[ymRegPtrs + 16]
	std		ymRegWork + 16
	
play_byte_8:
	;; Decrease counter
	deca
	sta		ymRegWork + 16
	
	lda		#8
	SOUND_BYTE_MACRO
	
reg_9:
	ldd		ymRegWork + 18
	cmpa		#0
	bne		play_byte_9
	
	;; Need to get the next byte-pair
	ldd		ymRegPtrs + 18
	addd		#2
	std		ymRegPtrs + 18
	ldd		[ymRegPtrs + 18]
	std		ymRegWork + 18
	
play_byte_9:
	;; Decrease counter
	deca
	sta		ymRegWork + 18
	
	lda		#9
	SOUND_BYTE_MACRO
	
reg_10:
	ldd		ymRegWork + 20
	cmpa		#0
	bne		play_byte_10
	
	;; Need to get the next byte-pair
	ldd		ymRegPtrs + 20
	addd		#2
	std		ymRegPtrs + 20
	ldd		[ymRegPtrs + 20]
	std		ymRegWork + 20
	
play_byte_10:
	;; Decrease counter
	deca
	sta		ymRegWork + 20
	
	lda		#10
	SOUND_BYTE_MACRO
		
	ldd     ymSongFrames
	subd    #1
	std     ymSongFrames
	rts
	
play_ym_music_done:
	ldy		#sgj_1
	jsr		Reinit_ym_music
;	jsr		Clear_Sound
	rts



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MGE_Draw_VL_a:      
	sta     $C823
MGE_Draw_VL:        
	ldd     ,X
	std		screenFlipCoords
	; Check the screen flip	
	ldb		screenFlip
	andb		#SCREEN_FLIP_X
	beq		no_x_flip
	
	lda		screenFlipCoords + 1
	nega
	sta		screenFlipCoords + 1

no_x_flip:
	ldb		screenFlip
	andb		#SCREEN_FLIP_Y
	beq		no_y_flip
	
	lda		screenFlipCoords
	nega
	sta		screenFlipCoords

no_y_flip:
	ldd		screenFlipCoords
   
	sta     <VIA_port_a     ;Send Y to A/D
    clr     <VIA_port_b     ;Enable mux
    leax    2,X             ;Point to next coordinate pair
    nop                     ;Wait a moment
    inc     <VIA_port_b     ;Disable mux
    stb     <VIA_port_a     ;Send X to A/D
	lda     Vec_Pattern
    ldb     #$00          ;Shift reg=$FF (solid line), T1H=0
          
	sta     <VIA_shift_reg  ;Put pattern in shift register
    stb     <VIA_t1_cnt_hi  ;Set T1H (scale factor?)
    ldd     #$0040          ;B-reg = T1 interrupt bit
LF3F4:          
	bitb    <VIA_int_flags  ;Wait for T1 to time out
    beq     LF3F4
    nop                     ;Wait a moment more
    sta     <VIA_shift_reg  ;Clear shift register (blank output)
    lda     $C823           ;Decrement line count
    deca
    bpl     MGE_Draw_VL_a       ;Go back for more points
    
	rts

	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MGE_Moveto_d:
	std		screenFlipCoords
	; Check the screen flip	
	ldb		screenFlip
	andb		#SCREEN_FLIP_X
	beq		move_no_x_flip
	
	lda		screenFlipCoords + 1
	nega
	sta		screenFlipCoords + 1

move_no_x_flip:
	ldb		screenFlip
	andb		#SCREEN_FLIP_Y
	beq		move_no_y_flip
	
	lda		screenFlipCoords
	nega
	sta		screenFlipCoords

move_no_y_flip:
	ldd		screenFlipCoords

	sta		<VIA_port_a
	clr		<VIA_port_b
	lda		#$CE
	sta		<VIA_cntl
	clr		<VIA_shift_reg
	inc		<VIA_port_b 
	stb		<VIA_port_a 
	clr		<VIA_t1_cnt_hi 

	ldb  	#$40
mge_movetod_loop:   	
	bitb 	<VIA_int_flags
	beq  	mge_movetod_loop
	
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;    DATA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
adsr_beep:
				fdb $aaaa,$aaaa,$8888,$4444,$0000,$0000,$0000,$0000
silence:
				fdb		adsr_beep, $FEB6
				fcb		30, $80	


jump_table:
		dw	Splash_screen
		dw	Game_screen
		dw	Stage_screen
		dw	Beta_screen

Splash_screen:



sgj_beta_str1:
		db	'SUPER GOAT JUMPER'
		db	$80	
sgj_beta_str2:
		db	'NON PUBLIC BETA'
		db	$80	
sgj_beta_str3:
		db	'MOUNTAIN GOAT 2016'
		db	$80	
sgj_beta_str4:
		db	'PLEASE'
		db	$80	
sgj_beta_str5:
		db	'DO NOT DISTRIBUTE'
		db	$80	
		

	
; Which columns to check for collisions
collision_check_flags:
    ;		Higher nibble for hill, lower for Bump
	db		$0 
	db 		$13, $13	; 1-2
	db		$33, $33	; 3-4
	db		$33, $33	; 5-6
	db		$33, $33	; 7-8
	db		$33, $33	; 9-A
	db		$27, $27	; B-C
	db		$27, $27	; D-E
	db		$26, $26	; F-10

; How long the stages are
stage_lengths:
	dw		$0180
	dw		$0020
	
; Pointer to the playfields
stages:
	dw		stage_1
	dw		stage_2

; Goat walk levels
goat_levels:
	db	$8B, $9B, $AB, $BB, $CB, $DB, $EB, $0B, $1B, $2B, $3B, $4B, $5B, $6B, $7B


; Intensity levels for terrain display
terrain_intensity:
	db	$1f, $1f, $3f, $5f, $5f, $5f, $5f, $5f, $5f, $5f, $5f, $5f, $5f, $4f, $3f, $2f, $1f

	
progress_bar_vl:
	db	$02, $60, $60
	db	$02, -$30, $30
	db	$00, -$20, -$20
	db	$02, $30, $30
	db	$02, -$30, $30
	db	$01

progress_marker_vl:
	db	$02, 9, -3
	db	$00, -5, -5
	db	$02, -4, 8
	db 	$01
	
minigoat_vectors:
	dw	minigoat_walk1_vector_list
	dw  minigoat_walk2_vector_list
	dw	minigoat_up_vector_list
	dw	minigoat_down_vector_list
	
	
MINIGOAT_LIST_LEN	equ	19
minigoat_walk1_vector_list:
	db	-85, 25
	db	90,	15
	db	10,	40
	db	40,	30
	db	-50, -10
	db	20,	60
	db	60,	0
	db	30,	20
	db	60,	-20
	db	-60, -10
	db	50,	-80
	db	0,	-80
	db	-40, -60
	db	-20, -75
	db	-115, -20
	db	30,	25
	db	-105, 30
	db	70,	20
	db	15,	90

	
minigoat_walk2_vector_list:
	db	-85, 0
	db	90,	40
	db	10,	40
	db	40,	30
	db	-50, -10
	db	20,	60
	db	60,	0
	db	30,	20
	db	60,	-20
	db	-60, -10
	db	50,	-80
	db	0,	-80
	db	-40, -60
	db	-20, -75
	db	-115, -20
	db	30,	25
	db	-105,	50
	db	70,	0
	db	15,	90
	
	
minigoat_up_vector_list:
	db	-70, 15
	db	75,	25
	db	15,	40
	db	35,	35
	db	-65, 0
	db	40,	60
	db	55,	-25
	db	35,	15
	db	60,	-50
	db	-55, 15
	db	40,	-70
	db	-20, -80
	db	-40, -60
	db	-20, -75
	db	-115, -20
	db	30,	25
	db	-105,	30
	db	70,	20
	db	35,	100

minigoat_down_vector_list:
	db	-85, 25
	db	90,	15
	db	-5,	40
	db	40,	30
	db	-55, -10
	db	25,	60
	db	60,	0
	db	30,	20
	db	60,	-20
	db	-65, -15
	db	50,	-75
	db	-5,	-75
	db	15,	-65
	db	-40, -70
	db	-85, -15
	db	30,	30
	db	-105, 20
	db	80,	25
	db	-35, 80
	
	
EXPLOSION_SCALE		equ 8	
EXPLOSION_LIST_LEN	equ	10
explosion_vector_list:
	db	-4 * EXPLOSION_SCALE, -8 * EXPLOSION_SCALE
	db	8 * EXPLOSION_SCALE, 10 * EXPLOSION_SCALE
	db	7 * EXPLOSION_SCALE, -7 * EXPLOSION_SCALE
	db	-7 * EXPLOSION_SCALE, 11 * EXPLOSION_SCALE
	db	8 * EXPLOSION_SCALE, 4 * EXPLOSION_SCALE
	db	-11 * EXPLOSION_SCALE, -3 * EXPLOSION_SCALE
	db	-2 * EXPLOSION_SCALE, 10 * EXPLOSION_SCALE
	db	0 * EXPLOSION_SCALE, -13 * EXPLOSION_SCALE
	db -9 * EXPLOSION_SCALE, 1 * EXPLOSION_SCALE
	db	10 * EXPLOSION_SCALE, -5 * EXPLOSION_SCALE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Goat face

goatface_right_horn_moveto:
	db	57, 9
goatface_right_horn_len:
	db	7
goatface_right_horn_vl:
	db 43, 18
	db 38, 11
	db 21, 2
	db -20, 5
	db -29, -2
	db -60, -13
	db 6, -21

	
goatface_left_horn_moveto:
	db 58, -17
goatface_left_horn_len:
	db	7	
goatface_left_horn_vl:
	db 47, -19	
	db 34, -13	
	db 19, -7	
	db -24, 0	
	db -31, 7	
	db -51, 13	
	db 7, 20	

goatface_face_moveto:
	db 72, 38
goatface_face_len:
	db 13
goatface_face_vl:
	db -32, 13	
	db -35, 1	
	db -63, -1	
	db -67, -8	
	db -28, -16	
	db -9, -28	
	db 13, -28	
	db 37, -14	
	db 46, -8	
	db 54, -7	
	db 42, -1	
	db 31, 6	
	db 12, 8	
	
goatface_nose_moveto:
	db -100, 22
goatface_nose_len:
	db 14
goatface_nose_vl:
	db -2, -12	
	db -15, -6	
	db 17, 0	
	db 5, 21	
	db -8, 8	
	db -18, -16	
	db -5, -15	
	db 7, -16	
	db 16, -13	
	db 9, 12	
	db -5, 16	
	db -18, -1	
	db 16, -6	
	db 2, -9	
	
goatface_mouth_moveto:
	db -127, 3
goatface_mouth_len:
	db 9
goatface_mouth_vl:
	db -4, 3	
	db 4, 17	
	db -11, -7	
	db -4, -9	
	db 0, -10	
	db 5, -9	
	db 10, -4	
	db -3, 16	
	db 5, 3	
	
goatface_goatee_moveto:
	db -124, -43
goatface_goatee_len:
	db 12
goatface_goatee_vl:
	db -48, -12	
	db -46, 12	
	db 36, 13	
	db -44, 8	
	db 49, 18	
	db -35, 13	
	db 26, 9	
	db -35, 18	
	db 38, 2	
	db -23, 18	
	db 49, 4	
	db 37, -13	

goatface_right_ear_moveto:
	db 65, 46
goatface_right_ear_len:
	db	6
goatface_right_ear_vl:
	db 14, 28	
	db 9, 41	
	db -36, -30	
	db -28, -32	
	db 32, 12	
	db 19, 32	
	

goatface_left_ear_moveto:
	db 65, -55
goatface_left_ear_len:
	db	6
goatface_left_ear_vl:
	db 16, -34	
	db 8, -40	
	db -41, 36	
	db -24, 30	
	db 32, -11	
	db 19, -32	

goatface_right_eye_moveto:
	db 9, 34
goatface_right_eye_len:
	db	7
goatface_right_eye_vl:
	db 9, 5	
	db 0, 8	
	db -9, 2	
	db -10, -3	
	db -3, -7	
	db 3, -4	
	db 9, -1	

goatface_left_eye_moveto:
	db 1, -38
goatface_left_eye_len:
	db	6
goatface_left_eye_vl:
	db 11, 0	
	db 6, -7	
	db -3, -7	
	db -11, 0	
	db -8, 3	
	db 4, 11	
	
	
stage_s_moveto:
	db 110, -70
stage_s_len:
	db	26
stage_s_vl:
	db 18, 26
	db 60, -108
	db -10, -46
	db -18, -22
	db -78, -2
	db -38, 20
	db -22, 20
	db -34, 84
	db -26, 46
	db -26, 16
	db -22, -6
	db	-9, -103
	db	-9, -103
	db -16, -22
	db 7, 104
	db 7, 104
	db 16, 32
	db 14, 16
	db 38, -2
	db 42, -56
	db 32, -86
	db 52, -36
	db 64, -4
	db 12, 8
	db 0, 16
	db -56, 104
;;;
	db 9, 13
	db 30, -54
	db -5, -23
	db -9, -11
	db -39, -1
	db -19, 10
	db -11, 10
	db -17, 42
	db -13, 23
	db -13, 8
	db -11, -3
	db -9, -103
	db -8, -11
	db 7, 104
	db 8, 16
	db 7, 8
	db 19, -1
	db 21, -28
	db 16, -43
	db 26, -18
	db 32, -2
	db 6, 4
	db 0, 8
	db -26, 52

stage_t_moveto:
	db 100, -40
stage_t_len:
	db	20
stage_t_vl:
	db 18, 26
	db 28, -58
	db 102, 6
	db -12, -26
	db -76, -6
	db 6, -6
	db -16, -26
	db -20, 28
	db -76, -6
	db -26, 8
	db -26, 36
	db -12, 54
	db 0, 36
	db 18, 20
	db 2, -56
	db 12, -34
	db 20, -28
	db 16, -8
	db 56, 4
	db -18, 36


stage_a_moveto:
	db 75, 0
stage_a_len:
	db	21
stage_a_vl:
	db 18, 22
	db 22, -30
	db 34, 6
	db 62, -16
	db -18, -22
	db -44, 0
	db -32, -12
	db 12, -36
	db 34, -6
	db 34, 14
	db -2, 28
	db 18, 24
	db 2, -40
	db -14, -30
	db -46, -24
	db -38, 4
	db -12, 44
	db 20, 36
	db -20, 0
	db -18, 18
	db -8, 16


	
stage_g_moveto:
	db 95, 30
stage_g_len:
	db	33
stage_g_vl:
	db 14, 24
	db 26, -16
	db 6, -50
	db -28, -52
	db -30, -12
	db -44, 12
	db -16, 22
	db -2, 44
	db 16, 26
	db -46, 12
	db -38, 12
	db -12, -28
	db -2, -126
	db 18, -52
	db 12, -62
	db -18, -24
	db -10, 64
	db -18, 58
	db 2, 127
	db 18, 48
	db 24, 26
	db 68, -22
	db 40, -8
	db 22, -2
	db -16, -26
	db -20, 0
	db -20, -10
	db 8, -46
	db 32, -12
	db 34, 6
	db 8, 22
	db -10, 38
	db -20, 10

	
stage_e_moveto:
	db 75, 80
stage_e_len:
	db	25
stage_e_vl:
	db 14, 20
	db 8, -36
	db 2, -56
	db 8, -38
	db 26, -40
	db 40, -18
	db 18, 8
	db -2, 68
	db -6, 16
	db -32, 28
	db 0, -70
	db -16, -22
	db 0, 122
	db 8, 18
	db 16, -4
	db 24, -24
	db 22, -18
	db 8, -82
	db -4, -24
	db -18, -28
	db -28, -14
	db -38, 16
	db -36, 50
	db -8, 72
	db -4, 52


stage_numbers:
	dw	stage_num_1_len
	dw	stage_num_2_len
	dw	stage_num_3_len
	dw	stage_num_4_len
	dw	stage_num_5_len
	

stage_num_1_len:
	db	7
stage_num_1_vl:	
	db -32, -1
	db -34, 1
	db 4, 8
	db 31, -1
	db 23, 2
	db 11, 0
	db -3, -9
	
stage_num_2_len:
	db	28
stage_num_2_vl:	
	db 4, 8
	db 9, 6
	db 0, 18
	db -3, 7
	db -5, 3
	db -22, 1
	db -4, -2
	db -4, -21
	db 0, -12
	db -5, -9
	db -8, 2
	db -4, 4
	db -1, 25
	db 0, 21
	db 5, 6
	db 0, -41
	db 2, -6
	db 6, -1
	db 1, 16
	db 3, 14
	db 6, 10
	db 6, 3
	db 20, -1
	db 6, -3
	db 5, -10
	db -1, -20
	db -4, -8
	db -12, -10
	
stage_num_3_len:
	db	39
stage_num_3_vl:	
	db 4, 7
	db 6, -1
	db 1, 9
	db -3, 6
	db -9, 3
	db -8, -1
	db -5, -12
	db -3, 0
	db 0, 11
	db 2, 7
	db 0, 9
	db -4, 5
	db -12, -3
	db -5, -4
	db -2, -7
	db -1, -16
	db 3, -10
	db 5, -10
	db 2, -2
	db -4, -8
	db -8, 16
	db -3, 15
	db 3, 17
	db 6, 12
	db 11, 7
	db 8, 1
	db 5, -4
	db 3, -7
	db -2, -10
	db -2, -8
	db 5, 7
	db 5, 4
	db 10, -1
	db 6, -5
	db 3, -5
	db -1, -12
	db -3, -7
	db -6, -4
	db -7, 1

stage_num_4_len:
	db	17
stage_num_4_vl:	
	db -23, -5
	db -25, -2
	db -6, 1
	db 0, 29
	db -10, 2
	db -10, 1
	db 3, 8
	db 11, -1
	db 8, -3
	db 16, -2
	db -3, -8
	db -10, 0
	db 0, -20
	db 23, 1
	db 20, 3
	db 9, 3
	db -3, -7

stage_num_5_len:
	db	31
stage_num_5_vl:	
	db -30, -2
	db -3, 4
	db 2, 6
	db 1, 19
	db -10, 5
	db -9, 0
	db -10, -4
	db 0, -20
	db 3, -8
	db 5, -2
	db 8, 0
	db -4, -8
	db -9, 0
	db -5, 3
	db -2, 7
	db 1, 24
	db 6, 11
	db 12, 5
	db 9, 0
	db 8, -4
	db 3, -5
	db -1, -19
	db -2, -5
	db 25, 1
	db -2, 29
	db 0, 20
	db 5, 6
	db 1, -33
	db 1, -15
	db 3, -8
	db -6, -7
	
num_movetos:
	dw	num_0_moveto
	dw	num_1_moveto
	dw	num_2_moveto
	dw	num_3_moveto
	dw	num_4_moveto
	dw	num_5_moveto
	dw	num_6_moveto
	dw	num_7_moveto
	dw	num_8_moveto
	dw	num_9_moveto
	
num_lens:
	db 7
	db 2
	db 6
	db 8
	db 3
	db 7
	db 7
	db 2
	db 8
	db 5
	
num_vls:
	dw	num_0_vl
	dw	num_1_vl
	dw	num_2_vl
	dw	num_3_vl
	dw	num_4_vl
	dw	num_5_vl
	dw	num_6_vl
	dw	num_7_vl
	dw	num_8_vl
	dw	num_9_vl
	
num_0_moveto:
	db 30, -11
num_0_len:
	db	7
num_0_vl:	
	db 0, 0	
	db -2, 26	
	db -19, 18	
	db -37, -9	
	db -8, -37	
	db 27, -19	
	db 38, 21	

num_1_moveto:
	db 28, 2
num_1_len:
	db	2
num_1_vl:
	db 2, 2
	db -65, -1	
	
num_2_moveto:
	db 13, -19
num_2_len:
	db	6
num_2_vl:	
	db 10, 10	
	db -1, 26	
	db -28, 6	
	db -12, -42	
	db -11, 3	
	db -1, 43	

num_3_moveto:
	db 14, -11
num_3_len:
	db	8
num_3_vl:	
	db 9, 4	
	db -2, 21	
	db -16, 0	
	db -9, -13	
	db 1, 29	
	db -21, 0	
	db -8, -32	
	db 10, -23	
	
num_4_moveto:
	db 30, -7
num_4_len:
	db	3
num_4_vl:	
	db -52, -10	
	db 5, 29	
	db -21, 6	

num_5_moveto:
	db 22, 39
num_5_len:
	db	7
num_5_vl:	
	db 3, -54	
	db -30, -3	
	db 3, 30	
	db -19, 6	
	db -14, -11	
	db 1, -31	
	db 11, -1	

num_6_moveto:
	db 30, 31
num_6_len:
	db	7
num_6_vl:	
	db 0, -1	
	db -11, -35	
	db -17, -15	
	db -34, 14	
	db 5, 20	
	db 20, -1	
	db 9, -23	

num_7_moveto:
	db 28, -24
num_7_len:
	db	2
num_7_vl:	
	db -1, 45	
	db -65, -38	

num_8_moveto:
	db 10, 1
num_8_len:
	db	8
num_8_vl:	
	db 16, -8	
	db 8, 15	
	db -13, 4	
	db -34, -38	
	db -21, 6	
	db 5, 36	
	db 22, 10	
	db 17, -26	

num_9_moveto:
	db 12, 7
num_9_len:
	db	5
num_9_vl:	
	db -9, -24	
	db 10, -6	
	db 20, 17	
	db -59, 28	
	db -14, -15	

num_inf_moveto:
	db -4, 2
num_inf_len:
	db	7
num_inf_vl:	
	db -10, 32	
	db 13, 17	
	db 9, -28	
	db -24, -60	
	db 21, -9	
	db 6, 25	
	db -15, 23	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;	
stage_1:
	db	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $08 ; 00
	db	$00, $00, $00, $00, $00, $00, $08, $00, $00, $00, $00, $08, $00, $00, $00, $08 ; 10
	db	$00, $00, $00, $00, $00, $00, $00, $01, $00, $00, $00, $01, $00, $00, $00, $01 ; 20
	db	$00, $00, $00, $08, $08, $00, $00, $08, $08, $00, $00, $08, $01, $01, $01, $01 ; 30
	db	$01, $01, $02, $01, $0A, $01, $02, $02, $02, $08, $08, $01, $01, $01, $01, $00 ; 40
	db  $00, $00, $00, $09, $00, $00, $00, $09, $00, $00, $00, $09, $00, $00, $00, $00 ; 50
	db  $00, $09, $01, $01, $01, $01, $08, $02, $02, $02, $08, $08, $02, $02, $02, $02 ; 60
	db  $02, $03, $03, $03, $03, $01, $01, $04, $04, $04, $01, $01, $05, $05, $05, $05 ; 70
	db  $05, $05, $05, $08, $08, $05, $05, $08, $08, $05, $05, $08, $08, $01, $01, $08 ; 80
	db  $08, $08, $00, $00, $00, $00, $08, $00, $00, $00, $08, $02, $02, $02, $08, $03 ; 90
	db  $03, $03, $08, $04, $04, $04, $08, $05, $05, $05, $05, $05, $08, $04, $08, $0B ; A0
	db  $0A, $09, $00, $00, $00, $08, $00, $00, $00, $00, $00, $08, $08, $01, $01, $08 ; B0
	db  $00, $02, $02, $09, $00, $03, $03, $0A, $00, $04, $04, $0B, $00, $05, $05, $05 ; C0
	db  $05, $08, $04, $08, $05, $05, $05, $08, $08, $03, $08, $08, $04, $04, $04, $04 ; D0
	db  $0B, $09, $0A, $08, $00, $00, $00, $00, $00, $08, $02, $02, $0A, $04, $04, $0C ; E0
	db  $06, $06, $06, $0E, $0E, $06, $06, $06, $06, $06, $00, $00, $00, $00, $05, $05 ; F0
	db  $08, $08, $08, $05, $08, $08, $08, $05, $08, $04, $08, $08, $08, $04, $08, $08 ; 100
	db  $08, $04, $08, $03, $08, $08, $08, $03, $08, $02, $08, $08, $08, $02, $08, $01 ; 110
	db  $08, $08, $08, $01, $08, $00, $00, $00, $00, $09, $01, $01, $01, $0A, $02, $02 ; 120
	db  $02, $0B, $03, $03, $03, $0C, $04, $04, $04, $08, $08, $04, $04, $0C, $03, $03 ; 130
	db  $03, $0B, $02, $02, $02, $02, $0A, $01, $01, $01, $08, $00, $00, $00, $00, $01 ; 140
	db  $00, $00, $00, $01, $08, $00, $00, $01, $08, $00, $00, $01, $08, $00, $00, $08 ; 150
	db  $08, $00, $00, $08, $08, $00, $00, $00, $08, $08, $00, $00, $00, $01, $01, $08 ; 160
	db  $08, $02, $02, $08, $08, $03, $03, $08, $00, $00, $00, $00, $00, $00, $00, $00 ; 170

	db  $00, $00, $00, $00, $00, $00, $00, $00

	
autoplay_moves_1:
	db	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $8A, $00 ; 00
	db	$00, $00, $00, $00, $00, $8A, $00, $00, $00, $00, $8A, $00, $00, $00, $8A, $00 ; 10
	db	$00, $00, $00, $00, $00, $00, $8A, $00, $00, $00, $8A, $00, $00, $00, $8A, $00 ; 20
	db  $00, $00, $86, $00, $00, $00, $86, $00, $00, $00, $86, $00, $00, $00, $00, $00 ; 30
	db  $8E, $00, $00, $82, $00, $00, $00, $00, $8E, $00, $00, $00, $00, $00, $00, $00 ; 40
	db  $00, $00, $8E, $00, $00, $00, $8E, $00, $00, $00, $8E, $00, $00, $00, $00, $00 ; 50
	db  $8E, $00, $00, $00, $00, $8E, $00, $00, $00, $8E, $00, $00, $00, $00, $00, $00 ; 60
	db  $8E, $00, $00, $00, $82, $00, $00, $00, $00, $82, $00, $00, $00, $00, $00, $00 ; 70
	db  $00, $00, $8E, $00, $00, $00, $8E, $00, $00, $00, $00, $00, $00, $00, $82, $00 ; 80
	db  $00, $00, $00, $00, $00, $82, $00, $00, $00, $82, $00, $00, $00, $82, $00, $00 ; 90
	db  $00, $82, $00, $00, $00, $82, $00, $00, $00, $00, $00, $00, $00, $00, $86, $00 ; A0
	db  $00, $00, $00, $00, $8E, $00, $00, $00, $00, $00, $86, $00, $00, $00, $82, $00 ; B0
	db  $00, $00, $82, $00, $00, $00, $82, $00, $00, $00, $82, $00, $00, $00, $00, $00 ; C0
	db  $00, $00, $00, $86, $00, $00, $00, $00, $00, $00, $8A, $00, $00, $00, $00, $82 ; D0
	db  $00, $00, $00, $00, $00, $00, $00, $00, $82, $00, $00, $82, $00, $00, $82, $00 ; E0
	db  $00, $00, $82, $00, $00, $00, $00, $00, $00, $00, $8A, $00, $00, $00, $00, $00 ; F0
	db  $86, $00, $00, $00, $86, $00, $00, $00, $00, $00, $86, $00, $00, $00, $86, $00 ; 100
	db  $00, $00, $00, $00, $86, $00, $00, $00, $00, $00, $86, $00, $00, $00, $00, $00 ; 110
	db  $86, $00, $00, $00, $00, $00, $00, $00, $8E, $00, $00, $00, $8E, $00, $00, $00 ; 120
	db  $8E, $00, $00, $00, $8E, $00, $00, $00, $8E, $00, $00, $00, $8E, $00, $00, $00 ; 130
	db  $82, $00, $00, $00, $00, $82, $00, $00, $00, $00, $00, $00, $00, $00, $86, $00 ; 140
	db  $00, $00, $86, $00, $00, $00, $86, $00, $00, $00, $86, $00, $00, $00, $86, $00 ; 150
	db  $00, $00, $86, $00, $00, $00, $00, $82, $00, $00, $00, $86, $00, $00, $84, $00 ; 160
	db  $00, $00, $86, $00, $00, $00, $00, $82, $00, $00, $0, $00, $00, $00, $00, $00 ; 170
	

stage_2:
	db	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $08 ; 00
	db	$00, $00, $00, $00, $00, $00, $08, $08, $00, $00, $00, $08, $08, $08, $08, $08 ; 10
	db	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00 ; 20	

	db  $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

	
AY_REG_COUNT			equ	11

;; YM conversion from c:\mystuff\vectrex\sgj_1.ym
;; Song title   : SGJ_1
;; Song author  : MountainGoat
;; Number of frames: 
SGJ_1_NUM_FRAMES		equ	3136
;; Number of AY registers output :


sgj_1:
		dw	3136	;; number of frames
		dw	sgj_1_r_0
		dw	sgj_1_r_1
		dw	sgj_1_r_2
		dw	sgj_1_r_3
		dw	sgj_1_r_4
		dw	sgj_1_r_5
		dw	sgj_1_r_6
		dw	sgj_1_r_7
		dw	sgj_1_r_8
		dw	sgj_1_r_9
		dw	sgj_1_r_10
;; Data stream for register 0
sgj_1_r_0:
		 db 	 255, $BC
		 db 	 255, $BC
		 db 	 255, $BC
		 db 	 187, $BC
		 db 	 56, $7E
		 db 	 112, $A4
		 db 	 56, $BC
		 db 	 56, $7E
		 db 	 28, $A4
		 db 	 28, $24
		 db 	 112, $BC
		 db 	 56, $7E
		 db 	 112, $A4
		 db 	 56, $BC
		 db 	 56, $7E
		 db 	 28, $A4
		 db 	 28, $24
		 db 	 112, $BC
		 db 	 56, $7E
		 db 	 56, $BC
		 db 	 56, $18
		 db 	 56, $BC
		 db 	 56, $7E
		 db 	 42, $BC
		 db 	 14, $24
		 db 	 112, $BC
		 db 	 56, $7E
		 db 	 56, $BC
		 db 	 56, $18
		 db 	 56, $BC
		 db 	 56, $7E
		 db 	 42, $BC
		 db 	 14, $24
		 db 	 112, $BC
		 db 	 56, $7E
		 db 	 56, $BC
		 db 	 56, $18
		 db 	 56, $BC
		 db 	 56, $7E
		 db 	 42, $BC
		 db 	 14, $24
		 db 	 56, $BC

;; Sum for R0 : 3136
;; Data stream for register 1
sgj_1_r_1:
		 db 	 255, $03
		 db 	 255, $03
		 db 	 255, $03
		 db 	 187, $03
		 db 	 168, $02
		 db 	 56, $03
		 db 	 84, $02
		 db 	 140, $03
		 db 	 168, $02
		 db 	 56, $03
		 db 	 84, $02
		 db 	 140, $03
		 db 	 56, $02
		 db 	 56, $03
		 db 	 56, $02
		 db 	 56, $03
		 db 	 56, $02
		 db 	 168, $03
		 db 	 56, $02
		 db 	 56, $03
		 db 	 56, $02
		 db 	 56, $03
		 db 	 56, $02
		 db 	 168, $03
		 db 	 56, $02
		 db 	 56, $03
		 db 	 56, $02
		 db 	 56, $03
		 db 	 56, $02
		 db 	 112, $03

;; Sum for R1 : 3136
;; Data stream for register 2
sgj_1_r_2:
		 db 	 224, $77
		 db 	 255, $BC
		 db 	 25, $BC
		 db 	 56, $7E
		 db 	 112, $A4
		 db 	 56, $BC
		 db 	 56, $7E
		 db 	 28, $A4
		 db 	 28, $24
		 db 	 56, $BC
		 db 	 28, $77
		 db 	 28, $64
		 db 	 28, $50
		 db 	 28, $64
		 db 	 7, $54
		 db 	 7, $59
		 db 	 7, $54
		 db 	 7, $59
		 db 	 7, $54
		 db 	 21, $59
		 db 	 56, $54
		 db 	 28, $77
		 db 	 28, $64
		 db 	 28, $50
		 db 	 28, $64
		 db 	 7, $54
		 db 	 7, $59
		 db 	 7, $54
		 db 	 7, $59
		 db 	 7, $54
		 db 	 21, $64
		 db 	 84, $77
		 db 	 28, $64
		 db 	 28, $50
		 db 	 28, $64
		 db 	 7, $54
		 db 	 7, $59
		 db 	 7, $54
		 db 	 7, $59
		 db 	 7, $54
		 db 	 21, $59
		 db 	 56, $54
		 db 	 28, $77
		 db 	 28, $64
		 db 	 28, $50
		 db 	 28, $64
		 db 	 7, $54
		 db 	 7, $59
		 db 	 7, $54
		 db 	 7, $59
		 db 	 7, $54
		 db 	 21, $64
		 db 	 70, $77
		 db 	 14, $64
		 db 	 14, $59
		 db 	 14, $54
		 db 	 14, $50
		 db 	 14, $54
		 db 	 14, $59
		 db 	 14, $64
		 db 	 14, $77
		 db 	 14, $64
		 db 	 14, $59
		 db 	 14, $54
		 db 	 28, $43
		 db 	 28, $47
		 db 	 14, $77
		 db 	 14, $64
		 db 	 14, $59
		 db 	 14, $54
		 db 	 14, $50
		 db 	 14, $54
		 db 	 14, $59
		 db 	 14, $64
		 db 	 14, $77
		 db 	 14, $64
		 db 	 14, $77
		 db 	 14, $7F
		 db 	 70, $77
		 db 	 14, $64
		 db 	 14, $59
		 db 	 14, $54
		 db 	 14, $50
		 db 	 14, $54
		 db 	 14, $59
		 db 	 14, $64
		 db 	 14, $77
		 db 	 14, $64
		 db 	 14, $59
		 db 	 14, $54
		 db 	 28, $43
		 db 	 28, $47
		 db 	 14, $77
		 db 	 14, $64
		 db 	 14, $59
		 db 	 14, $54
		 db 	 14, $50
		 db 	 14, $54
		 db 	 14, $59
		 db 	 14, $64
		 db 	 14, $77
		 db 	 14, $64
		 db 	 14, $77
		 db 	 14, $7F
		 db 	 56, $77
		 db 	 14, $3F
		 db 	 14, $43
		 db 	 14, $47
		 db 	 14, $4B
		 db 	 14, $50
		 db 	 14, $54
		 db 	 14, $59
		 db 	 14, $5F
		 db 	 14, $77
		 db 	 14, $64
		 db 	 14, $59
		 db 	 14, $54
		 db 	 28, $43
		 db 	 28, $47
		 db 	 14, $3F
		 db 	 14, $43
		 db 	 14, $47
		 db 	 14, $4B
		 db 	 14, $50
		 db 	 14, $54
		 db 	 14, $59
		 db 	 14, $5F
		 db 	 14, $77
		 db 	 14, $64
		 db 	 14, $77
		 db 	 14, $7F
		 db 	 56, $77

;; Sum for R2 : 3136
;; Data stream for register 3
sgj_1_r_3:
		 db 	 224, $00
		 db 	 255, $03
		 db 	 25, $03
		 db 	 168, $02
		 db 	 56, $03
		 db 	 84, $02
		 db 	 84, $03
		 db 	 255, $00
		 db 	 255, $00
		 db 	 255, $00
		 db 	 255, $00
		 db 	 255, $00
		 db 	 255, $00
		 db 	 255, $00
		 db 	 255, $00
		 db 	 200, $00

;; Sum for R3 : 3136
;; Data stream for register 4
sgj_1_r_4:
		 db 	 1, $92
		 db 	 1, $18
		 db 	 1, $A4
		 db 	 1, $24
		 db 	 24, $BC
		 db 	 1, $92
		 db 	 1, $18
		 db 	 1, $A4
		 db 	 1, $24
		 db 	 24, $BC
		 db 	 1, $92
		 db 	 1, $18
		 db 	 1, $A4
		 db 	 1, $24
		 db 	 24, $BC
		 db 	 1, $92
		 db 	 1, $18
		 db 	 1, $A4
		 db 	 1, $24
		 db 	 24, $BC
		 db 	 1, $92
		 db 	 1, $18
		 db 	 1, $A4
		 db 	 1, $24
		 db 	 24, $BC
		 db 	 1, $92
		 db 	 1, $18
		 db 	 1, $A4
		 db 	 1, $24
		 db 	 24, $BC
		 db 	 1, $92
		 db 	 1, $18
		 db 	 1, $A4
		 db 	 1, $24
		 db 	 24, $BC
		 db 	 1, $92
		 db 	 1, $18
		 db 	 1, $A4
		 db 	 1, $24
		 db 	 24, $BC
		 db 	 1, $92
		 db 	 1, $18
		 db 	 1, $A4
		 db 	 1, $24
		 db 	 24, $BC
		 db 	 1, $92
		 db 	 1, $18
		 db 	 1, $A4
		 db 	 1, $24
		 db 	 24, $BC
		 db 	 1, $92
		 db 	 1, $18
		 db 	 1, $A4
		 db 	 1, $24
		 db 	 24, $BC
		 db 	 1, $92
		 db 	 1, $18
		 db 	 1, $A4
		 db 	 1, $24
		 db 	 24, $BC
		 db 	 1, $92
		 db 	 1, $18
		 db 	 1, $A4
		 db 	 1, $24
		 db 	 24, $BC
		 db 	 1, $92
		 db 	 1, $18
		 db 	 1, $A4
		 db 	 1, $24
		 db 	 24, $BC
		 db 	 1, $92
		 db 	 1, $18
		 db 	 1, $A4
		 db 	 1, $24
		 db 	 24, $BC
		 db 	 1, $92
		 db 	 1, $18
		 db 	 1, $A4
		 db 	 1, $24
		 db 	 24, $BC
		 db 	 1, $92
		 db 	 1, $18
		 db 	 1, $A4
		 db 	 1, $24
		 db 	 24, $BC
		 db 	 1, $96
		 db 	 1, $BE
		 db 	 1, $E1
		 db 	 1, $FD
		 db 	 17, $1C
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 3, $53
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 10, $53
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 10, $53
		 db 	 1, $96
		 db 	 1, $BE
		 db 	 1, $E1
		 db 	 1, $FD
		 db 	 24, $1C
		 db 	 1, $92
		 db 	 1, $18
		 db 	 1, $A4
		 db 	 1, $24
		 db 	 24, $BC
		 db 	 1, $96
		 db 	 1, $BE
		 db 	 1, $E1
		 db 	 1, $FD
		 db 	 17, $1C
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 3, $53
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 10, $53
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 10, $53
		 db 	 1, $96
		 db 	 1, $BE
		 db 	 1, $E1
		 db 	 1, $FD
		 db 	 24, $1C
		 db 	 1, $92
		 db 	 1, $18
		 db 	 1, $A4
		 db 	 1, $24
		 db 	 24, $BC
		 db 	 1, $96
		 db 	 1, $BE
		 db 	 1, $E1
		 db 	 1, $FD
		 db 	 17, $1C
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 3, $53
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 10, $53
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 10, $53
		 db 	 1, $96
		 db 	 1, $BE
		 db 	 1, $E1
		 db 	 1, $FD
		 db 	 24, $1C
		 db 	 1, $92
		 db 	 1, $18
		 db 	 1, $A4
		 db 	 1, $24
		 db 	 24, $BC
		 db 	 1, $96
		 db 	 1, $BE
		 db 	 1, $E1
		 db 	 1, $FD
		 db 	 17, $1C
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 3, $53
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 10, $53
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 10, $53
		 db 	 1, $96
		 db 	 1, $BE
		 db 	 1, $E1
		 db 	 1, $FD
		 db 	 24, $1C
		 db 	 1, $92
		 db 	 1, $18
		 db 	 1, $A4
		 db 	 1, $24
		 db 	 24, $BC
		 db 	 1, $96
		 db 	 1, $BE
		 db 	 1, $E1
		 db 	 1, $FD
		 db 	 17, $1C
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 3, $53
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 10, $53
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 10, $53
		 db 	 1, $96
		 db 	 1, $BE
		 db 	 1, $E1
		 db 	 1, $FD
		 db 	 24, $1C
		 db 	 1, $92
		 db 	 1, $18
		 db 	 1, $A4
		 db 	 1, $24
		 db 	 24, $BC
		 db 	 1, $96
		 db 	 1, $BE
		 db 	 1, $E1
		 db 	 1, $FD
		 db 	 17, $1C
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 3, $53
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 10, $53
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 10, $53
		 db 	 1, $96
		 db 	 1, $BE
		 db 	 1, $E1
		 db 	 1, $FD
		 db 	 24, $1C
		 db 	 1, $92
		 db 	 1, $18
		 db 	 1, $A4
		 db 	 1, $24
		 db 	 24, $BC
		 db 	 1, $96
		 db 	 1, $BE
		 db 	 1, $E1
		 db 	 1, $FD
		 db 	 17, $1C
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 3, $53
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 10, $53
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 10, $53
		 db 	 1, $96
		 db 	 1, $BE
		 db 	 1, $E1
		 db 	 1, $FD
		 db 	 24, $1C
		 db 	 1, $92
		 db 	 1, $18
		 db 	 1, $A4
		 db 	 1, $24
		 db 	 24, $BC
		 db 	 1, $96
		 db 	 1, $BE
		 db 	 1, $E1
		 db 	 1, $FD
		 db 	 17, $1C
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 3, $53
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 10, $53
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 10, $53
		 db 	 1, $96
		 db 	 1, $BE
		 db 	 1, $E1
		 db 	 1, $FD
		 db 	 24, $1C
		 db 	 1, $92
		 db 	 1, $18
		 db 	 1, $A4
		 db 	 1, $24
		 db 	 24, $BC
		 db 	 1, $96
		 db 	 1, $BE
		 db 	 1, $E1
		 db 	 1, $FD
		 db 	 17, $1C
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 3, $53
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 10, $53
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 10, $53
		 db 	 1, $96
		 db 	 1, $BE
		 db 	 1, $E1
		 db 	 1, $FD
		 db 	 24, $1C
		 db 	 1, $92
		 db 	 1, $18
		 db 	 1, $A4
		 db 	 1, $24
		 db 	 24, $BC
		 db 	 1, $96
		 db 	 1, $BE
		 db 	 1, $E1
		 db 	 1, $FD
		 db 	 17, $1C
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 3, $53
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 10, $53
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 10, $53
		 db 	 1, $96
		 db 	 1, $BE
		 db 	 1, $E1
		 db 	 1, $FD
		 db 	 24, $1C
		 db 	 1, $92
		 db 	 1, $18
		 db 	 1, $A4
		 db 	 1, $24
		 db 	 24, $BC
		 db 	 1, $96
		 db 	 1, $BE
		 db 	 1, $E1
		 db 	 1, $FD
		 db 	 17, $1C
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 3, $53
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 10, $53
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 10, $53
		 db 	 1, $96
		 db 	 1, $BE
		 db 	 1, $E1
		 db 	 1, $FD
		 db 	 24, $1C
		 db 	 1, $92
		 db 	 1, $18
		 db 	 1, $A4
		 db 	 1, $24
		 db 	 24, $BC
		 db 	 1, $96
		 db 	 1, $BE
		 db 	 1, $E1
		 db 	 1, $FD
		 db 	 17, $1C
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 3, $53
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 10, $53
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 10, $53
		 db 	 1, $96
		 db 	 1, $BE
		 db 	 1, $E1
		 db 	 1, $FD
		 db 	 24, $1C
		 db 	 1, $92
		 db 	 1, $18
		 db 	 1, $A4
		 db 	 1, $24
		 db 	 24, $BC
		 db 	 1, $96
		 db 	 1, $BE
		 db 	 1, $E1
		 db 	 1, $FD
		 db 	 17, $1C
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 3, $53
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 10, $53
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 10, $53
		 db 	 1, $96
		 db 	 1, $BE
		 db 	 1, $E1
		 db 	 1, $FD
		 db 	 24, $1C
		 db 	 1, $92
		 db 	 1, $18
		 db 	 1, $A4
		 db 	 1, $24
		 db 	 24, $BC
		 db 	 1, $96
		 db 	 1, $BE
		 db 	 1, $E1
		 db 	 1, $FD
		 db 	 17, $1C
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 3, $53
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 10, $53
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 10, $53
		 db 	 1, $96
		 db 	 1, $BE
		 db 	 1, $E1
		 db 	 1, $FD
		 db 	 24, $1C
		 db 	 1, $92
		 db 	 1, $18
		 db 	 1, $A4
		 db 	 1, $24
		 db 	 24, $BC
		 db 	 1, $96
		 db 	 1, $BE
		 db 	 1, $E1
		 db 	 1, $FD
		 db 	 17, $1C
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 3, $53
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 10, $53
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 10, $53
		 db 	 1, $96
		 db 	 1, $BE
		 db 	 1, $E1
		 db 	 1, $FD
		 db 	 24, $1C
		 db 	 1, $92
		 db 	 1, $18
		 db 	 1, $A4
		 db 	 1, $24
		 db 	 24, $BC
		 db 	 1, $96
		 db 	 1, $BE
		 db 	 1, $E1
		 db 	 1, $FD
		 db 	 17, $1C
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 3, $53
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 10, $53
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 10, $53
		 db 	 1, $96
		 db 	 1, $BE
		 db 	 1, $E1
		 db 	 1, $FD
		 db 	 24, $1C
		 db 	 1, $92
		 db 	 1, $18
		 db 	 1, $A4
		 db 	 1, $24
		 db 	 24, $BC
		 db 	 1, $96
		 db 	 1, $BE
		 db 	 1, $E1
		 db 	 1, $FD
		 db 	 17, $1C
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 3, $53
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 10, $53
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 10, $53
		 db 	 1, $96
		 db 	 1, $BE
		 db 	 1, $E1
		 db 	 1, $FD
		 db 	 24, $1C
		 db 	 1, $92
		 db 	 1, $18
		 db 	 1, $A4
		 db 	 1, $24
		 db 	 24, $BC
		 db 	 1, $96
		 db 	 1, $BE
		 db 	 1, $E1
		 db 	 1, $FD
		 db 	 17, $1C
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 3, $53
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 10, $53
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 10, $53
		 db 	 1, $96
		 db 	 1, $BE
		 db 	 1, $E1
		 db 	 1, $FD
		 db 	 24, $1C
		 db 	 1, $92
		 db 	 1, $18
		 db 	 1, $A4
		 db 	 1, $24
		 db 	 24, $BC
		 db 	 1, $96
		 db 	 1, $BE
		 db 	 1, $E1
		 db 	 1, $FD
		 db 	 17, $1C
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 3, $53
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 10, $53
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 10, $53
		 db 	 1, $96
		 db 	 1, $BE
		 db 	 1, $E1
		 db 	 1, $FD
		 db 	 24, $1C
		 db 	 1, $92
		 db 	 1, $18
		 db 	 1, $A4
		 db 	 1, $24
		 db 	 24, $BC
		 db 	 1, $96
		 db 	 1, $BE
		 db 	 1, $E1
		 db 	 1, $FD
		 db 	 17, $1C
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 3, $53
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 10, $53
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 10, $53
		 db 	 1, $96
		 db 	 1, $BE
		 db 	 1, $E1
		 db 	 1, $FD
		 db 	 24, $1C
		 db 	 1, $92
		 db 	 1, $18
		 db 	 1, $A4
		 db 	 1, $24
		 db 	 24, $BC
		 db 	 1, $96
		 db 	 1, $BE
		 db 	 1, $E1
		 db 	 1, $FD
		 db 	 17, $1C
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 3, $53
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 10, $53
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 10, $53
		 db 	 1, $96
		 db 	 1, $BE
		 db 	 1, $E1
		 db 	 1, $FD
		 db 	 24, $1C
		 db 	 1, $92
		 db 	 1, $18
		 db 	 1, $A4
		 db 	 1, $24
		 db 	 24, $BC
		 db 	 1, $96
		 db 	 1, $BE
		 db 	 1, $E1
		 db 	 1, $FD
		 db 	 17, $1C
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 3, $53
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 10, $53
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 10, $53
		 db 	 1, $96
		 db 	 1, $BE
		 db 	 1, $E1
		 db 	 1, $FD
		 db 	 24, $1C
		 db 	 1, $92
		 db 	 1, $18
		 db 	 1, $A4
		 db 	 1, $24
		 db 	 24, $BC
		 db 	 1, $96
		 db 	 1, $BE
		 db 	 1, $E1
		 db 	 1, $FD
		 db 	 17, $1C
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 3, $53
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 10, $53
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 10, $53
		 db 	 1, $96
		 db 	 1, $BE
		 db 	 1, $E1
		 db 	 1, $FD
		 db 	 24, $1C
		 db 	 1, $92
		 db 	 1, $18
		 db 	 1, $A4
		 db 	 1, $24
		 db 	 24, $BC
		 db 	 1, $96
		 db 	 1, $BE
		 db 	 1, $E1
		 db 	 1, $FD
		 db 	 17, $1C
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 3, $53
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 10, $53
		 db 	 1, $C3
		 db 	 1, $38
		 db 	 1, $A4
		 db 	 1, $F6
		 db 	 10, $53
		 db 	 1, $96
		 db 	 1, $BE
		 db 	 1, $E1
		 db 	 1, $FD
		 db 	 24, $1C

;; Sum for R4 : 3136
;; Data stream for register 5
sgj_1_r_5:
		 db 	 1, $01
		 db 	 2, $02
		 db 	 25, $03
		 db 	 1, $01
		 db 	 2, $02
		 db 	 25, $03
		 db 	 1, $01
		 db 	 2, $02
		 db 	 25, $03
		 db 	 1, $01
		 db 	 2, $02
		 db 	 25, $03
		 db 	 1, $01
		 db 	 2, $02
		 db 	 25, $03
		 db 	 1, $01
		 db 	 2, $02
		 db 	 25, $03
		 db 	 1, $01
		 db 	 2, $02
		 db 	 25, $03
		 db 	 1, $01
		 db 	 2, $02
		 db 	 25, $03
		 db 	 1, $01
		 db 	 2, $02
		 db 	 25, $03
		 db 	 1, $01
		 db 	 2, $02
		 db 	 25, $03
		 db 	 1, $01
		 db 	 2, $02
		 db 	 25, $03
		 db 	 1, $01
		 db 	 2, $02
		 db 	 25, $03
		 db 	 1, $01
		 db 	 2, $02
		 db 	 25, $03
		 db 	 1, $01
		 db 	 2, $02
		 db 	 25, $03
		 db 	 1, $01
		 db 	 2, $02
		 db 	 25, $03
		 db 	 1, $01
		 db 	 2, $02
		 db 	 25, $03
		 db 	 1, $01
		 db 	 2, $02
		 db 	 25, $03
		 db 	 4, $00
		 db 	 18, $01
		 db 	 3, $02
		 db 	 3, $03
		 db 	 1, $01
		 db 	 3, $02
		 db 	 10, $03
		 db 	 1, $01
		 db 	 3, $02
		 db 	 10, $03
		 db 	 4, $00
		 db 	 25, $01
		 db 	 2, $02
		 db 	 25, $03
		 db 	 4, $00
		 db 	 18, $01
		 db 	 3, $02
		 db 	 3, $03
		 db 	 1, $01
		 db 	 3, $02
		 db 	 10, $03
		 db 	 1, $01
		 db 	 3, $02
		 db 	 10, $03
		 db 	 4, $00
		 db 	 25, $01
		 db 	 2, $02
		 db 	 25, $03
		 db 	 4, $00
		 db 	 18, $01
		 db 	 3, $02
		 db 	 3, $03
		 db 	 1, $01
		 db 	 3, $02
		 db 	 10, $03
		 db 	 1, $01
		 db 	 3, $02
		 db 	 10, $03
		 db 	 4, $00
		 db 	 25, $01
		 db 	 2, $02
		 db 	 25, $03
		 db 	 4, $00
		 db 	 18, $01
		 db 	 3, $02
		 db 	 3, $03
		 db 	 1, $01
		 db 	 3, $02
		 db 	 10, $03
		 db 	 1, $01
		 db 	 3, $02
		 db 	 10, $03
		 db 	 4, $00
		 db 	 25, $01
		 db 	 2, $02
		 db 	 25, $03
		 db 	 4, $00
		 db 	 18, $01
		 db 	 3, $02
		 db 	 3, $03
		 db 	 1, $01
		 db 	 3, $02
		 db 	 10, $03
		 db 	 1, $01
		 db 	 3, $02
		 db 	 10, $03
		 db 	 4, $00
		 db 	 25, $01
		 db 	 2, $02
		 db 	 25, $03
		 db 	 4, $00
		 db 	 18, $01
		 db 	 3, $02
		 db 	 3, $03
		 db 	 1, $01
		 db 	 3, $02
		 db 	 10, $03
		 db 	 1, $01
		 db 	 3, $02
		 db 	 10, $03
		 db 	 4, $00
		 db 	 25, $01
		 db 	 2, $02
		 db 	 25, $03
		 db 	 4, $00
		 db 	 18, $01
		 db 	 3, $02
		 db 	 3, $03
		 db 	 1, $01
		 db 	 3, $02
		 db 	 10, $03
		 db 	 1, $01
		 db 	 3, $02
		 db 	 10, $03
		 db 	 4, $00
		 db 	 25, $01
		 db 	 2, $02
		 db 	 25, $03
		 db 	 4, $00
		 db 	 18, $01
		 db 	 3, $02
		 db 	 3, $03
		 db 	 1, $01
		 db 	 3, $02
		 db 	 10, $03
		 db 	 1, $01
		 db 	 3, $02
		 db 	 10, $03
		 db 	 4, $00
		 db 	 25, $01
		 db 	 2, $02
		 db 	 25, $03
		 db 	 4, $00
		 db 	 18, $01
		 db 	 3, $02
		 db 	 3, $03
		 db 	 1, $01
		 db 	 3, $02
		 db 	 10, $03
		 db 	 1, $01
		 db 	 3, $02
		 db 	 10, $03
		 db 	 4, $00
		 db 	 25, $01
		 db 	 2, $02
		 db 	 25, $03
		 db 	 4, $00
		 db 	 18, $01
		 db 	 3, $02
		 db 	 3, $03
		 db 	 1, $01
		 db 	 3, $02
		 db 	 10, $03
		 db 	 1, $01
		 db 	 3, $02
		 db 	 10, $03
		 db 	 4, $00
		 db 	 25, $01
		 db 	 2, $02
		 db 	 25, $03
		 db 	 4, $00
		 db 	 18, $01
		 db 	 3, $02
		 db 	 3, $03
		 db 	 1, $01
		 db 	 3, $02
		 db 	 10, $03
		 db 	 1, $01
		 db 	 3, $02
		 db 	 10, $03
		 db 	 4, $00
		 db 	 25, $01
		 db 	 2, $02
		 db 	 25, $03
		 db 	 4, $00
		 db 	 18, $01
		 db 	 3, $02
		 db 	 3, $03
		 db 	 1, $01
		 db 	 3, $02
		 db 	 10, $03
		 db 	 1, $01
		 db 	 3, $02
		 db 	 10, $03
		 db 	 4, $00
		 db 	 25, $01
		 db 	 2, $02
		 db 	 25, $03
		 db 	 4, $00
		 db 	 18, $01
		 db 	 3, $02
		 db 	 3, $03
		 db 	 1, $01
		 db 	 3, $02
		 db 	 10, $03
		 db 	 1, $01
		 db 	 3, $02
		 db 	 10, $03
		 db 	 4, $00
		 db 	 25, $01
		 db 	 2, $02
		 db 	 25, $03
		 db 	 4, $00
		 db 	 18, $01
		 db 	 3, $02
		 db 	 3, $03
		 db 	 1, $01
		 db 	 3, $02
		 db 	 10, $03
		 db 	 1, $01
		 db 	 3, $02
		 db 	 10, $03
		 db 	 4, $00
		 db 	 25, $01
		 db 	 2, $02
		 db 	 25, $03
		 db 	 4, $00
		 db 	 18, $01
		 db 	 3, $02
		 db 	 3, $03
		 db 	 1, $01
		 db 	 3, $02
		 db 	 10, $03
		 db 	 1, $01
		 db 	 3, $02
		 db 	 10, $03
		 db 	 4, $00
		 db 	 25, $01
		 db 	 2, $02
		 db 	 25, $03
		 db 	 4, $00
		 db 	 18, $01
		 db 	 3, $02
		 db 	 3, $03
		 db 	 1, $01
		 db 	 3, $02
		 db 	 10, $03
		 db 	 1, $01
		 db 	 3, $02
		 db 	 10, $03
		 db 	 4, $00
		 db 	 25, $01
		 db 	 2, $02
		 db 	 25, $03
		 db 	 4, $00
		 db 	 18, $01
		 db 	 3, $02
		 db 	 3, $03
		 db 	 1, $01
		 db 	 3, $02
		 db 	 10, $03
		 db 	 1, $01
		 db 	 3, $02
		 db 	 10, $03
		 db 	 4, $00
		 db 	 25, $01
		 db 	 2, $02
		 db 	 25, $03
		 db 	 4, $00
		 db 	 18, $01
		 db 	 3, $02
		 db 	 3, $03
		 db 	 1, $01
		 db 	 3, $02
		 db 	 10, $03
		 db 	 1, $01
		 db 	 3, $02
		 db 	 10, $03
		 db 	 4, $00
		 db 	 25, $01
		 db 	 2, $02
		 db 	 25, $03
		 db 	 4, $00
		 db 	 18, $01
		 db 	 3, $02
		 db 	 3, $03
		 db 	 1, $01
		 db 	 3, $02
		 db 	 10, $03
		 db 	 1, $01
		 db 	 3, $02
		 db 	 10, $03
		 db 	 4, $00
		 db 	 25, $01
		 db 	 2, $02
		 db 	 25, $03
		 db 	 4, $00
		 db 	 18, $01
		 db 	 3, $02
		 db 	 3, $03
		 db 	 1, $01
		 db 	 3, $02
		 db 	 10, $03
		 db 	 1, $01
		 db 	 3, $02
		 db 	 10, $03
		 db 	 4, $00
		 db 	 25, $01
		 db 	 2, $02
		 db 	 25, $03
		 db 	 4, $00
		 db 	 18, $01
		 db 	 3, $02
		 db 	 3, $03
		 db 	 1, $01
		 db 	 3, $02
		 db 	 10, $03
		 db 	 1, $01
		 db 	 3, $02
		 db 	 10, $03
		 db 	 4, $00
		 db 	 25, $01
		 db 	 2, $02
		 db 	 25, $03
		 db 	 4, $00
		 db 	 18, $01
		 db 	 3, $02
		 db 	 3, $03
		 db 	 1, $01
		 db 	 3, $02
		 db 	 10, $03
		 db 	 1, $01
		 db 	 3, $02
		 db 	 10, $03
		 db 	 4, $00
		 db 	 25, $01
		 db 	 2, $02
		 db 	 25, $03
		 db 	 4, $00
		 db 	 18, $01
		 db 	 3, $02
		 db 	 3, $03
		 db 	 1, $01
		 db 	 3, $02
		 db 	 10, $03
		 db 	 1, $01
		 db 	 3, $02
		 db 	 10, $03
		 db 	 4, $00
		 db 	 25, $01
		 db 	 2, $02
		 db 	 25, $03
		 db 	 4, $00
		 db 	 18, $01
		 db 	 3, $02
		 db 	 3, $03
		 db 	 1, $01
		 db 	 3, $02
		 db 	 10, $03
		 db 	 1, $01
		 db 	 3, $02
		 db 	 10, $03
		 db 	 4, $00
		 db 	 24, $01

;; Sum for R5 : 3136
;; Data stream for register 6
sgj_1_r_6:
		 db 	 255, $06
		 db 	 221, $06
		 db 	 3, $09
		 db 	 18, $05
		 db 	 3, $09
		 db 	 4, $05
		 db 	 3, $09
		 db 	 11, $05
		 db 	 3, $09
		 db 	 11, $05
		 db 	 3, $09
		 db 	 25, $05
		 db 	 28, $06
		 db 	 3, $09
		 db 	 18, $05
		 db 	 3, $09
		 db 	 4, $05
		 db 	 3, $09
		 db 	 11, $05
		 db 	 3, $09
		 db 	 11, $05
		 db 	 3, $09
		 db 	 25, $05
		 db 	 28, $06
		 db 	 3, $09
		 db 	 18, $05
		 db 	 3, $09
		 db 	 4, $05
		 db 	 3, $09
		 db 	 11, $05
		 db 	 3, $09
		 db 	 11, $05
		 db 	 3, $09
		 db 	 25, $05
		 db 	 28, $06
		 db 	 3, $09
		 db 	 18, $05
		 db 	 3, $09
		 db 	 4, $05
		 db 	 3, $09
		 db 	 11, $05
		 db 	 3, $09
		 db 	 11, $05
		 db 	 3, $09
		 db 	 25, $05
		 db 	 28, $06
		 db 	 3, $09
		 db 	 18, $05
		 db 	 3, $09
		 db 	 4, $05
		 db 	 3, $09
		 db 	 11, $05
		 db 	 3, $09
		 db 	 11, $05
		 db 	 3, $09
		 db 	 25, $05
		 db 	 28, $06
		 db 	 3, $09
		 db 	 18, $05
		 db 	 3, $09
		 db 	 4, $05
		 db 	 3, $09
		 db 	 11, $05
		 db 	 3, $09
		 db 	 11, $05
		 db 	 3, $09
		 db 	 25, $05
		 db 	 28, $06
		 db 	 3, $09
		 db 	 18, $05
		 db 	 3, $09
		 db 	 4, $05
		 db 	 3, $09
		 db 	 11, $05
		 db 	 3, $09
		 db 	 11, $05
		 db 	 3, $09
		 db 	 25, $05
		 db 	 28, $06
		 db 	 3, $09
		 db 	 18, $05
		 db 	 3, $09
		 db 	 4, $05
		 db 	 3, $09
		 db 	 11, $05
		 db 	 3, $09
		 db 	 11, $05
		 db 	 3, $09
		 db 	 25, $05
		 db 	 28, $06
		 db 	 3, $09
		 db 	 18, $05
		 db 	 3, $09
		 db 	 4, $05
		 db 	 3, $09
		 db 	 11, $05
		 db 	 3, $09
		 db 	 11, $05
		 db 	 3, $09
		 db 	 25, $05
		 db 	 28, $06
		 db 	 3, $09
		 db 	 18, $05
		 db 	 3, $09
		 db 	 4, $05
		 db 	 3, $09
		 db 	 11, $05
		 db 	 3, $09
		 db 	 11, $05
		 db 	 3, $09
		 db 	 25, $05
		 db 	 28, $06
		 db 	 3, $09
		 db 	 18, $05
		 db 	 3, $09
		 db 	 4, $05
		 db 	 3, $09
		 db 	 11, $05
		 db 	 3, $09
		 db 	 11, $05
		 db 	 3, $09
		 db 	 25, $05
		 db 	 28, $06
		 db 	 3, $09
		 db 	 18, $05
		 db 	 3, $09
		 db 	 4, $05
		 db 	 3, $09
		 db 	 11, $05
		 db 	 3, $09
		 db 	 11, $05
		 db 	 3, $09
		 db 	 25, $05
		 db 	 28, $06
		 db 	 3, $09
		 db 	 18, $05
		 db 	 3, $09
		 db 	 4, $05
		 db 	 3, $09
		 db 	 11, $05
		 db 	 3, $09
		 db 	 11, $05
		 db 	 3, $09
		 db 	 25, $05
		 db 	 28, $06
		 db 	 3, $09
		 db 	 18, $05
		 db 	 3, $09
		 db 	 4, $05
		 db 	 3, $09
		 db 	 11, $05
		 db 	 3, $09
		 db 	 11, $05
		 db 	 3, $09
		 db 	 25, $05
		 db 	 28, $06
		 db 	 3, $09
		 db 	 18, $05
		 db 	 3, $09
		 db 	 4, $05
		 db 	 3, $09
		 db 	 11, $05
		 db 	 3, $09
		 db 	 11, $05
		 db 	 3, $09
		 db 	 25, $05
		 db 	 28, $06
		 db 	 3, $09
		 db 	 18, $05
		 db 	 3, $09
		 db 	 4, $05
		 db 	 3, $09
		 db 	 11, $05
		 db 	 3, $09
		 db 	 11, $05
		 db 	 3, $09
		 db 	 25, $05
		 db 	 28, $06
		 db 	 3, $09
		 db 	 18, $05
		 db 	 3, $09
		 db 	 4, $05
		 db 	 3, $09
		 db 	 11, $05
		 db 	 3, $09
		 db 	 11, $05
		 db 	 3, $09
		 db 	 25, $05
		 db 	 28, $06
		 db 	 3, $09
		 db 	 18, $05
		 db 	 3, $09
		 db 	 4, $05
		 db 	 3, $09
		 db 	 11, $05
		 db 	 3, $09
		 db 	 11, $05
		 db 	 3, $09
		 db 	 25, $05
		 db 	 28, $06
		 db 	 3, $09
		 db 	 18, $05
		 db 	 3, $09
		 db 	 4, $05
		 db 	 3, $09
		 db 	 11, $05
		 db 	 3, $09
		 db 	 11, $05
		 db 	 3, $09
		 db 	 25, $05
		 db 	 28, $06
		 db 	 3, $09
		 db 	 18, $05
		 db 	 3, $09
		 db 	 4, $05
		 db 	 3, $09
		 db 	 11, $05
		 db 	 3, $09
		 db 	 11, $05
		 db 	 3, $09
		 db 	 25, $05
		 db 	 28, $06
		 db 	 3, $09
		 db 	 18, $05
		 db 	 3, $09
		 db 	 4, $05
		 db 	 3, $09
		 db 	 11, $05
		 db 	 3, $09
		 db 	 11, $05
		 db 	 3, $09
		 db 	 25, $05
		 db 	 28, $06
		 db 	 3, $09
		 db 	 18, $05
		 db 	 3, $09
		 db 	 4, $05
		 db 	 3, $09
		 db 	 11, $05
		 db 	 3, $09
		 db 	 11, $05
		 db 	 3, $09
		 db 	 25, $05
		 db 	 28, $06
		 db 	 3, $09
		 db 	 18, $05
		 db 	 3, $09
		 db 	 4, $05
		 db 	 3, $09
		 db 	 11, $05
		 db 	 3, $09
		 db 	 11, $05
		 db 	 3, $09
		 db 	 25, $05
		 db 	 28, $06
		 db 	 3, $09
		 db 	 18, $05
		 db 	 3, $09
		 db 	 4, $05
		 db 	 3, $09
		 db 	 11, $05
		 db 	 3, $09
		 db 	 11, $05
		 db 	 3, $09
		 db 	 25, $05

;; Sum for R6 : 3136
;; Data stream for register 7
sgj_1_r_7:
		 db 	 1, $1B
		 db 	 4, $3B
		 db 	 23, $3F
		 db 	 1, $1B
		 db 	 4, $3B
		 db 	 23, $3F
		 db 	 1, $1B
		 db 	 4, $3B
		 db 	 23, $3F
		 db 	 1, $1B
		 db 	 4, $3B
		 db 	 23, $3F
		 db 	 1, $1B
		 db 	 4, $3B
		 db 	 23, $3F
		 db 	 1, $1B
		 db 	 4, $3B
		 db 	 23, $3F
		 db 	 1, $1B
		 db 	 4, $3B
		 db 	 23, $3F
		 db 	 1, $1B
		 db 	 4, $3B
		 db 	 23, $3F
		 db 	 1, $19
		 db 	 4, $39
		 db 	 23, $3D
		 db 	 1, $19
		 db 	 4, $39
		 db 	 23, $3D
		 db 	 1, $19
		 db 	 4, $39
		 db 	 23, $3D
		 db 	 1, $19
		 db 	 4, $39
		 db 	 23, $3D
		 db 	 1, $19
		 db 	 4, $39
		 db 	 23, $3D
		 db 	 1, $19
		 db 	 4, $39
		 db 	 23, $3D
		 db 	 1, $19
		 db 	 4, $39
		 db 	 23, $3D
		 db 	 1, $19
		 db 	 4, $39
		 db 	 23, $3D
		 db 	 1, $19
		 db 	 4, $39
		 db 	 23, $3D
		 db 	 1, $19
		 db 	 2, $39
		 db 	 2, $19
		 db 	 16, $3D
		 db 	 1, $19
		 db 	 2, $39
		 db 	 2, $19
		 db 	 2, $3D
		 db 	 1, $19
		 db 	 2, $39
		 db 	 2, $19
		 db 	 9, $3D
		 db 	 1, $19
		 db 	 2, $39
		 db 	 2, $19
		 db 	 9, $3D
		 db 	 1, $19
		 db 	 2, $39
		 db 	 2, $19
		 db 	 23, $3D
		 db 	 1, $19
		 db 	 4, $39
		 db 	 23, $3D
		 db 	 1, $19
		 db 	 2, $39
		 db 	 2, $19
		 db 	 16, $3D
		 db 	 1, $19
		 db 	 2, $39
		 db 	 2, $19
		 db 	 2, $3D
		 db 	 1, $19
		 db 	 2, $39
		 db 	 2, $19
		 db 	 9, $3D
		 db 	 1, $19
		 db 	 2, $39
		 db 	 2, $19
		 db 	 9, $3D
		 db 	 1, $19
		 db 	 2, $39
		 db 	 2, $19
		 db 	 23, $3D
		 db 	 1, $19
		 db 	 4, $39
		 db 	 23, $3D
		 db 	 1, $19
		 db 	 2, $39
		 db 	 2, $19
		 db 	 16, $3D
		 db 	 1, $19
		 db 	 2, $39
		 db 	 2, $19
		 db 	 2, $3D
		 db 	 1, $19
		 db 	 2, $39
		 db 	 2, $19
		 db 	 9, $3D
		 db 	 1, $19
		 db 	 2, $39
		 db 	 2, $19
		 db 	 9, $3D
		 db 	 1, $19
		 db 	 2, $39
		 db 	 2, $19
		 db 	 23, $3D
		 db 	 1, $19
		 db 	 4, $39
		 db 	 23, $3D
		 db 	 1, $19
		 db 	 2, $39
		 db 	 2, $19
		 db 	 16, $3D
		 db 	 1, $19
		 db 	 2, $39
		 db 	 2, $19
		 db 	 2, $3D
		 db 	 1, $19
		 db 	 2, $39
		 db 	 2, $19
		 db 	 9, $3D
		 db 	 1, $19
		 db 	 2, $39
		 db 	 2, $19
		 db 	 9, $3D
		 db 	 1, $19
		 db 	 2, $39
		 db 	 2, $19
		 db 	 23, $3D
		 db 	 1, $18
		 db 	 4, $38
		 db 	 23, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 16, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 2, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 9, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 9, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 23, $3C
		 db 	 1, $18
		 db 	 4, $38
		 db 	 23, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 16, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 2, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 9, $3C
		 db 	 1, $18
		 db 	 2, $3A
		 db 	 2, $1A
		 db 	 9, $3E
		 db 	 1, $1A
		 db 	 2, $3A
		 db 	 2, $1A
		 db 	 23, $3E
		 db 	 1, $18
		 db 	 4, $38
		 db 	 23, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 16, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 2, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 9, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 9, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 23, $3C
		 db 	 1, $18
		 db 	 4, $38
		 db 	 23, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 16, $3C
		 db 	 1, $18
		 db 	 2, $3A
		 db 	 2, $1A
		 db 	 2, $3E
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 9, $3C
		 db 	 1, $18
		 db 	 2, $3A
		 db 	 2, $1A
		 db 	 9, $3E
		 db 	 1, $1A
		 db 	 2, $3A
		 db 	 2, $1A
		 db 	 23, $3E
		 db 	 1, $18
		 db 	 4, $38
		 db 	 23, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 16, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 2, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 9, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 9, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 23, $3C
		 db 	 1, $18
		 db 	 4, $38
		 db 	 23, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 16, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 2, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 9, $3C
		 db 	 1, $18
		 db 	 2, $3A
		 db 	 2, $1A
		 db 	 9, $3E
		 db 	 1, $1A
		 db 	 2, $3A
		 db 	 2, $1A
		 db 	 23, $3E
		 db 	 1, $18
		 db 	 4, $38
		 db 	 23, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 16, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 2, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 9, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 9, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 23, $3C
		 db 	 1, $18
		 db 	 4, $38
		 db 	 23, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 16, $3C
		 db 	 1, $18
		 db 	 2, $3A
		 db 	 2, $1A
		 db 	 2, $3E
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 9, $3C
		 db 	 1, $18
		 db 	 2, $3A
		 db 	 2, $1A
		 db 	 9, $3E
		 db 	 1, $1A
		 db 	 2, $3A
		 db 	 2, $1A
		 db 	 23, $3E
		 db 	 1, $18
		 db 	 4, $38
		 db 	 23, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 16, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 2, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 9, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 9, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 23, $3C
		 db 	 1, $18
		 db 	 4, $38
		 db 	 23, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 16, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 2, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 9, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 9, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 23, $3C
		 db 	 1, $18
		 db 	 4, $38
		 db 	 23, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 16, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 2, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 9, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 9, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 23, $3C
		 db 	 1, $18
		 db 	 4, $38
		 db 	 23, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 16, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 2, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 9, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 9, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 23, $3C
		 db 	 1, $18
		 db 	 4, $38
		 db 	 23, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 16, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 2, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 9, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 9, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 23, $3C
		 db 	 1, $18
		 db 	 4, $38
		 db 	 23, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 16, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 2, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 9, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 9, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 23, $3C
		 db 	 1, $18
		 db 	 4, $38
		 db 	 23, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 16, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 2, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 9, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 9, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 23, $3C
		 db 	 1, $18
		 db 	 4, $38
		 db 	 23, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 16, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 2, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 9, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 9, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 23, $3C
		 db 	 1, $18
		 db 	 4, $38
		 db 	 23, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 16, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 2, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 9, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 9, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 23, $3C
		 db 	 1, $18
		 db 	 4, $38
		 db 	 23, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 16, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 2, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 9, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 9, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 23, $3C
		 db 	 1, $18
		 db 	 4, $38
		 db 	 23, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 16, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 2, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 9, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 9, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 23, $3C
		 db 	 1, $18
		 db 	 4, $38
		 db 	 23, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 16, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 2, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 9, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 9, $3C
		 db 	 1, $18
		 db 	 2, $38
		 db 	 2, $18
		 db 	 23, $3C

;; Sum for R7 : 3136
;; Data stream for register 8
sgj_1_r_8:
		 db 	 255, $00
		 db 	 255, $00
		 db 	 255, $00
		 db 	 131, $00
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 6, $09
		 db 	 6, $04
		 db 	 6, $06
		 db 	 6, $04
		 db 	 6, $06
		 db 	 2, $04
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 6, $09
		 db 	 6, $04
		 db 	 6, $06
		 db 	 6, $04
		 db 	 6, $06
		 db 	 2, $04
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 6, $09
		 db 	 6, $04
		 db 	 6, $06
		 db 	 6, $04
		 db 	 6, $06
		 db 	 2, $04
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 6, $09
		 db 	 6, $04
		 db 	 6, $06
		 db 	 6, $04
		 db 	 6, $06
		 db 	 2, $04
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 6, $09
		 db 	 6, $04
		 db 	 6, $06
		 db 	 6, $04
		 db 	 6, $06
		 db 	 2, $04
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 6, $09
		 db 	 6, $04
		 db 	 6, $06
		 db 	 6, $04
		 db 	 6, $06
		 db 	 2, $04
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 4, $09
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 4, $09
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 6, $09
		 db 	 6, $04
		 db 	 6, $06
		 db 	 6, $04
		 db 	 6, $06
		 db 	 2, $04
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 6, $09
		 db 	 6, $04
		 db 	 6, $06
		 db 	 6, $04
		 db 	 6, $06
		 db 	 2, $04
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 6, $09
		 db 	 6, $04
		 db 	 6, $06
		 db 	 6, $04
		 db 	 6, $06
		 db 	 2, $04
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 6, $09
		 db 	 6, $04
		 db 	 6, $06
		 db 	 6, $04
		 db 	 6, $06
		 db 	 2, $04
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 6, $09
		 db 	 6, $04
		 db 	 6, $06
		 db 	 6, $04
		 db 	 6, $06
		 db 	 2, $04
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 6, $09
		 db 	 6, $04
		 db 	 6, $06
		 db 	 6, $04
		 db 	 6, $06
		 db 	 2, $04
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 6, $09
		 db 	 6, $04
		 db 	 6, $06
		 db 	 6, $04
		 db 	 6, $06
		 db 	 2, $04
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 4, $09
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 4, $09
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 6, $09
		 db 	 6, $04
		 db 	 6, $06
		 db 	 6, $04
		 db 	 6, $06
		 db 	 2, $04
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 6, $09
		 db 	 6, $04
		 db 	 6, $06
		 db 	 6, $04
		 db 	 6, $06
		 db 	 2, $04
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 6, $09
		 db 	 6, $04
		 db 	 6, $06
		 db 	 6, $04
		 db 	 6, $06
		 db 	 2, $04
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 6, $09
		 db 	 6, $04
		 db 	 6, $06
		 db 	 6, $04
		 db 	 6, $06
		 db 	 2, $04
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 6, $09
		 db 	 6, $04
		 db 	 6, $06
		 db 	 6, $04
		 db 	 6, $06
		 db 	 2, $04
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 6, $09
		 db 	 6, $04
		 db 	 6, $06
		 db 	 6, $04
		 db 	 6, $06
		 db 	 2, $04
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 6, $09
		 db 	 6, $04
		 db 	 6, $06
		 db 	 6, $04
		 db 	 6, $06
		 db 	 2, $04
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 6, $09
		 db 	 6, $04
		 db 	 6, $06
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 6, $09
		 db 	 6, $04
		 db 	 6, $06
		 db 	 6, $04
		 db 	 6, $06
		 db 	 2, $04
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 6, $09
		 db 	 6, $04
		 db 	 6, $06
		 db 	 6, $04
		 db 	 6, $06
		 db 	 2, $04
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 6, $09
		 db 	 6, $04
		 db 	 6, $06
		 db 	 6, $04
		 db 	 6, $06
		 db 	 2, $04
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 6, $09
		 db 	 6, $04
		 db 	 6, $06
		 db 	 6, $04
		 db 	 6, $06
		 db 	 2, $04
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 6, $09
		 db 	 6, $04
		 db 	 6, $06
		 db 	 6, $04
		 db 	 6, $06
		 db 	 2, $04
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 6, $09
		 db 	 6, $04
		 db 	 6, $06
		 db 	 6, $04
		 db 	 6, $06
		 db 	 2, $04
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 6, $09
		 db 	 6, $04
		 db 	 6, $06
		 db 	 6, $04
		 db 	 6, $06
		 db 	 2, $04
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 6, $09
		 db 	 6, $04
		 db 	 6, $06
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 6, $09
		 db 	 6, $04
		 db 	 6, $06
		 db 	 6, $04
		 db 	 6, $06
		 db 	 2, $04
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 6, $09
		 db 	 6, $04
		 db 	 6, $06
		 db 	 6, $04
		 db 	 6, $06
		 db 	 2, $04
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 6, $09
		 db 	 6, $04
		 db 	 6, $06
		 db 	 6, $04
		 db 	 6, $06
		 db 	 2, $04
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 6, $09
		 db 	 6, $04
		 db 	 6, $06
		 db 	 6, $04
		 db 	 6, $06
		 db 	 2, $04
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 6, $09
		 db 	 6, $04
		 db 	 6, $06
		 db 	 6, $04
		 db 	 6, $06
		 db 	 2, $04
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 6, $09
		 db 	 6, $04
		 db 	 6, $06
		 db 	 6, $04
		 db 	 6, $06
		 db 	 2, $04
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 6, $09
		 db 	 6, $04
		 db 	 6, $06
		 db 	 6, $04
		 db 	 6, $06
		 db 	 2, $04
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 6, $09
		 db 	 6, $04
		 db 	 6, $06
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 6, $09
		 db 	 6, $04
		 db 	 6, $06
		 db 	 6, $04
		 db 	 6, $06
		 db 	 2, $04

;; Sum for R8 : 3136
;; Data stream for register 9
sgj_1_r_9:
		 db 	 224, $00
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 6, $09
		 db 	 6, $04
		 db 	 6, $06
		 db 	 6, $04
		 db 	 6, $06
		 db 	 2, $04
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 6, $09
		 db 	 6, $04
		 db 	 6, $06
		 db 	 6, $04
		 db 	 6, $06
		 db 	 2, $04
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 6, $09
		 db 	 6, $04
		 db 	 6, $06
		 db 	 6, $04
		 db 	 6, $06
		 db 	 2, $04
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 6, $09
		 db 	 6, $04
		 db 	 6, $06
		 db 	 6, $04
		 db 	 6, $06
		 db 	 2, $04
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 6, $09
		 db 	 6, $04
		 db 	 6, $06
		 db 	 6, $04
		 db 	 6, $06
		 db 	 2, $04
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 6, $09
		 db 	 6, $04
		 db 	 6, $06
		 db 	 6, $04
		 db 	 6, $06
		 db 	 2, $04
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 6, $09
		 db 	 6, $04
		 db 	 6, $06
		 db 	 6, $04
		 db 	 6, $06
		 db 	 2, $04
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 6, $09
		 db 	 6, $04
		 db 	 6, $06
		 db 	 6, $04
		 db 	 6, $06
		 db 	 2, $04
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 6, $09
		 db 	 6, $04
		 db 	 6, $06
		 db 	 6, $04
		 db 	 6, $06
		 db 	 2, $04
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 6, $09
		 db 	 6, $04
		 db 	 6, $06
		 db 	 6, $04
		 db 	 6, $06
		 db 	 2, $04
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 4, $09
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 4, $09
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 6, $09
		 db 	 6, $04
		 db 	 6, $06
		 db 	 6, $04
		 db 	 6, $06
		 db 	 2, $04
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 4, $09
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 4, $09
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 4, $09
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 4, $09
		 db 	 6, $0F
		 db 	 1, $08
		 db 	 6, $0F
		 db 	 1, $08
		 db 	 6, $0F
		 db 	 1, $08
		 db 	 6, $0F
		 db 	 1, $08
		 db 	 6, $0F
		 db 	 1, $08
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 3, $06
		 db 	 1, $0F
		 db 	 1, $0E
		 db 	 1, $0D
		 db 	 1, $0C
		 db 	 1, $0B
		 db 	 1, $0A
		 db 	 1, $09
		 db 	 1, $08
		 db 	 1, $07
		 db 	 1, $06
		 db 	 1, $05
		 db 	 1, $04
		 db 	 1, $03
		 db 	 1, $02
		 db 	 1, $01
		 db 	 41, $00
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 4, $09
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 4, $09
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 4, $09
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 4, $09
		 db 	 6, $0F
		 db 	 1, $08
		 db 	 6, $0F
		 db 	 1, $08
		 db 	 6, $0F
		 db 	 1, $08
		 db 	 6, $0F
		 db 	 1, $08
		 db 	 6, $0F
		 db 	 1, $08
		 db 	 1, $0F
		 db 	 1, $0E
		 db 	 1, $0D
		 db 	 1, $0C
		 db 	 1, $0B
		 db 	 1, $0A
		 db 	 1, $09
		 db 	 1, $08
		 db 	 1, $07
		 db 	 1, $06
		 db 	 1, $05
		 db 	 1, $04
		 db 	 1, $03
		 db 	 1, $02
		 db 	 1, $01
		 db 	 6, $00
		 db 	 1, $0F
		 db 	 1, $0E
		 db 	 1, $0D
		 db 	 1, $0C
		 db 	 1, $0B
		 db 	 1, $0A
		 db 	 1, $09
		 db 	 1, $08
		 db 	 1, $07
		 db 	 1, $06
		 db 	 1, $05
		 db 	 1, $04
		 db 	 1, $03
		 db 	 1, $02
		 db 	 1, $01
		 db 	 41, $00
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 4, $09
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 4, $09
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 4, $09
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 4, $09
		 db 	 6, $0F
		 db 	 1, $08
		 db 	 6, $0F
		 db 	 1, $08
		 db 	 6, $0F
		 db 	 1, $08
		 db 	 6, $0F
		 db 	 1, $08
		 db 	 6, $0F
		 db 	 1, $08
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 3, $06
		 db 	 1, $0F
		 db 	 1, $0E
		 db 	 1, $0D
		 db 	 1, $0C
		 db 	 1, $0B
		 db 	 1, $0A
		 db 	 1, $09
		 db 	 1, $08
		 db 	 1, $07
		 db 	 1, $06
		 db 	 1, $05
		 db 	 1, $04
		 db 	 1, $03
		 db 	 1, $02
		 db 	 1, $01
		 db 	 41, $00
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 4, $09
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 4, $09
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 4, $09
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 4, $09
		 db 	 6, $0F
		 db 	 1, $08
		 db 	 6, $0F
		 db 	 1, $08
		 db 	 6, $0F
		 db 	 1, $08
		 db 	 6, $0F
		 db 	 1, $08
		 db 	 6, $0F
		 db 	 1, $08
		 db 	 1, $0F
		 db 	 1, $0E
		 db 	 1, $0D
		 db 	 1, $0C
		 db 	 1, $0B
		 db 	 1, $0A
		 db 	 1, $09
		 db 	 1, $08
		 db 	 1, $07
		 db 	 1, $06
		 db 	 1, $05
		 db 	 1, $04
		 db 	 1, $03
		 db 	 1, $02
		 db 	 1, $01
		 db 	 6, $00
		 db 	 1, $0F
		 db 	 1, $0E
		 db 	 1, $0D
		 db 	 1, $0C
		 db 	 1, $0B
		 db 	 1, $0A
		 db 	 1, $09
		 db 	 1, $08
		 db 	 1, $07
		 db 	 1, $06
		 db 	 1, $05
		 db 	 1, $04
		 db 	 1, $03
		 db 	 1, $02
		 db 	 1, $01
		 db 	 41, $00
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 4, $09
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 4, $09
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 6, $09
		 db 	 6, $04
		 db 	 6, $06
		 db 	 6, $04
		 db 	 6, $06
		 db 	 2, $04
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 4, $09
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 4, $09
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 6, $09
		 db 	 6, $04
		 db 	 6, $06
		 db 	 6, $04
		 db 	 6, $06
		 db 	 2, $04
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 4, $09
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 4, $09
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 2, $0C
		 db 	 6, $0F
		 db 	 6, $08
		 db 	 6, $0C
		 db 	 6, $06
		 db 	 6, $09
		 db 	 6, $04
		 db 	 6, $06
		 db 	 6, $04
		 db 	 6, $06
		 db 	 2, $04

;; Sum for R9 : 3136
;; Data stream for register 10
sgj_1_r_10:
		 db 	 3, $0F
		 db 	 2, $0E
		 db 	 23, $00
		 db 	 3, $0F
		 db 	 2, $0E
		 db 	 23, $00
		 db 	 3, $0F
		 db 	 2, $0E
		 db 	 23, $00
		 db 	 3, $0F
		 db 	 2, $0E
		 db 	 23, $00
		 db 	 3, $0F
		 db 	 2, $0E
		 db 	 23, $00
		 db 	 3, $0F
		 db 	 2, $0E
		 db 	 23, $00
		 db 	 3, $0F
		 db 	 2, $0E
		 db 	 23, $00
		 db 	 3, $0F
		 db 	 2, $0E
		 db 	 23, $00
		 db 	 3, $0F
		 db 	 2, $0E
		 db 	 23, $00
		 db 	 3, $0F
		 db 	 2, $0E
		 db 	 23, $00
		 db 	 3, $0F
		 db 	 2, $0E
		 db 	 23, $00
		 db 	 3, $0F
		 db 	 2, $0E
		 db 	 23, $00
		 db 	 3, $0F
		 db 	 2, $0E
		 db 	 23, $00
		 db 	 3, $0F
		 db 	 2, $0E
		 db 	 23, $00
		 db 	 3, $0F
		 db 	 2, $0E
		 db 	 23, $00
		 db 	 3, $0F
		 db 	 2, $0E
		 db 	 23, $00
		 db 	 3, $0F
		 db 	 2, $0E
		 db 	 23, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 16, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 2, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 9, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 9, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 23, $00
		 db 	 3, $0F
		 db 	 2, $0E
		 db 	 23, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 16, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 2, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 9, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 9, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 23, $00
		 db 	 3, $0F
		 db 	 2, $0E
		 db 	 23, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 16, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 2, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 9, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 9, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 23, $00
		 db 	 3, $0F
		 db 	 2, $0E
		 db 	 23, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 16, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 2, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 9, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 9, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 23, $00
		 db 	 3, $0F
		 db 	 2, $0E
		 db 	 23, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 16, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 2, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 9, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 9, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 23, $00
		 db 	 3, $0F
		 db 	 2, $0E
		 db 	 23, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 16, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 2, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 9, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 9, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 23, $00
		 db 	 3, $0F
		 db 	 2, $0E
		 db 	 23, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 16, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 2, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 9, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 9, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 23, $00
		 db 	 3, $0F
		 db 	 2, $0E
		 db 	 23, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 16, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 2, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 9, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 9, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 23, $00
		 db 	 3, $0F
		 db 	 2, $0E
		 db 	 23, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 16, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 2, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 9, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 9, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 23, $00
		 db 	 3, $0F
		 db 	 2, $0E
		 db 	 23, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 16, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 2, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 9, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 9, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 23, $00
		 db 	 3, $0F
		 db 	 2, $0E
		 db 	 23, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 16, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 2, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 9, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 9, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 23, $00
		 db 	 3, $0F
		 db 	 2, $0E
		 db 	 23, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 16, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 2, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 9, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 9, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 23, $00
		 db 	 3, $0F
		 db 	 2, $0E
		 db 	 23, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 16, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 2, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 9, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 9, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 23, $00
		 db 	 3, $0F
		 db 	 2, $0E
		 db 	 23, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 16, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 2, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 9, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 9, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 23, $00
		 db 	 3, $0F
		 db 	 2, $0E
		 db 	 23, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 16, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 2, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 9, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 9, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 23, $00
		 db 	 3, $0F
		 db 	 2, $0E
		 db 	 23, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 16, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 2, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 9, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 9, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 23, $00
		 db 	 3, $0F
		 db 	 2, $0E
		 db 	 23, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 16, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 2, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 9, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 9, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 23, $00
		 db 	 3, $0F
		 db 	 2, $0E
		 db 	 23, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 16, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 2, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 9, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 9, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 23, $00
		 db 	 3, $0F
		 db 	 2, $0E
		 db 	 23, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 16, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 2, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 9, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 9, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 23, $00
		 db 	 3, $0F
		 db 	 2, $0E
		 db 	 23, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 16, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 2, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 9, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 9, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 23, $00
		 db 	 3, $0F
		 db 	 2, $0E
		 db 	 23, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 16, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 2, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 9, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 9, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 23, $00
		 db 	 3, $0F
		 db 	 2, $0E
		 db 	 23, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 16, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 2, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 9, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 9, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 23, $00
		 db 	 3, $0F
		 db 	 2, $0E
		 db 	 23, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 16, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 2, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 9, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 9, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 23, $00
		 db 	 3, $0F
		 db 	 2, $0E
		 db 	 23, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 16, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 2, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 9, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 9, $00
		 db 	 3, $0F
		 db 	 1, $0D
		 db 	 1, $0B
		 db 	 23, $00
		 
;; YM conversion from c:\mystuff\vectrex\sgj_loss.ym
;; Song title   : SGJ_Loss
;; Song author  : MountainGoat
;; Number of frames: 
SGJ_LOSS_NUM_FRAMES		equ	96
;; Number of AY registers output :

sgj_loss:
		dw	96	;; number of frames
		dw	sgj_loss_r_0
		dw	sgj_loss_r_1
		dw	sgj_loss_r_2
		dw	sgj_loss_r_3
		dw	sgj_loss_r_4
		dw	sgj_loss_r_5
		dw	sgj_loss_r_6
		dw	sgj_loss_r_7
		dw	sgj_loss_r_8
		dw	sgj_loss_r_9
		dw	sgj_loss_r_10
;; Data stream for register 0
sgj_loss_r_0:
		 db 	 2, $DE
		 db 	 2, $C4
		 db 	 2, $B5
		 db 	 2, $AC
		 db 	 2, $DE
		 db 	 2, $F2
		 db 	 2, $D4
		 db 	 2, $C3
		 db 	 2, $BC
		 db 	 4, $DE
		 db 	 2, $08
		 db 	 2, $E7
		 db 	 2, $DC
		 db 	 2, $C8
		 db 	 4, $DE
		 db 	 2, $22
		 db 	 2, $FB
		 db 	 2, $E2
		 db 	 2, $D7
		 db 	 4, $DE
		 db 	 2, $3F
		 db 	 2, $07
		 db 	 2, $F4
		 db 	 44, $E0

;; Sum for R0 : 96
;; Data stream for register 1
sgj_loss_r_1:
		 db 	 22, $01
		 db 	 2, $02
		 db 	 10, $01
		 db 	 2, $02
		 db 	 10, $01
		 db 	 4, $02
		 db 	 46, $01

;; Sum for R1 : 96
;; Data stream for register 2
sgj_loss_r_2:
		 db 	 2, $EF
		 db 	 2, $D5
		 db 	 2, $C6
		 db 	 2, $BD
		 db 	 2, $EF
		 db 	 2, $03
		 db 	 2, $E5
		 db 	 2, $D4
		 db 	 2, $CD
		 db 	 4, $EF
		 db 	 2, $19
		 db 	 2, $F8
		 db 	 2, $ED
		 db 	 2, $D9
		 db 	 4, $EF
		 db 	 2, $33
		 db 	 2, $0C
		 db 	 2, $F3
		 db 	 2, $E8
		 db 	 4, $EF
		 db 	 2, $50
		 db 	 2, $18
		 db 	 2, $05
		 db 	 44, $F1

;; Sum for R2 : 96
;; Data stream for register 3
sgj_loss_r_3:
		 db 	 10, $00
		 db 	 2, $01
		 db 	 10, $00
		 db 	 2, $01
		 db 	 10, $00
		 db 	 4, $01
		 db 	 8, $00
		 db 	 6, $01
		 db 	 44, $00

;; Sum for R3 : 96
;; Data stream for register 4
sgj_loss_r_4:
		 db 	 2, $BC
		 db 	 2, $A2
		 db 	 2, $93
		 db 	 2, $8A
		 db 	 2, $BC
		 db 	 2, $D0
		 db 	 2, $B2
		 db 	 2, $A1
		 db 	 2, $9A
		 db 	 4, $BC
		 db 	 2, $E6
		 db 	 2, $C5
		 db 	 2, $BA
		 db 	 2, $A6
		 db 	 4, $BC
		 db 	 2, $00
		 db 	 2, $D9
		 db 	 2, $C0
		 db 	 2, $B5
		 db 	 4, $BC
		 db 	 2, $1D
		 db 	 2, $E5
		 db 	 2, $D2
		 db 	 44, $BE

;; Sum for R4 : 96
;; Data stream for register 5
sgj_loss_r_5:
		 db 	 34, $03
		 db 	 2, $04
		 db 	 10, $03
		 db 	 2, $04
		 db 	 48, $03

;; Sum for R5 : 96
;; Data stream for register 6
sgj_loss_r_6:
		 db 	 96, $06

;; Sum for R6 : 96
;; Data stream for register 7
sgj_loss_r_7:
		 db 	 54, $38
		 db 	 42, $3F

;; Sum for R7 : 96
;; Data stream for register 8
sgj_loss_r_8:
		 db 	 2, $08
		 db 	 2, $09
		 db 	 2, $0B
		 db 	 2, $0C
		 db 	 2, $00
		 db 	 2, $07
		 db 	 2, $08
		 db 	 2, $0A
		 db 	 2, $0B
		 db 	 4, $00
		 db 	 2, $06
		 db 	 2, $07
		 db 	 2, $09
		 db 	 2, $0A
		 db 	 4, $00
		 db 	 2, $05
		 db 	 2, $06
		 db 	 2, $08
		 db 	 2, $09
		 db 	 4, $00
		 db 	 2, $03
		 db 	 2, $04
		 db 	 2, $06
		 db 	 2, $07
		 db 	 42, $00

;; Sum for R8 : 96
;; Data stream for register 9
sgj_loss_r_9:
		 db 	 2, $08
		 db 	 2, $09
		 db 	 2, $0B
		 db 	 2, $0C
		 db 	 2, $00
		 db 	 2, $07
		 db 	 2, $08
		 db 	 2, $0A
		 db 	 2, $0B
		 db 	 4, $00
		 db 	 2, $06
		 db 	 2, $07
		 db 	 2, $09
		 db 	 2, $0A
		 db 	 4, $00
		 db 	 2, $05
		 db 	 2, $06
		 db 	 2, $08
		 db 	 2, $09
		 db 	 4, $00
		 db 	 2, $03
		 db 	 2, $04
		 db 	 2, $06
		 db 	 2, $07
		 db 	 42, $00

;; Sum for R9 : 96
;; Data stream for register 10
sgj_loss_r_10:
		 db 	 2, $08
		 db 	 2, $09
		 db 	 2, $0B
		 db 	 2, $0C
		 db 	 2, $00
		 db 	 2, $07
		 db 	 2, $08
		 db 	 2, $0A
		 db 	 2, $0B
		 db 	 4, $00
		 db 	 2, $06
		 db 	 2, $07
		 db 	 2, $09
		 db 	 2, $0A
		 db 	 4, $00
		 db 	 2, $05
		 db 	 2, $06
		 db 	 2, $08
		 db 	 2, $09
		 db 	 4, $00
		 db 	 2, $03
		 db 	 2, $04
		 db 	 2, $06
		 db 	 2, $07
		 db 	 42, $00

;; Sum for R10 : 96


NUM_PCM_SAMPLES		equ	1802
;; PCM conversion from Bleat2k.raw
 
pcm_samples:
	db 4, 6, -1, 5, 4, -2, 2, 5, -5, 0, 6, -7, -3, 11, -4, -14
	db 9, -1, -21, 7, 0, -30, 3, 4, -33, -8, -2, -38, -13, 5, -39, -17
	db 27, -32, -28, 51, -20, -50, 49, 0, -51, 46, 24, -60, 38, 40, -50, 38
	db 57, -48, 21, 67, -37, 22, 77, -35, -4, 71, -27, -11, 66, -26, -33, 55
	db -4, -31, 41, 29, -53, 3, 36, -53, -9, 36, -50, -37, 36, -36, -38, 34
	db -22, -48, 33, 1, -37, 24, 12, -40, 12, 23, -25, 2, 27, -15, -5, 35
	db 4, -9, 11, 26, -18, 9, 27, 1, -6, 2, 17, -18, -3, 14, -7, -4
	db -10, -4, 0, -19, -4, -2, -8, -9, -14, 0, -7, -19, 2, -9, -13, -4
	db -18, -8, -2, -20, -9, 2, -14, -3, -2, -6, 5, 7, -2, 12, 15, 9
	db 17, 13, 19, 19, 14, 17, 19, 14, 11, 7, 15, 7, 5, 14, 10, 4
	db 5, 4, -3, -1, -1, -10, -7, -4, -11, -11, -17, -16, -17, -22, -22, -20
	db -27, -23, -18, -20, -20, -19, -15, -17, -14, -10, -12, -10, -3, -7, -4, 5
	db 4, 6, 8, 12, 15, 15, 19, 22, 21, 23, 26, 22, 24, 27, 22, 24
	db 24, 17, 20, 21, 11, 14, 15, 7, 8, 4, 2, 1, -3, -7, -8, -14
	db -19, -19, -22, -25, -23, -24, -28, -22, -22, -21, -19, -19, -12, -10, -7, 1
	db 4, 8, 9, 10, 15, 13, 12, 16, 14, 11, 15, 14, 10, 18, 3, -3
	db 13, -4, -10, 14, -7, -16, 17, 0, -12, 17, 3, -20, 16, 4, -33, 12
	db -2, -47, 5, -17, -62, 6, -12, -68, 13, 23, -72, 0, 58, -74, -17, 71
	db -54, -18, 87, -37, -36, 89, -20, -30, 100, 4, -42, 93, 21, -35, 93, 36
	db -55, 72, 48, -51, 63, 59, -61, 31, 68, -52, 11, 66, -54, -27, 56, -38
	db -42, 43, -22, -66, 36, 1, -55, 9, 6, -63, -20, 9, -45, -36, 0, -27
	db -44, 13, -1, -21, -24, 29, -12, -32, 39, 6, -13, 10, 27, -13, 12, 32
	db 10, 10, 5, 24, 7, -1, 23, 10, 7, 1, 8, 11, -11, 8, 6, -1
	db 0, -10, 5, -2, -18, 4, -7, -11, -1, -17, -2, 3, -19, 0, 4, -16
	db 3, -4, -9, 11, 6, -6, 21, 17, 3, 20, 16, 11, 24, 25, 10, 31
	db 31, 16, 23, 23, 14, 17, 22, 7, 13, 20, 6, 7, 3, -4, -3, -7
	db -13, -10, -11, -21, -13, -13, -19, -21, -19, -21, -26, -21, -19, -22, -24, -20
	db -19, -22, -17, -14, -17, -10, -4, -7, 2, 11, 9, 14, 16, 19, 20, 21
	db 24, 24, 25, 27, 27, 25, 28, 26, 25, 24, 19, 19, 18, 10, 11, 9
	db 2, -1, -8, -9, -13, -17, -17, -17, -20, -17, -18, -25, -20, -20, -27, -19
	db -16, -26, -15, -9, -17, -8, -10, -14, -5, -4, -11, 4, 4, -3, 14, 17
	db 7, 7, 20, 8, 5, 23, 7, -2, 24, 7, 6, 27, 2, 3, 23, 3
	db -3, 25, -6, -6, 30, -27, -10, 37, -38, -19, 51, -31, -39, 68, -28, -73
	db 67, -6, -79, 58, 10, -95, 49, 18, -88, 53, 36, -89, 46, 54, -69, 65
	db 74, -65, 51, 87, -48, 60, 95, -52, 37, 94, -44, 35, 98, -56, 6, 90
	db -39, -5, 92, -36, -29, 84, -21, -37, 75, -20, -68, 47, -6, -70, 26, 6
	db -82, 17, 20, -64, 2, 13, -71, -21, 16, -50, -39, 8, -34, -46, 18, -9
	db -31, -15, 18, -27, -15, 32, -1, -7, 0, 23, -13, 2, 25, 2, -3, 7
	db 15, -10, 9, 18, 5, 5, 6, 17, -3, 5, 15, 4, 2, -5, 11, 0
	db -11, 12, -1, -4, 1, -13, 1, -1, -15, 3, 5, -4, -1, 6, 3, -5
	db 13, 8, 9, 19, 8, 18, 25, 16, 15, 18, 12, 12, 21, 10, 15, 24
	db 18, 16, 14, 15, 9, 7, 10, 2, 2, 7, 0, 2, -5, -7, -2, -11
	db -13, -6, -17, -20, -6, -16, -16, -12, -18, -17, -13, -17, -16, -6, -11, -7
	db 6, 5, 6, 11, 15, 12, 14, 18, 12, 12, 17, 8, 10, 17, 12, 12
	db 11, 15, 13, 11, 14, 9, 4, 8, 1, -5, 3, -3, -5, -6, -11, -12
	db -12, -15, -16, -14, -17, -16, -10, -11, -6, -9, -15, -5, -11, -17, -6, -8
	db -19, -3, -6, -11, -2, -12, -9, 3, -5, -5, 11, 2, 3, 25, 22, -2
	db 27, 27, -7, 33, 34, -11, 32, 53, -27, 18, 70, -44, 3, 76, -42, -19
	db 79, -44, -59, 70, -38, -67, 62, -38, -82, 69, -21, -67, 68, -26, -78, 69
	db -14, -57, 81, -26, -58, 86, -14, -32, 99, -27, -35, 102, -13, -18, 107, -22
	db -25, 104, -15, -17, 106, -18, -30, 97, -9, -30, 95, -6, -52, 75, -3, -56
	db 66, 3, -76, 44, 16, -68, 25, 17, -78, 7, 17, -68, -9, 11, -70, -24
	db 19, -44, -34, 18, -23, -47, 24, -3, -32, 2, 17, -33, 0, 26, -14, -10
	db 10, 8, -19, 20, 13, -4, 2, 20, 0, 4, 30, 16, 11, 15, 29, 4
	db 13, 26, 11, 7, 6, 17, -1, 0, 12, -2, 1, -9, -6, 5, -12, -3
	db 9, -4, -6, -1, -1, -13, -1, 1, -4, 8, -2, 6, 17, 11, 11, 15
	db 14, 9, 22, 17, 11, 24, 20, 11, 10, 13, 6, 3, 11, 2, 0, 11
	db 2, 4, 2, -6, 1, -3, -13, -4, -6, -22, -6, -6, -17, -8, -8, -15
	db -7, -5, -16, -7, -3, -20, -8, 1, -12, -5, 1, -4, -2, 8, 1, 3
	db 15, 5, 6, 22, 14, 13, 19, 13, 11, 15, 11, 5, 15, 10, 6, 16
	db 16, 11, 12, 13, 9, 7, 10, 2, 2, 4, -3, -5, 4, -7, -25, -6
	db -14, -37, -12, -17, -47, -14, -15, -41, -13, -15, -34, -5, 0, -27, 10, 17
	db -14, 24, 18, -17, 37, 27, -22, 44, 48, -29, 37, 73, -45, 27, 83, -37
	db 14, 85, -43, -8, 91, -33, -9, 74, -46, -31, 79, -34, -18, 66, -59, -34
	db 63, -51, -18, 57, -81, -23, 57, -68, -6, 46, -96, -7, 50, -80, 14, 43
	db -96, 19, 56, -73, 30, 61, -74, 20, 77, -54, 26, 89, -50, 5, 96, -26
	db -5, 92, -18, -27, 84, -5, -29, 73, -8, -48, 59, 3, -52, 34, 10, -69
	db 13, 23, -54, -15, 27, -45, -32, 36, -25, -34, 15, -6, -43, 19, 4, -29
	db 2, 10, -21, 1, 23, -8, 3, 21, 9, 1, 33, 17, 12, 15, 24, 10
	db 9, 23, 13, 17, 5, 17, 22, 2, 19, 28, 12, 9, 13, 14, -7, 3
	db 4, -10, -14, -6, -9, -23, -6, -8, -17, -12, -14, -22, -16, -16, -24, -14
	db -9, -13, -14, -9, -3, -8, -2, 7, 0, 7, 19, 14, 20, 19, 18, 26
	db 21, 18, 26, 23, 16, 30, 27, 22, 29, 21, 19, 22, 15, 7, 12, 3
	db -7, 2, -2, -12, -11, -9, -19, -19, -14, -24, -25, -15, -26, -28, -12, -19
	db -23, -15, -14, -19, -10, -7, -13, -4, 4, -5, 7, 16, 9, 14, 16, 15
	db 15, 17, 14, 14, 16, 15, 16, 21, 20, 26, 18, 12, 25, 15, 4, 16
	db 9, -12, 5, 6, -14, -15, -3, -21, -26, -4, -19, -30, -1, 2, -39, -10
	db 22, -38, -21, 37, -17, -32, 39, 11, -47, 39, 31, -32, 37, 35, -39, 23
	db 58, -21, 35, 48, -37, 26, 50, -27, 36, 39, -42, 29, 36, -24, 45, 18
	db -47, 36, 14, -28, 38, -19, -50, 30, -19, -26, 24, -53, -36, 24, -38, -7
	db 18, -66, -15, 25, -44, 11, 19, -67, 5, 32, -41, 27, 35, -56, 16, 53
	db -32, 29, 51, -51, 16, 64, -33, 18, 61, -48, 0, 69, -24, -9, 62, -13
	db -31, 59, 10, -29, 38, 18, -39, 22, 34, -27, 2, 21, -18, -18, 25, -8
	db -19, 11, 3, -25, 2, 13, -17, -11, 7, -2, -19, 14, 12, -4, -2, 18
	db 7, -8, 23, 19, 4, 11, 24, 10, 2, 22, 14, 2, 11, 17, 4, 6
	db 19, 5, 4, 6, -2, -5, 3, -6, -10, 2, -3, -10, -11, -11, -15, -19
	db -16, -17, -21, -15, -13, -12, -12, -18, -9, -8, -15, -7, 1, -8, -2, 14
	db 6, 11, 19, 15, 16, 24, 20, 15, 24, 22, 9, 18, 22, 10, 14, 15
	db 8, 8, 12, 4, 0, 5, 0, -10, -2, -3, -12, -6, -11, -16, -11, -13
	db -22, -16, -12, -21, -16, -4, -12, -8, 1, -10, -6, 6, -3, -7, 11, 9
	db -6, 14, 24, 8, 13, 22, 14, 9, 23, 16, 1, 12, 19, -5, 6, 18
	db -12, -12, 22, 4, -20, 20, 28, -10, 3, 34, 7, -17, 26, 16, -22, 14
	db 13, -28, -18, 13, -26, -15, 12, -41, -39, 15, -21, -26, 24, -26, -37, 23
	db 7, -7, 39, -4, -20, 33, 15, 14, 43, -7, -5, 44, 14, 25, 42, -14
	db 0, 42, 8, 20, 29, -17, 0, 27, 3, 18, 12, -35, 2, 18, -16, 11
	db 8, -47, -16, 9, -28, -15, -10, -47, -29, -6, -26, -8, -19, -51, -12, 2
	db -35, 7, 12, -49, -15, 37, -14, -17, 42, 4, -25, 31, 45, -11, 18, 42
	db 10, -2, 40, 32, -3, 24, 32, 6, -1, 35, 19, -1, 12, 22, 5, -6
	db 17, 16, -2, -1, 6, 5, -13, -8, 2, -9, -13, -13, -5, -9, -19, -11
	db -5, -12, -16, -13, -3, -6, -10, 5, 9, 1, 10, 12, 6, 13, 21, 16
	db 12, 26, 25, 17, 18, 20, 17, 12, 14, 15, 6, 3, 8, 5, 0, -4
	db -4, -3, -9, -11, -6, -8, -16, -12, -6, -12, -13, -9, -11, -12, -10, -10
	db -14, -13, -9, -11, -15, -8, -4, -9, -7, -1, -1, -4, 3, 9, 5, 4
	db 17, 20, 15, 16, 21, 22, 17, 20, 26, 21, 15, 22, 24, 13, 10, 20
	db 14, 5, 9, 8, 0, -3, 1, -5, -15, -11, -6, -17, -24, -10, -8, -19
	db -18, -11, -13, -22, -17, -7, -13, -19, -7, 4, -8, -3, 15, 6, -1, 18
	db 26, 9, 7, 36, 34, 11, 18, 32, 23, 6, 16, 27, 7, 1, 19, 8
	db -6, -4, 9, -7, -7, 5, -12, -25, -14, -6, -14, 3, -14, -42, -23, 1
	db -12, 5, -5, -42, -17, 9, -2, 9, 1, -34, -8, 18, 13, 20, 8, -18
	db 8, 30, 23, 31, 18, -7, 15, 37, 31, 33, 16, -7, 16, 35, 28, 26
	db 11, -8, 9, 22, 13, 13, -1, -19, -6, 11, 6, 4, -11, -25, -10, 7
	db -1, -6, -19, -29, -20, -8, -15, -19, -23, -31, -23, -9, -5, -11, -4, -6
	db -5, 3, 11, 12, 13, 15, 13, 16, 23, 12

	
