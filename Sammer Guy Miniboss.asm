; Sammer Guy Miniboss.asm
;----------------------------
lorom

!A0Free = $A0F813	; For enemy headers
!A2Free = $A2F498	; AI code
!A3Free = $A3F3F5	; AI code
!B4Free = $B4F4E0	; For drops/weaknesses

!GraphSp  = $B89000 ; Free Space for Graphics

!sleep = $812F

!currHP = $0F8C			; Current HP of an enemy
!timer = $0F90			; Enemy timer
!state = $0FA8			; Enemy state pointer
!minDis = $0FAA			; Minimum distance the boss can be from the walls 
!bossLoc = $0FAC		; Variable indicating what state the boss' location is in
!swordsSpawned = $0FAE	; A variable indicating which swords the boss has spawned
!HPComparitor = $0FB0	; A variable used to store the initial max HP of the boss to compare it with the current HP for speed calculations
!floatState = $0FB2		; A variable used to determine which direction the boss is floating in and how quickly

!state0 = #$0000
!state2 = #$0002
!state4 = #$0004
!state6 = #$0006
!state8 = #$0008
!stateA = #$000A
!prepheight = #$0008
!maxHP = #$0C00
!secPhaseHP = #$0600

org !A0Free
EnemyHeaders:
{
print pc, " - Sword Enemy Header"
;       Palette             Damage        Y Radius        Hurt AI Time   Boss Value          Number of parts  Main AI              Hurt AI       Xray AI      Unused         PB AI        Unused       Touch AI        Unused                Layer Priority          Weakness Pointer
;GFX Size |          Health |      X Radius  |       AI Bank |     Hurt SFX  |  Setup           |   Unused    |         Grapple AI |  Frozen AI  | Death Anim. |   Unused    |   Unknown   |   Unused    |   Shot AI   |   GFX Address           | Drops Pointer       |          Name Pointer
;  |      |          |      |      |      |          |    |        |      |      |              |      |      |             |      |      |      |      |      |      |      |      |      |      |      |      |      |          |              |        |            |           |
DW $0200, Sword_PAL, $0100, $0032, $0004, $0010 : DB $A3, $00 : DW $0000, $0000, Sword_SETUPAI, $0001, $0000, Sword_MAINAI, $804C, $804C, $8041, $0000, $0000, $0000, $0000, $804C, $0000, $0000, $0000, $8023, $802D, $0000 : DL GFX_Sword : DB $02 : DW DROPS_Sword, WEAK_Sword, $E1DB

print pc, " - Boss Enemy Header"
;       Palette             Damage        Y Radius        Hurt AI Time   Boss Value         Number of parts  Main AI             Hurt AI       Xray AI      Unused         PB AI        Unused       Touch AI              Unused               Layer Priority         Weakness Pointer
;GFX Size |         Health  |      X Radius  |       AI Bank |     Hurt SFX  |  Setup          |   Unused    |        Grapple AI |  Frozen AI  | Death Anim. |   Unused    |   Unknown   |   Unused    |   Shot AI         |   GFX Address          | Drops Pointer      |         Name Pointer
;  |      |         |       |      |      |          |    |        |      |      |             |      |      |            |      |      |      |      |      |      |      |      |      |      |      |      |            |          |             |        |           |          |
DW $0400, Boss_PAL, !maxHP, $0032, $0010, $0014 : DB $A3, $00 : DW $0000, $0000, Boss_SETUPAI, $0001, $0000, Boss_MAINAI, $804C, $804C, $8041, $0000, $0003, $0000, $0000, $804C, $0000, $0000, $0000, $8023, Boss_SHOTAI, $0000 : DL GFX_Boss : DB $02 : DW DROPS_Boss, WEAK_Boss, $E1DB

print pc, " - Shield Enemy Header"
;       Palette              Damage        Y Radius        Hurt AI Time   Boss Value           Number of parts  Main AI               Hurt AI       Xray AI      Unused         PB AI        Unused       Touch AI        Unused                 Layer Priority           Weakness Pointer
;GFX Size |           Health |      X Radius  |       AI Bank |     Hurt SFX  |  Setup            |   Unused    |          Grapple AI |  Frozen AI  | Death Anim. |   Unused    |   Unknown   |   Unused    |   Shot AI   |   GFX Address            | Drops Pointer        |           Name Pointer
;  |      |           |      |      |      |          |    |        |      |      |               |      |      |              |      |      |      |      |      |      |      |      |      |      |      |      |      |          |               |        |             |            |
DW $0200, Shield_PAL, $0100, $0032, $0010, $0004 : DB $A3, $00 : DW $0000, $0000, Shield_SETUPAI, $0001, $0000, Shield_MAINAI, $804C, $804C, $8041, $0000, $0000, $0000, $0000, $804C, $0000, $0000, $0000, $8023, $802D, $0000 : DL GFX_Shield : DB $02 : DW DROPS_Shield, WEAK_Shield, $E1DB

print pc, " - Shuriken Enemy Header"
;       Palette              Damage        Y Radius        Hurt AI Time   Boss Value             Number of parts  Main AI       Hurt AI       Xray AI      Unused         PB AI        Unused       Touch AI        Unused                 Layer Priority           Weakness Pointer
;GFX Size |             Health |      X Radius  |       AI Bank |     Hurt SFX  |  Setup              |   Unused    |  Grapple AI |  Frozen AI  | Death Anim. |   Unused    |   Unknown   |   Unused    |   Shot AI   |   GFX Address            | Drops Pointer        |           Name Pointer
;  |      |             |      |      |      |          |    |        |      |      |                 |      |      |      |      |      |      |      |      |      |      |      |      |      |      |      |      |          |               |        |             |            |
DW $0400, Shuriken_PAL, $0100, $0032, $0008, $0008 : DB $A2, $00 : DW $0000, $0000, Shuriken_SETUPAI, $0001, $0000, $B40F, $800F, $804C, $8041, $0000, $0000, $0000, $0000, $804C, $0000, $0000, $0000, $8023, $802D, $0000 : DL GFX_Shuriken : DB $02 : DW DROPS_Shuriken, WEAK_Shuriken, $E1DB

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
LDA #.INSTLISTS_IDLE	: STA $0F92,x	; Load idle instruction list and store to memory
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
LDY $0E54						; Load enemy index
LDA $0F8C : BEQ ..Kill			; Get HP of enemy 0; Kill the sword if the boss is dead.
LDX !state,y					; Load the current state of the sword
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
LDY $0FB4,x						; Get the enemy's speed
LDA .SWORDDISTANCES,y			; Determine how far away from boss to be
CLC : ADC $0F7A					; Add it to the X position of Enemy 0 (The Boss)
STA $0F7A,x						; Store this position to the sword
LDA $0F7E : STA $0F7E,x			; Y position of enemy = Y position of enemy 0
LDA !timer 						; Load timer of enemy 0
CMP #$0001 : BEQ ..StartPrep	; If Timer = 1, Store Y position
RTL

..StartPrep
LDA $0F7E : STA $0F7E,x			; Y position of enemy = Y position of enemy 0
STA $0FAA,x						; Store this Y position to memory. This will be the return height
RTL

..AttackPrep
TYX
LDA $0FAA,x						; Load initial Y Position
CLC
SBC !prepheight					
CMP $0F7E,x : BPL ...End		; If it has reached !prepheight above the position it started at, stop
LDA #$FFFD						; Upward Speed
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
CMP $0F7E,x : BEQ ..Reset : BPL ..THigh	; If it has reached the position it started at, reset
LDA !HPComparitor : SEC : SBC !currHP	; Get HP of damage dealt to boss
ASL #3 : EOR #$FFFF : STA $12  			; Apply it to subpixel speed
LDA #$FFFE								; Upward Speed
STA $14
JSL $A0C786								; Move enemy up by A speed
RTL
..THigh
LDA $0F7E : STA $0F7E,x			; Y position of enemy = Y position of enemy 0, correcting the height
..Reset
LDA !state0 : STA !state		; set state of enemy 0 to 0
LDA #$0080 : STA !timer			; set timer of enemy 0 to 80
RTL

..Inactive
RTL

..Spawning
TYX
LDA $0FB4,x	: AND #$0002		; Load the enemy's speed and see if the enemy goes on the left or right
CMP #$0002 : BEQ ...Left

LDY $0FB4,x						; Get the enemy's speed
LDA .SWORDDISTANCES,y			; Determine how far away from boss it can go
CLC : ADC $0F7A					; Add it to the X position of Enemy 0 (The Boss)
CMP $0F7A,x	: BEQ ...End		; If sword is where it is supposed to be, stop
STZ $12 : LDA #$0001 : STA $14	; Otherwise, move right by one pixel
JSL $A0C6AB
BRA ...End

...Left
LDY $0FB4,x						; Get the enemy's speed
LDA .SWORDDISTANCES,y			; Determine how far away from boss it can go
CLC : ADC $0F7A					; Add it to the X position of Enemy 0 (The Boss)
CMP $0F7A,x	: BEQ ...End		; If sword is where it is supposed to be, stop
STZ $12 : LDA #$FFFF : STA $14	; Otherwise, move left by one pixel
JSL $A0C6AB

...End
RTL


.STATEPOINTERS
DW .MAINAI_Stopped, .MAINAI_AttackPrep, .MAINAI_Downward, .MAINAI_Return, .MAINAI_Inactive, .MAINAI_Spawning

.SWORDDISTANCES
DW $0020, $FFE0, $0030, $FFD0					; Distances for swords to stay from boss based on Speed

.INSTLISTS
print pc, " - Sword Instlists"
..IDLE
DW $0010, .SPM_IDLE1, !sleep

.SPM
print pc, " - Sword Spritemaps"
..IDLE1
DW $0008
DW $0000 : DB $F0 : DW $6100	; Top Right
DW $01F8 : DB $F0 : DW $2100	; Top Left
DW $0000 : DB $F8 : DW $6101	; Up Right
DW $01F8 : DB $F8 : DW $2101	; Up Left
DW $0000 : DB $00 : DW $6102	; Down Right
DW $01F8 : DB $00 : DW $2102	; Down Left
DW $0000 : DB $08 : DW $6103	; Bottom Right
DW $01F8 : DB $08 : DW $2103	; Bottom Left

.PAL
db $00,$00,$39,$7B,$C6,$30,$9E,$23,$0C,$21,$46,$08,$9F,$33,$1E,$17,$DC,$0E,$5A,$7F,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
}

