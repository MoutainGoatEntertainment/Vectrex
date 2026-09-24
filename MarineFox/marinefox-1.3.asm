;***************************************************************************
; DEFINE SECTION
;***************************************************************************
                include "VECTREX.I"
				

RESET0REF_MACRO 	macro

		ldd   #$00CC
		stb   <$D00C
		sta   <$D00A
		ldd   #$0302
		clr   <$D001  
		sta   <$D000   
		stb   <$D000   
		stb   <$D000   
		ldb   #$01
		stb   <$D000   
		endm
		

MOVETOD_MACRO		macro
		local	movetod_loop
		sta		<$D001
		clr		<$D000
		lda		#$CE
		sta		<$D00C
		clr		<$D00A
		inc		<$D000 
		stb		<$D001 
		clr		<$D005 
		ldb  #$40
movetod_loop:   	
		bitb <$D00D
		beq  movetod_loop
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
ANIM_DELAY			equ		5
BUBBLE_MAX_SIZE	equ		3
STAR_SIZE_MIN		equ		16
STAR_SIZE_MAX		equ		74
STAR_NUM_ROWS		equ		7
X_ANCHOR			equ		-88
Y_ANCHOR			equ		-100

DELTA_COORD		equ		25

SCREEN_LEVEL		equ		0
SCREEN_PLAY		equ		1
SCREEN_GAMEOVER	equ		2


POWERUP_NO_COLL	equ		1
POWERUP_SPEED		equ		2
POWERUP_ROW		equ		3
POWERUP_SLOW		equ		4
POWERUP_BONUS		equ		5

POWERUP_NO_COLL_T	equ		100
POWERUP_SPEED_T	equ		100
POWERUP_ROW_T		equ		20
POWERUP_SLOW_T	equ		100
POWERUP_BONUS_T	equ		20

;***************************************************************************
; RAM variables
;***************************************************************************
seed		equ	$C880	
animDelay	equ	$C881	

;;; 1 bit per shark
sharkOn	equ	$C882
;;; 1 bit per shark - 0 up, 1 down
sharkDir	equ	$C883

;;; Array for 8 sharks $C884 - C88B
sharkYs	equ	$C884
animFrame	equ	$C88C

;;; Bubbles - only 3 at a time 
bubbleYs	equ	$C88D	; $C88D - C88F
bubbleXs	equ	$C890	; $C890 - C892
bubbleSizes	equ	$C893	; $C893 - C895

;;; Star size
starSize	equ	$C896
;;; Array of stars for rows (9 - STAR_NUM_ROWS)
starArray	equ	$C897   ; $C897 - C89F
;;; Which half of stars to draw this time
starSelector	equ	$C8A0   ; This is a word!

;;; Current game level
gameLevel	equ	$C8A2

;;; Medusa rotation stuff
rotAngle		equ	$C8A3
rotatedMedusa	equ	$C8A4	; 24 bytes to C8C8
medusaX		equ	$C8CA	; 2 bytes
medusaY		equ	$C8CC	; 2 bytes

;;; Remaining life counter
lives		equ	$C8CE
;;; Which screen - game or level to display
screen		equ	$C8CF

;;; Score
score		equ	$C8D0	; 7 bytes

;;; Printing of the level - 3 bytes
levelStr	equ	$C8D8   ; C8DA will have a $80

;; Shark speed
sharkSpeed	equ	$C8DB
;; Max count of sharks on screen
sharkMax	equ	$C8DC

;; Current bonus scale
bonusScale	equ	$C8DD  ; Two bytes
	
;; Are we going yet?
medMoving	equ	$C8DF

;; Music that is playing
musicLoc	equ	$C8E0	;; 2 bytes!

;; String to print the lives 3 bytes!
livesStr	equ	$C8E2

powerupGive		equ	$C8E5
powerup			equ	$C8E6
powerupTime		equ	$C8E7
powerupGiveTime	equ	$C8E8
powerupX			equ	$C8E9
powerupY			equ	$C8EA

;;; Local loop and temp variables
loopI		equ	$C900
tempB1		equ	$C901
tempB2		equ	$C902
tempB3		equ	$C903
tempW1		equ	$C904
tempW2		equ	$C906
tempW3		equ	$C908


;***************************************************************************
; start of Vectrex memory with cartridge name...
	org     0				
;***************************************************************************
; HEADER SECTION
;***************************************************************************
        db      "g GCE MGE ", $80   	; 'g' is copyright sign
        dw      music7            		; music from the rom
        db      $F8, $50, $20, -$45 	; height, width, rel y, rel x
										; (from 0,0)
        db      "MARINE FOX",$80   	; some game information,
										; ending with $80
		db		$F8, $50, $0, -$45
		db		"V1.3", $80
        db      0                   	; end of game header
;***************************************************************************
; CODE SECTION
;***************************************************************************

; here the cartridge program starts off
	;; Switch to a smaller font, the original height/width are $F8, $50
	lda		#$FB
	sta		$C82A
	lda		#$30
	sta		$C82B
	
	jsr		Splash
	
setup:
;	jsr	DP_to_C8
		
	lda		#0
	sta		tempB1
	sta		tempB2
	sta		tempB3
			
	ldx		#0
	sta		tempW1
	sta		tempW2
	sta		tempW3
				
	lda		#5
	sta		lives
	
	lda		#SCREEN_LEVEL
	sta		screen
	lda		#$80
	sta		levelStr + 1
	
	ldx		#0
	stx		starSelector
				
	lda		#0
	sta		rotAngle
	sta		medusaY
	sta		medusaX
	sta		animFrame
		
	lda		#0
	sta		medMoving
	
	lda		#0
	sta		powerupGive

	lda		#0
	sta		powerup
	sta		powerupTime
	sta		powerupGiveTime
		
	lda		#$00
	sta		sharkOn

;	lda		#$55
;	sta		sharkDir
		
;	lda		#3
;	sta		sharkSpeed
	
;	lda		#4
;	sta		sharkMax
	
	lda		#STAR_SIZE_MIN
	sta		starSize

	ldx		#score
	jsr		Clear_Score 
	
	ldx		#score
	lda		#0
	jsr		Add_Score_a
	
	;; No music initially
	ldd		#silence
	std		musicLoc	
	jsr		Clear_Sound
	
	
	lda		#1
	sta		$C81F	; joystick 1 Y - enable with 1
								; 
;	$C820 joystick 1 Y - enable with 3
;	$C821 joystick 2 X - enable with 5
;	$C822 joystick 2 Y - enable with 7

	lda		#0
	sta		gameLevel
	jsr		Load_level

	lda		#17
	sta		seed

	lda		#8
	sta		loopI
			
	ldy		#sharkYs
	lda		#$20
				
				
setup_more_sharks:				
	sta		, y+
	
	dec		loopI
	bne		setup_more_sharks
								
				
	lda		#ANIM_DELAY
	sta		animDelay				

	
main:
    ldu     musicLoc               ; Play whatever is set up
    jsr     DP_to_C8                ; DP to RAM
    jsr     Init_Music_chk          ; and init new notes

	jsr     Wait_Recal              ; Wait for new frame
	ldd		#0
	MOVETOD_MACRO
	
    jsr     Do_Sound	
	
;    lda     #40	                    ; scaling factor 
;	sta		VIA_t1_cnt_lo           ; move to time 1 lo, this
                                    ; means scaling
			
;	jsr     Intensity_1F            ; Sets the intensity of the
                                        ; vector beam
	
	
	lda		screen
	cmpa		#SCREEN_LEVEL	
	bne		go_screen_check
	
	ldd		#level_music
	std		musicLoc
	lda     #1 
    sta     Vec_Music_Flag
	jsr		Level_screen
	
	bra		continue
	
go_screen_check:
	lda		screen
	cmpa		#SCREEN_GAMEOVER	
	bne		game_screen

	ldd		#gameover_music
	std		musicLoc
	lda     #1 
    sta     Vec_Music_Flag
	jsr		Gameover_screen
	
	; Start from the top
	bra		setup
	
game_screen:
	jsr		Game_level
	
continue:
    bra     main                    ; and repeat forever
				

;***************************************************************************
; Subroutines
;***************************************************************************
	include "debug.i"
				
				
Level_screen:	
	jsr     Wait_Recal  
	
    lda     #80	                    ; scaling factor 
	sta		VIA_t1_cnt_lo           ; move to time 1 lo, this
	
	jsr     Intensity_5F 
	
	lda		#SCREEN_PLAY
	sta		screen
	
	ldd		#$8000
	std		bonusScale
	
	
	;;	Print the game level string
	lda		gameLevel
	sta		tempB1
	
	cmpa		#20
	blt		twenty
	
	; Twenty-something
	lda		tempB1
	suba		#20
	sta		tempB1
	
	lda		#$32
	sta		levelStr
	
	bra		less_than_ten
	
twenty:
	; Teen-something
	cmpa		#10
	blt		ten
	
	lda		tempB1
	suba		#20
	sta		tempB1

	lda		#$31
	sta		levelStr

	bra		less_than_ten
	
ten:
	; Less than ten - set the high digit to '0'
	lda		#$30
	sta		levelStr

less_than_ten:
	lda		tempB1
	adda		#$31
	sta		levelStr + 1
	lda		#$80
	sta		levelStr + 2

	lda		#127
	sta		tempB1

	lda		#80
	sta		tempB2

level_wait_loop:	
	
	;; Do some logic with the counter to emulate winking
	lda		#0
	ldb		tempB1
	cmpb		#25
	bgt		wait_may_wink
	bra		wait_draw
wait_may_wink
	cmpb		#30
	bgt		wait_draw
	lda		#1
	
