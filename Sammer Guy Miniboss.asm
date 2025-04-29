; Sammer Guy Miniboss.asm
;----------------------------
lorom

!86Free = $86F4A6	; For enemy projectiles
!8DFree = $8DD9D0	; Palette FX Object
!92Free = $92EE00	; For title card stuff
!A0Free = $A0F813	; For enemy headers
!A2Free = $A2F498	; AI code
!A3Free = $A3F3F5	; AI code
!A4Free = $A4F6C0	; AI code
!A5Free = $A5F970	; AI code
!B4Free = $B4F4E0	; For drops/weaknesses

!GraphSp  = $B89000 ; Free Space for Graphics

!sleep = $812F

!currHP = $0F8C				; Current HP of an enemy
!timer = $0F90				; Enemy timer
!state = $0FA8				; Enemy state pointer
!minDis = $0FAA				; Minimum distance the boss can be from the walls 
!bossLoc = $0FAC			; Variable indicating what state the boss' location is in
!swordsSpawned = $0FAE		; A variable indicating which swords the boss has spawned
!floatState = $0FB0			; A variable used to determine which direction the boss is floating in and how quickly
!paletteIndex = $0FB2		; A variable used to determine which palette the boss should be using

!HPComparitor = EnemyHeaders_BossHeader+4	; A variable used to store the initial max HP of the boss to compare it with the current HP for speed calculations

!projectileTimer = $19DF	; The timer variable for enemy projectiles
!swordPosition = $1AFF		; Each sword's initialization value
!returnHeight = $1B23		; Height for sword projectiles to return to 

!state0 = #$0000
!state2 = #$0002
!state4 = #$0004
!state6 = #$0006
!state8 = #$0008
!stateA = #$000A
!prepheight = #$0008
!maxHP = #$1000
!secPhaseHP = #$0800

!TITLE_HEADER_LOCATION = #$F913
!BOSS_HEADER_LOCATION = #$F853
!TITLE_INDEX = $1F5B ; USES THE END OF THE STACK

org !A0Free
EnemyHeaders:
{
.SwordHeader
print pc, " - Sword Enemy Header"
;       Palette             Damage        Y Radius        Hurt AI Time   Boss Value          Number of parts  Main AI              Hurt AI       Xray AI      Unused         PB AI        Unused       Touch AI        Unused                Layer Priority          Weakness Pointer
;GFX Size |          Health |      X Radius  |       AI Bank |     Hurt SFX  |  Setup           |   Unused    |         Grapple AI |  Frozen AI  | Death Anim. |   Unused    |   Unknown   |   Unused    |   Shot AI   |   GFX Address           | Drops Pointer       |          Name Pointer
;  |      |          |      |      |      |          |    |        |      |      |              |      |      |             |      |      |      |      |      |      |      |      |      |      |      |      |      |          |              |        |            |           |
DW $0400, Sword_PAL, $0100, $0048, $0004, $0010 : DB $A3, $00 : DW $0000, $0000, Sword_SETUPAI, $0001, $0000, Sword_MAINAI, $804C, $804C, $8041, $0000, $0000, $0000, $0000, $804C, $0000, $0000, $0000, $8023, $802D, $0000 : DL GFX_Sword : DB $02 : DW DROPS_Sword, WEAK_Sword, $E1DB

.BossHeader
print pc, " - Boss Enemy Header"
;       Palette             Damage        Y Radius        Hurt AI Time   Boss Value         Number of parts  Main AI             Hurt AI       Xray AI      Unused         PB AI        Unused       Touch AI              Unused               Layer Priority         Weakness Pointer
;GFX Size |         Health  |      X Radius  |       AI Bank |     Hurt SFX  |  Setup          |   Unused    |        Grapple AI |  Frozen AI  | Death Anim. |   Unused    |   Unknown   |   Unused    |   Shot AI         |   GFX Address          | Drops Pointer      |         Name Pointer
;  |      |         |       |      |      |          |    |        |      |      |             |      |      |            |      |      |      |      |      |      |      |      |      |      |      |      |            |          |             |        |           |          |
DW $0400, Boss_PAL, !maxHP, $0064, $0010, $0014 : DB $A3, $00 : DW $0000, $0000, Boss_SETUPAI, $0001, $0000, Boss_MAINAI, $804C, $804C, $8041, $0000, $0003, $0000, $0000, $804C, $0000, $0000, $0000, $8023, Boss_SHOTAI, $0000 : DL GFX_Boss : DB $02 : DW DROPS_Boss, WEAK_Boss, $E1DB

.ShieldHeader
print pc, " - Shield Enemy Header"
;       Palette              Damage        Y Radius        Hurt AI Time   Boss Value           Number of parts  Main AI               Hurt AI       Xray AI      Unused         PB AI        Unused       Touch AI        Unused                 Layer Priority           Weakness Pointer
;GFX Size |           Health |      X Radius  |       AI Bank |     Hurt SFX  |  Setup            |   Unused    |          Grapple AI |  Frozen AI  | Death Anim. |   Unused    |   Unknown   |   Unused    |   Shot AI   |   GFX Address            | Drops Pointer        |           Name Pointer
;  |      |           |      |      |      |          |    |        |      |      |               |      |      |              |      |      |      |      |      |      |      |      |      |      |      |      |      |          |               |        |             |            |
DW $0200, Shield_PAL, $0100, $0064, $0012, $0004 : DB $A4, $00 : DW $0000, $0000, Shield_SETUPAI, $0001, $0000, Shield_MAINAI, $804C, $804C, $8041, $0000, $0000, $0000, $0000, $804C, $0000, $0000, $0000, $8023, $802D, $0000 : DL GFX_Shield : DB $02 : DW DROPS_Shield, WEAK_Shield, $E1DB

.ShurikenHeader
print pc, " - Shuriken Enemy Header"
;       Palette              Damage        Y Radius        Hurt AI Time   Boss Value             Number of parts  Main AI       Hurt AI       Xray AI      Unused         PB AI        Unused       Touch AI        Unused                 Layer Priority           Weakness Pointer
;GFX Size |             Health |      X Radius  |       AI Bank |     Hurt SFX  |  Setup              |   Unused    |  Grapple AI |  Frozen AI  | Death Anim. |   Unused    |   Unknown   |   Unused    |   Shot AI   |   GFX Address            | Drops Pointer        |           Name Pointer
;  |      |             |      |      |      |          |    |        |      |      |                 |      |      |      |      |      |      |      |      |      |      |      |      |      |      |      |      |          |               |        |             |            |
DW $0400, Shuriken_PAL, $0100, $0048, $0008, $0008 : DB $A2, $00 : DW $0000, $0000, Shuriken_SETUPAI, $0001, $0000, $B40F, $800F, $804C, $8041, $0000, $0000, $0000, $0000, $8037, $0000, $0000, $0000, $8023, $802D, $0000 : DL GFX_Shuriken : DB $02 : DW DROPS_Shuriken, WEAK_Shuriken, $E1DB

.TypewriterHeader
print pc, " - Typewriter Enemy Header"
dw $0000,$0000,$0028,$000F,$0010,$0008 
db $A5,$00,$59,$00,$00,$00
dw #AREA_TITLE_INIT,$0001,$0000,#AREA_TITLE_AI,$8004,#AREA_TITLE_SHOT_AI,$8041,$0000,$0000
dl $000000
db $00
dw #AREA_TITLE_SHOT_AI,$0000,$0000,$0000,#AREA_TITLE_SHOT_AI,#AREA_TITLE_SHOT_AI
db $00,$00,$00,$00,$00,$00,$00,$00,$08,$EF,$00,$00
}

org !A2Free
Shuriken:
{
; Copy-paste of multiviola setup AI except for Instlist
print pc, " - Shuriken SetupAI"
.SETUPAI
LDX $0E54
LDA $0FB4,x
STA $12
LDA $0FB6,x
AND #$00FF
STA $14
JSL $A0B643
LDA $16
STA $0FAC,x
LDA $18
STA $0FAE,x
LDA $1A
STA $0FB0,x
LDA $1C
STA $0FB2,x
LDA #.INSTLISTS_IDLE	; Changed to the shuriken's spritemap list
STA $0F92,x
RTL

.INSTLISTS
print pc, " - Shuriken Instlists"
..IDLE
DW $0002, .SPM_IDLE1
DW $0002, .SPM_IDLE2
DW $0002, .SPM_IDLE3
DW $0002, .SPM_IDLE4
DW $80ED, ..IDLE

.SPM
print pc, " - Shuriken Spritemaps"
..IDLE1
DW $0001
DW $81F8 : DB $F8 : DW $2100	; Cardinal Directions
..IDLE2
DW $0001
DW $81F8 : DB $F8 : DW $2102	; 1/16 tilt
..IDLE3
DW $0001
DW $81F8 : DB $F8 : DW $2104	; 1/8 tilt
..IDLE4
DW $0001
DW $81F8 : DB $F8 : DW $2106	; 3/16 tilt



.PAL
db $00,$38,$F7,$5E,$52,$4A,$CE,$39,$08,$21,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
}

org !A3Free
Sword:
{
; Stores initial Y position at $0FAA,x
print pc, " - Sword SetupAI"
.SETUPAI
LDX $0E54								; Load enemy index
LDA #.INSTLISTS_IDLE : STA $0F92,x		; Load idle instruction list and store to memory
LDA #$0008 : STA !state,x				; Set the default state to "inactive"
RTL

; State Table:
; 0000 = Stationary
; 0002 = Attack Prep
; 0004 = Attacking
; 0006 = Returning
; 0008 = Inactive
; 000A = Spawning

print pc, " - Sword MainAI"
.MAINAI
LDX $0E54						; Load enemy index
LDA !state : CMP #$000A 		; Check to see if state of enemy 0 is 10 (Spawning)
BNE ..NoSpawn					; If state != 10, not spawning swords
LDA !swordsSpawned : CMP #$0002 ; Check to see which set of swords have been spawned
BEQ ..NoSpawn					; If all swords have been spawned, no more spawning
LDA !timer : CMP #$003F			; Check to see if the timer is 3F (spawning second set of swords)
BEQ ..SecondSpawn
CMP #$001F : BNE ..NoSpawn		; If timer is not 1F (first spawn), no spawn
LDA !swordsSpawned 				; If SwordsSpawned = 0, spawn the first set of swords
BEQ ..FirstSpawn				; Otherwise, don't spawn

..NoSpawn
RTL

..FirstSpawn
; Inner left Sword
TDC
SEP #$20			;8-bit Mode
LDA #$00			;[A] = #$PP projectile parameter
REP #$20
LDY #$F4A6			; Load Index of the Projectile to fire
JSL $868027			; Fire projectile

; Inner Right Sword
TDC
SEP #$20			;8-bit Mode
LDA #$02			;[A] = #$PP projectile parameter
REP #$20
LDY #$F4A6			; Load Index of the Projectile to fire
JSL $868027			; Fire projectile

LDA #$0001 : STA !swordsSpawned		; Indicate that the first set of swords has been spawned
RTL

..SecondSpawn
; Leftmost Sword
TDC
SEP #$20			;8-bit Mode
LDA #$04			;[A] = #$PP projectile parameter
REP #$20
LDY #$F4A6			; Load Index of the Projectile to fire
JSL $868027			; Fire projectile

; Rightmost Sword
TDC
SEP #$20			;8-bit Mode
LDA #$06			;[A] = #$PP projectile parameter
REP #$20
LDY #$F4A6			; Load Index of the Projectile to fire
JSL $868027			; Fire projectile

LDA #$0002 : STA !swordsSpawned		; Indicate that the second set of swords has been spawned
RTL

.INSTLISTS
print pc, " - Sword Instlists"
..IDLE
DW $0010, .SPM_IDLE1, !sleep

.SPM
print pc, " - Sword Spritemaps"
..IDLE1
DW $0002
DW $81F8 : DB $F0 : DW $2100	; Top
DW $81F8 : DB $00 : DW $2102	; Bottom

.PAL
DW $0000,$339F,$1F5E,$0EDF,$065C,$7F7C,$7B39,$76F6,$30C6,$1CEC,$0846,$0000,$0000,$0000,$0000,$0000
}