; State Table:
; 0000 = Follow
; 0002 = Attack Prep
; 0004 = Attacking
; 0006 = Returning
; 0008 = Nothing
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
LDA #.INSTLISTS_IDLE	: STA $0F92		; Load idle instruction list and store to memory
LDA #$0080 : STA !timer					; Set timer to $0080
LDA #$0048 : STA !minDis				; Set the default minimum distance the boss can be from the walls
LDA #$000A : STA !state					; Set the default state to A
LDA #$0020 : STA !floatState			; Set the default float state to moving down at full speed, slowing down
LDA !currHP : STA !HPComparitor			; Store the boss' max HP to a variable
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
LDA $0F8C								; Load the enemy's current HP
CMP !secPhaseHP : BPL ..Flotation		; Check to see if the boss is below 1/2 of its max HP
LDA #$0058 : STA !minDis				; Increase minimum distance the boss can be from the walls to make room for the second set of swords

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
CMP #$0040 : BNE ..SkipThrow	; If timer = 40, throw shuriken
JSL $808111 : PHA				; Randomly determine whether to throw left or right and store it on the stack
LDA !swordsSpawned 				; Check to see which sets of swords have spawned
CMP #$0002 : BNE ..OnlyOne		; If only one set of swords have been spawned, only check to throw the first shuriken	