wait_draw:
	jsr		Draw_Fox
	
    ldu     musicLoc               ; Play whatever is set up
    jsr     DP_to_C8                ; DP to RAM
    jsr     Init_Music_chk          ; and init new notes

	jsr     Wait_Recal              ; Wait for new frame
	
    jsr     Do_Sound	
	
	lda     #140          
    sta     VIA_t1_cnt_lo
	
	lda		#-20
	ldb		#-50
	ldu		#level_string	
	jsr		Print_Str_d
	
	lda		#-20
	ldb		#20
	ldu		#levelStr	
	jsr		Print_Str_d

	lda		#-40
	ldb		#-50
	ldu		#lives_string	
	jsr		Print_Str_d
	
	lda		#$20
	sta		livesStr
	lda		lives
	adda		#$30
	sta		livesStr + 1
	lda		#$80
	sta		livesStr + 2
	
	lda		#-40
	ldb		#20
	ldu		#livesStr	
	jsr		Print_Str_d


	dec		tempB1
	bne		level_wait_loop	
	
	;; Let the vector unit "zone in" so put the medusa up for a short while
	lda		#0
	sta		rotAngle
	
	jsr		Rotate_medusa

	rts


Draw_Fox
	;; a has a non-zero value if we are to wink
	sta		tempB2
	
	RESET0REF_MACRO

	jsr     Intensity_5F 

	lda		#30
	ldb		#0
	MOVETOD_MACRO

	lda     #60          
    sta     VIA_t1_cnt_lo

	ldx		#fox_1_vector_list
	lda		#FOX_1_LIST_LEN - 1
	jsr		Draw_VL_a
	
	RESET0REF_MACRO
	
	lda		#70
	ldb		#-18
	MOVETOD_MACRO

	lda		tempB2
	bne		fox_wink
	
	ldx		#fox_2_vector_list
	lda		#FOX_2_LIST_LEN - 1
	bra		fox_draw_eye
	
fox_wink:
	ldx		#fox_2b_vector_list
	lda		#FOX_2B_LIST_LEN - 1
	
fox_draw_eye	
	jsr		Draw_VL_a

	lda		#2
	ldb		#40
	MOVETOD_MACRO

	ldx		#fox_3_vector_list
	lda		#FOX_3_LIST_LEN - 1
	jsr		Draw_VL_a
	
	RESET0REF_MACRO
	
	lda		#95
	ldb		#-38
	MOVETOD_MACRO

	ldx		#fox_4_vector_list
	lda		#FOX_4_LIST_LEN - 1
	jsr		Draw_VL_a
	
	lda		#-65
	ldb		#-53
	MOVETOD_MACRO

	ldx		#fox_5_vector_list
	lda		#FOX_5_LIST_LEN - 1
	jsr		Draw_VL_a
	
	lda		#26
	ldb		#-53
	MOVETOD_MACRO

	ldx		#fox_6_vector_list
	lda		#FOX_6_LIST_LEN - 1
	jsr		Draw_VL_a
	
	lda		#-13
	ldb		#-35
	jsr		Dot_d
	
	lda		#0
	ldb		#-8
	jsr		Dot_d

	RESET0REF_MACRO
	
	lda		#-24
	ldb		#-84
	MOVETOD_MACRO

	ldx		#fox_7_vector_list
	lda		#FOX_7_LIST_LEN - 1
	jsr		Draw_VL_a
	
	RESET0REF_MACRO
	
	lda		#90
	ldb		#0
	MOVETOD_MACRO

	jsr     Intensity_7F 
	
	ldx		#fox_logo_1_vector_list
	lda		#FOX_LOGO_1_LIST_LEN - 1
	jsr		Draw_VL_a
	
	lda		#15
	ldb		#-5
	MOVETOD_MACRO
	
	ldx		#fox_logo_2_vector_list
	lda		#FOX_LOGO_2_LIST_LEN - 1
	jsr		Draw_VL_a
	
	lda		#0
	ldb		#8
	MOVETOD_MACRO
	
	ldx		#fox_logo_3_vector_list
	lda		#FOX_LOGO_3_LIST_LEN - 1
	jsr		Draw_VL_a
	
	rts

Gameover_screen:	
	jsr     Wait_Recal  
	
    lda     #80	                    ; scaling factor 
	sta		VIA_t1_cnt_lo           ; move to time 1 lo, this
	
	jsr     Intensity_5F 
	
	lda		#SCREEN_PLAY
	sta		screen


gameover_wait_loop:	
		
	lda		#0
	jsr		Draw_Fox

	RESET0REF_MACRO
	
	lda		#-90
	ldb		#0
	MOVETOD_MACRO

	lda		#-90
	ldb		#0
	MOVETOD_MACRO

	jsr     Intensity_7F 
	
	ldx		#fox_logo_1_vector_list
	lda		#FOX_LOGO_1_LIST_LEN - 1
	jsr		Draw_VL_a
	
	lda		#15
	ldb		#-5
	MOVETOD_MACRO
	
	ldx		#fox_logo_2_vector_list
	lda		#FOX_LOGO_2_LIST_LEN - 1
	jsr		Draw_VL_a
	
	lda		#0
	ldb		#8
	MOVETOD_MACRO
	
	ldx		#fox_logo_3_vector_list
	lda		#FOX_LOGO_3_LIST_LEN - 1
	jsr		Draw_VL_a
		
    ldu     musicLoc               ; Play whatever is set up
    jsr     DP_to_C8                ; DP to RAM
    jsr     Init_Music_chk          ; and init new notes

	jsr     Wait_Recal              ; Wait for new frame
	
    jsr     Do_Sound	
		
	lda     #140          
    sta     VIA_t1_cnt_lo
	
	lda		#-20
	ldb		#-35
	ldu		#gameover_string	
	jsr		Print_Str_d
	
	lda		#-50
	ldb		#-35
	ldu		#score
	jsr		Print_Str_d

	
	jsr		Read_Btns_Mask
	lda		$C812
	cmpa		#1
	bne		gameover_wait_loop

	rts


Paused:
	jsr		Clear_Sound

paused_loop:
	jsr     Wait_Recal              ; Wait for new frame

	lda		#20
	ldb		#-30
	ldu		#paused_string	
	jsr		Print_Str_d

	jsr		Draw_medusa
	jsr		Draw_sharks

	jsr		Display_lives_and_score


	lda		#$0C
	jsr		Read_Btns_Mask
	lda		$C815
	cmpa		#8
	bne		paused_loop
	
	rts
	
	
Game_level:

	; Check the joystick
	jsr		Joy_Digital
	lda		$C81B
	lbeq		no_move
	lbmi		move_left

move_right:
	RAND_MACRO
	dec		rotAngle
	
	lda		#1
	sta		medMoving
	
	bra		no_move
			
move_left:				
	inc		rotAngle

	lda		#1
	sta		medMoving

	
no_move:
				
	; Check the buttons
	; We want to disable the differential check on Buttons 1 and 2
	; So we use 1100 for the mask
	lda		#$0C
	jsr		Read_Btns_Mask
	lda		$C812
	cmpa		#1
	bne		no_b1

	inc		rotAngle
	lda		#1
	sta		medMoving
	
no_b1:	

	lda		$C813
	cmpa		#2
	bne		no_b2

	RAND_MACRO

	dec		rotAngle
	lda		#1
	sta		medMoving

no_b2:
	lda		$C814
	cmpa		#4
	bne		no_b3

	
;	RAND_MACRO
;	anda		#$0F
;	ldx		#powerup_probabilities	
;	ldb		a, x
;	stb		powerup
	
;	ldx		#powerup_times
;	ldb		a, x
;	stb		powerupTime

;	lda		powerup
;	cmpa		#POWERUP_BONUS
;	bne		no_bonus_pup
	
;	ldd		#$8000
;	std		bonusScale
no_bonus_pup:	
	

no_b3:
	lda		$C815
	cmpa		#8
	bne		no_b4

	jsr		Paused

no_b4:	

;	lda	$C813
;	cmpa	#2
;	bne	no_b2

	lda		rotAngle
	anda		#63
	sta		rotAngle

	lda		medMoving
	cmpa		#1
	blt		buttons_done
	
	
already_moving:	
	; Button 2 - MOVING
	; Get the run and rise for our speed

	;;;;;;;;;;;;;;
	DP2C8
	lda		#120
	ldb		rotAngle
	jsr		Rise_Run_Y
	sta		tempB1
	stb		tempB2
	
	;; Store the incrementor as a 16 bit number
	ldb		tempB2
	sex
	std		tempW1
	
	;; Add the incrementor to the position
	ldd		medusaX
	addd		tempW1
	addd		tempW1
	addd		tempW1
	addd		tempW1
	std		medusaX
	
	lda		powerup
	cmpa		#POWERUP_SPEED
	bne		no_pu_speed
	
	ldd		medusaX
	addd		tempW1
	addd		tempW1
	std		medusaX
	
no_pu_speed:

	;; Same with the other coordinate
	ldb		tempB1
	sex
	std		tempW1
	
	;; Add the incrementor to the position
	ldd		medusaY
	addd		tempW1
	addd		tempW1
	addd		tempW1
	addd		tempW1
	std		medusaY

	lda		powerup
	cmpa		#POWERUP_SPEED
	bne		medusa_move_done

	ldd		medusaY
	addd		tempW1
	addd		tempW1
	std		medusaY
	
medusa_move_done:
	DP2D0


buttons_done:
	lda		animDelay
	deca
	sta		animDelay
	bne		no_anim
	
	lda		powerupGiveTime
	beq		pup_give_zero
	dec		powerupGiveTime
	
pup_give_zero:
	
	lda		powerup
	cmpa		#0
	beq		no_powerup
	
	dec		powerupTime
	bne		no_powerup
	
	;; Here we have to check the Row clear type powerup
	lda		powerup
	cmpa		#POWERUP_ROW
	bne		not_row_powerup
	
	;; Clear that row
	ldb		medusaY
	addb		#-8
	ldx		#star_collison
	lda		b, x
	blt		not_row_powerup
		
	;; Clear stars at index a
	ldx		#starArray
	ldb		#0
	stb		a, x
	
not_row_powerup:

	clr		powerup
	
