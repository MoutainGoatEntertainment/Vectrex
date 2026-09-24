;***************************************************************************
; DEFINE SECTION
;***************************************************************************
                include "VECTREX.I"
				
SOUND_BYTE_MACRO	macro
	ldx		#$C800
	stb		a, x
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

		
SET_FREQ 	macro	_channel
	;; b has the note to play
	lslb						;; Offset 2 *
	ldx		Vec_Freq_Table  ;; Vec_Freq_Table is a pointer
	
	ldx		b, x
	stx		tempMacroW
	
	lda		#(\1 * 2) + 1 
	ldb		tempMacroW
	SOUND_BYTE_MACRO
	
	lda		#(\1 * 2)
	ldb		tempMacroW + 1
	SOUND_BYTE_MACRO
	endm		

SET_NOISE 	macro	_channel
	;; b has the noise period
	;; Keep the least significant 5 bits for the noise
	andb		#$1F	
	lda		#6 
	SOUND_BYTE_MACRO
	endm
	
	
SET_VOLUME	macro	_channel	
	;; b has the fixed value volume
	lda		#\1 + 8
    SOUND_BYTE_MACRO        
	endm		

SET_ENVELOPE_FREQ	macro
	;; d has the frequency
	sta		tempMacroW
	lda		#11
	SOUND_BYTE_MACRO
	
	ldb		tempMacroW
	lda		#12
	SOUND_BYTE_MACRO
	endm
	
SET_ENVELOPE_SHAPE macro
	andb		#$0F
	lda		#13
	SOUND_BYTE_MACRO
	endm

SET_MASK_M_M_M	macro
	;; Set up Music on all channels
	ldb     Vec_Snd_Shadow + 7	; Noise off - sound on XX111000
	andb		#$FE
	ldb		#$38				
	lda     #$07              
    SOUND_BYTE_MACRO
	endm
	
SET_MASK_M_MN_MN	macro
	;; Set up Music on A, music and noise on B and C
	ldb     Vec_Snd_Shadow + 7	; Noise off - sound on XX100000
	andb		#$E0				
	lda     #$07              
    SOUND_BYTE_MACRO
	endm
	
SET_MASK_M_N_N	macro
	;; Set up Music on A, noise on B and C
	ldb     Vec_Snd_Shadow + 7	; Noise off - sound on XX100110
	andb		#$E6				
	lda     #$07              
    SOUND_BYTE_MACRO
	endm

SET_MASK_M_X_X	macro
	;; Set up Music on A, music and noise on B and C
	ldb     Vec_Snd_Shadow + 7	; Noise off - sound on XXXX1XX0
	andb		#$FE
	orb		#08
	lda     #$07              
    SOUND_BYTE_MACRO
	endm

SET_MASK_MN_X_X	macro
	;; Set up Music on A, music and noise on B and C
	ldb     Vec_Snd_Shadow + 7				; Noise off - sound on XXXX0XX0
	andb		#$F6
	lda     #$07              
    SOUND_BYTE_MACRO
	endm

SET_MASK_N_X_X	macro
	;; Set up Music on A, music and noise on B and C
	ldb     Vec_Snd_Shadow + 7				; Noise off - sound on XXXX0XX1
	andb		#$F7
	orb		#$1
	lda     #$07              
    SOUND_BYTE_MACRO
	endm

SET_MASK_X_M_X	macro
	;; Set up Music on A, music and noise on B and C
	ldb     Vec_Snd_Shadow + 7				; Noise off - sound on XXX1XX0X
	andb		#$FD
	orb		#$10
	lda     #$07              
    SOUND_BYTE_MACRO
	endm

SET_MASK_X_MN_X	macro
	;; Set up Music on A, music and noise on B and C
	ldb     Vec_Snd_Shadow + 7				; Noise off - sound on XXX0XX0X
	andb		#$ED
	lda     #$07              
    SOUND_BYTE_MACRO
	endm

SET_MASK_X_N_X	macro
	;; Set up Music on A, music and noise on B and C
	ldb     Vec_Snd_Shadow + 7				; Noise off - sound on XXX0XX1X
	andb		#$EF
	orb		#$02
	lda     #$07              
    SOUND_BYTE_MACRO
	endm

SET_MASK_X_X_M	macro
	;; Set up Music on A, music and noise on B and C
	ldb     Vec_Snd_Shadow + 7				; Noise off - sound on XX1XX0XX
	andb		#$FB
	orb		#$20
	lda     #$07              
    SOUND_BYTE_MACRO
	endm

SET_MASK_X_X_MN	macro
	;; Set up Music on A, music and noise on B and C
	ldb     Vec_Snd_Shadow + 7				; Noise off - sound on XX0XX0XX
	andb		#$DB
	lda     #$07              
    SOUND_BYTE_MACRO
	endm

SET_MASK_X_X_N	macro
	;; Set up Music on A, music and noise on B and C
	ldb     Vec_Snd_Shadow + 7				; Noise off - sound on XX0XX1XX
	andb		#$DF
	orb		#$04
	lda     #$07              
    SOUND_BYTE_MACRO
	endm

SET_SONG_A			macro  __song, __adsr	
	;; Params - song to play, ADSR to use
	ldd		#\1
	std		chanASong

	ldd		#\2
	std		chanAADSR
	
	ldx		chanASong
	lda		0, x
	sta		chanANoteLength

	clr		chanANoteDuration

	ldd		#1
	std		chanAIndex
	endm
		
SET_SONG_B			macro  __song, __adsr	
	;; Params - song to play, ADSR to use
	ldd		#\1
	std		chanBSong

	ldd		#\2
	std		chanBADSR
	
	ldx		chanBSong
	lda		0, x
	sta		chanBNoteLength

	clr		chanBNoteDuration

	ldd		#1
	std		chanBIndex
	endm
	
	
SET_SONG_C			macro  __song, __adsr	
	;; Params - song to play, ADSR to use
	ldd		#\1
	std		chanCSong

	ldd		#\2
	std		chanCADSR
	
	ldx		chanCSong
	lda		0, x
	sta		chanCNoteLength

	clr		chanCNoteDuration

	ldd		#1
	std		chanCIndex
	endm

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

		
INTENSITY_A_MACRO	macro
		sta		<$0001
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

SCREEN_INTRO		equ	0
SCREEN_SELECT		equ	1
SCREEN_CODE			equ	2
SCREEN_GAME			equ	3
SCREEN_WIN			equ	4
SCREEN_LOSS			equ	5
SCREEN_HELP			equ	6


MOVE_FRAME_COUNT	equ	4

TDATA_OFF_X			equ	0
TDATA_OFF_Y			equ	1
TDATA_OFF_VELO		equ	2
TDATA_OFF_ORI_LANE	equ	3
TDATA_OFF_DIST		equ	4

GLEVEL_OFF_LANES	equ	0
GLEVEL_OFF_TOKENMAX	equ	2
GLEVEL_OFF_TDELAY	equ	3
GLEVEL_OFF_MNEEDED	equ	4
GLEVEL_OFF_TSPEED	equ	5
GLEVEL_OFF_MISTAKES	equ	6

;; Sound channels
CHANNEL_A			equ	0
CHANNEL_B			equ	1
CHANNEL_C			equ	2			


;***************************************************************************
; RAM variables
;***************************************************************************
;;; Random seed - do NOT initialize to 0 or 128
seed			equ	$C880	

screen			equ	$C881
gameLevel		equ	$C882

laneCoords		equ	$C883	;; 4 bytes
laneDirs		equ	$C887	;; 4 bytes

receptorX		equ	$C88B	;; 4 bytes
receptorY		equ	$C88F	;; 4 bytes

moveFrame		equ	$C893
tokenCount		equ	$C894
tokenAddDelay	equ	$C895

joyPosition		equ	$C896
receptorMask	equ	$C897

matchers		equ	$C898	;; 4 bytes

levelPtr		equ	$C89C	;; 2 bytes
nextTokenLane	equ	$C89E
tokenSpeed		equ	$C89F

;; 16 tokens
tokenData		equ	$C8A0   ;; to $C8EF 

matchCount		equ	$C8F0
mistakesLeft	equ	$C8F1


;;; Local loop and temp variables
loopI		equ	$C9F0
tempB1		equ	$C9F1
tempB2		equ	$C9F2
tempB3		equ	$C9F3
tempB4		equ	$C9F4
tempW1		equ	$C9F6
tempW2		equ	$C9F8
tempW3		equ	$C9FA
tempMacroW	equ	$C9FC


chanAIndex			equ	$CA00	; 2 bytes
chanASong			equ	$CA02	; 2 bytes
chanANoteDuration	equ	$CA04
chanANoteLength		equ	$CA05
chanAADSR			equ	$CA06	; 2 bytes

chanBIndex			equ	$CA08	; 2 bytes
chanBSong			equ	$CA0A	; 2 bytes
chanBNoteDuration	equ	$CA0C
chanBNoteLength		equ	$CA0D
chanBADSR			equ	$CA0E	; 2 bytes

chanCIndex			equ	$CA10	; 2 bytes
chanCSong			equ	$CA12	; 2 bytes
chanCNoteDuration	equ	$CA14
chanCNoteLength		equ	$CA15
chanCADSR			equ	$CA16	; 2 bytes

;***************************************************************************
; start of Vectrex memory with cartridge name...
	org     0				
;***************************************************************************
; HEADER SECTION
;***************************************************************************
        db      "g GCE MGE ", $80   	; 'g' is copyright sign
        dw      silence           		; music from the rom
        db      $F8, $50, $20, -$45 	; height, width, rel y, rel x
										; (from 0,0)
        db      "MALLEUS",$80   		; some game information,
										; ending with $80
		db		$F8, $50, $0, -$45
		db		"V0.9", $80
		
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
	
	lda		#17
	sta		seed
	