LDY #$01C0						; Load index of enemy 7 to Y, the second shuriken
LDA $0F7A,y						; Load X position of enemy 7 to A
CMP #$0100 : BMI ..OnlyOne		; If enemy is already in area, don't throw again
LDA $0F7A : STA $0F7A,y			; X position of enemy 7 = X position of enemy 0
LDA $0F7E : STA $0F7E,y			; Y position of enemy 7 = Y position of enemy 0
PLA	: BMI ..ThrowDnLeft			; Get throw direction from stack
PHA : LDA #$0070 : STA $0FB4,y	; Set direction of enemy 7 to down right and put throw direction back on stack
BRA ..OnlyOne
..ThrowDnLeft
PHA : LDA #$0010 : STA $0FB4,y	; Set direction of enemy 7 to down left and put throw direction back on stack


..OnlyOne
LDY #$0180						; Load index of enemy 6 to Y, the first shuriken
LDA $0F7A,y						; Load X position of enemy 6 to A
CMP #$0100 : BMI ..NoThrow		; If enemy is already in area, don't throw again
LDA $0F7A : STA $0F7A,y			; X position of enemy 6 = X position of enemy 0
LDA $0F7E : STA $0F7E,y			; Y position of enemy 6 = Y position of enemy 0
PLA	: BMI ..ThrowUpLeft			; Get throw direction from stack
PHA : LDA #$0090 : STA $0FB4,y	; Set direction of enemy 6 to up right and put throw direction back on stack
BRA ..NoThrow
..ThrowUpLeft
PHA : LDA #$00F0 : STA $0FB4,y	; Set direction of enemy 6 to up left and put throw direction back on stack

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
BPL ..Left						; If Difference =  or 1, set variable. If Difference < 0, move right
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
CMP $0F7A : BEQ ..Stop					; If Enemy is on top of Samus
..Right
LDA !bossLoc 
CMP #$0002 : BEQ ..Stop					; If enemy is too far right, don't move
LDA #$0001 : STA $14					; Move right by one pixel plus change
LDA !HPComparitor : SEC : SBC !currHP	; Get HP of damage dealt to boss
ASL #3 : STA $12  						; Apply it to subpixel speed
JSL $A0C6AB								;/
BRA ..Stop
..Left
LDA !bossLoc 
CMP #$0001 : BEQ ..Stop					; If enemy is too far left, don't move
LDA #$FFFE : STA $14					; Move left by one pixel plus change
LDA !HPComparitor : SEC : SBC !currHP	; Get HP of damage dealt to boss
ASL #3 : EOR #$FFFF : STA $12  			; Apply it to subpixel speed
JSL $A0C6AB								;/
..Stop
RTL
}