; State Table:
; 0000 = Follow
; 0002 = Attack Prep
; 0004 = Attacking
; 0006 = Returning
; 0008 = Intro
; 000A = Spawning Swords

; Boss Location Table:
; 0000 = Center
; 0001 = Too far left
; 0002 = Too far right
Boss:
{
; THIS BOSS MUST BE ENEMY INDEX 0!
print pc, " - Boss SetupAI"
.SETUPAI
LDA #.INSTLISTS_IDLE : STA $0F92		; Load idle spritemap
LDA #$0300 : STA !timer					; Set timer to $0300
LDA #$0008 : STA !state					; Set the default state to Intro
LDA #$2400 : STA $0F86					; Make boss intangible at the start
LDA #$0024 : STA $0FAC					; Stores Maximum Letters in title card
LDA #$FFFF : STA $0FB2					; Stores a timer, which will Dec each frame
LDA #$0200 : STA $0FAE					; Stores Master lifespan for title card once xray fool tile is touched

; Into text setup stuff
LDA.w #GFX_REFRESH : STA $00
LDA.w #GFX_REFRESH>>8 : STA $01
JSL $818EB2						; Loading tilemap stuff
LDA $0E54 : STA !TITLE_INDEX
LDA #.MAINAI_A_SAMMER_INTRO : STA $0F92	; Stores the gfx pointer to change the message to be shown
RTL

print pc, " - Boss MainAI"
.MAINAI
{
LDX !state 						; Load state to X
JMP (.STATEPOINTERS,x)			; Jump to states based on STATEPOINTERS

..Follow

DEC !timer						; Decrement timer
BEQ ..StartPrepSend				; If Timer = 0, set state to 2
BRA ..CheckHP

..StartPrepSend
JMP ..StartPrep

..CheckHP
LDA !swordsSpawned 
CMP #$0002 : BEQ ..Flotation			; If both sets of swords have been spawned, skip the next chunk of code
LDA $0F8C								; Load the enemy's current HP
CMP !secPhaseHP : BPL ..Flotation		; Check to see if the boss is below 1/2 of its max HP
LDA #$0058 : STA !minDis				; Increase minimum distance the boss can be from the walls to make room for the second set of swords
JMP ..SkipThrow                         ; If prepping for the phase shift, do not run flotation or shuriken code

..Flotation
; Have boss float up and down
; State Table:
; 0XXX = Slowing down
; 8XXX = Speeding up
; X0XX = Going down
; X1XX = Going up
; XXYY = YY is location on sine table

LDA !floatState : AND #$00FF	; Load the movement speed
ASL : TAX						; Double it and transfer to X for indexing
LDA $A0B1C3,x : PHA				; Load the speed at the location on the sine table and push to the stack
LDA !floatState : AND #$0F00	; Load the movement direction
STZ $14 : BEQ ..GoingDown
CPX #$0000 : BEQ ..GoingDown	; If speed is 0, do not invert. This avoids an off by one error at the trough of the slope
DEC $14							; Set vertical speed to $FFFF if negative
PLA : EOR #$FFFF : INC : PHA	; Invert the subspeed if negative	
..GoingDown
PLA : STA $12	  				; Pop speed from stack and apply to subpixel speed
LDX #$0000 : JSL $A0C788		; Move up or down by subpixel value.
LDA !floatState					; Determine the direction of accelleration
BMI ..Increment					; If State = #$8XXX, it sees this as "negative" and will branch
DEC !floatState
JMP ..CheckStop					; Increment or decrement the speed based on acceleration
..Increment
INC !floatState
..CheckStop
LDA !floatState : AND #$00FF	; Load the movement speed
BNE ..Continue					; Check to see if it is stopped
LDA !floatState 				
EOR #$8100 : STA !floatState	; Invert the direction and acceleration
PHA : JMP ..ShurikenCheck
..Continue
LDA !floatState
PHA : AND #$00FF : CMP #$0020	; Check for peak speed, putting A on the stack
BNE ..ShurikenCheck
PLA : EOR #$8000 				; Pop A from the stack to apply the inversion
STA !floatState : PHA			; Invert the acceleration if at peak speed and put A back on stack

..ShurikenCheck
PLA								; Get A back from the stack regardless of the outcome of the branch
LDA !timer
CMP #$0040 : BEQ ..Throw	; If timer = 40, throw shuriken
JMP ..SkipThrow
..Throw
JSL $808111 : PHA				; Randomly determine whether to throw left or right and store it on the stack
LDA !swordsSpawned 				; Check to see which sets of swords have spawned
CMP #$0002 : BNE ..OnlyOne		; If only one set of swords have been spawned, only check to throw the first shuriken	
LDY #$0100						; Load index of enemy 4 to Y, the second shuriken
LDA $0F7A,y						; Load X position of enemy 4 to A
CMP #$0100 : BMI ..OnlyOne		; If enemy is already in area, don't throw again
LDA $0F7A : STA $0F7A,y			; X position of enemy 4 = X position of enemy 0
LDA $0F7E : CLC 
ADC #$0008 : STA $0F7E,y		; Y position of enemy 4 = Y position of enemy 0 + 8
PLA	: BMI ..ThrowDnLeft			; Get throw direction from stack
PHA : LDA #$0070 : STA $0FB4,y	; Set direction of enemy 4 to down right and put throw direction back on stack
LDA #.INSTLISTS_RIGHTTHROW 
STA $0F92						; Load left throw animation routine
LDA #$0001 : STA $0F94			; Set spritemap timer to 1
BRA ..OnlyOne
..ThrowDnLeft
PHA : LDA #$0010 : STA $0FB4,y	; Set direction of enemy 4 to down left and put throw direction back on stack
LDA #.INSTLISTS_LEFTTHROW 
STA $0F92						; Load left throw animation routine
LDA #$0001 : STA $0F94			; Set spritemap timer to 1

..OnlyOne
LDY #$00C0						; Load index of enemy 3 to Y, the first shuriken
LDA $0F7A,y						; Load X position of enemy 3 to A
CMP #$0100 : BMI ..NoThrow		; If enemy is already in area, don't throw again
LDA $0F7A : STA $0F7A,y			; X position of enemy 3 = X position of enemy 0
LDA $0F7E : CLC 
ADC #$0008 : STA $0F7E,y		; Y position of enemy 4 = Y position of enemy 0 + 8
PLA	: BMI ..ThrowUpLeft			; Get throw direction from stack
PHA : LDA #$0090 : STA $0FB4,y	; Set direction of enemy 3 to up right and put throw direction back on stack
LDA #.INSTLISTS_RIGHTTHROW 
STA $0F92						; Load left throw animation routine
LDA #$0001 : STA $0F94			; Set spritemap timer to 1
BRA ..NoThrow
..ThrowUpLeft
PHA : LDA #$00F0 : STA $0FB4,y	; Set direction of enemy 3 to up left and put throw direction back on stack
LDA #.INSTLISTS_LEFTTHROW 
STA $0F92						; Load left throw animation routine
LDA #$0001 : STA $0F94			; Set spritemap timer to 1

..NoThrow
PLA 							; Take throw direction off the stack if it was ever determined
..SkipThrow
; Keep the boss from moving swords into a wall
{
LDA $0F7A						; Get enemy X position
CLC : SBC !minDis				; Subtract the miminum distance from walls
BEQ ..TFLeft 
CMP #$0001 : BEQ ..TFLeft 
BMI ..Right						; If Difference = 0 or 1, set variable. If Difference < 0, move right

LDA $0F7A						; Get enemy X position
CLC : ADC !minDis				; Add the miminum distance from walls
CMP #$0100 : BEQ ..TFRight 		; Compare it with the right edge of the first scroll.
CMP #$0101 : BEQ ..TFRight		
BPL ..Left						; If Difference = 0 or 1, set variable. If Difference < 0, move left
LDA #$0000 : STA !bossLoc		; Set BossLoc to say that the boss is centered and run like normal
BRA ..CheckPhaseShift

..TFLeft
LDA #$0001 : STA !bossLoc		; Set BossLoc to say that the boss is too far to the left
BRA ..CheckPhaseShift

..TFRight
LDA #$0002 : STA !bossLoc		; Set BossLoc to say that the boss is too far to the right
}

..CheckPhaseShift
LDA !swordsSpawned 
CMP #$0002 : BEQ ..FollowSamus			; If both sets of swords have been spawned, skip the next chunk of code
LDA $0F8C								; Load the enemy's current HP
CMP !secPhaseHP : BPL ..FollowSamus		; If boss' HP is not below 1/2, skip the next chunk of code
LDA !stateA : STA !state				; Set State to "spawning"
RTL										; Skip all other actions this frame

; Determine which direction to move while following Samus
{
..FollowSamus
LDA $0AF6								; Load Samus X Position
CMP $0F7A : BMI ..Left					; If Enemy is to the right of Samus
BEQ ..Stop								; If Enemy is on top of Samus
..Right
LDA !bossLoc 
CMP #$0002 : BEQ ..Stop					; If enemy is too far right, don't move
LDA #$0001 : STA $14					; Move right by one pixel plus change
LDA $0AF6 : SEC : SBC $0F7A				; Load Samus X Position
CMP #$0001 : BEQ ..NoSub				; If Enemy one pixel off Samus, skip subpixel movement
LDA !HPComparitor : SEC : SBC !currHP	; Get HP of damage dealt to boss
ASL #3 : STA $12  						; Apply it to subpixel speed
JSL $A0C6AB								;/
BRA ..Stop
..Left
LDA !bossLoc 
CMP #$0001 : BEQ ..Stop					; If enemy is too far left, don't move
LDA #$FFFE : STA $14					; Move left by one pixel plus change
LDA $0AF6 : SEC : SBC $0F7A				; Load Samus X Position
CMP #$FFFE : BEQ ..NoSub				; If Enemy one pixel off Samus, skip subpixel movement
LDA !HPComparitor : SEC : SBC !currHP	; Get HP of damage dealt to boss
ASL #3 : EOR #$FFFF : STA $12  			; Apply it to subpixel speed
JSL $A0C6AB								;/
..Stop
RTL

..NoSub
STZ $12 : JSL $A0C6AB					; Apply movement but with no subpixel speed
RTL

}

; Run the boss' attack protocols
{
..StartPrep
LDA !state2 : STA !state		; set state to 2
LDA #$0020 : STA !timer			; set timer to 20
LDA #.INSTLISTS_PREPPING 
STA $0F92						; Load raising spritemap
LDA #$0001 : STA $0F94			; Set spritemap timer to 1
RTL

..AttackPrep
DEC !timer						; Decrement Timer
BEQ ..StartThrust				; If Timer = 0, set state to 4
RTL

..StartThrust				
LDA !state4 : STA !state		; set state to 4
LDA !currHP : LSR #7			; Get current HP /80h
CLC : ADC #$0040 : STA !timer	; set timer to 40 + HP/80 (Range from 40 - 58)
LDA #.INSTLISTS_THRUSTING 
STA $0F92						; Load thrusting spritemap sequence
LDA #$0001 : STA $0F94			; Set spritemap timer to 1
RTL

..Downward
DEC !timer						; Decrement Timer
BEQ ..StartReturn				; If Timer = 0, set state to 6
RTL

..StartReturn				
LDA !state6 : STA !state		; set state to 6
LDA #.INSTLISTS_RETURNING
STA $0F92						; Load returning spritemap sequence
LDA #$0001 : STA $0F94			; Set spritemap timer to 1
..Return
RTL
}

print pc, " - Boss IntroAI"
..Intro
LDA $0FAE : BNE ..Run_Text
LDA $0F94 : CMP #$0001 : BNE ..Run_Text	; If both master = 0 and current lifespan = 1, spawn the boss
LDA #$0005 : JSL $808FC1				; Trigger boss music change
JSL $90A7E2								; Disable the minimap
LDA #$0018 : STA $0F9C					; Set enemy flash timer to 24 for boss
LDY #$D9D0 : JSL $8DC4E9				; Spawn palette FX Object for background flash
LDY #$D9D4 : JSL $8DC4E9				; Spawn palette FX Object for door flash
LDA #.INSTLISTS_SPAWNING : STA $0F92	; Load spawning spritemap
LDA #$0001 : STA $0F94					; Set spritemap timer to 1
LDA #$0080 : STA !timer					; Set timer to $0080
LDA #$000A : STA !state					; Set state to spawning swords
LDA #$2000 : STA $0F86					; Make boss tangible and visible
LDA #$2000 : STA $1006					; Make shield tangible and visible
LDA #$0048 : STA !minDis				; Set the default minimum distance the boss can be from the walls
LDA #$0020 : STA !floatState			; Set the default float state to moving down at full speed, slowing down
RTL
..Run_Text
	LDX $0E54		; Loads Current enemy in room
	LDA $07F3 : CMP #$0021 : BPL + 		; Check to see if the song is at or above set 21 (Mother brain fight) 
	LDA $0F94							; Load enemy instruction timer (lifetime)
	CMP #$0002							
	BNE ++								; Continue if not equal to 2
+	;STZ $0F7A,x		; Zero out enemy X position
	;STZ $0F7E,x		; Zero out enemy Y position
	;STZ $0F78,X 	; Zero out enemy ID (to delete it?)
	RTL
++	TXA
	RTL
RTL

; Intro Text Spritemap
{
..A_SAMMER_INTRO		; Speed	$0000
	DW $01A4, ..AT_SAMMER_INTRO
	DW $80ED, ..A_SAMMER_INTRO
..AT_SAMMER_INTRO	 DW $0024	
	DB $E8,$01,$20,$D8,$3A ; I
	DB $F0,$01,$20,$DD,$3A ; N
	DB $F8,$01,$20,$E5,$3A ; V
	DB $00,$00,$20,$D0,$3A ; A
	DB $08,$00,$20,$D3,$3A ; D
	DB $10,$00,$20,$D4,$3A ; E
	DB $18,$00,$20,$E1,$3A ; R
	DB $20,$00,$20,$E2,$3A ; S
	DB $28,$00,$20,$EB,$3A ; .
	DB $30,$00,$20,$EB,$3A ; .
	DB $38,$00,$20,$EB,$3A ; .
	DB $40,$00,$20,$EF,$3A ; Long pause
	DB $E8,$01,$38,$DC,$3A ; M
	DB $F0,$01,$38,$E4,$3A ; U
	DB $F8,$01,$38,$E2,$3A ; S
	DB $00,$00,$38,$E3,$3A ; T
	DB $08,$00,$38,$EE,$3A ; Short pause
	DB $10,$00,$38,$E2,$3A ; S
	DB $18,$00,$38,$E3,$3A ; T
	DB $20,$00,$38,$DE,$3A ; O
	DB $28,$00,$38,$DF,$3A ; P
	DB $30,$00,$38,$EB,$3A ; .
	DB $38,$00,$38,$EB,$3A ; .
	DB $40,$00,$38,$EB,$3A ; .
	DB $48,$00,$38,$EE,$3A ; Short Pause
	DB $E8,$01,$50,$D8,$3A ; I
	DB $F0,$01,$50,$DD,$3A ; N
	DB $F8,$01,$50,$E5,$3A ; V
	DB $00,$00,$50,$D0,$3A ; A
	DB $08,$00,$50,$D3,$3A ; D
	DB $10,$00,$50,$D4,$3A ; E
	DB $18,$00,$50,$E1,$3A ; R
	DB $20,$00,$50,$E2,$3A ; S
	DB $28,$00,$50,$EB,$3A ; .
	DB $30,$00,$50,$EB,$3A ; .
	DB $38,$00,$50,$EB,$3A ; .
}

..Spawning
LDA !swordsSpawned : BEQ ..FirstSet		; If no swords have been spawned, spawn the first set
LDA $0F8C								; Load the enemy's current HP
CMP !secPhaseHP : BPL ..End				; Check to see if the boss is below 1/2 of its max HP If so, do nothing
LDA !swordsSpawned 						; If exactly one set of swords have been spawned, spawn the second set
CMP #$0001 : BEQ ..SecondSet		
BRA ..End								; Otherwise, do nothing

..FirstSet
LDA #$0020 : STA !timer				; set timer to 20
BRA ..End
..SecondSet
LDA #$0040 : STA !timer				; set timer to 40
LDA #.INSTLISTS_SPAWNING : STA $0F92; Load spawning spritemap
LDA #$0001 : STA $0F94				; Set spritemap timer to 1

..End
DEC !timer							; Decrement Timer
CLC : BEQ ..RestartAttack			; If Timer = 0, set state to 0
RTL	

..RestartAttack				
LDA !state0 : STA !state			; set state to 0
LDA #$0080 : STA !timer				; set timer of enemy 0 to 80
LDA #.INSTLISTS_IDLE : STA $0F92	; Load idle spritemap
LDA #$0001 : STA $0F94				; Set spritemap timer to 1
RTL
}

print pc, " - Boss ShotAI"
.SHOTAI
LDX $0E54						; Load enemy index
LDA $0F7A,x						; Load enemy X position
STA $7EF434						; Store to special multi-drop location
LDA $0F7E,x						; Load enemy Y position
STA $7EF436						; Store to special multi-drop location
JSL $A0A6A7						; Run normal enemy hit AI skipping some things
LDA $0F8C,x	: BNE ..NotDead		; Load enemy health to see if it's dead
LDA #$0003
JSL $A0A3AF						; Run death animation
JSL $A0B92B						; Run multi-drop routine TO DO: MAKE OWN VERSION OF THIS
LDX #$00C0 : STX $0E54			; Trick the game to thinking it's working with Enemy 3 to remotely kill it
STZ $0F8C,x						; Set this enemy's HP to 0
JSL $A0A643						; Call Enemy Shot AI to kill it
LDX #$0100 : STX $0E54			; Trick the game to thinking it's working with Enemy 4 to remotely kill it
STZ $0F8C,x						; Set this enemy's HP to 0
JSL $A0A643						; Call Enemy Shot AI to kill it
STZ $0E54						; Restore the proper enemy index at this location
RTL
..NotDead
JSR ..PalChanges
RTL

print pc, " - Boss PaletteAI"
..PalChanges
LDA !paletteIndex		;\
CMP #$0010              ;| If [enemy health-based palette index] = 10h: return
BEQ ...Return       	;/
TAY                     ;\
LDA $0F8C	 			;|
CMP .PALTHRESHOLDS,y  	;| If [enemy health] >= [$981B + [enemy health-based palette index]]: return
BPL ...Return      	 	;/

...SkipCheck
CMP .PALTHRESHOLDS+2,y  ;\
BPL ...ShiftPAL			;|
INY #2					;| If the enemy has passed a second health threshold, increment Y and check again
JMP ...SkipCheck		;/

...ShiftPAL
TYA						;\
ASL #4                  ;| $12 = [enemy health-based palette index] * 10h
STA $12      			;/
LDA $0F96	  			;\
LSR #4                  ;| $14 = [enemy palette index] / 10h + 100h (palette data offset)
CLC                     ;|
ADC #$0100              ;|
STA $14      			;/

...LOOP
LDY $12      			;\
LDX $14      			;|
LDA .HEALTHPALETTES,y  	;| $7E:C000 + [$14] = [$971B + [$12]]
STA $7EC000,x			;/
INC $12      			;\
INC $12      			;| $12 += 2
INC $14      			;\
INC $14      			;| $14 += 2
LDA $14      			;\
CMP #$0140 : BNE ...LOOP;| If [$14] != 140h: go to LOOP
LDX $0E54    			;\
LDA !paletteIndex		;|
INC A                   ;| Enemy health-based palette index += 2
INC A                   ;|
STA !paletteIndex		;/
...Return
RTS

.STATEPOINTERS
DW .MAINAI_Follow, .MAINAI_AttackPrep, .MAINAI_Downward, .MAINAI_Return, .MAINAI_Intro, .MAINAI_Spawning

.INSTLISTS
print pc, " - Boss Instlists"
..IDLE
DW $0008, .SPM_EXTENDING
DW $0010, .SPM_IDLE1
DW $0020, .SPM_IDLE2
DW $0010, .SPM_IDLE1
DW $0030, .SPM_THRUSTING
DW $0010, .SPM_IDLE1, !sleep
..IDLE2
DW $0008, .SPM_RAISING
DW $0010, .SPM_IDLE1
DW $0020, .SPM_IDLE2
DW $0010, .SPM_IDLE1
DW $0030, .SPM_THRUSTING
DW $0010, .SPM_IDLE1, !sleep
..SPAWNING
DW $0008, .SPM_EXTENDING
DW $0008, .SPM_EXTENDED, !sleep
..PREPPING
DW $0002, .SPM_RAISING
DW $0002, .SPM_RAISING2, !sleep
..THRUSTING
DW $0004, .SPM_RAISING
DW $0004, .SPM_IDLE1
DW $0004, .SPM_THRUSTING, !sleep
..RETURNING
DW $0008, .SPM_IDLE1
DW $0008, .SPM_RAISING
DW $0008, .SPM_RAISING2, !sleep
..LEFTTHROW
DW $0004, .SPM_LEFTGRAB1
DW $0004, .SPM_LEFTGRAB2
DW $0004, .SPM_LEFTGRAB1
DW $0010, .SPM_IDLE1, !sleep
..RIGHTTHROW
DW $0004, .SPM_RIGHTGRAB1
DW $0004, .SPM_RIGHTGRAB2
DW $0004, .SPM_RIGHTGRAB1
DW $0010, .SPM_IDLE1, !sleep

.SPM
print pc, " - Boss Spritemaps"
{
..IDLE1
DW $0013

DW $0009 : DB $F8 : DW $6106	; Far right mustache
DW $0001 : DB $F8 : DW $6107	; Near right mustache
DW $01EF : DB $F8 : DW $2106	; Far left mustache
DW $01F7 : DB $F8 : DW $2107	; Near left mustache

DW $0000 : DB $F4 : DW $6102	; Upper right face
DW $01F8 : DB $F4 : DW $2102	; Upper left face
DW $0000 : DB $FC : DW $6112	; Lower right face
DW $01F8 : DB $FC : DW $2112	; Lower left face

DW $8000 : DB $EC : DW $6100	; Top Right helmet
DW $0008 : DB $FC : DW $6116	; Right helmet base

DW $81F0 : DB $EC : DW $2100	; Top Left helmet
DW $01F0 : DB $FC : DW $2116	; Left helmet base

DW $0000 : DB $FF : DW $6105	; Right shoulder
DW $01F8 : DB $FF : DW $2105	; Left shoulder
DW $0007 : DB $07 : DW $6115	; Right hand
DW $01F1 : DB $07 : DW $2115	; Left hand

DW $81F8 : DB $02 : DW $2103	; Body

DW $0002 : DB $0B : DW $6117	; Right foot
DW $01F6 : DB $0B : DW $2117	; Left foot

..IDLE2
DW $0013

DW $0009 : DB $F9 : DW $6106	; Far right mustache
DW $0001 : DB $F9 : DW $6107	; Near right mustache
DW $01EF : DB $F9 : DW $2106	; Far left mustache
DW $01F7 : DB $F9 : DW $2107	; Near left mustache

DW $0000 : DB $F5 : DW $6102	; Upper right face
DW $01F8 : DB $F5 : DW $2102	; Upper left face
DW $0000 : DB $FD : DW $6112	; Lower right face
DW $01F8 : DB $FD : DW $2112	; Lower left face

DW $8000 : DB $ED : DW $6100	; Top Right helmet
DW $0008 : DB $FD : DW $6116	; Right helmet base

DW $81F0 : DB $ED : DW $2100	; Top Left helmet
DW $01F0 : DB $FD : DW $2116	; Left helmet base

DW $0000 : DB $FF : DW $6105	; Right shoulder
DW $01F8 : DB $FF : DW $2105	; Left shoulder
DW $0007 : DB $07 : DW $6115	; Right hand
DW $01F1 : DB $07 : DW $2115	; Left hand

DW $81F8 : DB $02 : DW $2103	; Body

DW $0002 : DB $0B : DW $6117	; Right foot
DW $01F6 : DB $0B : DW $2117	; Left foot

..EXTENDING
DW $0013

DW $0009 : DB $F9 : DW $6106	; Far right mustache
DW $0001 : DB $F9 : DW $6107	; Near right mustache
DW $01EF : DB $F9 : DW $2106	; Far left mustache
DW $01F7 : DB $F9 : DW $2107	; Near left mustache

DW $0000 : DB $F5 : DW $6118	; Upper right face (Eyes closing)
DW $01F8 : DB $F5 : DW $2118	; Upper left face (Eyes closing)
DW $0000 : DB $FD : DW $6112	; Lower right face
DW $01F8 : DB $FD : DW $2112	; Lower left face

DW $8000 : DB $ED : DW $6100	; Top Right helmet
DW $0008 : DB $FD : DW $6116	; Right helmet base

DW $81F0 : DB $ED : DW $2100	; Top Left helmet
DW $01F0 : DB $FD : DW $2116	; Left helmet base

DW $0002 : DB $00 : DW $610A	; Right shoulder (extending)
DW $01F6 : DB $00 : DW $210A	; Left shoulder (extending)
DW $000A : DB $05 : DW $611A	; Right hand (extending)
DW $01EE : DB $05 : DW $211A	; Left hand (extending)

DW $81F8 : DB $02 : DW $2103	; Body

DW $0002 : DB $0B : DW $6117	; Right foot
DW $01F6 : DB $0B : DW $2117	; Left foot

..EXTENDED
DW $0013

DW $0009 : DB $F9 : DW $6106	; Far right mustache
DW $0001 : DB $F9 : DW $6107	; Near right mustache
DW $01EF : DB $F9 : DW $2106	; Far left mustache
DW $01F7 : DB $F9 : DW $2107	; Near left mustache

DW $0000 : DB $F5 : DW $6108	; Upper right face (Eyes closed)
DW $01F8 : DB $F5 : DW $2108	; Upper left face (Eyes closed)
DW $0000 : DB $FD : DW $6112	; Lower right face
DW $01F8 : DB $FD : DW $2112	; Lower left face

DW $8000 : DB $ED : DW $6100	; Top Right helmet
DW $0008 : DB $FD : DW $6116	; Right helmet base

DW $81F0 : DB $ED : DW $2100	; Top Left helmet
DW $01F0 : DB $FD : DW $2116	; Left helmet base

DW $0003 : DB $00 : DW $6109	; Right shoulder (extended)
DW $01F5 : DB $00 : DW $2109	; Left shoulder (extended)
DW $000A : DB $02 : DW $6119	; Right hand (extended)
DW $01EE : DB $02 : DW $2119	; Left hand (extended)

DW $81F8 : DB $02 : DW $2103	; Body

DW $0002 : DB $0B : DW $6117	; Right foot
DW $01F6 : DB $0B : DW $2117	; Left foot

..RAISING
DW $0013

DW $0009 : DB $F8 : DW $610B	; Far right mustache (raised)
DW $0001 : DB $F8 : DW $610C	; Near right mustache (raised)
DW $01EF : DB $F8 : DW $210B	; Far left mustache (raised)
DW $01F7 : DB $F8 : DW $210C	; Near left mustache (raised)

DW $0000 : DB $F4 : DW $6102	; Upper right face
DW $01F8 : DB $F4 : DW $2102	; Upper left face
DW $0000 : DB $FC : DW $6112	; Lower right face
DW $01F8 : DB $FC : DW $2112	; Lower left face

DW $8000 : DB $EC : DW $6100	; Top Right helmet
DW $0008 : DB $FC : DW $6116	; Right helmet base

DW $81F0 : DB $EC : DW $2100	; Top Left helmet
DW $01F0 : DB $FC : DW $2116	; Left helmet base

DW $0000 : DB $FE : DW $6105	; Right shoulder
DW $01F8 : DB $FE : DW $2105	; Left shoulder
DW $0007 : DB $06 : DW $6115	; Right hand
DW $01F1 : DB $06 : DW $2115	; Left hand

DW $81F8 : DB $02 : DW $2103	; Body

DW $0002 : DB $0B : DW $6117	; Right foot
DW $01F6 : DB $0B : DW $2117	; Left foot

..RAISING2
DW $0013

DW $0009 : DB $F8 : DW $610B	; Far right mustache (raised)
DW $0001 : DB $F8 : DW $610C	; Near right mustache (raised)
DW $01EF : DB $F8 : DW $210B	; Far left mustache (raised)
DW $01F7 : DB $F8 : DW $210C	; Near left mustache (raised)

DW $0000 : DB $F4 : DW $6102	; Upper right face
DW $01F8 : DB $F4 : DW $2102	; Upper left face
DW $0000 : DB $FC : DW $6112	; Lower right face
DW $01F8 : DB $FC : DW $2112	; Lower left face

DW $8000 : DB $EC : DW $6100	; Top Right helmet
DW $0008 : DB $FC : DW $6116	; Right helmet base

DW $81F0 : DB $EC : DW $2100	; Top Left helmet
DW $01F0 : DB $FC : DW $2116	; Left helmet base

DW $0001 : DB $FE : DW $610A	; Right shoulder (extending)
DW $01F7 : DB $FE : DW $210A	; Left shoulder (extending)
DW $0008 : DB $04 : DW $611A	; Right hand (extending)
DW $01F0 : DB $04 : DW $211A	; Left hand (extending)

DW $81F8 : DB $02 : DW $2103	; Body

DW $0002 : DB $0B : DW $6117	; Right foot
DW $01F6 : DB $0B : DW $2117	; Left foot

..THRUSTING
DW $0013

DW $0009 : DB $F9 : DW $6106	; Far right mustache
DW $0001 : DB $F9 : DW $6107	; Near right mustache
DW $01EF : DB $F9 : DW $2106	; Far left mustache
DW $01F7 : DB $F9 : DW $2107	; Near left mustache

DW $0000 : DB $F5 : DW $6102	; Upper right face
DW $01F8 : DB $F5 : DW $2102	; Upper left face
DW $0000 : DB $FD : DW $6112	; Lower right face
DW $01F8 : DB $FD : DW $2112	; Lower left face

DW $8000 : DB $ED : DW $6100	; Top Right helmet
DW $0008 : DB $FD : DW $6116	; Right helmet base

DW $81F0 : DB $ED : DW $2100	; Top Left helmet
DW $01F0 : DB $FD : DW $2116	; Left helmet base

DW $0000 : DB $FF : DW $6105	; Right shoulder
DW $01F8 : DB $FF : DW $2105	; Left shoulder
DW $0007 : DB $07 : DW $611B	; Right hand (Thrusting)
DW $01F1 : DB $07 : DW $211B	; Left hand (Thrusting)

DW $81F8 : DB $02 : DW $2103	; Body

DW $0002 : DB $0B : DW $6117	; Right foot
DW $01F6 : DB $0B : DW $2117	; Left foot

..LEFTGRAB1
DW $0013

DW $0009 : DB $F8 : DW $6106	; Far right mustache
DW $0001 : DB $F8 : DW $6107	; Near right mustache
DW $01EF : DB $F8 : DW $2106	; Far left mustache
DW $01F7 : DB $F8 : DW $2107	; Near left mustache

DW $0000 : DB $F4 : DW $6102	; Upper right face
DW $01F8 : DB $F4 : DW $2102	; Upper left face
DW $0000 : DB $FC : DW $6112	; Lower right face
DW $01F8 : DB $FC : DW $2112	; Lower left face

DW $8000 : DB $EC : DW $6100	; Top Right helmet
DW $0008 : DB $FC : DW $6116	; Right helmet base

DW $81F0 : DB $EC : DW $2100	; Top Left helmet
DW $01F0 : DB $FC : DW $2116	; Left helmet base

DW $0000 : DB $FF : DW $6105	; Right shoulder
DW $0007 : DB $07 : DW $6115	; Right hand
DW $01F8 : DB $FF : DW $2105	; Left shoulder

DW $81F8 : DB $02 : DW $2103	; Body

DW $01F1 : DB $07 : DW $211B	; Left hand (Thrusting)

DW $0002 : DB $0B : DW $6117	; Right foot
DW $01F6 : DB $0B : DW $2117	; Left foot

..LEFTGRAB2
DW $0013

DW $0009 : DB $F8 : DW $6106	; Far right mustache
DW $0001 : DB $F8 : DW $6107	; Near right mustache
DW $01EF : DB $F8 : DW $2106	; Far left mustache
DW $01F7 : DB $F8 : DW $2107	; Near left mustache

DW $0000 : DB $F4 : DW $6102	; Upper right face
DW $01F8 : DB $F4 : DW $2102	; Upper left face
DW $0000 : DB $FC : DW $6112	; Lower right face
DW $01F8 : DB $FC : DW $2112	; Lower left face

DW $8000 : DB $EC : DW $6100	; Top Right helmet
DW $0008 : DB $FC : DW $6116	; Right helmet base

DW $81F0 : DB $EC : DW $2100	; Top Left helmet
DW $01F0 : DB $FC : DW $2116	; Left helmet base

DW $0000 : DB $FF : DW $6105	; Right shoulder
DW $0007 : DB $07 : DW $6115	; Right hand
DW $01F8 : DB $FF : DW $2105	; Left shoulder

DW $81F8 : DB $02 : DW $2103	; Body

DW $01F3 : DB $07 : DW $211C	; Left hand (Down)

DW $0002 : DB $0B : DW $6117	; Right foot
DW $01F6 : DB $0B : DW $2117	; Left foot

..RIGHTGRAB1
DW $0013

DW $0009 : DB $F8 : DW $6106	; Far right mustache
DW $0001 : DB $F8 : DW $6107	; Near right mustache
DW $01EF : DB $F8 : DW $2106	; Far left mustache
DW $01F7 : DB $F8 : DW $2107	; Near left mustache

DW $0000 : DB $F4 : DW $6102	; Upper right face
DW $01F8 : DB $F4 : DW $2102	; Upper left face
DW $0000 : DB $FC : DW $6112	; Lower right face
DW $01F8 : DB $FC : DW $2112	; Lower left face

DW $8000 : DB $EC : DW $6100	; Top Right helmet
DW $0008 : DB $FC : DW $6116	; Right helmet base

DW $81F0 : DB $EC : DW $2100	; Top Left helmet
DW $01F0 : DB $FC : DW $2116	; Left helmet base

DW $0000 : DB $FF : DW $6105	; Right shoulder
DW $01F8 : DB $FF : DW $2105	; Left shoulder
DW $01F1 : DB $07 : DW $2115	; Left hand

DW $81F8 : DB $02 : DW $2103	; Body

DW $0007 : DB $07 : DW $611B	; Right hand (Thrusting)

DW $0002 : DB $0B : DW $6117	; Right foot
DW $01F6 : DB $0B : DW $2117	; Left foot

..RIGHTGRAB2
DW $0013

DW $0009 : DB $F8 : DW $6106	; Far right mustache
DW $0001 : DB $F8 : DW $6107	; Near right mustache
DW $01EF : DB $F8 : DW $2106	; Far left mustache
DW $01F7 : DB $F8 : DW $2107	; Near left mustache

DW $0000 : DB $F4 : DW $6102	; Upper right face
DW $01F8 : DB $F4 : DW $2102	; Upper left face
DW $0000 : DB $FC : DW $6112	; Lower right face
DW $01F8 : DB $FC : DW $2112	; Lower left face

DW $8000 : DB $EC : DW $6100	; Top Right helmet
DW $0008 : DB $FC : DW $6116	; Right helmet base

DW $81F0 : DB $EC : DW $2100	; Top Left helmet
DW $01F0 : DB $FC : DW $2116	; Left helmet base

DW $0000 : DB $FF : DW $6105	; Right shoulder
DW $01F1 : DB $07 : DW $2115	; Left hand
DW $01F8 : DB $FF : DW $2105	; Left shoulder

DW $81F8 : DB $02 : DW $2103	; Body

DW $0005 : DB $07 : DW $611C	; Right hand (Down)

DW $0002 : DB $0B : DW $6117	; Right foot
DW $01F6 : DB $0B : DW $2117	; Left foot
}
.PAL
DW $3800, $6A0C, $59CB, $458A, $0000, $4275, $3612, $08A7, $0844, $335C, $7FFF, $0000, $0000, $0000, $0000, $0000

.PALTHRESHOLDS
dw $0E00, $0C00, $0A00, $0800, $0600, $0400, $0200, $0000, $FFFF  ; Terminator

.HEALTHPALETTES
dw $3800, $6A0C, $59CB, $458A, $0000, $4275, $3612, $08A7, $0844, $335C, $7FFF, $0000, $0000, $0000, $0000, $0000
dw $3800, $5DCE, $4D8C, $3D4B, $0000, $4274, $3611, $08A7, $0844, $3B5C, $7FFF, $0000, $0000, $0000, $0000, $0000
dw $3800, $51B0, $456E, $352C, $0000, $4673, $3A10, $08A7, $0844, $435C, $7FFF, $0000, $0000, $0000, $0000, $0000
dw $3800, $4992, $392F, $2CED, $0000, $4A72, $3E0F, $08A7, $0844, $4B5C, $7FFF, $0000, $0000, $0000, $0000, $0000
dw $3800, $3D74, $3111, $24CF, $0000, $4E71, $420E, $08A7, $0844, $537C, $7FFF, $0000, $0000, $0000, $0000, $0000
dw $3800, $3156, $24D3, $1CB0, $0000, $4E70, $420D, $08A7, $0844, $5B7C, $7FFF, $0000, $0000, $0000, $0000, $0000
dw $3800, $2938, $1CB4, $1471, $0000, $526F, $460C, $08A7, $0844, $637C, $7FFF, $0000, $0000, $0000, $0000, $0000
dw $3800, $14FC, $0858, $0434, $0000, $5A6E, $4E0B, $08A7, $0844, $739C, $7FFF, $0000, $0000, $0000, $0000, $0000
}