;	$C81F	; joystick 1 X - enable with 1
;	$C820 	; joystick 1 Y - enable with 3
;	$C821 	; joystick 2 X - enable with 5
;	$C822 	; joystick 2 Y - enable with 7
	lda		#1
	sta		$C81F	
	lda		#3
	sta		$C820	
	
	;; No music initially
	ldb		#0
	SET_VOLUME CHANNEL_A
	ldb		#0
	SET_VOLUME CHANNEL_B
	ldb		#0
	SET_VOLUME CHANNEL_C

	ldd		#$0016
	SET_ENVELOPE_FREQ
	ldb		#$08
	SET_ENVELOPE_SHAPE
	
	ldb		#$45
	SET_NOISE
	
	SET_MASK_M_M_M

	ldd		#0
	std		chanASong
	std		chanBSong
	std		chanCSong

	lda		#0
	sta		gameLevel
	
	jsr		Load_level
		
	lda		#SCREEN_SELECT
	sta		screen

	;; Play the intro music
	SET_SONG_A song_intro_1, adsr_fade
	SET_SONG_B song_intro_2, adsr_fade
	SET_SONG_C song_intro_3, adsr_fade



	
main:
	jsr     Wait_Recal              

	jsr		Play_sounds
	
	lda		screen

	cmpa		#SCREEN_GAME	
	beq		Screen_game

	cmpa		#SCREEN_WIN	
	lbeq		Screen_win
	
	cmpa		#SCREEN_LOSS	
	lbeq		Screen_loss
	
	cmpa		#SCREEN_SELECT	
	lbeq		Screen_select

	cmpa		#SCREEN_HELP
	lbeq		Screen_help
	
	cmpa		#SCREEN_CODE
	lbeq		Screen_enter_code

main_loop_bottom:
	
	bra main

	
Screen_game:
	
	jsr		Draw_lanes

	jsr		Handle_controls
	
	jsr		Draw_tokens
	jsr		Draw_matcher
	jsr		Draw_receptors	
	
	dec		moveFrame
	bgt		no_move
	
	ldx		levelPtr
	lda		#GLEVEL_OFF_TSPEED
	lda		a, x
	sta		moveFrame

	jsr		Token_add_check
	
	jsr		Move_tokens
	jsr		Check_tokens_hit
	jsr		Check_win_loss
	

no_move:	
	jsr		Draw_score

;	lda		matchCount
;	jsr		Debug_A	
		
	lbra		main_loop_bottom

Handle_controls:
	
	;; Check the joystick
	lda		#$FF
	sta		joyPosition
	jsr		Joy_Digital

	; Joystick 1 X direction
	lda		$C81B
	beq		no_joy_x
	bmi		joy_left

joy_right:
	lda		#6
	sta		joyPosition
	bra		joy_x_done
	
joy_left:
	lda		#2
	sta		joyPosition

joy_x_done:	
no_joy_x:
	; Joystick 1 Y direction
	lda		$C81C
	beq		joy_done
	bmi		joy_down
	
joy_up:
	lda		joyPosition
	cmpa		#2
	bne		joy_up_check_2
	
	;; Up and Left
	lda		#1
	sta		joyPosition
	bra		joy_done

joy_up_check_2:
	cmpa		#6
	bne		joy_up_only

	;; Up and Right
	lda		#7
	sta		joyPosition
	bra		joy_done	
	
joy_up_only:
	lda		#0
	sta		joyPosition
	bra		joy_done
	
joy_down:
	lda		joyPosition
	cmpa		#2
	bne		joy_down_check_2
	
	;; Down and Left
	lda		#3
	sta		joyPosition
	bra		joy_done

joy_down_check_2:
	cmpa		#6
	bne		joy_down_only

	;; Down and Right
	lda		#5
	sta		joyPosition
	bra		joy_done	

joy_down_only:	
	lda		#4
	sta		joyPosition

joy_done:
	
	clr		receptorMask
	
	;; All buttons no debounce
	lda		#$00
	jsr		Read_Btns_Mask

check_b1:
	lda		$C811
	anda		#$01
	beq		check_b2	

	;; Show Receptor 1
	lda		#1
	ora		receptorMask
	sta		receptorMask
	
	;; Get the lane direction to match 90 or 45 degrees
	lda		laneDirs + 0
	anda		#1
	sta		tempB1
	lda		joyPosition
	anda		#1
	eora		tempB1
	bne		check_b2

	;; 45 or 90 match, put it down
	;; Add the matcher - if there isn't one already
	lda		matchers + 0
	bge		check_b2
	lda		joyPosition
	sta		matchers + 0
	
check_b2:	
	lda		$C811
	anda		#$02
	beq		check_b3	

	;; Show Receptor 2
	lda		#2
	ora		receptorMask
	sta		receptorMask

	;; Get the lane direction to match 90 or 45 degrees
	lda		laneDirs + 1
	anda		#1
	sta		tempB1
	lda		joyPosition
	anda		#1
	eora		tempB1
	bne		check_b3

	;; 45 or 90 match, put it down
	;; Add the matcher - if there isn't one already
	lda		matchers + 1
	bge		check_b3
	lda		joyPosition
	sta		matchers + 1

check_b3:	
	lda		$C811
	anda		#$04
	beq		check_b4	

	;; Show Receptor 3
	lda		#4
	ora		receptorMask
	sta		receptorMask

	;; Get the lane direction to match 90 or 45 degrees
	lda		laneDirs + 2
	anda		#1
	sta		tempB1
	lda		joyPosition
	anda		#1
	eora		tempB1
	bne		check_b4

	;; 45 or 90 match, put it down
	;; Add the matcher - if there isn't one already
	lda		matchers + 2
	bge		check_b4
	lda		joyPosition
	sta		matchers + 2

check_b4:	
	lda		$C811
	anda		#$08
	beq		buttons_done	

	;; Show Receptor 4
	lda		#8
	ora		receptorMask
	sta		receptorMask

	;; Get the lane direction to match 90 or 45 degrees
	lda		laneDirs + 3
	anda		#1
	sta		tempB1
	lda		joyPosition
	anda		#1
	eora		tempB1
	bne		buttons_done

	;; 45 or 90 match, put it down
	;; Add the matcher - if there isn't one already
	lda		matchers + 3
	bge		buttons_done
	lda		joyPosition
	sta		matchers + 3
	
buttons_done:
	rts


	
Load_level:
	lda		#$FF
	sta		matchers + 0
	sta		matchers + 1
	sta		matchers + 2
	sta		matchers + 3
	
	lda		gameLevel
	asla

	ldx		#game_levels
	ldx		a, x
	stx		levelPtr
	
	lda		#GLEVEL_OFF_TSPEED
	lda		a, x
	sta		moveFrame

	lda		#GLEVEL_OFF_MISTAKES
	lda		a, x
	sta		mistakesLeft
	
	lda		#GLEVEL_OFF_LANES
	ldx		a, x
	jsr		Load_lanes	

	lda		#0
	ldb		#0
	jsr		Add_token
	lda		#1
	sta		nextTokenLane
	
	lda		#0
	sta		tokenAddDelay
	sta		matchCount
	lda		#1
	sta		tokenCount

	rts

Screen_select:

	ldx		#lanes_select
	jsr		Load_lanes

	;; Make sure that we do not show matchers
	lda		#$FF
	sta		matchers + 0
	sta		matchers + 1
	sta		matchers + 2
	sta		matchers + 3

    lda     #128                    
	sta		VIA_t1_cnt_lo  

	jsr		Draw_lanes
	
	lda		#$7F
	INTENSITY_A_MACRO
;	jsr		Intensity_7F

	RESET0REF_MACRO
	ldd		#$0000
	MOVETOD_MACRO
	
	ldu		#select_play_str
	lda		#52
	ldb		#-40
	jsr		Print_Str_d

	ldu		#select_code_str
	lda		#20
	ldb		#-40
	jsr		Print_Str_d

	ldu		#select_challenge_str
	lda		#-13
	ldb		#-40
	jsr		Print_Str_d
	
	ldu		#select_help_str
	lda		#-62
	ldb		#-40
	jsr		Print_Str_d

	RESET0REF_MACRO
	ldd		#$60D0
	MOVETOD_MACRO
	
	ldx		#malleus_vector_list_1
	jsr		Draw_VL_mode

	RESET0REF_MACRO
	ldd		#$60D0
	MOVETOD_MACRO
	
	ldx		#malleus_vector_list_2
	jsr		Draw_VL_mode

	RESET0REF_MACRO
	ldd		#$60D0
	MOVETOD_MACRO
	
	ldx		#malleus_vector_list_3
	jsr		Draw_VL_mode

	jsr		Draw_receptors
	
	
	clr		receptorMask
	
	;; All buttons no debounce
	lda		#$00
	jsr		Read_Btns_Mask

select_check_b1:
	lda		$C811
	anda		#$01
	beq		select_check_b2	

	;; Show Receptor 1
	lda		#1
	ora		receptorMask
	sta		receptorMask
	bra		select_buttons_done

select_check_b2:
	lda		$C811
	anda		#$02
	beq		select_check_b3	

	;; Show Receptor 2
	lda		#2
	ora		receptorMask
	sta		receptorMask
	bra		select_buttons_done

select_check_b3:
	lda		$C811
	anda		#$04
	beq		select_check_b4	

	;; Show Receptor 3
	lda		#4
	ora		receptorMask
	sta		receptorMask
	bra		select_buttons_done
	
select_check_b4:	
	lda		$C811
	anda		#$08
	beq		select_buttons_done	

	;; Show Receptor 4
	lda		#8
	ora		receptorMask
	sta		receptorMask
	
select_buttons_done:	

	;; Check the joystick
	jsr		Joy_Digital

	; Joystick 1 X direction
	lda		$C81B
	beq		select_no_joy_x

	bra		select_joy_pressed
	
select_no_joy_x:
	; Joystick 1 Y direction
	lda		$C81C
	lbeq		select_joy_done

select_joy_pressed:
	
	;; We are leaving the selection screen
	lda		receptorMask
	cmpa		#1
	lbne		select_check_2

	;; stop the music
	ldd		#0
	std		chanASong
	std		chanBSong
	std		chanCSong

	ldb		#0
	SET_VOLUME CHANNEL_A
	ldb		#0
	SET_VOLUME CHANNEL_B
	ldb		#0
	SET_VOLUME CHANNEL_C

	;; Need to wait for the button to get released
	jsr		Wait_for_buttons_release

	lda		#0
	sta		gameLevel
	
	jsr		Load_level
	
	lda		#SCREEN_GAME
	sta		screen