no_powerup:
	;; Check if we have to grant powerup
	lda		powerupGiveTime
	bne		already_powered_up
	
	lda		powerupGive
	beq		already_powered_up
	
	lda		powerupTime
	bne		already_powered_up
	
	RAND_MACRO
	cmpa		#23
	bne		already_powered_up
	jsr		Give_powerup
	
already_powered_up:

				
	lda		animFrame
	inca
	inca
	cmpa		#SHARK_FRAME_COUNT * 2 - 1
	ble		more_frames
				
	lda		#0
more_frames:
	sta		animFrame
				
	; Reset animDelay
	lda 	#ANIM_DELAY
	sta	animDelay

no_anim:			
;	inc	sharkYs
;	inc	sharkYs + 3
;	inc	sharkYs + 3
;				
;	dec	sharkYs + 5
				
	
	jsr	Rotate_medusa
	jsr	Draw_medusa

;	lda		powerupGive
;	jsr		Debug_A
	
	jsr	Update_sharks
	
	jsr	Update_and_draw_bonus_bar
	
	jsr	Draw_sharks
	jsr	Draw_stars

	jsr	Update_and_draw_powerup
	
	jsr	Display_lives_and_score

	jsr	Check_star_collision
	jsr	Check_level_complete
	
	rts
	
Give_powerup:
	lda		powerupGive
	beq		give_powerup_done

	lda		#100
	sta		powerupGiveTime
	
	RAND_MACRO
	anda		#$E0
	lsra
	sta		powerupX

	RAND_MACRO
	anda		#$E0
	lsra
	sta		powerupY

	dec		powerupGive
	
give_powerup_done:
	rts

Update_and_draw_powerup:
	lda		powerupGiveTime
	lbeq		powerup_update_done
		
	RESET0REF_MACRO
	
	lda		#$80
	sta     VIA_t1_cnt_lo

	lda		powerupY
	ldb		powerupX
	MOVETOD_MACRO

	lda		#32
	sta     VIA_t1_cnt_lo

	ldx		#fox_logo_1_vector_list
	lda		#FOX_LOGO_1_LIST_LEN - 1
	jsr		Draw_VL_a
	
	lda		#15
	ldb		#-5
	MOVETOD_MACRO
	
	ldx		#fox_logo_2_vector_list
	lda		#FOX_LOGO_2_LIST_LEN - 1
	jsr		Draw_VL_a
	
	lda		#0
	ldb		#8
	MOVETOD_MACRO
	
	ldx		#fox_logo_3_vector_list
	lda		#FOX_LOGO_3_LIST_LEN - 1
	jsr		Draw_VL_a
	
powerup_draw_done:
	;; Check if the Medusa is colliding with it
	lda		medusaX
	anda		#$F0
	cmpa		powerupX
	bne		powerup_update_done

	lda		medusaY
	anda		#$F0
	cmpa		powerupY
	bne		powerup_update_done

	
	;; Powerup is picked up
	
	; Play the powerup music
	ldd		#powerup_music
	std		musicLoc
	lda     #1 
    sta     Vec_Music_Flag 

	clr		powerupGiveTime
	
	RAND_MACRO
	anda		#$0F
	ldx		#powerup_probabilities	
	ldb		a, x
	stb		powerup
	
	ldx		#powerup_times
	ldb		a, x
	stb		powerupTime

	lda		powerup
	cmpa		#POWERUP_BONUS
	bne		powerup_update_done
	
	ldd		#$8000
	std		bonusScale	
	
powerup_update_done:
	rts
	
Check_level_complete:
	;; The basic idea is that if *any* of the star bytes non-zero, level is NOT complete
	;; Routine will set screen to SCREEN_LEVEL if complete and increment gameLevel
	
	lda		#7
	sta		tempB1
	
check_level_loop:
	; Retrieve the right index of the star RAM array
	lda		tempB1
	ldx		#starArray
	ldb		a, x
	andb		#$FF

	lbne		level_not_complete

	lda		tempB1
	deca
	sta		tempB1
	
	bge		check_level_loop		
	
	;; Level complete!
	
	;; Play some music while adding up the bonus
	ldd		#add_bonus_music
	std		musicLoc
	lda     #1 
    sta     Vec_Music_Flag

	;; Add the bonus
	ldb		#8
	stb		tempB2
	
	lda		bonusScale
	sta		tempB1
	
	;; Only do this fancy stuff if there was in fact some bonus left
	ble		no_bonus_left
	
	;; Divide by 8 and store - so we can subtract later
	lsra
	lsra
	lsra
	sta		tempB3
	
add_bonus_loop
	ldx		#score
	lda		tempB1
	jsr		Add_Score_a

	lda		bonusScale
	suba		tempB3
	blt		dont_save_scale
	
	sta		bonusScale

dont_save_scale:	
	lda		#10
	sta		loopI

add_bonus_inner_loop	
    ldu     musicLoc               ; Play whatever is set up
    jsr     DP_to_C8                ; DP to RAM
    jsr     Init_Music_chk          ; and init new notes

	jsr     Wait_Recal              ; Wait for new frame
	
    jsr     Do_Sound	

	jsr		Draw_medusa
	
	jsr		Update_and_draw_bonus_bar
	
	jsr		Display_lives_and_score
	
	dec		loopI
	bne		add_bonus_inner_loop
	
	dec		tempB2
	bne		add_bonus_loop
	
no_bonus_left:
	; Play the level music
	ldd		#level_music
	std		musicLoc
	lda     #1 
    sta     Vec_Music_Flag 

	;; Up the game level
	inc	gameLevel
	lda	gameLevel
	anda	#$F
	sta	gameLevel
				
	jsr	Load_level
	;; Check if the game is complete
		
	lda		#SCREEN_LEVEL
	sta		screen
	
level_not_complete:
	
	rts

	
Update_sharks:
	;; Count how many sharks we have in tempB1
	lda		#0
	sta		tempB1
	
	;; Loop
	lda		#7
	sta		loopI
	
shark_update_loop:
	ldx		#bit_positions
	ldb		loopI
	lda		b, x
	
	anda		sharkOn
	lbeq		no_shark_here
	
	;; Increment the shark counter
	inc		tempB1
	
	
	;; Move the shark
	;; Which way?
	ldx		#bit_positions
	ldb		loopI
	lda		b, x

	anda		sharkDir	
	bne		shark_up
	
shark_down:
	;; See if this shark just ate us or not
	;; Only if we don't have the powerup!
	lda		powerup
	cmpa		#POWERUP_NO_COLL
	beq		no_shark_food_down
	
	ldb		medusaX
	negb							; Sharks are the other way - right to left
	ldx		#shark_collison
	lda		b, x
	
	;; Are we on the same column?
	cmpa		loopI
	bne		no_shark_food_down
	
	;; Are we in the shark Y range?
	ldy		#sharkYs
	ldb		loopI
	lda		b, y

	cmpa		medusaY
	bgt		no_shark_food_down
	
	adda		#30
	cmpa		medusaY
	blt		no_shark_food_down
	
	;; EATEN!!!
	jsr		Eaten
	
no_shark_food_down:

	;; Normal speed or slow sharks?
	lda		powerup
	cmpa		#POWERUP_SLOW
	beq		slow_shark_down
	
	lda		sharkSpeed
	sta		tempB2
	bra		shark_down_speed_ok
	
slow_shark_down:	
	lda		#1
	sta		tempB2
	
shark_down_speed_ok:
	ldy		#sharkYs
	ldb		loopI
	lda		b, y
	suba		tempB2
	sta		b, y

	; Deactivate the shark once it reaches the bottom
	cmpa		#$90
	bgt		shark_down_ok
	
	ldx		#bit_masks
	ldb		loopI
	lda		b, x

	anda		sharkOn
	sta		sharkOn
	lbra		shark_stuff_done
	
shark_down_ok:

	lbra		shark_stuff_done
	
shark_up:
	;; See if this shark just ate us or not
	;; Only if we don't have the powerup!
	lda		powerup
	cmpa		#POWERUP_NO_COLL
	beq		no_shark_food_up

	ldb		medusaX
	negb							; Sharks are the other way - right to left
	ldx		#shark_collison
	lda		b, x
	
	;; Are we on the same column?
	cmpa		loopI
	bne		no_shark_food_up
	
	;; Are we in the shark Y range?
	ldy		#sharkYs
	ldb		loopI
	lda		b, y

	cmpa		medusaY
	blt		no_shark_food_up
	
	suba		#30
	cmpa		medusaY
	bgt		no_shark_food_up
	
	;; EATEN!!!
	jsr		Eaten
	
no_shark_food_up:
	;; Normal speed or slow sharks?
	lda		powerup
	cmpa		#POWERUP_SLOW
	beq		slow_shark_up
	
	lda		sharkSpeed
	sta		tempB2
	bra		shark_up_speed_ok
	
slow_shark_up:	
	lda		#1
	sta		tempB2
	
shark_up_speed_ok:
	ldy		#sharkYs
	ldb		loopI
	lda		b, y
	adda		tempB2
	sta		b, y

	; Deactivate the shark once it reaches the top
	cmpa		#$70
	blt		shark_up_ok
	
	ldx		#bit_masks
	ldb		loopI
	lda		b, x

	anda		sharkOn
	sta		sharkOn
	bra		shark_stuff_done

shark_up_ok:
	bra		shark_stuff_done	
	
no_shark_here:
	;; loopI points to an empty shark slot, save it
	lda		loopI
	sta		tempB2

shark_stuff_done:
	lda		loopI
	deca
	sta		loopI
	bge		shark_update_loop
		
	; We add one shark if we don't have enough
	lda		tempB1
	cmpa		sharkMax
	bge		no_more_sharks
		
	; Add a shark at a random location - save the expensive random number
	RAND_MACRO
	sta		tempB2