org !A4Free
Shield:
{
.SETUPAI
LDX $0E54								; Load enemy index
LDA #.INSTLISTS_IDLE	: STA $0F92,x	; Load idle instruction list and store to memory
LDA #$2500 : STA $0F86,x				; Make shield intangible and invisible at the start
RTL

.MAINAI
LDY $0E54						; Load enemy index
LDA $0F8C : BEQ ..Kill			; Get HP of enemy 0; Kill the sheild if the boss is dead.
LDX !state,y					; Load the current state of the sheild
CPX #$0008 : BEQ ..States		; If inactive, skip to "inactive" code
LDX !state	 					; Load state of enemy 0 to x
..States
JMP (.STATEPOINTERS,x)			; Jump to states based on STATEPOINTERS

..Kill
TYX 
STZ $0F8C,x						; Set this enemy's HP to 0
JSL $A3802D						; Call Enemy Shot AI to kill it
RTL

..Stopped
TYX
LDA $0F7A : STA $0F7A,x			; Set X position of enemy to that of enemy 0
LDA $0F7E 
CLC : ADC #$0018 : STA $0F7E,x	; Set Y position of enemy to that of enemy 0 + 18
LDA !timer 						; Load timer of enemy 0
CMP #$0001 : BEQ ..StartPrep	; If Timer = 1, Store Y position
RTL

..StartPrep
LDA $0F7E 
CLC : ADC #$0018 : STA $0F7E,x	; Set Y position of enemy to that of enemy 0 + 18
STA $0FAA,x						; Store this Y position to memory. This will be the return height
RTL

..AttackPrep
TYX
LDA $0FAA,x						; Load initial Y Position
CLC
SBC #$0002				
CMP $0F7E,x : BPL ...End		; If it has reached !prepheight above the position it started at, stop
LDA #$FFFE						; Upward Speed
STZ $12
STA $14						
JSL $A0C786						; Move enemy up by A speed
...End
RTL

..Downward
TYX
LDA #$0003								; Downward Speed
STA $14		
LDA !HPComparitor : SEC : SBC !currHP	; Get HP of damage dealt to boss
ASL #3 : STA $12  						; Apply it to subpixel speed				
JSL $A0C786								; Move enemy down by A speed
RTL


..Return
TYX
LDA $0FAA,x								; Load initial Y Position
CMP $0F7E,x : BEQ ..Stop : BPL ..THigh	; If it has reached the position it started at, reset
LDA #$FFFE								; Upward Speed
STA $14
LDA !HPComparitor : SEC : SBC !currHP	; Get HP of damage dealt to boss
ASL #3 : EOR #$FFFF : STA $12  			; Apply it to subpixel speed
JSL $A0C786								; Move enemy up by A speed
..Stop
..Inactive
..Spawning
RTL
..THigh	
LDA $0F7E 
CLC : ADC #$0018 : STA $0F7E,x			; Set Y position of enemy to that of enemy 0 + 18, correcting any overshoots
RTL

.STATEPOINTERS
DW .MAINAI_Stopped, .MAINAI_AttackPrep, .MAINAI_Downward, .MAINAI_Return, .MAINAI_Inactive, .MAINAI_Spawning

.INSTLISTS
print pc, " - Shield Instlists"
..IDLE
DW $0010, .SPM_IDLE1
DW $0010, .SPM_IDLE2
DW $0010, .SPM_IDLE3
DW $0010, .SPM_IDLE4
DW $0010, .SPM_IDLE5
DW $0010, .SPM_IDLE6
DW $0010, .SPM_IDLE7
DW $80ED, ..IDLE

.SPM
print pc, " - Shield Spritemaps"
..IDLE1
DW $0004
DW $0008 : DB $FC : DW $6100	; Rightmost
DW $0000 : DB $FC : DW $6101	; Right
DW $01F8 : DB $FC : DW $2101	; Left
DW $01F0 : DB $FC : DW $2100	; Leftmost
..IDLE2
DW $0004
DW $0008 : DB $FC : DW $6102	; Rightmost
DW $0000 : DB $FC : DW $6103	; Right
DW $01F8 : DB $FC : DW $2103	; Left
DW $01F0 : DB $FC : DW $2102	; Leftmost
..IDLE3
DW $0004
DW $0008 : DB $FC : DW $6104	; Rightmost
DW $0000 : DB $FC : DW $6105	; Right
DW $01F8 : DB $FC : DW $2105	; Left
DW $01F0 : DB $FC : DW $2104	; Leftmost
..IDLE4
DW $0004
DW $0008 : DB $FC : DW $6106	; Rightmost
DW $0000 : DB $FC : DW $6107	; Right
DW $01F8 : DB $FC : DW $2107	; Left
DW $01F0 : DB $FC : DW $2106	; Leftmost
..IDLE5
DW $0004
DW $0008 : DB $FC : DW $6108	; Rightmost
DW $0000 : DB $FC : DW $6109	; Right
DW $01F8 : DB $FC : DW $2109	; Left
DW $01F0 : DB $FC : DW $2108	; Leftmost
..IDLE6
DW $0004
DW $0008 : DB $FC : DW $610A	; Rightmost
DW $0000 : DB $FC : DW $610B	; Right
DW $01F8 : DB $FC : DW $210B	; Left
DW $01F0 : DB $FC : DW $210A	; Leftmost
..IDLE7
DW $0004
DW $0008 : DB $FC : DW $610C	; Rightmost
DW $0000 : DB $FC : DW $610D	; Right
DW $01F8 : DB $FC : DW $210D	; Left
DW $01F0 : DB $FC : DW $210C	; Leftmost

.PAL
db $00,$00,$FF,$7F,$DE,$7B,$BD,$77,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
}