select_check_2:	
	cmpa		#2
	bne		select_check_3

	;; Need to wait for the button to get released
	jsr		Wait_for_buttons_release
	
	lda		#SCREEN_CODE
	sta		screen

select_check_3:	
	cmpa		#4
	bne		select_check_4
	
;	lda		#SCREEN_GAME
;	sta		screen

select_check_4:	
	cmpa		#8
	bne		select_joy_done
	
	lda		#SCREEN_HELP
	sta		screen
	
	
select_joy_done:
	
	lbra		main_loop_bottom
	
	
Screen_help:

	;; Since the framerate is bad due to the strings
	;; stop the music
	ldb		#0
	SET_VOLUME CHANNEL_A
	ldb		#0
	SET_VOLUME CHANNEL_B
	ldb		#0
	SET_VOLUME CHANNEL_C


	ldx		#lanes_select
	jsr		Load_lanes

	lda		#$4C
	sta		laneCoords
	lda		#4
	sta		laneDirs
	
	lda		#1
	sta		receptorMask
	
	lda		#6
	sta		joyPosition
	
    lda     #128                    
	sta		VIA_t1_cnt_lo  


	RESET0REF_MACRO
	ldd		#$0000
	MOVETOD_MACRO

	ldu		#select_help_str
	lda		#$70
	ldb		#$E0
	jsr		Print_Str_d

	lda		laneCoords
	ldb		laneDirs
	jsr		Draw_lane	
		
	lda		#$5F
	INTENSITY_A_MACRO
	ldu		#help_lane_str
	lda		#42
	ldb		#5
	jsr		Print_Str_d

	RESET0REF_MACRO
    lda     #128                    
	sta		VIA_t1_cnt_lo  
		
	lda		#$30
	ldb		#$C0
	MOVETOD_MACRO
	
    lda     #40             
    sta     VIA_t1_cnt_lo	

	ldx		#token_base_2
	lda		#TOKEN_VECTOR_LEN - 1
	jsr		Draw_VL_a

	lda		#$5F
	INTENSITY_A_MACRO
	ldu		#help_token_str
	lda		#3
	ldb		#-43
	jsr		Print_Str_d

	
	jsr		Draw_receptors

	lda		#$5F
	INTENSITY_A_MACRO
	ldu		#help_receptor_str
	lda		#35
	ldb		#$E0
	jsr		Print_Str_d

	jsr		Draw_matcher

	lda		#$5F
	INTENSITY_A_MACRO
	ldu		#help_matcher_str
	lda		#0
	ldb		#0
	jsr		Print_Str_d

	RESET0REF_MACRO
    lda     #128                    
	sta		VIA_t1_cnt_lo  
		
	lda		#$30
	ldb		#$F0
	MOVETOD_MACRO

	ldu		#help_desc_0_str
	lda		#0
	ldb		#0
	jsr		Print_Str_d
	
	ldu		#help_desc_1_str
	lda		#$20
	ldb		#$F0
	jsr		Print_Str_d
	
	ldu		#help_desc_2_str
	lda		#$10
	ldb		#$F0
	jsr		Print_Str_d
	
	ldu		#help_desc_3_str
	lda		#$00
	ldb		#$F0
	jsr		Print_Str_d
	
	RESET0REF_MACRO
    lda     #128                    
	sta		VIA_t1_cnt_lo  
		
	lda		#-5
	ldb		#$50
	MOVETOD_MACRO
	
    lda     #40             
    sta     VIA_t1_cnt_lo	

	ldx		#token_base_2
	lda		#TOKEN_VECTOR_LEN - 1
	jsr		Draw_VL_a

	lda		#0
	ldb		#28
	MOVETOD_MACRO

	ldx		#token_base_6
	lda		#TOKEN_VECTOR_LEN - 1
	jsr		Draw_VL_a

	lda		#$FF
	jsr		Read_Btns_Mask

	lda		$C811
	anda		#$0F
	beq		screen_help_done	

	lda		#SCREEN_SELECT
	sta		screen
	
	;; Play the intro music
	SET_SONG_A song_intro_1, adsr_fade
	SET_SONG_B song_intro_2, adsr_fade
	SET_SONG_C song_intro_3, adsr_fade

	
screen_help_done:
		
	lbra		main_loop_bottom

	
Screen_enter_code:
	ldx		#lanes_enter_code
	jsr		Load_lanes

    lda     #128                    
	sta		VIA_t1_cnt_lo  

;;	jsr		Draw_lanes
	
	lda		#$3F
	INTENSITY_A_MACRO
	
	;; Lanes
	RESET0REF_MACRO
    lda     #128                    
	sta		VIA_t1_cnt_lo  

	lda		#$00
	ldb		#$D0
	MOVETOD_MACRO

    lda     #40              
    sta     VIA_t1_cnt_lo	
	ldx		#enter_code_box_vector_list
	jsr		Draw_VL_mode
	
	;; 2
	RESET0REF_MACRO
    lda     #128                    
	sta		VIA_t1_cnt_lo  

	lda		#$00
	ldb		#$F0
	MOVETOD_MACRO

    lda     #40              
    sta     VIA_t1_cnt_lo	
	ldx		#enter_code_box_vector_list
	jsr		Draw_VL_mode
	
	;; 3
	RESET0REF_MACRO
    lda     #128                    
	sta		VIA_t1_cnt_lo  

	lda		#$00
	ldb		#$10
	MOVETOD_MACRO

    lda     #40              
    sta     VIA_t1_cnt_lo	
	ldx		#enter_code_box_vector_list
	jsr		Draw_VL_mode
	
	;; 3
	RESET0REF_MACRO
    lda     #128                    
	sta		VIA_t1_cnt_lo  

	lda		#$00
	ldb		#$30
	MOVETOD_MACRO

    lda     #40              
    sta     VIA_t1_cnt_lo	
	ldx		#enter_code_box_vector_list
	jsr		Draw_VL_mode

	;; Big 1
	RESET0REF_MACRO
    lda     #128                    
	sta		VIA_t1_cnt_lo  

	lda		#$00
	ldb		#$E0
	MOVETOD_MACRO
	
	ldx		#enter_code_box_vector_list
	jsr		Draw_VL_mode

	;; Big 2
	RESET0REF_MACRO
    lda     #128                    
	sta		VIA_t1_cnt_lo  

	lda		#$00
	ldb		#$00
	MOVETOD_MACRO
	
	ldx		#enter_code_box_vector_list
	jsr		Draw_VL_mode

	;; Big 3
	RESET0REF_MACRO
    lda     #128                    
	sta		VIA_t1_cnt_lo  

	lda		#$00
	ldb		#$20
	MOVETOD_MACRO
	
	ldx		#enter_code_box_vector_list
	jsr		Draw_VL_mode
	
	jsr		Handle_controls

	jsr		Draw_matcher
	jsr		Draw_receptors	

	lda		#$FF
	cmpa		matchers + 0
	lbeq		screen_enter_code_done

	cmpa		matchers + 1
	lbeq		screen_enter_code_done

	cmpa		matchers + 2
	lbeq		screen_enter_code_done

	cmpa		matchers + 3
	lbeq		screen_enter_code_done
	
	;; All four matchers are set - compare against the codes
	lda		#0
	sta		loopI

code_check_loop:
	;; Get an offset into the codes array (4 * loopI)
	lda		loopI
	asla
	asla
	sta		tempB1

	ldx		#level_codes

	;; Make the four compares
	ldb		a, x
	cmpb		matchers + 0
	bne		no_code_match

	inca
	
	;; Make the four compares
	ldb		a, x
	cmpb		matchers + 1
	bne		no_code_match

	inca
	
	;; Make the four compares
	ldb		a, x
	cmpb		matchers + 2
	bne		no_code_match
	
	inca
	
	;; Make the four compares
	ldb		a, x
	cmpb		matchers + 3
	bne		no_code_match
	
	;; Code Matched!
	;; Do a little cleanup
	lda		#$FF
	sta		matchers + 0
	sta		matchers + 1
	sta		matchers + 2
	sta		matchers + 3
	
	;; Go to the right game level
	;; It is (loopI + 1) * 4 
	lda		loopI
	inca
	lsla
	lsla
	sta		gameLevel

	jsr		Wait_for_buttons_release

	jsr		Load_level
	
	lda		#SCREEN_GAME
	sta		screen
	bra		screen_enter_code_done
	
	
no_code_match:
	;; Go for the next code
	inc		loopI
	lda		loopI
	cmpa		#NUM_CODES
	bne		code_check_loop


	;; Code did not match - get out
	jsr		Wait_for_buttons_release
	lda		#SCREEN_SELECT
	sta		screen

	;; Play the intro music
	SET_SONG_A song_intro_1, adsr_fade
	SET_SONG_B song_intro_2, adsr_fade
	SET_SONG_C song_intro_3, adsr_fade


	
screen_enter_code_done:
	lbra		main_loop_bottom
	
Screen_win:
	
    lda     #128                    
	sta		VIA_t1_cnt_lo  

	lda		#$7F
	INTENSITY_A_MACRO
;	jsr		Intensity_7F

	RESET0REF_MACRO
	ldb		#$00
	lda		#19
	suba		gameLevel
	MOVETOD_MACRO
	ldx		#token_base_0
	lda		#TOKEN_VECTOR_LEN - 1
	jsr		Draw_VL_a

	RESET0REF_MACRO
	lda		#$00
	ldb		#-19
	addb		gameLevel
	MOVETOD_MACRO
	ldx		#token_base_2
	lda		#TOKEN_VECTOR_LEN - 1
	jsr		Draw_VL_a

	RESET0REF_MACRO
	ldb		#$00
	lda		#-19
	adda		gameLevel
	MOVETOD_MACRO
	ldx		#token_base_4
	lda		#TOKEN_VECTOR_LEN - 1
	jsr		Draw_VL_a

	RESET0REF_MACRO
	lda		#$00
	ldb		#19
	subb		gameLevel
	MOVETOD_MACRO
	ldx		#token_base_6
	lda		#TOKEN_VECTOR_LEN - 1
	jsr		Draw_VL_a
	
	lda		#$3F
	INTENSITY_A_MACRO