;	cmpa		#120
	cmpa		#110
	blt		no_more_sharks
	
	anda		#$7
	
	ldx		#bit_positions
	lda		a, x
	
	; See if there is already a shark there
	anda		sharkOn
	bne		no_more_sharks

	; Add a shark there	
	; Save back only the lower 4 bits for the shark X position
	ldb		tempB2
	lda		tempB2
	
	anda		#$7
	sta		tempB2
	
	; Pick a random direction from a bit in the random
	andb		#$08
	beq		add_down_shark

	ldy		#sharkYs
	ldb		tempB2
	lda		#$A0
	sta		b, y
	
	; Flip the direction bit to 1 - UP
	ldx		#bit_positions
	lda		b, x
	ora		sharkDir
	sta		sharkDir
	
	bra		enable_new_shark
	
add_down_shark:
	ldy		#sharkYs
	ldb		tempB2
	lda		#$60
	sta		b, y
	
	; Flip the direction bit to 0 - DOWN 
	ldx		#bit_masks
	lda		b, x
	anda		sharkDir
	sta		sharkDir

	
enable_new_shark:	
	;; Enable the shark
	;; We saved an empty location in tempB2
	ldy		#bit_positions
	ldb		tempB2
	lda		b, y
	
	ora		sharkOn
	sta		sharkOn
	
no_more_sharks:
	
	rts
	

Eaten:
	; No more powerups
	lda		#0
	sta		powerup
	sta		powerupTime
	
	; Play the sink sound
	ldd		#sink
	std		musicLoc
	lda     #1 
    sta     Vec_Music_Flag 
	
	; Wait a bit to show the graphics
	lda		#0
	sta		tempB1
eaten_loop:
    ldu     musicLoc               ; Play whatever is set up
    jsr     DP_to_C8                ; DP to RAM
    jsr     Init_Music_chk          ; and init new notes

	jsr     Wait_Recal              ; Wait for new frame
	
    jsr     Do_Sound	

	jsr		Display_lives_and_score
	jsr		Draw_sharks
	jsr		Draw_medusa
	; Display collision graphics
	lda		tempB1
	sta     VIA_t1_cnt_lo
	ldd		#0
	MOVETOD_MACRO
	ldx		#explosion_vector_list
	lda		#EXPLOSION_LIST_LEN - 1
	jsr		Draw_VL_a

	RESET0REF_MACRO
	lda		#100
	ldb		#-50
	ldu		#lives_string	
	jsr		Print_Str_d
	
	lda		#$20
	sta		livesStr
	lda		lives
	adda		#$2F
	sta		livesStr + 1
	lda		#$80
	sta		livesStr + 2
	
	lda		#100
	ldb		#20
	ldu		#livesStr	
	jsr		Print_Str_d

	
	lda		tempB1
	inca
	sta		tempB1
	bgt		eaten_loop
	
	; Turn sharks off
	lda		#0
	sta		sharkOn
	; Reset ship
	sta		medusaX
	sta		medusaY
	sta		rotAngle
	sta		medMoving

	;; Check for game over
	; Decrement life
	dec		lives
	bgt		still_alive
	
	lda		#SCREEN_GAMEOVER
	sta		screen

still_alive:


	rts
	
Update_and_draw_bonus_bar:
	lda		#0
	cmpa		bonusScale	
	beq		no_bonus

	RESET0REF_MACRO
	
	lda		#-113
	ldb		#-110	
	MOVETOD_MACRO
	
	lda     bonusScale             
	sta     VIA_t1_cnt_lo
	
	ldx		#bonus_vector
	lda		#0
	jsr		Draw_VL_a
	ldx		#bonus_vector
	lda		#0
	jsr		Draw_VL_a
	

	lda		bonusScale + 1
	suba		#5
	sta		bonusScale + 1
	ble		bonus_dec
	
	dec		bonusScale
	clr		bonusScale + 1
	bra		no_bonus
	
bonus_dec

no_bonus
	rts
bonus_vector
	db 0, 80
	
Display_lives_and_score:
;;; Byte 'h' (104) is the ship character and 'i' (105) is the person one
;;; Please see Zachary Whalen's work on video game typography at
;;; http://etd.fcla.edu/UF/UFE0022526/whalen_z.pdf
	RESET0REF_MACRO
	
;	ldb	lives
;	lda	#'i'
;	ldx	#$7040

;	jsr	Print_Ships
	
	lda		#$70
	ldb		#-100
	ldu		#score

	jsr		Print_Str_d
	
	lda     #16             
	sta     VIA_t1_cnt_lo

	RESET0REF_MACRO

	lda     #$80             
	sta     VIA_t1_cnt_lo

	ldd		#$7000
	MOVETOD_MACRO
	
	lda     #16             
	sta     VIA_t1_cnt_lo

	ldx		#pup_vectors
	lda		powerup
	asla
	ldx		a, x
	jsr		Draw_VL_mode

	rts
	
		
Check_star_collision:
	; Recompute the medusa coordinates into an 8x8 grid
				
	; Look up the coordinates in our finely crafted collision lookup table
	ldb	medusaX
	ldx	#star_collison
	lda	b, x
	blt	no_collision
				
	; This is the bit position, get the actual bit value
	anda	#7 		; Just to be safe
	ldx	#bit_positions
	lda	a, x
	sta	tempB1	; Save it
	
	; The Y coordinate needs a bit adjustment
	ldb	medusaY
	addb	#-8
	ldx	#star_collison
	lda	b, x
	blt	no_collision
	
	; Save the index
	sta	tempB3
	
	; Retrieve the right index of the star RAM array
	ldx	#starArray
	lda	a, x
	
	; Save this too
	sta	tempB2
	
	; Is there still a star there?
	anda	tempB1
	beq	no_collision

	; All good, we have caught a star, remove it from the map
	lda	tempB2
	eora	tempB1
	
	; Write it back
	ldb	tempB3; Index was saved here
	ldx	#starArray
	sta	b, x
	
	; Update score
	lda #100
	ldx	#score
	jsr	Add_Score_a

	; Play the beep
	ldd		#beep
	std		musicLoc
	lda     #1 
    sta     Vec_Music_Flag  
	
	
	
no_collision:
	rts

	
Rotate_medusa:
	lda		animFrame
	ldy		#medusa_anim_frames
	ldx		a,y	

	lda     rotAngle

	ldb    	#MEDUSA_LIST_LEN - 1	
	ldu     #rotatedMedusa			; Save to 
	jsr     Rot_VL_ab            	; Rotates the coordinates	
	rts
	
Draw_medusa:

	RESET0REF_MACRO

	lda     #128              
	sta     VIA_t1_cnt_lo	

	; Same as shark positions -90 + (i * 25)
	; Because the row loop will adjust it, we star on the -1st row
	lda	medusaY
	ldb	medusaX
	MOVETOD_MACRO

 	jsr     Intensity_7F 
	
	lda     #100              
    sta     VIA_t1_cnt_lo	

	
;	lda	animFrame
;	ldy	#medusa_anim_frames
;	ldx	a,y	

	ldx	#rotatedMedusa
	lda	#MEDUSA_LIST_LEN - 1
	jsr	Draw_VL_a	
	
	
	rts
	
Load_level:
	lda	gameLevel
	;		Need 2 for the word offset, just multiply up
	asla
	ldy	#level_maps
	ldx	a,y	
	
	lda	, x+
	sta	starArray + 0

	lda	, x+
	sta	starArray + 1

	lda	, x+
	sta	starArray + 2

	lda	, x+
	sta	starArray + 3

	lda	, x+
	sta	starArray + 4

	lda	, x+
	sta	starArray + 5

	lda	, x+
	sta	starArray + 6

	lda	, x+
	sta	starArray + 7

	;; Reset the ship
	lda		#0
	sta		rotAngle
	sta		medMoving

	ldd		#0
	sta		medusaX
	sta		medusaY
	sta		animFrame


	
	; Set the max number of sharks and their speed
	lda		gameLevel
	ldx		#shark_max
	lda		a, x
	sta		sharkMax
	
	;; sharkSpeed = 1 + level, max is 4
	lda		gameLevel
	ldx		#shark_speed
	lda		a, x
	sta		sharkSpeed
		
		
	;; Reset the powerup
	lda		#0
	sta		powerup
	sta		powerupTime
	
	lda		gameLevel
	ldx		#num_powerups
	lda		a, x
	sta		powerupGive
		
	rts
	
	
star_row_offsets:
	db 	4 * DELTA_COORD
	db	3 * DELTA_COORD
	db	2 * DELTA_COORD
	db	1 * DELTA_COORD
	
Draw_stars:
	RESET0REF_MACRO

	jsr     Intensity_5F 
	


	lda     #128              
    sta     VIA_t1_cnt_lo	

	; Same as shark positions -90 + (i * 25)
	; Because the row loop will adjust it, we start on the -1st row
	lda		#-100
	sta		tempB2
	
	lda		#4
;	lda		#8
	sta		loopI
	
	ldx		starSelector
;	ldx		#0
	stx		tempW1 	; Index		

	beq		star_row_loop

	; Upper half
	lda		#0
	sta		tempB2
	
	
star_row_loop:
	lda		#1
	sta		tempB1	; Bit position
	
	lda     #128              
    sta     VIA_t1_cnt_lo	

	RESET0REF_MACRO
	lda		loopI
	deca
	ldx		#star_row_offsets
	lda		a, x
	adda		tempB2
		
	ldb		#X_ANCHOR
	MOVETOD_MACRO
	
	; Cannot move -200 in one sitting
;	lda		#DELTA_COORD
;	ldb		#-100
;	MOVETOD_MACRO	

;	lda		#0
;	ldb		#-100
;	MOVETOD_MACRO	
	
star_loop:
	ldx		tempW1
	lda		starArray, x
	
	; Do we have to draw this one?
	anda		tempB1
	beq		no_star		
	
	; Set the size
	lda     #STAR_SIZE_MIN
;	inca
    sta     VIA_t1_cnt_lo
	
;	sta		starSize
;	cmpa		#STAR_SIZE_MAX
;	ble		star_no_reset
	
;	lda		#STAR_SIZE_MIN
;	sta		starSize

star_no_reset:
	lda		animFrame
	ldy		#star_anim_frames
	ldx		a,y	

;	ldx		#star_vector_list
	lda		#STAR_LIST_LEN - 1
	jsr		Draw_VL_a
	