org !86Free 
SwordProjectile:
{
DW .InitAI, .MAINAI, .GFXPointer : DB $04, $10 : DW $C032, $0000, $84FB
print pc, " - Sword Projectile InitAI"
.InitAI
LDA $0F7A : STA $1A4B,y				; X position of projectile = X position of enemy 0
LDA $0F7E : STA $1A93,y				; Y position of projectile = Y position of enemy 0
LDA $1993 : STA !swordPosition,y	; Store initialization variable as sword position indicator
TYX : LDA #$0001 : STA $7EF380,x	; Attempt to make the projectile immute to shots
RTS

print pc, " - Sword Projectile MainAI"
.MAINAI
TXY								; Put projectile index into Y instead of X
LDA $0F8C : BEQ ..Kill			; Get HP of enemy 0; Kill the sword if the boss is dead.
LDX !state	 					; Load state of enemy 0 to x
..States
JMP (.STATEPOINTERS,x)			; Jump to states based on STATEPOINTERS

..Kill
LDA !projectileTimer,x			; Load this enemy's timer to A
SEC : SBC #$0010 : TAY			; Add a 16 frame delay before the swords fall. Store A in Y
LDA !swordPosition,x			; Get sword's position indicator 
BIT #$0004 : BEQ ..NoExtraDelay	; If sword is on the outer layer, add an extra delay
TYA : SEC : SBC #$0010 : TAY
..NoExtraDelay

TYA
BMI ..NoFloorHit
PHX : ASL #3 : TAX : PLY		; Shift this left by 3 to align with quadratic speed chart and move to X for indexing. Put projectile index into Y at same time
LDA $1A6F,y						;\ Get projectile subpixel position
CLC : ADC $A0CBC7,x				;| If [enemy projectile $1A6F] + [$A0:CBC7 + [X]] >= 10000h:
BCC ..NoSubMovement				;/ If subpixel speed does not overflow, skip next step
PHA								;\
LDA $1A93,y						;|
INC A							;| Increment enemy projectile Y position
STA $1A93,y						;|
PLA								;/

..NoSubMovement
STA $1A6F,y				 ; Store new subpixel position
LDA $1A93,y 			 ;\
CLC             		 ;|
ADC $A0CBC9,x			 ;| Enemy projectile Y position += Gravity value
STA $1A93,y  			 ;/



TYX
LDA $1A93,y : CMP #$00C8
BMI ..NoFloorHit				; If the enemy has not hit the ground, don't prematurely kill it
LDA #$00C8 : STA $1A93,y  		; Enemy projectile Y position = C8h
LDA #$EB93 : STA $1A03,y  		; Enemy projectile function = RTS
LDA #$E208 : STA $1B47,y  		; Enemy projectile instruction list pointer = $E208
LDA #$0A00 : STA $19BB,y  		; Enemy projectile VRAM tiles index = 0, palette index = 5
LDA #$0001 : STA $1B8F,y  		; Enemy projectile instruction timer = 1
JSR $EB94    					; Queue small explosion sound effect
LDA $19D7                       ; Check to see if a fourth enemy projectile ever spawned in the room (Second set of swords spawned)
BEQ ..QuickKillFailsafe         ; If so, run the code that checks for sword 0002 instead of 0006
LDA !swordPosition,x
CMP #$0006 : BEQ ..FinalSword	; If this is the last sword on the list, perform final procedures
RTS
..NoFloorHit
INC !projectileTimer,x			; Increment this projectile's timer
RTS

..QuickKillFailsafe
LDA !swordPosition,x
CMP #$0002 : BEQ ..FinalSword	; If this is the last sword on the list, perform final procedures
RTS

..FinalSword
STZ $0E52						; Unlock the doors
LDA #$0004 : JSL $808FC1		; Reset music
STZ $05F7						; Enable the minimap
LDY #$D9D8 : JSL $8DC4E9		; Spawn palette FX Object for color reset
RTS


..Stopped
TYX
LDY !swordPosition,x			; Get the enemy's position indicator
LDA .SWORDDISTANCES,y			; Determine how far away from boss to be
CLC : ADC $0F7A					; Add it to the X position of Enemy 0 (The Boss)
STA $1A4B,x						; Store this position to the sword
LDA $0F7E : STA $1A93,x			; Y position of enemy = Y position of enemy 0
LDA !timer 						; Load timer of enemy 0
CMP #$0001 : BEQ ..StartPrep	; If Timer = 1, Store Y position
RTS

..StartPrep
LDA $0F7E : STA !returnHeight,x	; Store enemy 0 Y position to memory. This will be the return height
LDA #$FD00 : STA $1ADB,x		; Upward Speed = FD Pixels and 00 Subpixels. Store to projectile Y velocity		
RTS

..AttackPrep
TYX
LDA !returnHeight,x				; Load initial Y Position
CLC
SBC !prepheight					
CMP $1A93,x : BPL ...SlashReady	; If it has reached !prepheight above the position it started at, stop				
JSR $897B						; Move enemy up by previously-determined speed
BRA ...End						
...SlashReady
LDA !HPComparitor : SEC : SBC !currHP	; Get HP of damage dealt to boss
LSR #5 : AND #$00FF						; Shift over 5 times to right nybble and chop off left nybble to get subspeed
ORA #$0300 : STA $1ADB,x  				; Set pixel speed to 3 and apply to speed
...End
RTS

..Downward
TYX
JSR $897B						; Move enemy down by previously-determined speed
RTS


..Return
TYX
LDA !returnHeight,x						; Load initial Y Position
CMP $1A93,x : BEQ ..Reset : BPL ..THigh	; If it has reached the position it started at, reset
LDA !HPComparitor : SEC : SBC !currHP	; Get HP of damage dealt to boss
LSR #5 : EOR #$FFFF : AND #$00FF		; Negate value and chop off left nybble to get subspeed
ORA #$FE00 : STA $1ADB,x					; Set pixel speed to -2 and apply to speed
JSR $897B								; Move enemy up by previously-determined speed
RTS
..THigh
LDA $0F7E : STA $1A93,x			; Y position of enemy = Y position of enemy 0, correcting the height
..Reset
LDA !state0 : STA !state		; set state of enemy 0 to 0
LDA #$0080 : STA !timer			; set timer of enemy 0 to 80

LDA #Boss_INSTLISTS_IDLE2 : STA $0F92	; Load idle spritemap for enemy 0
LDA #$0001 : STA $0F94					; Set spritemap timer to 1 for enemy 0
RTS

..Inactive
RTS

..Spawning
TYX
LDA !swordPosition,x : AND #$0002	; Load the enemy's speed and see if the enemy goes on the left or right
CMP #$0002 : BEQ ...Left

LDY !swordPosition,x				; Get the enemy's speed
LDA .SWORDDISTANCES,y				; Determine how far away from boss it can go
CLC : ADC $0F7A						; Add it to the X position of Enemy 0 (The Boss)
CMP $1A4B,x	: BEQ ...End			; If sword is where it is supposed to be, stop
INC $1A4B,x							; Otherwise, move right by one pixel
BRA ...End

...Left
LDY !swordPosition,x				; Get the enemy's speed
LDA .SWORDDISTANCES,y				; Determine how far away from boss it can go
CLC : ADC $0F7A						; Add it to the X position of Enemy 0 (The Boss)
CMP $1A4B,x	: BEQ ...End			; If sword is where it is supposed to be, stop
DEC $1A4B,x							; Otherwise, move left by one pixel

...End
RTS



.STATEPOINTERS
DW .MAINAI_Stopped, .MAINAI_AttackPrep, .MAINAI_Downward, .MAINAI_Return, .MAINAI_Inactive, .MAINAI_Spawning

.SWORDDISTANCES
DW $0020, $FFE0, $0030, $FFD0					; Distances for swords to stay from boss based on Speed

.GFXPointer
print pc, " - Sword Instlists"
..IDLE
DW $0010, .Spritemap, $8159

; Projectile spritemaps must be in Bank $8D
org $8D8EF3
print pc, " - Sword Projectile Spritemaps"
.Spritemap
DW $0002
DW $81F8 : DB $F0 : DW $2100	; Top
DW $81F8 : DB $00 : DW $2102	; Bottom
}