;	jsr		Intensity_3F

	jsr		Draw_lanes
	jsr		Draw_score
	
	;; If we are on a mod 4 = 0 level, we need to give a code
	lda		gameLevel
	inca
	sta		tempB1
	anda		#3
	lbne     win_check_buttons
	
	;; Gamelevel + 1 can be used as the index into the code array
	;; Just need to subtract 4
	lda		tempB1
	suba		#4
	sta		tempB1

	lda		#$5F
	INTENSITY_A_MACRO

    lda     #128                    
	sta		VIA_t1_cnt_lo  

	RESET0REF_MACRO
	ldd		#$A0D0
	MOVETOD_MACRO

	lda     #40             
    sta     VIA_t1_cnt_lo	

	lda		tempB1
	
	ldy		#level_codes
	lda		a, y

	ldy		#token_base
	asla
	ldx		a, y
	lda		#TOKEN_VECTOR_LEN - 1
	jsr		Draw_VL_a

	
	lda     #128                    
	sta		VIA_t1_cnt_lo  

	RESET0REF_MACRO
	ldd		#$A0F0
	MOVETOD_MACRO

	lda     #40             
    sta     VIA_t1_cnt_lo	

	inc		tempB1
	lda		tempB1
	
	ldy		#level_codes
	lda		a, y
	
	ldy		#token_base
	asla
	ldx		a, y
	lda		#TOKEN_VECTOR_LEN - 1
	jsr		Draw_VL_a

	lda     #128                    
	sta		VIA_t1_cnt_lo  

	RESET0REF_MACRO
	ldd		#$A010
	MOVETOD_MACRO

	lda     #40             
    sta     VIA_t1_cnt_lo	

	inc		tempB1
	lda		tempB1
	
	ldy		#level_codes
	lda		a, y
	
	ldy		#token_base
	asla
	ldx		a, y
	lda		#TOKEN_VECTOR_LEN - 1
	jsr		Draw_VL_a

	lda     #128                    
	sta		VIA_t1_cnt_lo  

	RESET0REF_MACRO
	ldd		#$A030
	MOVETOD_MACRO

	lda     #40             
    sta     VIA_t1_cnt_lo	

	inc		tempB1
	lda		tempB1
	
	ldy		#level_codes
	lda		a, y
	
	ldy		#token_base
	asla
	ldx		a, y
	lda		#TOKEN_VECTOR_LEN - 1
	jsr		Draw_VL_a
	
win_check_buttons:	
	lda		#$FF
	jsr		Read_Btns_Mask

	lda		$C811
	anda		#$0F
	beq		screen_win_done	

	;; Load level X + 1
	inc		gameLevel
	jsr		Load_level
	
	lda		#SCREEN_GAME
	sta		screen
	

	
screen_win_done:
	
	lbra		main_loop_bottom
	
Screen_loss:
	
    lda     #128                    
	sta		VIA_t1_cnt_lo  

	lda		#$7F
	INTENSITY_A_MACRO
;	jsr		Intensity_7F

	RESET0REF_MACRO
	ldd		#$10F0
	MOVETOD_MACRO
	ldx		#token_base_0
	lda		#TOKEN_VECTOR_LEN - 1
	jsr		Draw_VL_a

	RESET0REF_MACRO
	ldd		#$0000
	MOVETOD_MACRO
	ldx		#token_base_2
	lda		#TOKEN_VECTOR_LEN - 1
	jsr		Draw_VL_a

	RESET0REF_MACRO
	ldd		#$F010
	MOVETOD_MACRO
	ldx		#token_base_4
	lda		#TOKEN_VECTOR_LEN - 1
	jsr		Draw_VL_a


;	ldu		#level_complete_str
;	lda		#20
;	ldb		#-50
;	jsr		Print_Str_d

	lda		#$3F
	INTENSITY_A_MACRO
;	jsr		Intensity_3F

	jsr		Draw_lanes
	jsr		Draw_score
	
	lda		#$FF
	jsr		Read_Btns_Mask

	lda		$C811
	anda		#$0F
	beq		screen_loss_done	

	;; Go back to selection

	lda		#SCREEN_SELECT
	sta		screen

	;; Play the intro music
	SET_SONG_A song_intro_1, adsr_fade
	SET_SONG_B song_intro_2, adsr_fade
	SET_SONG_C song_intro_3, adsr_fade

	
	
screen_loss_done:

	lbra		main_loop_bottom

Wait_for_buttons_release:
	lda		#$00
	jsr		Read_Btns_Mask
	lda		$C811
	anda		#$0F
	bne		Wait_for_buttons_release	
	
	rts	
	
	
Token_add_check:
	;; Do we still need to add tokens?
	ldx		levelPtr
	lda		#GLEVEL_OFF_TOKENMAX
	lda		a, x	
	cmpa		tokenCount
	
	ble		no_more_tokens
	
	;; Is it time to add one?
	inc		tokenAddDelay

	lda		#GLEVEL_OFF_TDELAY
	lda		a, x
	cmpa		tokenAddDelay
	
	bgt		no_more_tokens
	
	;; Ok, we are adding one, clear the delay
	clr		tokenAddDelay
	
	lda		tokenCount
	ldb		nextTokenLane
	
	jsr		Add_token
	
	inc		tokenCount
	lda		nextTokenLane
	inca
	anda		#$3
	sta		nextTokenLane
	
no_more_tokens:
	
	rts

	
Draw_matcher:
	lda		joyPosition
	bmi		no_matcher
	
	lda		#$5F
	INTENSITY_A_MACRO
	
	RESET0REF_MACRO
    lda     #128                    
	sta		VIA_t1_cnt_lo  
	
	lda		#-115
	ldb		#0
	MOVETOD_MACRO
	
    lda     #40             
    sta     VIA_t1_cnt_lo	

	ldy		#token_base
	lda		joyPosition
	anda		#$0F
	asla
	ldx		a, y
	lda		#TOKEN_VECTOR_LEN - 1
	jsr		Draw_VL_a

no_matcher:
	rts
	

Add_token:
	;;  a - the token Index
	;;  b - the lane to add to
		
	;; Find the right token data storage
	ldx		#token_data_ptr
	asla
	ldx		a, x
	
	;; Lane is 0-3, save it
	andb		#3
	stb		tempB3
	aslb
	aslb
	aslb
	aslb
	stb		tempB2
	ldb		tempB3
		
	ldy		#laneCoords
	ldb		b, y

	stb		tempB1
	andb		#$F0
	stb		TDATA_OFF_Y, x
	
	ldb		tempB1
	andb		#$0F
	aslb
	aslb
	aslb
	aslb
	stb		TDATA_OFF_X, x
	
	ldb		tempB3
	ldy		#laneDirs
	ldb		b, y
	stb		tempB1
	
	ldy		#dir_to_velo
	ldb		b, y
	stb		TDATA_OFF_VELO, x
	
	;; Need an orientation for the token
	lda		tempB1
	anda		#1
	bne		token_ori_45
	
token_ori_90:
	RAND_MACRO
	anda		#$3
	asla
	ora		tempB2
	sta		TDATA_OFF_ORI_LANE, x
	bra		token_ori_done
	
token_ori_45:
	RAND_MACRO
	anda		#$3
	asla
	ora		#1
	ora		tempB2	
	sta		TDATA_OFF_ORI_LANE, x

token_ori_done:
	lda		#0
	sta		TDATA_OFF_DIST, x

	rts
	

Draw_tokens:
	lda		#$5F
	INTENSITY_A_MACRO
;	jsr		Intensity_5F
	
	lda		#0
	sta		loopI
	
draw_tokens_loop:
	
	RESET0REF_MACRO
    lda     #128                    
	sta		VIA_t1_cnt_lo  
	
	;; Find the right token data storage
	ldx		#token_data_ptr
	lda		loopI
	asla
	ldx		a, x
	
	lda		TDATA_OFF_Y, x
	ldb		TDATA_OFF_X, x
	MOVETOD_MACRO
	
    lda     #40             
    sta     VIA_t1_cnt_lo	

	ldy		#token_base
	lda		TDATA_OFF_ORI_LANE, x
	
	sta		tempB1
	
	anda		#$0F
	asla
	ldx		a, y
	lda		#TOKEN_VECTOR_LEN - 1
	jsr		Draw_VL_a
	
	inc		loopI
	lda		loopI
	cmpa		tokenCount
	blt		draw_tokens_loop
	
	rts
	