no_star:
	; Move to the next one
	lda     #128              
    sta     VIA_t1_cnt_lo	

	lda		#0
	ldb		#DELTA_COORD
	MOVETOD_MACRO
	
	lda		tempB1
	asla
	sta		tempB1
	bcc		star_loop
	
	; Now the loop over the different rows of stars
	inc		tempW1 + 1	; The 6809 is Big Endian	
	
	dec		loopI
	bne		star_row_loop

	lda		starSelector + 1
	adda		#4
	anda		#$7
	sta		starSelector + 1
	
	rts

	
Draw_bubbles:
 	jsr     Intensity_3F 
	
	lda	#2
	sta	tempW1
	
bubble_loop:
	RESET0REF_MACRO
	lda     #128              
        sta     VIA_t1_cnt_lo	

	ldx	tempW1
	
	lda	bubbleYs, x
	ldb	bubbleXs, x
	MOVETOD_MACRO
	
		
	; Bubbles should be growing
	lda     bubbleSizes, x          
        sta     VIA_t1_cnt_lo
	
	ldx	#bubble_vector_list
	lda	#BUBBLE_LIST_LEN - 1
	jsr	Draw_VL_a

	ldx	tempW1
	
	inc	bubbleSizes, x
	lda	bubbleSizes, x
	suba	BUBBLE_MAX_SIZE
	
	blt	bubble_done
	
	; Reset the bubble
	lda	#1
	sta	bubbleSizes, x
	jsr	Random
	sta	bubbleYs, x
	jsr	Random
	sta	bubbleXs, x
	
bubble_done:
	
	dec	tempW1
	bge	bubble_loop

	rts


Draw_sharks:
	RESET0REF_MACRO
	jsr     Intensity_5F 	
	
	lda	#7
	sta	loopI
	
	; Shark X position is -90 + i * 25
	lda	#X_ANCHOR
	sta	tempB3	
	
loop_sharks:	
	; scaling factor - 140 gives the full screen with the -128, 127 range
	; X is visible -100, +100
    lda     #128              
    sta     VIA_t1_cnt_lo	

	RESET0REF_MACRO
	
	ldy		#sharkYs
	ldb		loopI
	lda		b, y	
	
	ldb		tempB3
	MOVETOD_MACRO
	
	; Check if we have to draw it or not...
	ldx		#bit_positions
	ldb		loopI
	lda		b, x
	
	anda		sharkOn
	beq		no_shark
		
	; Sharks should be smaller
	lda     #64               
    sta     VIA_t1_cnt_lo
	
	; Going up or down?
	lda		b, x
	anda		sharkDir
	
	beq	down_shark
	
	lda	animFrame
	ldy	#shark_up_anim_frames
	bra	draw_shark

down_shark:	
	lda	animFrame
	ldy	#shark_down_anim_frames

draw_shark:
	ldx	a,y

	lda	#SHARK_LIST_LEN - 1
	jsr	Draw_VL_a

no_shark:		
	lda	tempB3
	adda	#DELTA_COORD
	sta	tempB3

	dec	loopI
	; Branch if >= 0
	bge	loop_sharks

	rts
	
; Splash screen
Splash:
    lda     #3	
	sta		tempB1
	jsr     Intensity_5F
	
	lda		#0
	sta		tempB2
	

keep_splashing:
    jsr     Wait_Recal 
	lda		tempB1
    sta     VIA_t1_cnt_lo 
	
	; Draw the goat at the current scale
	lda     #40                     ; to - y
    ldb     #-120                   ; to - x
    MOVETOD_MACRO                

	lda     #0                     ; to - y
    ldb     #-50                   ; to - x
    MOVETOD_MACRO               
	
	lda 		#GOAT_VECTOR_LEN
	ldx     	#goat_vector_list 
    jsr     Draw_VL_a												
                
;	lda 		#24
;	ldx     	#goat_vector_list + 48 
;    jsr     Draw_VL_a												
                

	; Change the scale up or down depending on INCREMENTOR
	lda	  	tempB1
	inca
	cmpa		#66
	blt		still_upscale
	deca
	
still_upscale
	sta		tempB1

	; Put the string up - easier to start from 0,0
	jsr     Reset0Ref				
	ldu     #mg_string 
    lda     #-50 
    ldb     #-50 
    jsr     Print_Str_d 

	ldu     #ent_string     		
    lda     #-70                   
    ldb     #-50              
    jsr     Print_Str_d          
       

	lda		tempB2
	inca
	sta		tempB2
	
	bne		keep_splashing
	
	rts

;***************************************************************************
; Other data
;***************************************************************************

shark_speed:
	db	1, 1, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 4, 4, 4, 5
	
shark_max:
	db	2, 2, 2, 2, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4

;; Number of powerups to give per level
num_powerups:
	db	0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 4
	
;; Array of 16 - will index into with a random - these two arrays must match
powerup_probabilities:
	db	POWERUP_NO_COLL
	db	POWERUP_NO_COLL
	db	POWERUP_NO_COLL
	db	POWERUP_SPEED
	db	POWERUP_SPEED
	db	POWERUP_SPEED
	db	POWERUP_ROW
	db	POWERUP_ROW
	db	POWERUP_ROW
	db	POWERUP_SLOW
	db	POWERUP_SLOW
	db	POWERUP_SLOW
	db	POWERUP_BONUS
	db	POWERUP_BONUS
	db	POWERUP_BONUS
	db	POWERUP_BONUS

powerup_times:
	db	POWERUP_NO_COLL_T
	db	POWERUP_NO_COLL_T
	db	POWERUP_NO_COLL_T
	db	POWERUP_SPEED_T
	db	POWERUP_SPEED_T
	db	POWERUP_SPEED_T
	db	POWERUP_ROW_T
	db	POWERUP_ROW_T
	db	POWERUP_ROW_T
	db	POWERUP_SLOW_T
	db	POWERUP_SLOW_T
	db	POWERUP_SLOW_T
	db	POWERUP_BONUS_T
	db	POWERUP_BONUS_T
	db	POWERUP_BONUS_T
	db	POWERUP_BONUS_T

pup_vectors:
	dw	pup_none_vector_list		; 0
	dw	pup_nocoll_vector_list	; 1
	dw	pup_speed_vector_list		; 2
	dw	pup_row_vector_list		; 3
	dw	pup_slow_vector_list		; 4
	dw	pup_bonus_vector_list		; 5

pup_none_vector_list:
	db	0, 0, 0
	db	1

pup_nocoll_vector_list:
	db	2, -40, -20
	db	2, -40, 20
	db	0, 0, 40
	db	2, 40, 20
	db	2, 40, -20
	db	1

pup_speed_vector_list:
	db	2, -40, 20
	db	2, -40, -20
	db	0, 0, 20
	db	2, 40, 20
	db	2, 40, -20
	db	1

pup_row_vector_list:
	db	2, -40, -24
	db	2, -40, 24
	db	2, 40, 24
	db	2, 40, -24
	db 	0, -40, -50
	db	2, 0, 100
	db	1

	
pup_slow_vector_list:
	db	0, -80, 0
	db	2, 80, 0
	db	2, -10, 20
	db	2, -40, 40
	db	2, -30, 20
	db	1
	
pup_bonus_vector_list:
	db	2, 20, -20
	db	2, -20, -20
	db	2, -40, 40
	db	2, -20, -20
	db	2, 20, -20
	db	0, -30, 20
	db	2, 100, 0
	db	1

	
SHARK_FRAME_COUNT	equ	12
shark_up_anim_frames:	
	dw	shark_u_1_vector_list
	dw	shark_u_2_vector_list
	dw	shark_u_3_vector_list
	dw	shark_u_4_vector_list
	dw	shark_u_3_vector_list
	dw	shark_u_2_vector_list
	dw	shark_u_1_vector_list
	dw	shark_u_5_vector_list
	dw	shark_u_6_vector_list
	dw	shark_u_7_vector_list
	dw	shark_u_6_vector_list
	dw	shark_u_5_vector_list				

shark_down_anim_frames:
	dw	shark_d_1_vector_list
	dw	shark_d_2_vector_list
	dw	shark_d_3_vector_list
	dw	shark_d_4_vector_list
	dw	shark_d_3_vector_list
	dw	shark_d_2_vector_list
	dw	shark_d_1_vector_list
	dw	shark_d_5_vector_list
	dw	shark_d_6_vector_list
	dw	shark_d_7_vector_list
	dw	shark_d_6_vector_list
	dw	shark_d_5_vector_list

	
SHARK_LIST_LEN	equ	20
shark_u_1_vector_list:
	db 	-1, -3
	db 	-10, -2
	db 	-3, -4
	db 	-5, -5
	db 	1, 9
	db 	-17, 2
	db 	-4, -4
	db 	0, 4
	db 	-17, 3
	db 	-8, 0
	
	db 	8, 1
	db 	17, 2
	db 	0, 4
	db 	4, -4
	db 	17, 2
	db 	-1, 9
	db 	5, -5
	db 	3, -4
	db 	10, -2
	db 	1, -3

shark_d_1_vector_list:
	db 	1, -3
	db 	10, -2
	db 	3, -4
	db 	5, -5
	db 	-1, 9
	db 	17, 2
	db 	4, -4
	db 	0, 4
	db 	17, 3
	db 	8, 0
	
	db	 -8, 1
	db	 -17, 2
	db	 0, 4
	db	 -4, -4
	db	 -17, 2
	db	 1, 9
	db	 -5, -5
	db	 -3, -4
	db	 -10, -2
	db	 -1, -3

	
shark_u_2_vector_list:
	db 	-1, -3
	db 	-10, -2
	db 	-3, -4
	db 	-5, -5
	db 	1, 9
	db 	-17, 4
	db 	-4, -4
	db 	0, 4
	db 	-17, 1
	db 	-8, -1
	
	db 	8, 2
	db 	17, 4
	db 	0, 4
	db 	4, -4
	db 	17, 0
	db 	-1, 9
	db 	5, -5
	db 	3, -4
	db 	10, -2
	db 	1, -3
	