; Original typewriter code by Drewseph
org !A5Free
print pc, " - Typewriter AI"
{
AREA_TITLE_SHOT_AI:
;	PHX : LDA $18A6 : ASL A : TAX : LDA $0C04,X : AND #$FFEF : STA $0C04,X : PLX : RTL
	RTL
AREA_TITLE_INIT:	
	LDA.w #GFX_REFRESH
	STA $00
	LDA.w #GFX_REFRESH>>8
	STA $01
	JSL $818EB2

	LDA $0E54
	STA !TITLE_INDEX
	TAX
	; Speed2 = Event to check and set
	PHX
	LDA $0FB6,X : JSL $80818E : LDA $7ED820,X : BIT $05E7 : BNE KILL_AREA_TITLE ; Check to see if it has already been shown
	PLX
	LDA $0FB4,x	; Loads enemy Speed
	ASL A		; Multiplies by 2 to get a valid pointer
	PHY
	TAY
	LDA TITLE_TABLE,y
	STA $0F92,X	; Stores the gfx pointer to change the message to be shown
	LDA TITLE_LETTER_COUNT,y
	STA $0FAC,X	; Stores Maximum Letters in title card
	LDA TITLE_INIT_DELAY,y
	STA	$0FB2,X	; Stores a timer, which will Dec each frame
	LDA TITLE_LIFESPAN,y
	STA $0FAE,X	; Stores Master lifespan for title card once xray fool tile is touched
	PLY
	RTL
KILL_AREA_TITLE:
	PLX
	STZ !TITLE_INDEX
	STZ $0F78,X
	RTL
TITLE_TABLE:
dw A_CERES_STATION,A_CRATERIA,A_CRATERIA_DEPTHS,A_BRINSTAR,A_NORFAIR
dw A_LOWER_NORFAIR,A_LOST_CAVERNS,A_MARIDIA,A_TOURIAN_ACCESS,A_TOURIAN
TITLE_LETTER_COUNT:
dw $0020,$000A,$0011,$000A,$0009,$000F,$000E,$0009,$0010,$0009
TITLE_INIT_DELAY:
dw $FFFF,$FFFF,$003C,$003C,$003C
dw $003C,$003C,$003C,$003C,$003C
TITLE_LIFESPAN:
dw $01E0,$01A4,$01E0,$01A4,$01A4,$01E0,$01E0,$01A4,$01E0,$01A4
TC_SPACE_PAUSES:		; Time to wait for each different space tile
dw $0006, $0032, $0064

AREA_TITLE_AI:
	LDX $0E54		; Loads Current enemy in room
	LDA $07F3 : CMP #$0021 : BPL + 		; Check to see if the song is at or above set 21 (Mother brain fight) 
	LDA $0F94,X							; Load enemy instruction timer (lifetime)
	CMP #$0002							
	BNE ++								; Continue if not equal to 2
+	;STZ $0F7A,x		; Zero out enemy X position
	;STZ $0F7E,x		; Zero out enemy Y position
	STZ $0F78,X 	; Zero out enemy ID (to delete it?)
	RTL
++	TXA
	RTL
;	$0F7A,x	= Current Enemies X position in room
;	$0F7E,x	= Current Enemies Y position in room
;	$7E7024,x = Mirrors Enemy Orientations
;	$0F92,x = Current Enemy GFX pointer, change this, you change the world!(enemy)
;	$0F94,x = LIFETIME for title card
;	$0FB6,X = Speed 2, event bit to check
;	$0FB4,x = Current Enemy Speed:	Used to determine the Title Card to show
;	$0FA4,x = Counter for current enemy
;	$0FB2,x = TIMER: How Long before INCREASE in the letter count in frames
;	$0FAA,X = LETTER COUNT: INCREASES every time ^ Reaches its max character count
;	$0FAC,X = MAXIMUM LETTER COUNT:  ^^^ I compared to this evert frame
				; If equal, then stop increasing
	
 AREA_TILE_INIT: ; This is a blank text field
	DW $0010,AT_BRINSTAR ; AREA_BLANK
	DW $80ED,AREA_TILE_INIT
;------------------------------------------------------------------------------------	

; Format: $XX,$01,$YY,$LL,$3A
; $XX = Letter X position
; $01 = Negative X bit (Set if to the left of enemy, not if to the right) 
; $YY = Letter Y position
; $LL = Letter tile number ('A' = $D0, 'B' = $D1, etc.)
; $3A = Sprite attributes

print pc, " - Typewriter Spritemaps"
; Graphics found at $9AEC00 (PC: D6C00)
 A_CERES_STATION:		; Speed	$0000
	DW $01A4,AT_CERES_STATION
	DW $80ED,A_CERES_STATION
AT_CERES_STATION:	 DW $0020	
	DB $C8,$01,$C0,$E3,$3A ; T
	DB $D0,$01,$C0,$D7,$3A ; H
	DB $D8,$01,$C0,$D4,$3A ; E
	DB $E0,$01,$C0,$E8,$3A ; Y
	DB $E8,$01,$C0,$ED,$3A ;  
	DB $F0,$01,$C0,$D0,$3A ; A
	DB $F8,$01,$C0,$E1,$3A ; R
	DB $00,$00,$C0,$D4,$3A ; E
	DB $08,$00,$C0,$ED,$3A ;  
	DB $10,$00,$C0,$D2,$3A ; C
	DB $18,$00,$C0,$DE,$3A ; O
	DB $20,$00,$C0,$DC,$3A ; M
	DB $28,$00,$C0,$D8,$3A ; I
	DB $30,$00,$C0,$DD,$3A ; N
	DB $38,$00,$C0,$D6,$3A ; G
	DB $40,$00,$C0,$EB,$3A ; .
	DB $48,$00,$C0,$EB,$3A ; .
	DB $50,$00,$C0,$EB,$3A ; .
	DB $58,$00,$C0,$EE,$3A ; Short pause
	DB $C8,$01,$D0,$E6,$3A ; W
	DB $D0,$01,$D0,$D7,$3A ; H
	DB $D8,$01,$D0,$D0,$3A ; A
	DB $E0,$01,$D0,$E3,$3A ; T
	DB $E8,$01,$D0,$ED,$3A ;  
	DB $F0,$01,$D0,$D3,$3A ; D
	DB $F8,$01,$D0,$DE,$3A ; O
	DB $00,$00,$D0,$ED,$3A ;  
	DB $08,$00,$D0,$D8,$3A ; I
	DB $10,$00,$D0,$ED,$3A ;  
	DB $18,$00,$D0,$D3,$3A ; D
	DB $20,$00,$D0,$DE,$3A ; O
	DB $28,$00,$D0,$EC,$3A ; ?
;------------------------------------------------------------------------------------
 A_CRATERIA:			; Speed	$0001
	DW $01D4,AT_CRATERIA
	DW $80ED,A_CRATERIA
AT_CRATERIA:	 DW $000A	
	DB $B0,$01,$FC,$EA,$3A ; -
	DB $B8,$01,$FC,$D2,$3A ; C
	DB $C0,$01,$FC,$E1,$3A ; R
	DB $C8,$01,$FC,$D0,$3A ; A
	DB $D0,$01,$FC,$E3,$3A ; T
	DB $D8,$01,$FC,$D4,$3A ; E
	DB $E0,$01,$FC,$E1,$3A ; R
	DB $E8,$01,$FC,$D8,$3A ; I
	DB $F0,$01,$FC,$D0,$3A ; A
	DB $F8,$01,$FC,$EA,$3A ; -
;------------------------------------------------------------------------------------
 A_CRATERIA_DEPTHS:	; Speed	$0002
	DW $01E0,AT_CRATERIA_DEPTHS
	DW $80ED,A_CRATERIA_DEPTHS
AT_CRATERIA_DEPTHS:	 DW $0011	
	DB $78,$01,$FC,$F4,$3A ; -
	DB $80,$01,$FC,$EA,$3A ; C
	DB $88,$01,$FC,$F8,$3A ; R
	DB $90,$01,$FC,$DE,$3A ; A
	DB $98,$01,$FC,$FA,$3A ; T
	DB $A0,$01,$FC,$EC,$3A ; E
	DB $A8,$01,$FC,$F8,$3A ; R
	DB $B0,$01,$FC,$EE,$3A ; I
	DB $B8,$01,$FC,$DE,$3A ; A
	DB $C0,$01,$FC,$F3,$3A ;  
	DB $C8,$01,$FC,$EB,$3A ; D
	DB $D0,$01,$FC,$EC,$3A ; E
	DB $D8,$01,$FC,$FF,$3A ; P
	DB $E0,$01,$FC,$FA,$3A ; T
	DB $E8,$01,$FC,$FE,$3A ; H
	DB $F0,$01,$FC,$F9,$3A ; S
	DB $F8,$01,$FC,$F4,$3A ; -
;------------------------------------------------------------------------------------
 A_BRINSTAR:			; Speed	$0003
	DW $01A4,AT_BRINSTAR
	DW $80ED,A_BRINSTAR
AT_BRINSTAR:	DW $000A	
	DB $B0,$01,$FC,$F4,$3A	; -
	DB $B8,$01,$FC,$DF,$3A	; B
	DB $C0,$01,$FC,$F8,$3A	; R
	DB $C8,$01,$FC,$EE,$3A	; I
	DB $D0,$01,$FC,$F6,$3A	; N
	DB $D8,$01,$FC,$F9,$3A	; S
	DB $E0,$01,$FC,$FA,$3A	; T
	DB $E8,$01,$FC,$DE,$3A	; A
	DB $F0,$01,$FC,$F8,$3A	; R
	DB $F8,$01,$FC,$F4,$3A	; -
;------------------------------------------------------------------------------------
 A_NORFAIR:			; Speed	$0004
	DW $01A4,AT_NORFAIR
	DW $80ED,A_NORFAIR
AT_NORFAIR:		DW $0009	
	DB $B8,$01,$FC,$F4,$3A ; -
	DB $C0,$01,$FC,$F6,$3A ; N
	DB $C8,$01,$FC,$F7,$3A ; O
	DB $D0,$01,$FC,$F8,$3A ; R
	DB $D8,$01,$FC,$ED,$3A ; F
	DB $E0,$01,$FC,$DE,$3A ; A
	DB $E8,$01,$FC,$EE,$3A ; I
	DB $F0,$01,$FC,$F8,$3A ; R
	DB $F8,$01,$FC,$F4,$3A ; -
;------------------------------------------------------------------------------------
 A_LOWER_NORFAIR:		; Speed	$0005
	DW $01E0,AT_LOWER_NORFAIR
	DW $80ED,A_LOWER_NORFAIR
AT_LOWER_NORFAIR:	DW $000F	
	DB $88,$01,$FC,$F4,$3A ; -
	DB $90,$01,$FC,$EF,$3A ; L
	DB $98,$01,$FC,$F7,$3A ; O
	DB $A0,$01,$FC,$FC,$3A ; W
	DB $A8,$01,$FC,$EC,$3A ; E
	DB $B0,$01,$FC,$F8,$3A ; R
	DB $B8,$01,$FC,$F3,$3A ;  
	DB $C0,$01,$FC,$F6,$3A ; N
	DB $C8,$01,$FC,$F7,$3A ; O
	DB $D0,$01,$FC,$F8,$3A ; R
	DB $D8,$01,$FC,$ED,$3A ; F
	DB $E0,$01,$FC,$DE,$3A ; A
	DB $E8,$01,$FC,$EE,$3A ; I
	DB $F0,$01,$FC,$F8,$3A ; R
	DB $F8,$01,$FC,$F4,$3A ; -
;------------------------------------------------------------------------------------
 A_LOST_CAVERNS:		; Speed	$0006
	DW $01E0,AT_LOST_CAVERNS
	DW $80ED,A_LOST_CAVERNS
AT_LOST_CAVERNS:	 DW $000E	
	DB $90,$01,$FC,$F4,$3A ; -
	DB $98,$01,$FC,$EF,$3A ; L
	DB $A0,$01,$FC,$F7,$3A ; O
	DB $A8,$01,$FC,$F9,$3A ; S
	DB $B0,$01,$FC,$FA,$3A ; T
	DB $B8,$01,$FC,$F3,$3A ;  
	DB $C0,$01,$FC,$EA,$3A ; C
	DB $C8,$01,$FC,$DE,$3A ; A
	DB $D0,$01,$FC,$FD,$3A ; V
	DB $D8,$01,$FC,$EC,$3A ; E
	DB $E0,$01,$FC,$F8,$3A ; R
	DB $E8,$01,$FC,$F6,$3A ; N
	DB $F0,$01,$FC,$F9,$3A ; S
	DB $F8,$01,$FC,$F4,$3A ; -
;------------------------------------------------------------------------------------
 A_MARIDIA:			; Speed	$0007
	DW $01A4,AT_MARIDIA
	DW $80ED,A_MARIDIA
AT_MARIDIA:	 DW $0009	
	DB $B8,$01,$FC,$F4,$3A ; -
	DB $C0,$01,$FC,$F5,$3A ; M
	DB $C8,$01,$FC,$DE,$3A ; A
	DB $D0,$01,$FC,$F8,$3A ; R
	DB $D8,$01,$FC,$EE,$3A ; I
	DB $E0,$01,$FC,$EB,$3A ; D
	DB $E8,$01,$FC,$EE,$3A ; I
	DB $F0,$01,$FC,$DE,$3A ; A
	DB $F8,$01,$FC,$F4,$3A ; -
;------------------------------------------------------------------------------------
 A_TOURIAN_ACCESS:		; Speed	$0008
	DW $01E0,AT_TOURIAN_ACCESS
	DW $80ED,A_TOURIAN_ACCESS
AT_TOURIAN_ACCESS:	 DW $0010	
	DB $80,$01,$FC,$F4,$3A ; -
	DB $88,$01,$FC,$FA,$3A ; T
	DB $90,$01,$FC,$F7,$3A ; O
	DB $98,$01,$FC,$FB,$3A ; U
	DB $A0,$01,$FC,$F8,$3A ; R
	DB $A8,$01,$FC,$EE,$3A ; I
	DB $B0,$01,$FC,$DE,$3A ; A
	DB $B8,$01,$FC,$F6,$3A ; N
	DB $C0,$01,$FC,$F3,$3A ;  
	DB $C8,$01,$FC,$DE,$3A ; A
	DB $D0,$01,$FC,$EA,$3A ; C
	DB $D8,$01,$FC,$EA,$3A ; C
	DB $E0,$01,$FC,$EC,$3A ; E
	DB $E8,$01,$FC,$F9,$3A ; S
	DB $F0,$01,$FC,$F9,$3A ; S
	DB $F8,$01,$FC,$F4,$3A ; -
;------------------------------------------------------------------------------------
 A_TOURIAN:			; Speed	$0009
	DW $01A4,AT_TOURIAN
	DW $80ED,A_TOURIAN
AT_TOURIAN:	 DW $0009	
	DB $B8,$01,$FC,$F4,$3A ; -
	DB $C0,$01,$FC,$FA,$3A ; T
	DB $C8,$01,$FC,$F7,$3A ; O
	DB $D0,$01,$FC,$FB,$3A ; U
	DB $D8,$01,$FC,$F8,$3A ; R
	DB $E0,$01,$FC,$EE,$3A ; I
	DB $E8,$01,$FC,$DE,$3A ; A
	DB $F0,$01,$FC,$F6,$3A ; N
	DB $F8,$01,$FC,$F4,$3A ; -

}