Draw_score:
	
	lda		#$5F
	INTENSITY_A_MACRO
	
	ldx		levelPtr
	lda		#GLEVEL_OFF_MNEEDED
	lda		a, x
	sta		tempB1
	nega		
	sta		tempB2

	RESET0REF_MACRO
    lda     #128                    
	sta		VIA_t1_cnt_lo  
		
	lda		#110
	ldb		#0
	MOVETOD_MACRO
	
    lda     #24             
    sta     VIA_t1_cnt_lo	
	
	lda		#0
	ldb		tempB1
	MOVETOD_MACRO
	lda		#0
	ldb		tempB1
	MOVETOD_MACRO
	lda		#0
	ldb		tempB1
	MOVETOD_MACRO
	lda		#0
	ldb		tempB1
	MOVETOD_MACRO

	ldx		#token_base_6
	lda		#TOKEN_VECTOR_LEN - 1
	jsr		Draw_VL_a

	RESET0REF_MACRO
    lda     #128                    
	sta		VIA_t1_cnt_lo  
		
	lda		#110
	ldb		#0
	MOVETOD_MACRO
	
    lda     #24             
    sta     VIA_t1_cnt_lo	
	
	lda		#0
	ldb		tempB2
	MOVETOD_MACRO
	lda		#0
	ldb		tempB2
	MOVETOD_MACRO
	lda		#0
	ldb		tempB2
	MOVETOD_MACRO
	lda		#0
	ldb		tempB2
	MOVETOD_MACRO

	ldx		#token_base_2
	lda		#TOKEN_VECTOR_LEN - 1
	jsr		Draw_VL_a


	RESET0REF_MACRO
    lda     #128                    
	sta		VIA_t1_cnt_lo  
		
	lda		#110
	ldb		#0
	MOVETOD_MACRO

	lda		matchCount
	sta		tempB1
	
    lda     #24             
    sta     VIA_t1_cnt_lo	
	
	lda		#0
	ldb		tempB1
	jsr		Draw_Line_d
	lda		#0
	ldb		tempB1
	jsr		Draw_Line_d
	lda		#0
	ldb		tempB1
	jsr		Draw_Line_d
	lda		#0
	ldb		tempB1
	jsr		Draw_Line_d
	
	RESET0REF_MACRO
    lda     #128                    
	sta		VIA_t1_cnt_lo  
		
	lda		#110
	ldb		#0
	MOVETOD_MACRO

	lda		matchCount
	nega
	sta		tempB1
	
    lda     #24             
    sta     VIA_t1_cnt_lo	
	
	lda		#0
	ldb		tempB1
	jsr		Draw_Line_d
	lda		#0
	ldb		tempB1
	jsr		Draw_Line_d
	lda		#0
	ldb		tempB1
	jsr		Draw_Line_d
	lda		#0
	ldb		tempB1
	jsr		Draw_Line_d
		
	RESET0REF_MACRO
    lda     #128                    
	sta		VIA_t1_cnt_lo  
		
	lda		#100
	ldb		#0
	MOVETOD_MACRO
	
    lda     #24             
    sta     VIA_t1_cnt_lo	
	
	lda		mistakesLeft
	nega
	sta		tempB1

	lda		#0
	ldb		tempB1
	jsr		Draw_Line_d
	lda		#0
	ldb		tempB1
	jsr		Draw_Line_d
	lda		#0
	ldb		tempB1
	jsr		Draw_Line_d
	lda		#0
	ldb		tempB1
	jsr		Draw_Line_d
	lda		#0
	ldb		tempB1
	jsr		Draw_Line_d
	lda		#0
	ldb		tempB1
	jsr		Draw_Line_d
	lda		#0
	ldb		tempB1
	jsr		Draw_Line_d
	lda		#0
	ldb		tempB1
	jsr		Draw_Line_d

	ldx		#token_base_6
	lda		#TOKEN_VECTOR_LEN - 1
	jsr		Draw_VL_a

	RESET0REF_MACRO
    lda     #128                    
	sta		VIA_t1_cnt_lo  
		
	lda		#100
	ldb		#0
	MOVETOD_MACRO
	
    lda     #24             
    sta     VIA_t1_cnt_lo	

	lda		mistakesLeft
	sta		tempB1

	lda		#0
	ldb		tempB1
	jsr		Draw_Line_d
	lda		#0
	ldb		tempB1
	jsr		Draw_Line_d
	lda		#0
	ldb		tempB1
	jsr		Draw_Line_d
	lda		#0
	ldb		tempB1
	jsr		Draw_Line_d
	lda		#0
	ldb		tempB1
	jsr		Draw_Line_d
	lda		#0
	ldb		tempB1
	jsr		Draw_Line_d
	lda		#0
	ldb		tempB1
	jsr		Draw_Line_d
	lda		#0
	ldb		tempB1
	jsr		Draw_Line_d

	ldx		#token_base_2
	lda		#TOKEN_VECTOR_LEN - 1
	jsr		Draw_VL_a
	
	rts
	
Check_win_loss:
	ldx		levelPtr
	lda		#GLEVEL_OFF_MNEEDED
	lda		a, x
	cmpa		matchCount
	ble		level_complete
	
	lda		#0
	cmpa		mistakesLeft
	lblt		win_loss_done
	
level_lost:

	jsr		Wait_for_buttons_release

	;; Play the loss accords
	SET_SONG_A song_loss_1, adsr_fade
	SET_SONG_B song_loss_2, adsr_fade
	SET_SONG_C song_loss_3, adsr_fade
	
	lda		#SCREEN_LOSS
	sta		screen

	bra		win_loss_done
	
level_complete:

	jsr		Wait_for_buttons_release

	;; Play the win accords
	SET_SONG_A song_win_1, adsr_fade
	SET_SONG_B song_win_2, adsr_fade
	SET_SONG_C song_win_3, adsr_fade
	
	lda		#SCREEN_WIN
	sta		screen

win_loss_done:
	rts
	
	
Move_tokens:	

	lda		#0
	sta		loopI

move_tokens_loop:
	;; Find the right token data storage
	ldx		#token_data_ptr
	lda		loopI
	asla
	ldx		a, x

	lda		TDATA_OFF_VELO, x
	anda		#$F0
	lsra
	lsra
	lsra
	lsra
	sta		tempB1
	ldb		tempB1
	andb		#$08
	bne		token_move_y_neg
	
token_move_y_pos:
	lda		tempB1
	adda		TDATA_OFF_Y, x
	sta		TDATA_OFF_Y, x
	bra		token_move_x
	
token_move_y_neg:
	lda		tempB1
	anda		#$7
	nega
	adda		TDATA_OFF_Y, x
	sta		TDATA_OFF_Y, x
	
token_move_x:
	lda		TDATA_OFF_VELO, x
	anda		#$0F
	sta		tempB1
	ldb		tempB1
	andb		#$08
	bne		token_move_x_neg
	
token_move_x_pos:
	lda		tempB1
	adda		TDATA_OFF_X, x
	sta		TDATA_OFF_X, x
	bra		token_move_xy_done
	
token_move_x_neg:
	lda		tempB1
	anda		#$7
	nega
	adda		TDATA_OFF_X, x
	sta		TDATA_OFF_X, x
	
token_move_xy_done:
	inc		TDATA_OFF_DIST, x

	inc		loopI
	lda		loopI
	cmpa		tokenCount
	blt		move_tokens_loop

	rts

Check_tokens_hit:
	lda		#0
	sta		loopI

check_tokens_loop:
	;; Find the right token data storage
	ldx		#token_data_ptr
	lda		loopI
	asla
	ldx		a, x

	lda		TDATA_OFF_DIST, x
	cmpa		#$50
	lbne		token_ok
		
	;; At the end of a lane!
	;; Save the orientation of the token
	ldb		TDATA_OFF_ORI_LANE, x
	andb		#$0F
	stb		tempB1
	
	;; Then recover the lane
	ldb		TDATA_OFF_ORI_LANE, x
	andb		#$F0
	lsrb
	lsrb
	lsrb
	lsrb

	;; Check the matcher match
	
	;; Get the opposite position for the token
	ldy		#matcher_match_positions
	lda		tempB1
	lda		a, y
	sta		tempB2

	;; Get the matcher position
	ldy		#matchers
	lda		b, y
	cmpa		tempB2
	beq		token_matched
	
token_not_matched:
	stb		tempB3

	SET_SONG_A song_mismatch_1, adsr_fade
	SET_SONG_B song_mismatch_2, adsr_fade
	SET_SONG_C song_mismatch_3, adsr_fade

	dec		mistakesLeft

	ldb		tempB3
	bra		remove_matcher

token_matched:

	stb		tempB3

	SET_SONG_A song_match_1, adsr_fade
	SET_SONG_B song_match_2, adsr_fade
	SET_SONG_C song_match_3, adsr_fade

	inc		matchCount
	
	ldb		tempB3
	
remove_matcher:
	;; Remove the matcher
	;; Store a < 0 number for the matcher
	lda		#$FF
	sta		b, y
	
	;; Add back in the same lane
	lda		loopI
	;; b already has the lane
	jsr		Add_token
	
token_ok:

	inc		loopI
	lda		loopI
	cmpa		tokenCount
	blt		check_tokens_loop

	rts

Draw_receptors:
	lda		receptorMask
	sta		tempB1
	lda		#0
	sta		loopI
	
draw_receptors_loop:

	lda		loopI
	ldx		#laneCoords
	ldb		a, x
	stb		tempB2
	
	lda		#$7F
	INTENSITY_A_MACRO
;	jsr		Intensity_7F
	
	RESET0REF_MACRO
    lda     #128                    
	sta		VIA_t1_cnt_lo  
	
	ldb		tempB2
	andb		#$0F
	aslb
	aslb
	aslb
	aslb
	lda		tempB2
	anda		#$F0
	std		tempW1
		
	ldx		#laneDirs
	lda		loopI
	lda		a, x
	asla
	;; Save this *2 index
	sta		tempB3

	ldx		#lane_endpoints
	ldd		a, x

	adda		tempW1
	addb		tempW1 + 1
	MOVETOD_MACRO
	
    lda     #40             
    sta     VIA_t1_cnt_lo	

	lda		tempB1
	anda		#1
	lbeq		draw_matcher

	lda		tempB3
	ldx		#receptors
	ldx		a, x

	jsr		Draw_VL_mode

draw_matcher:	
	ldx		#matchers
	lda		loopI
	lda		a, x
	bmi		next_receptor

	ldy		#token_base
	anda		#$0F
	asla
	ldx		a, y
	lda		#TOKEN_VECTOR_LEN - 1
	jsr		Draw_VL_a
	
next_receptor:
	lda		tempB1
	lsra
	sta		tempB1

	inc		loopI
	lda		loopI
	cmpa		#4
	blt		draw_receptors_loop
	
draw_no_receptors:	
	rts

	
Draw_receptors2:
	lda		receptorMask
	lbeq		draw_no_receptors
	
	sta		tempB1
	lda		#0
	sta		loopI
	
draw_receptors_loop2:

	lda		tempB1
	anda		#1
	lbeq		next_receptor

	lda		loopI
	ldx		#laneCoords
	ldb		a, x
	stb		tempB2
	
	lda		#$7F
	INTENSITY_A_MACRO
;	jsr		Intensity_7F
	
	RESET0REF_MACRO
    lda     #128                    
	sta		VIA_t1_cnt_lo  
	
	ldb		tempB2
	andb		#$0F
	aslb
	aslb
	aslb
	aslb
	lda		tempB2
	anda		#$F0
	std		tempW1
		
	ldx		#laneDirs
	lda		loopI
	lda		a, x
	asla
	;; Save this *2 index
	sta		tempB3

	ldx		#lane_endpoints
	ldd		a, x

	adda		tempW1
	addb		tempW1 + 1
	MOVETOD_MACRO
	
    lda     #40             
    sta     VIA_t1_cnt_lo	

	lda		tempB3
	ldx		#receptors
	ldx		a, x

	jsr		Draw_VL_mode

	lda		joyPosition
	bmi		next_receptor

	ldy		#token_base
	lda		joyPosition
	anda		#$0F
	asla
	ldx		a, y
	lda		#TOKEN_VECTOR_LEN - 1
	jsr		Draw_VL_a
	