shark_d_2_vector_list:
	db 	1, -3
	db 	10, -2
	db 	3, -4
	db 	5, -5
	db 	-1, 9
	db 	17, 4
	db 	4, -4
	db 	0, 4
	db 	17, 1
	db 	8, -1
	
	db 	-8, 2
	db 	-17, 4
	db 	0, 4
	db 	-4, -4
	db 	-17, 0
	db 	1, 9
	db 	-5, -5
	db 	-3, -4
	db 	-10, -2
	db 	-1, -3
	
shark_u_3_vector_list:
	db 	-1, -3
	db 	-10, -2
	db 	-3, -4
	db 	-5, -5
	db 	1, 9
	db 	-17, 7
	db 	-4, -4
	db 	0, 4
	db 	-17, 1
	db 	-8, 1
	
	db 	8, 0
	db 	17, 3
	db 	0, 4
	db 	4, -4
	db 	17, -2
	db 	-1, 9
	db 	5, -5
	db 	3, -4
	db 	10, -2
	db 	1, -3
	
shark_d_3_vector_list:
	db 	1, -3
	db 	10, -2
	db 	3, -4
	db 	5, -5
	db 	-1, 9
	db 	17, 7
	db 	4, -4
	db 	0, 4
	db 	17, 1
	db 	8, 1
	
	db 	-8, 0
	db 	-17, 3
	db 	0, 4
	db 	-4, -4
	db 	-17, -2
	db 	1, 9
	db 	-5, -5
	db 	-3, -4
	db 	-10, -2
	db 	-1, -3
	

shark_u_4_vector_list:
	db 	-1, -3
	db 	-10, -2
	db 	-3, -4
	db 	-5, -5
	db 	1, 9
	db 	-17, 7
	db 	-4, -4
	db 	0, 4
	db 	-17, 4
	db 	-8, 1
	
	db 	8, 0
	db 	17, 0
	db 	0, 4
	db 	4, -4
	db 	17, -2
	db 	-1, 9
	db 	5, -5
	db 	3, -4
	db 	10, -2
	db 	1, -3

shark_d_4_vector_list:
	db 	1, -3
	db 	10, -2
	db 	3, -4
	db 	5, -5
	db 	-1, 9
	db 	17, 7
	db 	4, -4
	db 	0, 4
	db 	17, 4
	db 	8, 1
	
	db 	-8, 0
	db 	-17, 0
	db 	0, 4
	db 	-4, -4
	db 	-17, -2
	db 	1, 9
	db 	-5, -5
	db 	-3, -4
	db 	-10, -2
	db 	-1, -3
	
shark_u_5_vector_list:
	db 	-1, -3
	db 	-10, -2
	db 	-3, -4
	db 	-5, -5
	db 	1, 9
	db 	-17, 0
	db 	-4, -4
	db 	0, 4
	db 	-17, 1
	db 	-8, 1
	
	db 	8, 1
	db 	17, 3
	db 	0, 4
	db 	4, -4
	db 	17, 4
	db 	-1, 9
	db 	5, -5
	db 	3, -4
	db 	10, -2
	db 	1, -3
	
shark_d_5_vector_list:
	db 	1, -3
	db 	10, -2
	db 	3, -4
	db 	5, -5
	db 	-1, 9
	db 	17, 0
	db 	4, -4
	db 	0, 4
	db 	17, 1
	db 	8, 1
	
	db 	-8, 1
	db 	-17, 3
	db 	0, 4
	db 	-4, -4
	db 	-17, 4
	db 	1, 9
	db 	-5, -5
	db 	-3, -4
	db 	-10, -2
	db 	-1, -3
	
shark_u_6_vector_list:
	db 	-1, -3
	db 	-10, -2
	db 	-3, -4
	db 	-5, -5
	db 	1, 9
	db 	-17, -3
	db 	-4, -4
	db 	0, 4
	db 	-17, 4
	db 	-8, 2
	
	db 	8, -1
	db 	17, 0
	db 	0, 4
	db 	4, -4
	db 	17, 8
	db 	-1, 9
	db 	5, -5
	db 	3, -4
	db 	10, -2
	db 	1, -3
	
shark_d_6_vector_list:
	db 	1, -3
	db 	10, -2
	db 	3, -4
	db 	5, -5
	db 	-1, 9
	db 	17, -3
	db 	4, -4
	db 	0, 4
	db 	17, 4
	db 	8, 2
	
	db 	-8, -1
	db 	-17, 0
	db 	0, 4
	db 	-4, -4
	db 	-17, 8
	db 	1, 9
	db 	-5, -5
	db 	-3, -4
	db 	-10, -2
	db 	-1, -3

shark_u_7_vector_list:
	db 	-1, -3
	db 	-10, -2
	db 	-3, -4
	db 	-5, -5
	db 	1, 9
	db 	-17, -3
	db 	-4, -4
	db 	0, 4
	db 	-17, 1
	db 	-8, 2
	
	db 	8, -1
	db 	17, 3
	db 	0, 4
	db 	4, -4
	db 	17, 8
	db 	-1, 9
	db 	5, -5
	db 	3, -4
	db 	10, -2
	db 	1, -3
	
shark_d_7_vector_list:
	db 	1, -3
	db 	10, -2
	db 	3, -4
	db 	5, -5
	db 	-1, 9
	db 	17, -3
	db 	4, -4
	db 	0, 4
	db 	17, 1
	db 	8, 2
	
	db 	-8, -1
	db 	-17, 3
	db 	0, 4
	db 	-4, -4
	db 	-17, 8
	db 	1, 9
	db 	-5, -5
	db 	-3, -4
	db 	-10, -2
	db 	-1, -3
	
	

BUBBLE_LIST_LEN	equ	12
bubble_vector_list:
	db	-1, -5
	db	-4, -4
	db	-5, -1
	db	-5, 1
	db	-4, 4
	db 	-1, 5
	db 	1, 5
	db	4, 4
	db	5, 1
	db	5, -1
	db	4, -4
	db	1, -5
	

BSTAR_LIST_LEN	equ	3
bstar_vector_list:
	db	-80, -24
	db	0, 48
	db	80, -24

	
CSTAR_LIST_LEN	equ	5
cstar_vector_list:
	db	-80, -24
	db	52, 64
	db	0, -80
	db	-52, 64
	db	80, -24

STAR_LIST_LEN	equ	4
star_vector_list:
	db	-40, -24
	db	-40, 24
	db	40, 24
	db	40, -24

star_anim_frames:
	dw	star_vector_list_1
	dw	star_vector_list_1
	dw	star_vector_list_2
	dw	star_vector_list_2
	dw	star_vector_list_3
	dw	star_vector_list_4
	dw	star_vector_list_4
	dw	star_vector_list_3
	dw	star_vector_list_2
	dw	star_vector_list_2
	dw	star_vector_list_1
	dw	star_vector_list_1
		
	
star_vector_list_1:
	db	-40, -24
	db	-40, 24
	db	40, 24
	db	40, -24

star_vector_list_2:
	db	-40, -22
	db	-40, 22
	db	40, 22
	db	40, -22

star_vector_list_3:
	db	-40, -20
	db	-40, 20
	db	40, 20
	db	40, -20

star_vector_list_4:
	db	-40, -18
	db	-40, 18
	db	40, 18
	db	40, -18

	
ASTAR_LIST_LEN	equ	10
Astar_vector_list:
	db	-6, -3
	db	-1, -6
	db	-5, 5
	db	-6, -2
	db	3, 6
	
	db	-3, 6
	db	6, -2
	db 	5, 5
	db 	1, -6
	db 	6, -3

level_maps:
	dw	level_1_map
	dw	level_2_map
	dw	level_3_map
	dw	level_4_map
	dw	level_5_map
	dw	level_6_map
	dw	level_7_map
	dw	level_8_map
	dw	level_9_map
	dw	level_10_map
	dw	level_11_map
	dw	level_12_map
	dw	level_13_map
	dw	level_14_map
	dw	level_15_map
	dw	level_16_map
	

level_1_map:
	db	$0, $FF, $81, $99, $99, $81, $FF, $0
level_2_map:
	db	$18, $24, $5A, $A5, $A5, $5A, $24, $18
level_3_map:
	db	$C1, $60, $30, $18, $18, $0C, $06, $83
level_4_map:
	db	$18, $3C, $66, $C3, $C3, $66, $3C, $18
level_5_map:
	db	$FF, $C3, $A5, $81, $81, $A5, $C3, $FF
level_6_map:
	db	$A5, $00, $A5, $24, $24, $A5, $00, $A5
level_7_map:
	db	$62, $62, $F7, $62, $46, $EF, $46, $46
level_8_map:
	db	$81, $66, $7E, $24, $E7, $7E, $18, $18 
level_9_map:
	db	$30, $70, $7A, $F5, $F0, $7A, $75, $30
level_10_map:
	db	$C3, $C3, $24, $00, $00, $24, $C3, $C3
level_11_map:
	db	$88, $88, $44, $44, $22, $22, $11, $11
level_12_map:
	db	$42, $C3, $18, $24, $24, $18, $C3, $42
level_13_map:
	db	$03, $84, $48, $30, $03, $84, $48, $30
level_14_map:
	db	$81, $42, $24, $42, $81, $42, $24, $42
level_15_map:
	db	$0F, $F0, $07, $E0, $03, $C0, $01, $80
level_16_map:
	db	$24, $3C, $81, $A5, $00, $5A, $66, $42
	
	
	
	


medusa_anim_frames:
	dw	medusa_1_vector_list
	dw	medusa_2_vector_list
	dw	medusa_3_vector_list
	dw	medusa_2_vector_list
	dw	medusa_1_vector_list
	dw	medusa_4_vector_list
	dw	medusa_2_vector_list
	dw	medusa_5_vector_list
	dw	medusa_2_vector_list
	dw	medusa_1_vector_list
	dw	medusa_3_vector_list
	dw	medusa_2_vector_list

