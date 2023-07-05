; Sammer Guy Miniboss.asm
;----------------------------
lorom

!86Free = $86F4A6	; For enemy projectiles
!A0Free = $A0F813	; For enemy headers
!A2Free = $A2F498	; AI code
!A3Free = $A3F3F5	; AI code
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
!maxHP = #$0C00
!secPhaseHP = #$0600

org !A0Free
EnemyHeaders:
{
.SwordHeader
print pc, " - Sword Enemy Header"
;       Palette             Damage        Y Radius        Hurt AI Time   Boss Value          Number of parts  Main AI              Hurt AI       Xray AI      Unused         PB AI        Unused       Touch AI        Unused                Layer Priority          Weakness Pointer
;GFX Size |          Health |      X Radius  |       AI Bank |     Hurt SFX  |  Setup           |   Unused    |         Grapple AI |  Frozen AI  | Death Anim. |   Unused    |   Unknown   |   Unused    |   Shot AI   |   GFX Address           | Drops Pointer       |          Name Pointer
;  |      |          |      |      |      |          |    |        |      |      |              |      |      |             |      |      |      |      |      |      |      |      |      |      |      |      |      |          |              |        |            |           |
DW $0400, Sword_PAL, $0100, $0032, $0004, $0010 : DB $A3, $00 : DW $0000, $0000, Sword_SETUPAI, $0001, $0000, Sword_MAINAI, $804C, $804C, $8041, $0000, $0000, $0000, $0000, $804C, $0000, $0000, $0000, $8023, $802D, $0000 : DL GFX_Sword : DB $02 : DW DROPS_Sword, WEAK_Sword, $E1DB

.BossHeader
print pc, " - Boss Enemy Header"
;       Palette             Damage        Y Radius        Hurt AI Time   Boss Value         Number of parts  Main AI             Hurt AI       Xray AI      Unused         PB AI        Unused       Touch AI              Unused               Layer Priority         Weakness Pointer
;GFX Size |         Health  |      X Radius  |       AI Bank |     Hurt SFX  |  Setup          |   Unused    |        Grapple AI |  Frozen AI  | Death Anim. |   Unused    |   Unknown   |   Unused    |   Shot AI         |   GFX Address          | Drops Pointer      |         Name Pointer
;  |      |         |       |      |      |          |    |        |      |      |             |      |      |            |      |      |      |      |      |      |      |      |      |      |      |      |            |          |             |        |           |          |
DW $0400, Boss_PAL, !maxHP, $0032, $0010, $0014 : DB $A3, $00 : DW $0000, $0000, Boss_SETUPAI, $0001, $0000, Boss_MAINAI, $804C, $804C, $8041, $0000, $0003, $0000, $0000, $804C, $0000, $0000, $0000, $8023, Boss_SHOTAI, $0000 : DL GFX_Boss : DB $02 : DW DROPS_Boss, WEAK_Boss, $E1DB

.ShieldHeader
print pc, " - Shield Enemy Header"
;       Palette              Damage        Y Radius        Hurt AI Time   Boss Value           Number of parts  Main AI               Hurt AI       Xray AI      Unused         PB AI        Unused       Touch AI        Unused                 Layer Priority           Weakness Pointer
;GFX Size |           Health |      X Radius  |       AI Bank |     Hurt SFX  |  Setup            |   Unused    |          Grapple AI |  Frozen AI  | Death Anim. |   Unused    |   Unknown   |   Unused    |   Shot AI   |   GFX Address            | Drops Pointer        |           Name Pointer
;  |      |           |      |      |      |          |    |        |      |      |               |      |      |              |      |      |      |      |      |      |      |      |      |      |      |      |      |          |               |        |             |            |
DW $0200, Shield_PAL, $0100, $0032, $0010, $0004 : DB $A3, $00 : DW $0000, $0000, Shield_SETUPAI, $0001, $0000, Shield_MAINAI, $804C, $804C, $8041, $0000, $0000, $0000, $0000, $804C, $0000, $0000, $0000, $8023, $802D, $0000 : DL GFX_Shield : DB $02 : DW DROPS_Shield, WEAK_Shield, $E1DB

.ShurikenHeader
print pc, " - Shuriken Enemy Header"
;       Palette              Damage        Y Radius        Hurt AI Time   Boss Value             Number of parts  Main AI       Hurt AI       Xray AI      Unused         PB AI        Unused       Touch AI        Unused                 Layer Priority           Weakness Pointer
;GFX Size |             Health |      X Radius  |       AI Bank |     Hurt SFX  |  Setup              |   Unused    |  Grapple AI |  Frozen AI  | Death Anim. |   Unused    |   Unknown   |   Unused    |   Shot AI   |   GFX Address            | Drops Pointer        |           Name Pointer
;  |      |             |      |      |      |          |    |        |      |      |                 |      |      |      |      |      |      |      |      |      |      |      |      |      |      |      |      |          |               |        |             |            |
DW $0400, Shuriken_PAL, $0100, $0032, $0008, $0008 : DB $A2, $00 : DW $0000, $0000, Shuriken_SETUPAI, $0001, $0000, $B40F, $800F, $804C, $8041, $0000, $0000, $0000, $0000, $8037, $0000, $0000, $0000, $8023, $802D, $0000 : DL GFX_Shuriken : DB $02 : DW DROPS_Shuriken, WEAK_Shuriken, $E1DB

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
LDA #.INSTLISTS_SPAWNING : STA $0F92	; Load spawning spritemap
LDA #$0080 : STA !timer					; Set timer to $0080
LDA #$0048 : STA !minDis				; Set the default minimum distance the boss can be from the walls
LDA #$000A : STA !state					; Set the default state to A
LDA #$0020 : STA !floatState			; Set the default float state to moving down at full speed, slowing down
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

LDY #$0100						; Load index of enemy 4 to Y, the second shuriken
LDA $0F7A,y						; Load X position of enemy 4 to A
CMP #$0100 : BMI ..OnlyOne		; If enemy is already in area, don't throw again
LDA $0F7A : STA $0F7A,y			; X position of enemy 4 = X position of enemy 0
LDA $0F7E : STA $0F7E,y			; Y position of enemy 4 = Y position of enemy 0
PLA	: BMI ..ThrowDnLeft			; Get throw direction from stack
PHA : LDA #$0070 : STA $0FB4,y	; Set direction of enemy 4 to down right and put throw direction back on stack
BRA ..OnlyOne
..ThrowDnLeft
PHA : LDA #$0010 : STA $0FB4,y	; Set direction of enemy 4 to down left and put throw direction back on stack


..OnlyOne
LDY #$00C0						; Load index of enemy 3 to Y, the first shuriken
LDA $0F7A,y						; Load X position of enemy 3 to A
CMP #$0100 : BMI ..NoThrow		; If enemy is already in area, don't throw again
LDA $0F7A : STA $0F7A,y			; X position of enemy 3 = X position of enemy 0
LDA $0F7E : STA $0F7E,y			; Y position of enemy 3 = Y position of enemy 0
PLA	: BMI ..ThrowUpLeft			; Get throw direction from stack
PHA : LDA #$0090 : STA $0FB4,y	; Set direction of enemy 3 to up right and put throw direction back on stack
BRA ..NoThrow
..ThrowUpLeft
PHA : LDA #$00F0 : STA $0FB4,y	; Set direction of enemy 3 to up left and put throw direction back on stack

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
BEQ ..Stop								; If Enemy is on top of Samus
..Right
LDA !bossLoc 
CMP #$0002 : BEQ ..Stop					; If enemy is too far right, don't move
LDA #$0001 : STA $14					; Move right by one pixel plus change
LDA !HPComparitor : SEC : SBC !currHP	; Get HP of damage dealt to boss
ASL #3 : STA $12  						; Apply it to subpixel speed
JSL $A0C6AB								;/
LDA $0AF6 								; Reload Samus X Position
CMP $0F7A : BMI	..CorrectPosition		; If enemy moved too far, correct position
BRA ..Stop
..Left
LDA !bossLoc 
CMP #$0001 : BEQ ..Stop					; If enemy is too far left, don't move
LDA #$FFFE : STA $14					; Move left by one pixel plus change
LDA !HPComparitor : SEC : SBC !currHP	; Get HP of damage dealt to boss
ASL #3 : EOR #$FFFF : STA $12  			; Apply it to subpixel speed
JSL $A0C6AB								;/
LDA $0AF6 								; Reload Samus X Position
CMP $0F7A : BPL	..CorrectPosition		; If enemy moved too far, correct position
..Stop
RTL

..CorrectPosition
STA $0F7A								; If the enemy moved past Samus, reset the X position to Samus'
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

..Nothing
RTL


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
..NotDead
RTL

.STATEPOINTERS
DW .MAINAI_Follow, .MAINAI_AttackPrep, .MAINAI_Downward, .MAINAI_Return, .MAINAI_Nothing, .MAINAI_Spawning

.INSTLISTS
print pc, " - Boss Instlists"
..IDLE
DW $0008, .SPM_EXTENDING
DW $0010, .SPM_IDLE1, !sleep
..IDLE2
DW $0008, .SPM_RAISING
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

.SPM
print pc, " - Boss Spritemaps"
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
DW $0007 : DB $07 : DW $611B	; Right hand (Thrusting)
DW $01F1 : DB $07 : DW $211B	; Left hand (Thrusting)

DW $81F8 : DB $02 : DW $2103	; Body

DW $0002 : DB $0B : DW $6117	; Right foot
DW $01F6 : DB $0B : DW $2117	; Left foot

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
CLC : ADC $A0CBC7,x				;} If [enemy projectile $1A6F] + [$A0:CBC7 + [X]] >= 10000h:
BCC ..NoSubMovement				;/ If subpixel speed does not overflow, skip next step
PHA								;\
LDA $1A93,y						;|
INC A							;} Increment enemy projectile Y position
STA $1A93,y						;|
PLA								;/