next_receptor2:
	lda		tempB1
	lsra
	sta		tempB1

	inc		loopI
	lda		loopI
	cmpa		#4
	blt		draw_receptors_loop
	
draw_no_receptors2:	
	rts
	
Draw_receptor:
	;; a has the index (0 - 3)
	sta		tempB1

	ldx		#laneCoords
	ldb		a, x
	stb		tempB2
	
	lda		#$7F
	INTENSITY_A_MACRO
;	jsr		Intensity_7F
	
	RESET0REF_MACRO
    lda     #128                    
	sta		VIA_t1_cnt_lo  
	
	ldb		tempB2
	andb		#$0F
	aslb
	aslb
	aslb
	aslb
	lda		tempB2
	anda		#$F0
	std		tempW1
		
	ldx		#laneDirs
	lda		tempB1
	lda		a, x
	asla
	;; Save this *2 index
	sta		tempB3

	ldx		#lane_endpoints
	ldd		a, x

	adda		tempW1
	addb		tempW1 + 1
	MOVETOD_MACRO
	
    lda     #40             
    sta     VIA_t1_cnt_lo	

	lda		tempB3
	ldx		#receptors
	ldx		a, x

	jsr		Draw_VL_mode
	
	rts
	
Load_lanes:
	;; x has the level object
	
	;; First 4 bytes are the lane coords
	lda		0, x
	sta		laneCoords + 0
	lda		1, x
	sta		laneCoords + 1
	lda		2, x
	sta		laneCoords + 2
	lda		3, x
	sta		laneCoords + 3
	
	;; Next four bytes are the directions
	lda		4, x
	sta		laneDirs + 0
	lda		5, x
	sta		laneDirs + 1
	lda		6, x
	sta		laneDirs + 2
	lda		7, x
	sta		laneDirs + 3
	
	rts

	
Draw_lanes:
	lda		laneCoords
	ldb		laneDirs
	jsr		Draw_lane

	lda		laneCoords + 1
	ldb		laneDirs + 1
	jsr		Draw_lane

	lda		laneCoords + 2
	ldb		laneDirs + 2
	jsr		Draw_lane

	lda		laneCoords + 3
	ldb		laneDirs + 3
	jsr		Draw_lane

	rts
	
	
Draw_lane:
	;; a has the position
	;; b has the direction (0 - 7)
	sta		tempB1
	aslb
	stb		tempB2
	ldx		#lanes
	ldx		b, x
	
	lda		#$3F
	INTENSITY_A_MACRO
;	jsr		Intensity_3F
	
	;; Lane
	RESET0REF_MACRO
    lda     #128                    
	sta		VIA_t1_cnt_lo  

	ldb		tempB1
	andb		#$0F
	aslb
	aslb
	aslb
	aslb
	lda		tempB1
	anda		#$F0
	std		tempW1
	MOVETOD_MACRO

    lda     #40              
    sta     VIA_t1_cnt_lo	
	; x already has the list
	jsr		Draw_VL_mode
	
	RESET0REF_MACRO
    lda     #128                    
	sta		VIA_t1_cnt_lo  
	
	ldx		#lane_endpoints
	ldb		tempB2
	ldd		b, x
	adda		tempW1
	addb		tempW1 + 1
	jsr		Dot_d

	rts
	
	
	
All_lanes:	
	lda		#$10
	ldb		#0
	jsr		Draw_lane

	lda		#$1F
	ldb		#1
	jsr		Draw_lane

	lda		#$0F
	ldb		#2
	jsr		Draw_lane

	lda		#$FF
	ldb		#3
	jsr		Draw_lane

	lda		#$F0
	ldb		#4
	jsr		Draw_lane

	lda		#$F1
	ldb		#5
	jsr		Draw_lane

	lda		#$01
	ldb		#6
	jsr		Draw_lane

	lda		#$11
	ldb		#7
	jsr		Draw_lane

	rts
	

Play_sounds:
	
play_channel_a:

	ldx		chanASong
	lbeq		play_channel_b
	
	
	ldd		chanAIndex
	ldb		d, x

continue_channel_a:
	SET_FREQ CHANNEL_A

	ldx		#adsr_index_table
	lda		chanANoteLength
	lda		a, x
	
	ldx		chanAADSR
	ldx		a, x
	
	ldb		chanANoteDuration
	ldb		b, x
	SET_VOLUME	CHANNEL_A
	

	lda		chanANoteDuration
	inca		
	sta		chanANoteDuration
	cmpa		chanANoteLength
	blt		channel_a_note_keep

	ldd		chanAIndex
	addd		#1
	std		chanAIndex
	
	ldx		chanASong
	ldb		d, x
	
	stb		chanANoteLength
	
	cmpb		#$82					;; Specials start at $80
	bgt		channel_a_normal_note
	
	cmpb		#$80						;; Loop
	bne		channel_a_stop
	
	;; Need to loop
channel_a_loop:

	ldd		#1			
	std		chanAIndex
	
	ldx		chanASong
	lda		, x
	sta		chanANoteLength
	clr		chanANoteDuration

	bra		channel_a_note_keep
	
channel_a_stop:

	ldd		#0
	std		chanAIndex
	std		chanASong
	
	SET_VOLUME CHANNEL_A
	
	bra		play_channel_b
	
channel_a_normal_note:	
	clr		chanANoteDuration
	
	ldd		chanAIndex
	addd		#1
	std		chanAIndex

channel_a_note_keep:

	
play_channel_b:	

	ldx		chanBSong
	lbeq		play_channel_c
	
	ldd		chanBIndex
	ldb		d, x

continue_channel_b:
	SET_FREQ CHANNEL_B

	ldx		#adsr_index_table
	lda		chanBNoteLength
	lda		a, x
	
	ldx		chanBADSR
	ldx		a, x
	
	ldb		chanBNoteDuration
	ldb		b, x
	SET_VOLUME	CHANNEL_B
	

	lda		chanBNoteDuration
	inca		
	sta		chanBNoteDuration
	cmpa		chanBNoteLength
	blt		channel_b_note_keep

	ldd		chanBIndex
	addd		#1
	std		chanBIndex
	
	ldx		chanBSong
	ldb		d, x
	
	stb		chanBNoteLength
	
	cmpb		#$82					;; Specials start at $80
	bgt		channel_b_normal_note
	
	cmpb		#$80						;; Loop
	bne		channel_b_stop
	
	;; Need to loop
channel_b_loop:

	ldd		#1			
	std		chanBIndex
	
	ldx		chanBSong
	lda		, x
	sta		chanBNoteLength
	clr		chanBNoteDuration

	bra		channel_b_note_keep
	
channel_b_stop:

	ldd		#0
	std		chanBIndex
	std		chanBSong
	
	SET_VOLUME CHANNEL_B
	
	bra		play_channel_c
	
channel_b_normal_note:	
	clr		chanBNoteDuration
	
	ldd		chanBIndex
	addd		#1
	std		chanBIndex

channel_b_note_keep:


play_channel_c:
	
	ldx		chanCSong
	lbeq		play_sound_done
	
	ldd		chanCIndex
	ldb		d, x

continue_channel_c:
	SET_FREQ CHANNEL_C

	ldx		#adsr_index_table
	lda		chanCNoteLength
	lda		a, x
	
	ldx		chanCADSR
	ldx		a, x
	
	ldb		chanCNoteDuration
	ldb		b, x
	SET_VOLUME	CHANNEL_C
	

	lda		chanCNoteDuration
	inca		
	sta		chanCNoteDuration
	cmpa		chanCNoteLength
	blt		channel_c_note_keep

	ldd		chanCIndex
	addd		#1
	std		chanCIndex
	
	ldx		chanCSong
	ldb		d, x
	
	stb		chanCNoteLength
	
	cmpb		#$82					;; Specials start at $80
	bgt		channel_c_normal_note
	
	cmpb		#$80						;; Loop
	bne		channel_c_stop
	
	;; Need to loop
channel_c_loop:

	ldd		#1			
	std		chanCIndex
	
	ldx		chanCSong
	lda		, x
	sta		chanCNoteLength
	clr		chanCNoteDuration

	bra		channel_c_note_keep
	
channel_c_stop:

	ldd		#0
	std		chanCIndex
	std		chanCSong
	
	SET_VOLUME CHANNEL_C
	
	bra		play_sound_done
	
channel_c_normal_note:	
	clr		chanCNoteDuration
	
	ldd		chanCIndex
	addd		#1
	std		chanCIndex

channel_c_note_keep:


play_sound_done:
	rts	
	
;***************************************************************************
; Additional includes
;***************************************************************************
	include "debug.i"
	
	
;***************************************************************************
; Vectors, etc
;***************************************************************************

game_levels:
	dw		game_level_1
	dw		game_level_2
	dw		game_level_3
	dw		game_level_4
	dw		game_level_5
	dw		game_level_6
	dw		game_level_7
	dw		game_level_8
	dw		game_level_9
	dw		game_level_10
	dw		game_level_11
	dw		game_level_12
	dw		game_level_13
	dw		game_level_14
	dw		game_level_15
	dw		game_level_16
	dw		game_level_17
	dw		game_level_18
	dw		game_level_19

	dw		game_level_impossible
	

game_level_1:
	dw		lanes_level_1	;; The lane layout
	db		4				;; Max concurrent token count
	db		20				;; Token add delay
	db		40				;; Matches needed
	db		4				;; Token speed (smaller is faster)
	db		10				;; Mistakes allowed

lanes_level_1:
	;;  The four lanes
	db	$2B, $2E, $22, $25
	;;  The directions
	db	4, 4, 4, 4

game_level_2:
	dw		lanes_level_2	;; The lane layout
	db		4				;; Max concurrent token count
	db		20				;; Token add delay
	db		64				;; Matches needed
	db		4				;; Token speed (smaller is faster)
	db		10				;; Mistakes allowed