MEDUSA_LIST_LEN	equ 12
medusa_1_vector_list:
	db	-17, 2
	db	0, 1
	db 	12, 1
	db	1, 8
	db	9, -4
	db	3, -8
	
	db	-3, -8
	db	-9, -4
	db	-1, 8
	db	-12, 3
	db	0, 1
	db	17, 0

medusa_2_vector_list:
	db	-17, 1
	db	0, 1
	db 	12, 2
	db	1, 8
	db	9, -4
	db	3, -8
	
	db	-3, -8
	db	-9, -4
	db	-1, 8
	db	-12, 2
	db	0, 1
	db	17, 1

medusa_3_vector_list:
	db	-17, 0
	db	0, 1
	db 	12, 3
	db	1, 8
	db	9, -4
	db	3, -8
	
	db	-3, -8
	db	-9, -4
	db	-1, 8
	db	-12, 1
	db	0, 1
	db	17, 2

medusa_4_vector_list:
	db	-17, 2
	db	0, 1
	db 	12, 1
	db	1, 8
	db	9, -4
	db	3, -8
	
	db	-3, -8
	db	-9, -4
	db	-1, 8
	db	-12, 1
	db	0, 1
	db	17, 2


medusa_5_vector_list:
	db	-17, 0
	db	0, 1
	db 	12, 3
	db	1, 8
	db	9, -4
	db	3, -8
	
	db	-3, -8
	db	-9, -4
	db	-1, 8
	db	-12, 3
	db	0, 1
	db	17, 0

;***************************************************************************
; Home-grown rise/run for angles
;   index is rotation angle, result is 16 * cos / sin for angle
;***************************************************************************
angle_to_y:
	db	16
	db	16
	db	16
	db	15
	db	15
	db	14
	db	13
	db	12
	db	11
	db	10
	db	9
	db	8
	db	6
	db	5
	db	3
	db	2
	db	0
	db	-2
	db	-3
	db	-5
	db	-6
	db	-8
	db	-9
	db	-10
	db	-11
	db	-12
	db	-13
	db	-14
	db	-15
	db	-15
	db	-16
	db	-16
	db	-16
	db	-16
	db	-16
	db	-15
	db	-15
	db	-14
	db	-13
	db	-12
	db	-11
	db	-10
	db	-9
	db	-8
	db	-6
	db	-5
	db	-3
	db	-2
	db	-0
	db	2
	db	3
	db	5
	db	6
	db	8
	db	9
	db	10
	db	11
	db	12
	db	13
	db	14
	db	15
	db	15
	db	16
	db	16

angle_to_x:
	db	-0
	db	-2
	db	-3
	db	-5
	db	-6
	db	-8
	db	-9
	db	-10
	db	-11
	db	-12
	db	-13
	db	-14
	db	-15
	db	-15
	db	-16
	db	-16
	db	-16
	db	-16
	db	-16
	db	-15
	db	-15
	db	-14
	db	-13
	db	-12
	db	-11
	db	-10
	db	-9
	db	-8
	db	-6
	db	-5
	db	-3
	db	-2
	db	-0
	db	2
	db	3
	db	5
	db	6
	db	8
	db	9
	db	10
	db	11
	db	12
	db	13
	db	14
	db	15
	db	15
	db	16
	db	16
	db	16
	db	16
	db	16
	db	15
	db	15
	db	14
	db	13
	db	12
	db	11
	db	10
	db	9
	db	8
	db	6
	db	5
	db	3
	db	2

;; Fox herself
FOX_1_LIST_LEN equ 36
fox_1_vector_list:
	db 12,	5
	db 8,	19
	db 17,	19
	db -37,	9
	db -33,	-19
	db -2,	4
	db -13,	-16
	db 8,	33
	db 8,	0
	db 11,	22
	db 12,	9
	db 18,	-5
	db 6,	-15
	db 10,	1
	db 22,	-7
	db 17,	-10
	db 20,	-27
	db 3,	-21
	db -5,	-22
	db -13,	-22
	db -17,	-13
	db -20,	-7
	db -17,	-1
	db -11,	-22
	db -14,	1
	db -10,	11
	db -12,	1
	db -7,	21
	db -10,	31
	db 19,	-18
	db 3,	6
	db 28,	-12
	db 23,	0
	db 13,	7
	db -24,	36
	db -12,	4
	db 23,	-47
	db 13,	7
	db -24,	36
	db -12,	4

FOX_2_LIST_LEN equ 12
fox_2_vector_list:
	db -4,	0
	db -2,	-5
	db 2,	-4
	db 3,	0
	db 2,	1
	db -1,	7
	db -5,	6
	db -3,	-11
	db 2,	-7
	db 3,	-4
	db 3,	6
	db -2,	10

FOX_2B_LIST_LEN equ	5
fox_2b_vector_list:
	db	0,	-16
	db	-5, 8
	db	1,	8
	db	4,	4
	db	-1,	-5
	
	
FOX_3_LIST_LEN equ 12
fox_3_vector_list:
	db -4,	0
	db -2,	5
	db 2,	4
	db 3,	0
	db 2,	-1
	db -1,	-7
	db -5,	-6
	db -3,	11
	db 2,	7
	db 3,	4
	db 3,	-6
	db -2,	-10

FOX_4_LIST_LEN equ 8
fox_4_vector_list:
	db -21,	-4
	db -39,	11
	db -22,	27
	db 3,	5
	db -3,	5
	db 22,	26
	db 41,	14
	db 19,	-4

FOX_5_LIST_LEN equ 8
fox_5_vector_list:
	db 3,	7
	db -0,	10
	db -3,	6
	db -1,	-23
	db -3,	4
	db -2,	8
	db 3,	8
	db 3,	3
	
FOX_6_LIST_LEN equ 7
fox_6_vector_list:
	db -0,	25
	db 4,	8
	db 6,	5
	db 0,	7
	db -6,	6
	db -4,	13
	db 1,	17
	
FOX_7_LIST_LEN equ 12
fox_7_vector_list:
	db	16,	16
	db	8,	20
	db	4,	20
	db	-12, -12
	db	-16, 32
	
	db	-12, 8
	db	12,	8
	
	db	16,	32
	db	12,	-12
	db	-3,	20
	db	-8,	20
	db	-16, 16
	
	
	

;; Vectors for the fox logo on Fox's helmet	
FOX_LOGO_1_LIST_LEN equ 17
fox_logo_1_vector_list:
	db 0,	4
	db -6,	2
	db 12,	3
	db 4,	11
	db 5,	-2
	db 7,	0
	db 13,	4
	db -8,	-11
	db -0,	-18
	db 8,	-11
	db -11,	3
	db -7,	-1
	db -5,	-3
	db -4,	12
	db -14,	3
	db 6,	3
	db -0,	3
	
FOX_LOGO_2_LIST_LEN equ 3
fox_logo_2_vector_list:
	db	5,	-8
	db	-5,	0
	db 0,	8

FOX_LOGO_3_LIST_LEN equ 3
fox_logo_3_vector_list:
	db	5,	8
	db	-5,	0
	db 0,	-8
	
; Considered unsigned divide 25 for the coordinate stuff
; Never mind that the 6809 cannot divide, it would be useless anyway since is it a
;	 2s complement signed number converted to an unsigned index of 0-7 
star_collison_array:
	db -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
	db -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
	db -1, -1, -1, -1, -1, -1, -1, -1
	db	-1, -1, -1, -1, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, -1, -1, -1, -1
	db	-1, -1, -1, -1, -1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, -1, -1, -1, -1, -1
	db	-1, -1, -1, -1, -1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, -1, -1, -1, -1, -1
	db	-1, -1, -1, -1, -1, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, -1, -1, -1, -1, -1
star_collison:  ; Right in the middle since offsets can both be + and -
	db	-1, -1, -1, -1, -1, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, -1, -1, -1, -1, -1
	db	-1, -1, -1, -1, -1, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, -1, -1, -1, -1, -1
	db	-1, -1, -1, -1, -1, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, -1, -1, -1, -1, -1
	db	-1, -1, -1, -1, -1, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, -1, -1, -1, -1, -1
	db -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
	db -1, -1, -1, -1, -1, -1, -1, -1, -1, -1

	;; We can skip some -1s here between the two, they will just index into each other

shark_collison_array:
	db -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
	db -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
	db	-1, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, -1, -1
	db	-1, -1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, -1, -1
	db	-1, -1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, -1, -1
	db	-1, -1, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, -1, -1
shark_collison:  ; Right in the middle since offsets can both be + and -
	db	-1, -1, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, -1, -1
	db	-1, -1, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, -1, -1
	db	-1, -1, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, -1, -1
	db	-1, -1, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, -1, -1
	db -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
	db -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
	db -1, -1, -1, -1, -1, -1, -1, -1

	;; Bit positions for indices or OR-ing with. Index with a loop counter and get the Nth bit
bit_positions:
	db	1, 2, 4, 8, 16, 32, 64, 128
	
	;; Bit masks for leaving a bit out. Used for AND-ing to turn a bit off
bit_masks:
	db	$FE, $FD, $FB, $F7, $EF, $DF, $BF, $7F
	

level_string:
	db 'LEVEL'
	db $80
	
lives_string:
	db 'LIVES'
	db $80
		
gameover_string:
	db	'GAME OVER'
	db	$80
	
DEBUG_LIST_LEN	equ	4
debug_vector_list:
	db	10, 0
	db	0, -10
	db 	-10, 0
	db 	0, 10
	
EXPLOSION_LIST_LEN	equ	10
explosion_vector_list:
	db	-4, -8
	db	8, 10
	db	7, -7
	db	-7, 11
	db	8, 4
	db	-11, -3
	db	-2, 10
	db	0, -13
	db -9, 1
	db	10, -5

; Splash screen stuff
mg_string:
                db	"MOUNTAIN GOAT" ; only capital letters
                db	$80                        ; $80 is end of string
ent_string:
                db	"ENTERTAINMENT" ; only capital letters
                db	$80                        ; $80 is end of string

				