; Run the boss' attack protocols
{
..StartPrep
LDA !state2 : STA !state		; set state to 2
LDA #$0020 : STA !timer			; set timer to 20
RTL

..AttackPrep
DEC !timer						; Decrement Timer
BEQ ..StartThrust				; If Timer = 0, set state to 4
RTL

..StartThrust				
LDA !state4 : STA !state		; set state to 4
LDA !currHP : LSR #7			; Get current HP /80h
CLC : ADC #$0040 : STA !timer	; set timer to 40 + HP/80 (Range from 40 - 58)
RTL

..Downward
DEC !timer						; Decrement Timer
BEQ ..StartReturn				; If Timer = 0, set state to 6
RTL

..StartReturn				
LDA !state6 : STA !state		; set state to 6
..Return
RTL
}

..Nothing
RTL


..Spawning
LDA !swordsSpawned : BEQ ..FirstSet		; If no swords have been spawned, spawn the first set
LDA $0F8C								; Load the enemy's current HP
CMP !secPhaseHP : BPL ..MoveSwords_End	; Check to see if the boss is below 1/2 of its max HP If so, do nothing
LDA !swordsSpawned 						; If exactly one set of swords have been spawned, spawn the second set
CMP #$0001 : BEQ ..SecondSet		
BRA ..MoveSwords_End					; Otherwise, do nothing

..FirstSet
LDX #$0040							; Index of the first sword
LDA #$0001 : STA !swordsSpawned		; Indicate that the first set of swords has been spawned
LDA #$0020 : STA !timer				; set timer to 20
BRA ..MoveSwords
..SecondSet
LDX #$00C0							; Index of the third sword
LDA #$0002 : STA !swordsSpawned		; Indicate that the second set of swords has been spawned
LDA #$0040 : STA !timer				; set timer to 40