lanes_level_2:
	;;  The four lanes
	db	$2B, $EE, $E2, $25
	;;  The directions
	db	4, 0, 0, 4
	
game_level_3:
	dw		lanes_level_3	;; The lane layout
	db		4				;; Max concurrent token count
	db		15				;; Token add delay
	db		64				;; Matches needed
	db		3				;; Token speed (smaller is faster)
	db		10				;; Mistakes allowed

lanes_level_3:
	;;  The four lanes
	db	$2C, $32, $03, $D5
	;;  The directions
	db	4, 2, 2, 2
		
game_level_4:
	dw		lanes_level_4	;; The lane layout
	db		4				;; Max concurrent token count
	db		15				;; Token add delay
	db		64				;; Matches needed
	db		3				;; Token speed (smaller is faster)
	db		10				;; Mistakes allowed

lanes_level_4:
	;;  The four lanes
	db	$2C, $32, $CD, $23
	;;  The directions
	db	4, 2, 6, 4
	
game_level_5:
	dw		lanes_level_5	;; The lane layout
	db		4				;; Max concurrent token count
	db		15				;; Token add delay
	db		64				;; Matches needed
	db		3				;; Token speed (smaller is faster)
	db		15				;; Mistakes allowed

lanes_level_5:
	;;  The four lanes
	db	$2D, $24, $06, $DB
	;;  The directions
	db	5, 2, 2, 6
		
game_level_6:
	dw		lanes_level_6	;; The lane layout
	db		4				;; Max concurrent token count
	db		20				;; Token add delay
	db		64				;; Matches needed
	db		3				;; Token speed (smaller is faster)
	db		15				;; Mistakes allowed

lanes_level_6:
	;;  The four lanes
	db	$B0, $0D, $0F, $F0
	;;  The directions
	db	2, 5, 7, 7
		

game_level_7:
	dw		lanes_level_7	;; The lane layout
	db		4				;; Max concurrent token count
	db		20				;; Token add delay
	db		64				;; Matches needed
	db		3				;; Token speed (smaller is faster)
	db		15				;; Mistakes allowed

lanes_level_7:
	;;  The four lanes
	db	$32, $12, $1E, $A3
	;;  The directions
	db	2, 3, 5, 2

game_level_8:
	dw		lanes_level_8	;; The lane layout
	db		4				;; Max concurrent token count
	db		20				;; Token add delay
	db		64				;; Matches needed
	db		3				;; Token speed (smaller is faster)
	db		15				;; Mistakes allowed

lanes_level_8:
	;;  The four lanes
	db	$32, $12, $3E, $1E
	;;  The directions
	db	3, 3, 5, 5

game_level_9:
	dw		lanes_level_9	;; The lane layout
	db		8				;; Max concurrent token count
	db		10				;; Token add delay
	db		64				;; Matches needed
	db		4				;; Token speed (smaller is faster)
	db		15				;; Mistakes allowed

lanes_level_9:
	;;  The four lanes
	db	$2C, $0E, $3F, $10
	;;  The directions
	db	4, 4, 6, 6
	
game_level_10:
	dw		lanes_level_10	;; The lane layout
	db		8				;; Max concurrent token count
	db		10				;; Token add delay
	db		64				;; Matches needed
	db		3				;; Token speed (smaller is faster)
	db		15				;; Mistakes allowed

lanes_level_10:
	;;  The four lanes
	db	$0C, $1E, $3E, $D4
	;;  The directions
	db	4, 5, 6, 0
	
game_level_11:
	dw		lanes_level_11	;; The lane layout
	db		8				;; Max concurrent token count
	db		10				;; Token add delay
	db		64				;; Matches needed
	db		3				;; Token speed (smaller is faster)
	db		15				;; Mistakes allowed

lanes_level_11:
	;;  The four lanes
	db	$03, $C3, $3C, $FC
	;;  The directions
	db	1, 1, 5, 5
	

game_level_12:
	dw		lanes_level_12	;; The lane layout
	db		8				;; Max concurrent token count
	db		10				;; Token add delay
	db		64				;; Matches needed
	db		3				;; Token speed (smaller is faster)
	db		4				;; Mistakes allowed

lanes_level_12:
	;;  The four lanes
	db	$50, $FA, $90, $F6
	;;  The directions
	db	4, 6, 0, 2
	

game_level_13:
	dw		lanes_level_1	;; The lane layout
	db		4				;; Max concurrent token count
	db		20				;; Token add delay
	db		64				;; Matches needed
	db		1				;; Token speed (smaller is faster)
	db		20				;; Mistakes allowed


game_level_14:
	dw		lanes_level_2	;; The lane layout
	db		4				;; Max concurrent token count
	db		20				;; Token add delay
	db		64				;; Matches needed
	db		1				;; Token speed (smaller is faster)
	db		20				;; Mistakes allowed


game_level_15:
	dw		lanes_level_3	;; The lane layout
	db		4				;; Max concurrent token count
	db		20				;; Token add delay
	db		64				;; Matches needed
	db		1				;; Token speed (smaller is faster)
	db		20				;; Mistakes allowed

	
game_level_16:
	dw		lanes_level_16	;; The lane layout
	db		4				;; Max concurrent token count
	db		20				;; Token add delay
	db		64				;; Matches needed
	db		1				;; Token speed (smaller is faster)
	db		20				;; Mistakes allowed

lanes_level_16:
	;;  The four lanes
	db	$00, $FF, $E0, $F1
	;;  The directions
	db	0, 2, 4, 6
	
game_level_17:
	dw		lanes_level_impossible	;; The lane layout
	db		12				;; Max concurrent token count
	db		7				;; Token add delay
	db		64				;; Matches needed
	db		3				;; Token speed (smaller is faster)
	db		20				;; Mistakes allowed

game_level_18:
	dw		lanes_level_5	;; The lane layout
	db		12				;; Max concurrent token count
	db		7				;; Token add delay
	db		64				;; Matches needed
	db		3				;; Token speed (smaller is faster)
	db		20				;; Mistakes allowed

game_level_19:
	dw		lanes_level_9	;; The lane layout
	db		12				;; Max concurrent token count
	db		7				;; Token add delay
	db		64				;; Matches needed
	db		3				;; Token speed (smaller is faster)
	db		20				;; Mistakes allowed

	
	
game_level_impossible:
	dw		lanes_level_impossible	;; The lane layout
	db		12				;; Max concurrent token count
	db		7				;; Token add delay
	db		64				;; Matches needed
	db		1				;; Token speed (smaller is faster)
	db		32				;; Mistakes allowed

lanes_level_impossible:
	;;  The four lanes
	db	$2D, $3F, $31, $23
	;;  The directions
	db	4, 4, 4, 4
	
	
	
	
lanes_select:
	;;  The four lanes
	db	$32, $12, $F2, $C2
	;;  The directions
	db	2, 2, 2, 2

lanes_enter_code:
	;;  The four lanes
	db	$5D, $5F, $51, $53
	;;  The directions
	db	4, 4, 4, 4

	
NUM_CODES			equ	4	
level_codes:
	db		0, 2, 2, 0
	db		4, 0, 2, 6
	db		4, 6, 6, 0
	db		2, 4, 0, 6
	db		0, 0, 0, 0
	
matcher_match_positions:
	db		4
	db		5
	db		6
	db		7
	db		0
	db		1
	db		2
	db		3
	
token_data_ptr:
	dw	$C8A0
	dw	$C8A5
	dw	$C8AA
	dw	$C8AF
	dw	$C8B4
	dw	$C8B9
	dw	$C8BE
	dw	$C8C3
	dw	$C8C8
	dw	$C8CD
	dw	$C8D2
	dw	$C8D7
	dw	$C8DC
	dw	$C8E1
	dw	$C8E6
	dw	$C8EB
	dw	$C8F0
	dw	$C8F5
	dw	$C8FA
	

	
	
;; Lane direction to token velocity mapping
;; Four bits per direction, highest bit 1 for negative
dir_to_velo:
	db	$10
	db	$19
	db	$09
	db	$99
	db	$90
	db	$91
	db	$01
	db	$11


receptors:
	dw	receptor_0
	dw	receptor_1
	dw	receptor_2
	dw	receptor_3
	dw	receptor_4
	dw	receptor_5
	dw	receptor_6
	dw	receptor_7

	
receptor_0:
	db	0, 0, 36
	db	2, 36, -36
	db	2, -36, -36
	db	0, 0, 36
	db	1
receptor_1:
	db	0, 24, 24
	db	2, 0, -48
	db	2, -48, 0
	db	0, 24, 24
	db	1
receptor_2:
	db	0, 36, 0
	db	2, -36, -36
	db	2, 	-36, 36
	db	0, 36, 0
	db	1
receptor_3:
	db	0, 24, -24
	db	2, -48, 0
	db	2, 0, 48
	db	0, 24, -24
	db	1
receptor_4:
	db	0, 0, -36
	db	2, -36, 36
	db	2, 	36, 36
	db	0, 0, -36
	db	1	
receptor_5:
	db	0, -24, -24
	db	2, 0, 48
	db	2, 48, 0
	db	0, -24, -24
	db	1
receptor_6:
	db	0, -36, 0
	db	2, 36, 36
	db	2, 36, -36
	db	0, -36, 0
	db	1
receptor_7:
	db	0, -24, 24
	db	2, 48, 0
	db	2, 0, -48
	db	0, -24, 24
	db	1

TOKEN_VECTOR_LEN	equ	5
token_base:
	dw	token_base_0
	dw	token_base_1
	dw	token_base_2
	dw	token_base_3
	dw	token_base_4
	dw	token_base_5
	dw	token_base_6
	dw	token_base_7
	
token_base_0:
	db	0, 28
	db	28, -28
	db	-28, -28
	db	0, 28
	db	28, 0
token_base_1:	
	db	18, 18
	db	0, -36
	db	-36, 0
	db	18, 18
	db	18, -18
token_base_2:
	db	28, 0
	db	-28, -28
	db	-28, 28
	db	28, 0
	db	0, -28
token_base_3:	
	db	18, -18
	db	-36, 0
	db	0, 36
	db	18, -18
	db	-18, -18	