paused_string:
				db	"PAUSED"
				db	$80
				
	
GOAT_FACTOR 	equ 1
GOAT_VECTOR_LEN equ 48
goat_vector_list:
			db 39 * GOAT_FACTOR,  0 * GOAT_FACTOR	  
			db 10 * GOAT_FACTOR,  -6 * GOAT_FACTOR  
			db 10 * GOAT_FACTOR,  0 * GOAT_FACTOR	  
			db 18 * GOAT_FACTOR,  -9 * GOAT_FACTOR  
			db 20 * GOAT_FACTOR,  -1 * GOAT_FACTOR  
			db 19 * GOAT_FACTOR,  6 * GOAT_FACTOR	  
			db -21 * GOAT_FACTOR, 0 * GOAT_FACTOR	  
			db -8 * GOAT_FACTOR,  4 * GOAT_FACTOR	  
			db 9 * GOAT_FACTOR,   2 * GOAT_FACTOR	  
			db 10 * GOAT_FACTOR,  7 * GOAT_FACTOR	  
			db -14 * GOAT_FACTOR, -1 * GOAT_FACTOR  
			db -10 * GOAT_FACTOR, 0 * GOAT_FACTOR	  
			db 29 * GOAT_FACTOR,  29 * GOAT_FACTOR  
			db 30 * GOAT_FACTOR,  59 * GOAT_FACTOR  
			db -3 * GOAT_FACTOR,  79 * GOAT_FACTOR  
			db -40 * GOAT_FACTOR, 54 * GOAT_FACTOR  
			db 7 * GOAT_FACTOR,   25 * GOAT_FACTOR  
			db -14 * GOAT_FACTOR, 37 * GOAT_FACTOR  
			db -53 * GOAT_FACTOR, 40 * GOAT_FACTOR  
			db -88 * GOAT_FACTOR, -4 * GOAT_FACTOR  
			db 49 * GOAT_FACTOR,  -10 * GOAT_FACTOR 
			db -30 * GOAT_FACTOR, -20 * GOAT_FACTOR 
			db -7 * GOAT_FACTOR,  -23 * GOAT_FACTOR 
			db -29 * GOAT_FACTOR, 11 * GOAT_FACTOR  
			db -11 * GOAT_FACTOR, -11 * GOAT_FACTOR 
			db -37 * GOAT_FACTOR, -4 * GOAT_FACTOR  
			db -5 * GOAT_FACTOR,  -25 * GOAT_FACTOR 
			db 18 * GOAT_FACTOR,  7 * GOAT_FACTOR	  
			db 20 * GOAT_FACTOR,  -1 * GOAT_FACTOR  
			db 8 * GOAT_FACTOR,   -12 * GOAT_FACTOR 
			db 32 * GOAT_FACTOR,  0 * GOAT_FACTOR	  
			db 2 * GOAT_FACTOR,   -40 * GOAT_FACTOR 
			db 27 * GOAT_FACTOR,  -31 * GOAT_FACTOR 
			db -36 * GOAT_FACTOR, 2 * GOAT_FACTOR	  
			db -4 * GOAT_FACTOR,  -7 * GOAT_FACTOR  
			db -36 * GOAT_FACTOR, 4 * GOAT_FACTOR	  
			db -10 * GOAT_FACTOR, -10 * GOAT_FACTOR 
			db 0 * GOAT_FACTOR,   -23 * GOAT_FACTOR 
			db 21 * GOAT_FACTOR,  11 * GOAT_FACTOR  
			db 23 * GOAT_FACTOR,  -6 * GOAT_FACTOR  
			db 10 * GOAT_FACTOR,  -12 * GOAT_FACTOR 
			db 19 * GOAT_FACTOR,  -1 * GOAT_FACTOR  
			db 13 * GOAT_FACTOR,  -41 * GOAT_FACTOR 
			db 39 * GOAT_FACTOR,  -23 * GOAT_FACTOR 
			db -5 * GOAT_FACTOR,  -13 * GOAT_FACTOR 
			db -32 * GOAT_FACTOR, 17 * GOAT_FACTOR  
			db 7 * GOAT_FACTOR,   -30 * GOAT_FACTOR 
			db -4 * GOAT_FACTOR,  -19 * GOAT_FACTOR 
			db 8 * GOAT_FACTOR,   -11 * GOAT_FACTOR
;***************************************************************************
; Sounds
;***************************************************************************
adsr_beep:
				fdb $aaaa,$aaaa,$8888,$4444,$0000,$0000,$0000,$0000

adsr_sink:
				fdb $4488, $ffff, $ffff, $dddd, $8888, $4444, $2222, $0000

adsr_music:
				fdb $EEFF,$FFEE,$EEDD,$CCBB,$AA99,$8888,$8888,$8888 
				
silence:
				fdb		adsr_beep, $FEB6
				fcb		30, $80				

				
beep:
				fdb		adsr_beep, $FEB6
				fcb		$80 + C6, G6, 8
				fcb		30, $80

sink:
				fdb		adsr_sink, $FEB6
				fcb		$80 + 30, $40 + 30, 4
				fcb		$80 + 28, $40 + 28, 4
				fcb		$80 + 26, $40 + 26, 4
				fcb		$80 + 24, $40 + 24, 4
				fcb		$80 + 22, $40 + 22, 4
				fcb		$80 + 20, $40 + 20, 4
				fcb		$80 + 18, $40 + 18, 4
				fcb		$80 + 16, $40 + 16, 4
				fcb		$80 + 14, $40 + 14, 4
				fcb		$80 + 12, $40 + 12, 4
				fcb		$80 + 10, $40 + 10, 4
				fcb		$80 + 8, $40 + 8, 4
				fcb		$80 + 6, $40 + 6, 4
				fcb		$80 + 4, $40 + 4, 4
				fcb		$80 + 2, $40 + 2, 4
				fcb		$80 + 0, $40 + 0, 2
				fcb		$C0 + 0, $40 + 2, 2
				fcb		$C0 + 2, $40 + 0, 2
				fcb		$C0 + 0, $40 + 2, 2
				fcb		$C0 + 2, $40 + 0, 2
				fcb		$C0 + 0, $40 + 2, 2
				fcb		$C0 + 2, $40 + 0, 2
				fcb		$C0 + 0, $40 + 2, 2
				fcb		$C0 + 2, $40 + 0, 2
				fcb		$40 + 30, $80
	
level_music:
				fdb		adsr_music, $FEB6
				fcb		$80 + C4, C3, 8
				fcb		$80 + D4, C3, 8
				fcb		$80 + C4, C3, 8
				fcb		$80 + G4, $80 + C3, G2, 16
				fcb		$80 + C4, C3, 8
				fcb		$80 + D4, C3, 8
				fcb		$80 + C4, C3, 8
				fcb		$80 + G4, G2, 16
				fcb		$80 + A4, D3, 8
				fcb		$80 + G4, $80 +  C3,  C4, 16
				fcb		0, $80
				
gameover_music:
				fdb		adsr_music, $FEB6
				fcb		A4, 8
				fcb		GS4, 8
				fcb		A4, 8
				fcb		$80 + C4, $80 + F3, GS3, 32
				fcb		$80 + B3, $80 + D3, GS3, 32
				fcb		$80 + A3, $80 + E3, A2, 32
				fcb		0, $80
	
add_bonus_music:
				fdb		adsr_music, $FEB6	
				fcb		$80 + C4, G4, 4
				fcb		$80 + D4, A4, 4
				fcb		$80 + E4, B4, 4
				fcb		$80 + F4, C5, 4
				fcb		$80 + G4, D5, 4
				fcb		$80 + A4, E5, 4
				fcb		$80 + B4, F5, 4
				fcb		$80 + C5, G5, 4
				fcb		$80 + D5, A5, 4
				fcb		$80 + E5, B5, 4
				fcb		$80 + F5, C6, 4
				fcb		$80 + G5, D6, 4
				fcb		$80 + A5, E6, 4
				fcb		$80 + B5, F6, 4
				fcb		$80 + C6, G6, 8
				fcb		0, $80

powerup_music:
				fdb		adsr_music, $FEB6	
				fcb		$80 + C4, $80 + E4, G4, 8
				fcb		$80 + D4, $80 + F4, A4, 8
				fcb		$80 + C4, $80 + G4, C5, 16
				fcb		0, $80
				
				
;; The supported notes
G2      equ     $00               
GS2     equ     $01              
A2      equ     $02
AS2     equ     $03
B2      equ     $04
C3      equ     $05
CS3     equ     $06
D3      equ     $07
DS3     equ     $08
E3      equ     $09
F3      equ     $0A
FS3     equ     $0B
G3      equ     $0C
GS3     equ     $0D
A3      equ     $0E
AS3     equ     $0F
B3      equ     $10
C4      equ     $11
CS4     equ     $12
D4      equ     $13
DS4     equ     $14
E4      equ     $15
F4      equ     $16
FS4     equ     $17
G4      equ     $18
GS4     equ     $19
A4      equ     $1A
AS4     equ     $1B
B4      equ     $1C
C5      equ     $1D
CS5     equ     $1E
D5      equ     $1F
DS5     equ     $20
E5      equ     $21
F5      equ     $22
FS5     equ     $23
G5      equ     $24
GS5     equ     $25
A5      equ     $26
AS5     equ     $27
B5      equ     $28
C6      equ     $29
CS6     equ     $2A
D6      equ     $2B
DS6     equ     $2C
E6      equ     $2D
F6      equ     $2E
FS6     equ     $2F
G6      equ     $30
GS6     equ     $31
A6      equ     $32
AS6     equ     $33
B6      equ     $34
C7      equ     $35
CS7     equ     $36
D7      equ     $37
DS7     equ     $38
E7      equ     $39
F7      equ     $3A
FS7     equ     $3B
G7      equ     $3C
GS7     equ     $3D
A7      equ     $3E
AS7     equ     $3F
;***************************************************************************
; Macros
;***************************************************************************

;***************************************************************************
    end main