; Other Typewriter-necessary code
{
 ; HIJACK POINT FOR TITLE CARD
org $818AB8
	JMP $F780
	NOP

org $81F780
	PHA
	LDA $0F78,X					; Loads Current Enemy
	CMP !TITLE_HEADER_LOCATION	; Checks if its a Title Card
	BEQ TC_CONTINUE				
	CMP !BOSS_HEADER_LOCATION	; Checks if its a Sammer Guy Boss
	BNE TC_WRONG_ENEMY
	LDA !state,x : CMP #$0008	; Check to see if the Sammer Guy Boss is in its intro state
	BEQ TC_CONTINUE
TC_WRONG_ENEMY:
	JMP TC_HIJACK_END			; branch to end if Not
	
TC_CONTINUE:
	PLA
	LDA $0FB2,X	; Loads Timer
	BNE ++
	PHX			; Save X for later
	LDA $0FB6,X	; Checks speed 2 for Event bit to check
	BEQ +
	JSL $80818E
	LDA $7ED820,X
	ORA $05E7
	STA $7ED820,X	; Turns event bit on
+	PLX			; Restore X
	LDA $0FAA,X	; Loads Letter count
	CMP $0FAC,X	; Compares ot max letter count
	BNE +		; Branch if not equal
	BRA TC_ROUTINE_END

+	INC $0FAA,X	; Increment letter count
	LDA #$0006
	STA $0FB2,X	; Reset timer to 6 frames
	
	
	LDA $0FB2,X
	CMP #$0200
	BPL +
	LDA $0FAE,X
	BEQ +
	STZ $0FAE,X
	STA $0F94,X
	
+	LDA $0FAA,X					; Loads Letter count
	ASL #2 : CLC : ADC $0FAA,x 	; Multiply by 5
	SEC : SBC #$0002			; Add 2 to get the right byte
	ADC $0F8E,x
	PHX : TAX : LDA $0000,x		; Load the value at the offset
	PLX 						; Restore X
	CMP #$ED00 
	BPL TC_ROUTINE_SPACE		; Go to handler if character encountered is a space
	LDA #$000D					; Queue and play Typewriter Sound
	JSL $809125
	BRA TC_ROUTINE_END
	
++	LDA $0FB2,X
	CMP #$0200
	BCS TC_ROUTINE_END
	DEC $0FB2,X
TC_ROUTINE_END:
	STZ $0FA4,x
	LDA $0FAA,X	; Loads Letter count
	PHY
	JMP $8ABC	; Return to add spritemap function	
	
TC_HIJACK_END:
	PLA
	PHY
	LDA $0000,y	; Loads original Letter count
	JMP $8ABC	; Return to add spritemap function
	
TC_ROUTINE_SPACE:
	XBA : AND #$00FF			; Move the tile number to the less significant byte and focus on it
	SEC : SBC #$00ED			; Get how many tiles above the base space it is
	ASL : PHX : TAX				; Store X for safekeeping and move A to it
	LDA TC_SPACE_PAUSES,x		; Load the corresponding space wait value
	PLX : STA $0fB2,X			; Restore X and overwrite the previous timer value with this
	JMP TC_ROUTINE_END

org $A0C284
	JSR TC_LIFESPAN			; Hijack from processing enemy instrutions
	
; AREA TITLE MOVES WITH SCREEN
org $A08859
	JSR AT_MOVE_SCREEN		; Hijack from drawing Samus and projectiles
	NOP
	
org $A0FA00 
 ; TITLE CARD LIFESPAN SETUP
TC_LIFESPAN:
	LDA $0F78,x						; Loads Current Enemy	
	CMP !TITLE_HEADER_LOCATION		; Checks if its a Title Card
	BEQ ++							; Skip if not
	CMP !BOSS_HEADER_LOCATION		; Checks if its a Sammer Guy Boss
	BNE +
	LDA !state,x : CMP #$0008	; Check to see if the Sammer Guy Boss is in its intro state
	BEQ ++
	JMP +						; Skip if not
++	LDA #$7FFF
	RTS
+	LDA $0000,y
	RTS
	
 ; AREA TITLE MOVES WITH SCREEN CODE
	AT_MOVE_SCREEN:
	PHX
	LDX !TITLE_INDEX
	LDA $0F78,x						; Loads Current Enemy	
	CMP !TITLE_HEADER_LOCATION		; Checks if it's a Title Card
	BNE +							; Skip if not
	LDA $0F86,x	: AND #$00FF		; Loads enemy "special" value and isolates second byte
	BNE +							; If zero, follows camera. Otherwise, stays in place
	LDA $0911						; Load screen horizonal position
	CLC
	ADC #$00F8
	STA $0F7A,x						; Apply with offset to the horizonal position
	LDA $0915						; Load screen vertical position
	CLC
	ADC #$00D8
	STA $0F7E,x						; Apply with offset to the enemy's vertical position
+	PLX
	JSL $93834D		; Draw bombs and projectile explosions (Overwritten action)
	RTS
}