..NoSubMovement
STA $1A6F,y				 ; Store new subpixel position
LDA $1A93,y 			 ;\
CLC             		 ;|
ADC $A0CBC9,x			 ;} Enemy projectile Y position += Gravity value
STA $1A93,y  			 ;/



TYX
LDA $1A93,y
CMP #$00C8						;\
BMI ..NoFloorHit				; If the enemy has not hit the ground, don't prematurely kill it
LDA #$00C8
STA $1A93,y  					;} Enemy projectile Y position = C8h
LDA #$EB93             			;\
STA $1A03,y  					;} Enemy projectile function = RTS
LDA #$E208            			;\
STA $1B47,y  					;} Enemy projectile instruction list pointer = $E208
LDA #$0A00             			;\
STA $19BB,y  					;} Enemy projectile VRAM tiles index = 0, palette index = 5
LDA #$0001             			;\
STA $1B8F,y  					;} Enemy projectile instruction timer = 1
JSR $EB94    					; Queue small explosion sound effect
RTS
..NoFloorHit
INC !projectileTimer,x			; Increment this projectile's timer
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

; Fix improper indexing for projectile block dud shots
org $A09A3D 
LDA $0B64,y 	; Formerly X-indexed. Now Y-indexed
STA $12
LDA $0B78,y