token_base_4:
	db	0, -28
	db	-28, 28
	db	28, 28
	db	0, -28
	db	-28, 0
token_base_5:	
	db	-18, -18
	db	0, 36
	db	36, 0
	db	-18, -18
	db	-18, 18
token_base_6:
	db	-28, 0
	db	28, 28
	db	28, -28
	db	-28, 0
	db	0, 28
token_base_7:	
	db	-18, 18
	db	36, 0
	db	0, -36
	db	-18, 18
	db	18, 18

	
	
lane_endpoints:
	dw	$5000
	dw	$50B0
	dw	$00B0
	dw	$B0B0
	dw	$B000
	dw	$B050
	dw	$0050
	dw	$5050
	
lanes:
	dw	lane_vector_list_0
	dw	lane_vector_list_1
	dw	lane_vector_list_2
	dw	lane_vector_list_3
	dw	lane_vector_list_4
	dw	lane_vector_list_5
	dw	lane_vector_list_6
	dw	lane_vector_list_7
	
	
lane_vector_list_0:
	db	0, -32, 0
	db	2, 32, 32
	db	2, 127, 0
	db	2, 127, 0
	db	2, 32, -32
	db	2, -32, -32
	db	2, -127, 0
	db	2, -127, 0
	db	2, -32, 32
	db	1
				
lane_vector_list_1:
	db	0, -22, -22
	db	2, 0, 44
	db	2, 44, 0
	db	2, 127, -127
	db	2, 127, -127
	db	2, 0, -44
	db	2, -44, 0
	db	2, -127, 127
	db	2, -127, 127
	db	1

lane_vector_list_2:
	db	0, 0, 32
	db	2, 32, -32
	db	2, 0, -127
	db	2, 0, -127
	db	2, -32, -32
	db	2, -32, 32
	db	2, 0, 127
	db	2, 0,127
	db	2, 32, 32
	db	1

lane_vector_list_3:
	db	0, -22, 22
	db	2, 44, 0
	db	2, 0, -44
	db	2, -127, -127
	db	2, -127, -127
	db	2, -44, 0
	db	2, 0, 44
	db	2, 127, 127
	db	2, 127, 127
	db	1
	
lane_vector_list_4:
	db	0, 32, 0
	db	2, -32, -32
	db	2, -127, 0
	db	2, -127, 0
	db	2, -32, 32
	db	2, 32, 32
	db	2, 127, 0
	db	2, 127, 0
	db	2, 32, -32
	db	1	

lane_vector_list_5:
	db	0, 22, 22
	db	2, 0, -44
	db	2, -44, 0
	db	2, -127, 127
	db	2, -127, 127
	db	2, 0, 44
	db	2, 44, 0
	db	2, 127, -127
	db	2, 127, -127
	db	1
	
lane_vector_list_6:
	db	0, 0, -32
	db	2, -32, 32
	db	2, 0, 127
	db	2, 0, 127
	db	2, 32, 32
	db	2, 32, -32
	db	2, 0, -127
	db	2, 0,-127
	db	2, -32, -32
	db	1
	
lane_vector_list_7:
	db	0, 22, -22
	db	2, -44, 0
	db	2, 0, 44
	db	2, 127, 127
	db	2, 127, 127
	db	2, 44, 0
	db	2, 0, -44
	db	2, -127, -127
	db	2, -127, -127
	db	1


malleus_vector_list_1:
	db	2, 0, 56
	db	2, -12, -8
	db	2, 0, 	30
	db	2, 30, 10
	db	2, 0, -20
	db	2, -8, -6
	db	2, 0, -50
	db	2, -4, -10
	db	2, -6, -2
	db 	1

malleus_vector_list_2:
	db	2, -10, 0
	db	2, 0, 49
	db	0, -2, -1
	db	2, -10, 0
	db	2, 4, 14
	db	2, 6, 16
	db	2, -10, 0
	db	2, 4, -16
	db	2, 6, -14
	db	0, -10, 0
	db	2, 0, 30
	db	2, 32, 10
	db 	2, 8, 0
	db	1

malleus_vector_list_3:
	db	0, 5, 65
	db	2, -6, 3
	db	2, 6, 10
	db	2, 5, -3
	db	2, -5, -10
	db	2, 0, 13
	db	0, 5, -3
	db	2, -11, -7
	db	1

enter_code_box_vector_list:
	db	0, 32, 0
	db	2, -32, -32
	db	2, -32, 32
	db	2, 32, 32
	db	2, 32, -32
	db	1	

	
level_1:
	;;  The four lanes
	db	$2B, $2E, $22, $25
	;;  The directions
	db	4, 4, 4, 4
	
	
level_example_1:
	;;  The four lanes
	db	$10, $F0, $2B, $12
	;;  The directions
	db	0, 1, 4, 4

level_square:
	;;  The four lanes
	db	$C4, $44, $4C, $CC
	;;  The directions
	db	0, 2, 4, 6
		
level_diamond:
	;;  The four lanes
	db	$06, $60, $0A, $A0
	;;  The directions
	db	1, 3, 5, 7
		
	
select_play_str:
				db "PLAY"
				db	$80
				
select_code_str:
				db "CODE"
				db	$80
	
select_challenge_str:
				db "CHALLENGE"
				db	$80

select_help_str:
				db "HELP"
				db	$80
		
help_lane_str:
				db "LANE"
				db	$80
help_token_str:
				db "TOKEN"
				db	$80

help_receptor_str:
				db "RECEPTOR"
				db	$80

help_matcher_str:
				db "MATCHER"
				db	$80

help_desc_0_str:
				db "USE RECEPTOR AND"
				db	$80
help_desc_1_str:
				db "MATCHER TO MATCH"
				db	$80
help_desc_2_str:
				db "TOKEN ORIENTATION"
				db	$80
help_desc_3_str:
				db "TO COMPLETE"
				db	$80
				
				
level_lost_str:
				db "LEVEL LOST"
				db	$80
	
level_complete_str:
				db "LEVEL COMPLETE"
				db	$80
	
;***************************************************************************
; Sounds
;***************************************************************************
;; How to find the right ADSR table for a note duration
adsr_index_table:
		db	0
		db	2, 2
		db	4, 4
		db 	6, 6, 6, 6
		db	8, 8, 8, 8, 8, 8, 8, 8
		db	10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10
		db	12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12
		db	12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12
		db	14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14
		db	14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14
		db	14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14
		db	14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14

adsr_beep:
				fdb $aaaa,$aaaa,$8888,$4444,$0000,$0000,$0000,$0000
silence:
				fdb		adsr_beep, $FEB6
				fcb		30, $80	

adsr_fade:
		dw adsr_fade_0
		dw adsr_fade_2
		dw adsr_fade_4
		dw adsr_fade_8
		dw adsr_fade_16
		dw adsr_fade_32
		dw adsr_fade_64
		dw adsr_fade_128
		
adsr_fade_128:
		db  8, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15
		db 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15
		db 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15
		db 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15
		db 14, 14, 14, 14, 13, 13, 13, 13, 12, 12, 12, 12, 11, 11, 11, 11
		db 10, 10, 10, 10, 9, 9, 9, 9, 8, 8, 8, 8, 7, 7, 7, 7
		db 6, 6, 6, 6, 5, 5, 5, 5, 4, 4, 4, 4, 3, 3, 3, 3
		db 2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0

adsr_fade_64:
		db  8, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15
		db 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15
		db 14, 14, 13, 13, 12, 12, 11, 11, 10, 10, 9, 9, 8, 8, 7, 7
		db	6, 6, 5, 5, 4, 4, 3, 3, 2, 2, 1, 1, 0, 0, 0, 0
		
adsr_fade_32:
		db  8, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15
		db  14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0, 0

adsr_fade_16:
		db  8, 15, 15, 15, 15, 15, 15, 15, 13, 11, 9, 7, 5, 3, 1, 0
		
adsr_fade_8:
		db  8, 15, 15, 15, 12, 9, 6, 2

adsr_fade_4:
		db  15, 15, 8, 4
		
adsr_fade_2:
		db  15, 6
		
adsr_fade_0:
		db  0
				

song_match_1:
		db	8, C6, 8, REST
		db	$81

song_match_2:
		db	8, E6, 8, REST
		db	$81

song_match_3:
		db	8, G6, 8, REST
		db	$81


song_mismatch_1:
		db	8, C5, 8, REST
		db	$81

song_mismatch_2:
		db	8, CS5, 8, REST
		db	$81

song_mismatch_3:
		db	8, DS5, 8, REST
		db	$81

song_win_1:
		db	32, C5, 32, D5, 64, C5
		db	$81		

song_win_2:
		db	32, E5, 32, F5, 64, G5
		db	$81		

song_win_3:
		db	32, G5, 32, G5, 64, C6
		db	$81		
		
song_loss_1:
		db	32, C5, 32, C5, 64, C5
		db	$81		

song_loss_2:
		db	32, DS5, 32, D5, 64, CS5
		db	$81		

song_loss_3:
		db	32, FS5, 32, F5, 64, E5
		db	$81		

song_intro_1:
		db	16, G5, 16, G5, 16, G5, 16, G5, 32, FS5, 32, DS5
		db	16, G5, 16, G5, 16, G5, 16, G5, 32, FS5, 32, DS5
		db	16, G5, 16, G5, 16, G5, 16, G5, 32, FS5, 32, DS5
		db	16, G5, 16, FS5, 16, G5, 16, FS5, 32, G5, 32, REST
		db	$81		
		
song_intro_2:
		db	16, C5, 16, C5, 16, C5, 16, C5, 32, CS5, 32, REST
		db	16, C5, 16, C5, 16, C5, 16, C5, 32, CS5, 32, REST
		db	16, C5, 16, C5, 16, C5, 16, C5, 32, CS5, 32, REST
		db	16, C5, 16, CS5, 16, C5, 16, CS5, 32, C5, 32, REST
		db	$81		

song_intro_3:
		db	64, C4, 32, CS4, 32, DS4
		db	64, C4, 32, CS4, 32, DS4
		db	64, C4, 32, CS4, 32, DS4
		db	16, C4, 16, CS4, 16, C4, 16, CS4, 32, C4, 32, REST
		db	$81	

		
		
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
REST    equ     $3F	