; Block inside reaction - spike air - jump table
org $9498AC
dw $97D8, $9812, $9866, TC_TRIGGER, $97D7, $97D7, $97D7, $97D7, $97D7, $97D7, $97D7, $97D7, $97D7, $97D7, $97D7, $97D7

; Free space in Bank $94
org $94B19F
 TC_TRIGGER:				; BTS 03
	PHX
	LDX !TITLE_INDEX
	LDA $0F78,x
	CMP !TITLE_HEADER_LOCATION	; Checks if it's a Title Card
	BEQ ++
	CMP !BOSS_HEADER_LOCATION	; Checks if it's a Sammer Guy Boss
	BNE +
	LDA !state,x : CMP #$0008	; Check to see if the Sammer Guy Boss is in its intro state
	BEQ ++
	JMP +						; Skip if not
++	LDA $0FAE,X					; Ensure the master lifespan of the enemy is not currently 0
	BEQ +
	STZ $0FAE,X					; Zero out the master lifespan of the enemy
	STA $0F94,X					; Store the original master lifespan to the current lifespan
	LDA #$0000
	STA $0FB2,X					; Zero out the time before typing the next character
+	PLX
	RTS
	

org !B4Free	;free space in $B4 for weaknesses and drops
{
WEAK:
.Sword
db $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00
.Boss
db $82, $82, $82, $82, $82, $82, $82, $82, $82, $82, $82, $82, $82, $02, $02, $00, $02, $02, $00, $02, $02, $02
.Shield
db $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00
.Shuriken
db $82, $82, $82, $82, $82, $82, $82, $82, $82, $82, $82, $82, $82, $02, $02, $04, $02, $02, $00, $02, $02, $02


DROPS:
.Sword
db $00, $00, $00, $00, $00, $00
.Boss
db $00, $00, $00, $00, $00, $00
.Shield
db $00, $00, $00, $00, $00, $00
.Shuriken
db $30, $30, $20, $4F, $10, $10
}

 ; BANK $92 Free Space