..MoveSwords
LDA $0F7A : STA $0F7A,x				; X position of enemy 1/3 = X position of enemy 0
LDA $0F7E : STA $0F7E,x				; Y position of enemy 1/3 = Y position of enemy 0
LDA #$000A : STA !state,x			; State of affected sword = Spawning
TXA : CLC : ADC #$0040 : TAX		; Index of the next sword
LDA $0F7A : STA $0F7A,x				; X position of enemy 2/4 = X position of enemy 0
LDA $0F7E : STA $0F7E,x				; Y position of enemy 2/4 = Y position of enemy 0
LDA #$000A : STA !state,x			; State of affected sword = Spawning
...End
DEC !timer							; Decrement Timer
CLC : BEQ ..RestartAttack			; If Timer = 0, set state to 0
RTL	

..RestartAttack				
LDA !state0 : STA !state			; set state to 0
LDA #$0080 : STA !timer				; set timer of enemy 0 to 80
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
LDX #$0180 : STX $0E54			; Trick the game to thinking it's working with Enemy 6 to remotely kill it
STZ $0F8C,x						; Set this enemy's HP to 0
JSL $A0A643						; Call Enemy Shot AI to kill it
LDX #$01C0 : STX $0E54			; Trick the game to thinking it's working with Enemy 7 to remotely kill it
STZ $0F8C,x						; Set this enemy's HP to 0
JSL $A0A643						; Call Enemy Shot AI to kill it
..NotDead
RTL

.STATEPOINTERS
DW .MAINAI_Follow, .MAINAI_AttackPrep, .MAINAI_Downward, .MAINAI_Return, .MAINAI_Nothing, .MAINAI_Spawning

.INSTLISTS
print pc, " - Boss Instlists"
..IDLE
DW $0010, .SPM_IDLE1, !sleep

.SPM
print pc, " - Boss Spritemaps"
..IDLE1
DW $001A

DW $0009 : DB $F8 : DW $6105	; Far right mustache
DW $0001 : DB $F8 : DW $6106	; Near right mustache
DW $01EF : DB $F8 : DW $2105	; Far left mustache
DW $01F7 : DB $F8 : DW $2106	; Near left mustache

DW $0008 : DB $EC : DW $6100	; Top Right helmet
DW $0000 : DB $EC : DW $6101	; Up Right helmet
DW $0008 : DB $F4 : DW $6110	; Right helmet side
DW $0008 : DB $FC : DW $6115	; Right helmet base

DW $01F8 : DB $EC : DW $2101	; Up Left Ceiling
DW $01F0 : DB $EC : DW $2100	; Top Left Corner
DW $01F0 : DB $F4 : DW $2110	; Left helmet side
DW $01F0 : DB $FC : DW $2115	; Left helmet base

DW $0000 : DB $F4 : DW $6102	; Upper right face
DW $01F8 : DB $F4 : DW $2102	; Upper left face
DW $0000 : DB $FC : DW $6112	; Lower right face
DW $01F8 : DB $FC : DW $2112	; Lower left face

DW $0000 : DB $FF : DW $6104	; Right shoulder
DW $01F8 : DB $FF : DW $2104	; Left shoulder
DW $0007 : DB $07 : DW $6114	; Right hand
DW $01F1 : DB $07 : DW $2114	; Left hand

DW $0000 : DB $02 : DW $6103	; Upper right body
DW $01F8 : DB $02 : DW $2103	; Upper left body
DW $0000 : DB $0A : DW $6113	; Lower right body
DW $01F8 : DB $0A : DW $2113	; Lower left body

DW $0002 : DB $0B : DW $6116	; Right foot
DW $01F6 : DB $0B : DW $2116	; Left foot

.PAL
db $00,$00,$2E,$1B,$C4,$12,$43,$1A,$00,$00,$75,$42,$FF,$7F,$44,$08,$A7,$08,$5F,$7B,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
}

Shield:
{
.SETUPAI
LDX $0E54								; Load enemy index
LDA #.INSTLISTS_IDLE	: STA $0F92,x	; Load idle instruction list and store to memory
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
db $00,$00,$FF,$7F,$DE,$7B,$BD,$77,$0C,$21,$46,$08,$9F,$33,$1E,$17,$DC,$0E,$5A,$7F,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
}
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
db $82, $82, $82, $82, $82, $82, $82, $82, $82, $82, $82, $82, $82, $02, $02, $00, $02, $02, $00, $02, $02, $02


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