org !92Free
 ; GFX_REFRESH
GFX_REFRESH:
	dw $0600,$EC00,$009A,$6D00,$FFFF
	
org !GraphSp ;Free Space for Graphics
GFX:
.Sword
incbin ".\Graphics\Sword.gfx"
.Boss
incbin ".\Graphics\Sammer Guy.gfx"
.Shield
incbin ".\Graphics\Sammer Guy Shield.gfx"
.Shuriken
incbin ".\Graphics\Shuriken.gfx"
print pc, " - End of GFX"

; Put alphabet GFX in general GFX
org $9AEC00
incbin ".\Graphics\Alphabet.gfx"

; Fix improper indexing for projectile block dud shots
org $A09A3D 
LDA $0B64,y 	; Formerly X-indexed. Now Y-indexed
STA $12
LDA $0B78,y

;MUSIC

;this value is the song's index as it appears in RF and the offset from the first track in the SPC engine
;change it from #$0000 to #$0003 to replace Smile song 03, to #$0006 to replace Smile song 06, etc

!Song_Index = $0027

;this next value is the address in ROM where your NSPC gets written to, make sure you have enough freespace at this address!

!Song_Location = $D899B2

;this next value needs to be set to the name of your song, in the same folder as this patch!
;your song should be an NSPC file. Delete the sample title and replace it with your filename.

!Song_Title = Sammers_Last_Stand.nspc

;edit music pointer table @8FE7E1 + !Song_Index
;track 00 + !Song_Index
ORG $8FE7E1+!Song_Index
DL !Song_Location


;then, INCnspc your nspc files
ORG !Song_Location
INCBIN !Song_Title

org !8DFree
print pc, " - Palette FX Objects"
DW $C685,BACKGROUND_FLASH
DW $C685,DOOR_FLASH
DW $C685,BACKGROUND_RETURN
BACKGROUND_FLASH:
DW $C655,$0082		; Start on color 1 of palette 4
DW $0003    ;| Skip colors 2 and 3                                 | Skip colors C, D, and E
	DW $294F,$C599,$252E,$210C,$1CEB,$18C9,$1087,$1085,$0843,$0421,$C5A2,$0000
	DW $C595 		; Done
DW $0003
	DW $4215,$C599,$3DF4,$39D2,$35B1,$318F,$294D,$294B,$2109,$1CE7,$C5A2,$18C6
	DW $C595 		; Done
DW $0003
	DW $5ADB,$C599,$56BA,$5298,$4E77,$4A55,$4213,$4211,$39CF,$35AD,$C5A2,$318C
	DW $C595 		; Done
DW $0003
	DW $739F,$C599,$6F7F,$6B5E,$673D,$631B,$5AD9,$5AD7,$5295,$4E73,$C5A2,$4A52
	DW $C595 		; Done
DW $0003
	DW $5ADB,$C599,$56BA,$5298,$4E77,$4A55,$4213,$4211,$39CF,$35AD,$C5A2,$318C
	DW $C595 		; Done
DW $0003
	DW $4215,$C599,$3DF4,$39D2,$35B1,$318F,$294D,$294B,$2109,$1CE7,$C5A2,$18C6
	DW $C595 		; Done
DW $0003
	DW $294F,$C599,$252E,$210C,$1CEB,$18C9,$1087,$1085,$0843,$0421,$C5A2,$0000
	DW $C595 		; Done
	DW $C5CF		; Delete
DOOR_FLASH:
DW $C655,$0028		; Start on color 4 of palette 1
DW $0003
	DW $5EBB,$3DB3,$292E,$1486
	DW $C595 		; Done
DW $0003
	DW $777F,$5679,$41F4,$2D4C
	DW $C595 		; Done
DW $0003
	DW $7FFF,$6F3F,$5ABA,$4612
	DW $C595 		; Done
DW $0003
	DW $7FFF,$7FFF,$737F,$5ED8
	DW $C595 		; Done
DW $0003
	DW $7FFF,$6F3F,$5ABA,$4612
	DW $C595 		; Done
DW $0003
	DW $777F,$5679,$41F4,$2D4C
	DW $C595 		; Done
DW $0003
	DW $5EBB,$3DB3,$292E,$1486
	DW $C595 		; Done
	DW $C5CF		; Delete
BACKGROUND_RETURN:
DW $C655,$0082		; Start on color 1 of palette 4
DW $0001    ;| Skip colors 2 and 3                                 | Skip colors C, D, and E
	DW $3D4A,$C599,$3929,$3108,$2CE7,$24C6,$1C84,$1484,$0C42,$0421,$C5A2,$0000
	DW $C595 		; Done
	DW $C5CF		; Delete
print pc, " - Palette FX Object End"