Lorom


; =============================== FLEXGLOW ENGINE MADE BY BLACK_FALCON v1.1 ===============================
;
;	v1.1 changelog
;	- fixed a bug where the timers wouldn't get reset when changing rooms, causing them to mess things up
;	  this was fixed by changing the used RAM to that reserved for enemy 0x1F (the 32nd enemy in the room)
;	  because all enemy RAM is initialized to 0000 when entering a room
;	  so unless you're as fancy as to use 32 enemies in a single room, it should work
;	- also very minor improvements were done here and there, without changing the location of the offsets

; What this does:
; With this engine you can set up glows whereever you want.
; 	The engine:
;		- lets you choose whatever and how much palette bits to glow
;		- can make things glow red/blue/green or any combination of these three
;		- allows you to set different timers for each glow
;		- can make the chosen colors circle forwards or backwards
;		- lets you choose how intense the glow should be
;		- can handle a maximum of 16 glows per room (I *think* that should be enough for now...)

; Tables are located below the code (also see 'Palette Table.png' and keep it handy, it'll help understanding the format)
; if you still need help, feel free to contact me (don't expect a fast answer, though)

;  ===================== YOU CAN IGNORE THE FOLLOWING CODE, SCROLL DOWN TO THE TABLES SECTION FOR THE SETUP! =======

{							; collapse code here (N++ only)

!bank = $8500				;bank 85, can be set to a different bank if you need the space, you'd then need to repoint the tables at the end, too
!timer = $173A,x 			;relative specific glow timer
!timer2 = $174A,x 			;relative specific timer used for intensity

org $A0868F : JSR $FFB0		 ;main hijack point, also used by DSO's glowpatch, so REPOINT THIS incase you're using it
org $A0FFB0 				; push stuff in case it's needed later

	PHA : PHX : PHY : PHB
	JSL MAINGLOW
	PLB : PLY : PLX : PLA
	LDA $1840 				;pull stuff after the routine is run and do what the hijack jump overwrote
	RTS

org $85CD00 : MAINGLOW:
	LDA $0A78 : BNE GETOUT								;pause time
	PEA !bank : PLB : PLB
	LDX $07BB : LDA $8F0010, X : BEQ GETOUT 					;loads roomVAR value for the current roomstate
								   BPL GETOUT
	TAY : LDA $0000,y : AND #$000F : BEQ GETOUT				;How many glows (no more than F glows per room)
	ASL a : STA $12 : INY : LDX #$0000						;Y is pointer +1 , X is the glow index (used for timer)
NEXTGLOW:	
	STX $1A											;= current glow index
	LDA !timer : AND #$00FF : BEQ B
	DEC !timer : BRA NEXT
B:
	LDA $0000,y : AND #$00FF : STA $16
	LDA !timer : AND #$1100 : ORA $16 : STA !timer
	AND #$1000 : BNE DO
	LDA $0001,y : AND #$0003 : CMP #$0001 : BNE +
	LDA !timer : ORA #$0100 : STA !timer							;set Substractor bit
+	LDA !timer : ORA #$1000 : STA !timer							;needs intitialisation, because it has to know if it should ADD first and THEN SUBSTRACT, or vice versa
DO:
	PHX
	LDA $0001,y : AND #$0003 : ASL A : TAX
	JSR (TODO,x)												;whether to add/substract or cycle
	PLX
NEXT:
	TYA : CLC : ADC #$0007 : TAY				;get next glow pointer	
	INX : INX : CPX $12 : BMI NEXTGLOW			;all glows processed? No? Then check for next glow!
GETOUT:						;leave stuff
	RTL
	
TODO:
	DW ADD
	DW SUBSTRACT
	DW CFORWARD
	DW CBACKWARDS

CHECK: 
{
	LDA $0002,y : AND #$00FF : STA $16					;current palette bit
				AND #$000F : STA $14	
	LDA #$000F : SEC : SBC $14 : STA $14	
	LDA $0004,y : AND #$000F : CMP $14 : BEQ + : BMI +
	LDA $14
+	CLC : ADC $16									;max. palette index
	ASL : STA $16	
	RTS					
}
	
CFORWARD: 
{	
	JSR CHECK
	DEC $16 : DEC $16
	LDA $0002,y : ASL A : TAX
-
	LDA $7EC002,x : STA $14						
	LDA $7EC000,x : STA $7EC002,x
	LDA $14 : STA $7EC000,x
	INX : INX : CPX $16 : BMI -						;Increase until max. palette bit is reached	
	RTS					
}
	
CBACKWARDS: 
{
	JSR CHECK
	DEC $16 : DEC $16 : DEC $16 : DEC $16
	LDA $0002,y : DEC : ASL A : STA $18				
	LDX $16
-
	LDA $7EC000,x : STA $14	
	LDA $7EC002,x : STA $7EC000,x
	LDA $14 : STA $7EC002,x					;swap palette values for each palette bit
	DEX : DEX : CPX $18 : BNE -						;Increase until max. palette bit	
	RTS					
}
	
ADD: 
{
	LDX $1A : LDA !timer : AND #$0100 : BEQ +
	JMP SUBSTRACT
+	JSR CHECK

	LDA $0002,y : ASL A : TAX						;set X
	LDA $0005,y : AND #$0007 : STA $18				;RGB
BACK:
	LDA $18 : BIT #$0001 : BEQ REDBACK
	JMP REDADD
REDBACK:
	BIT #$0002 : BEQ GREENBACK
	JMP GREENADD
GREENBACK:
	BIT #$0004 : BEQ BLUEBACK
	JMP BLUEADD
BLUEBACK:
	INX : INX : CPX $16 : BMI BACK						;Increase until max. palette bit	
	LDX $1A : INC !timer2
	LDA $0006,y : AND #$00FF : CMP !timer2 : BNE +		;intensity
	STZ !timer2
	LDA !timer : ORA #$0100 : STA !timer
+	RTS 
}
;additions: 
{
	
REDADD: 
	{	
	LDA $7EC000,x : AND #%0000000000011111		;check if an addition would go over the limit
	CLC : ADC #%0000000000000001
	CMP #%0000000000100000 : BPL TOORED					;branch if so
	LDA $7EC000,x : CLC				;else add 1 bit to red	
	ADC #%0000000000000001 : STA $7EC000,x				;and store it
TOORED:
	LDA $18 : BRA REDBACK 
	}
	
GREENADD: 
	{
	LDA $7EC000,x : AND #%0000001111100000		;same in green
	CLC : ADC #%0000000000100000
	CMP #%0000010000000000 : BPL TOOGREEN

	LDA $7EC000,x
	CLC : ADC #%0000000000100000
	STA $7EC000,x
TOOGREEN:
	LDA $18 : JMP GREENBACK 
	}

BLUEADD: 
	{
	LDA $7EC000,x : AND #%0111110000000000		;same in blue
	CLC : ADC #%0000010000000000
	CMP #%1000000000000000 : BPL TOOBLUE
	LDA $7EC000,x
	CLC : ADC #%0000010000000000
	STA $7EC000,x
TOOBLUE:
	LDA $18 : JMP BLUEBACK 
	}
}
	
SUBSTRACT: 
{
	LDX $1A
	LDA !timer : AND #$0100 : BNE +
	JMP ADD
+
	JSR CHECK
	LDA $0002,y : ASL A : TAX
	LDA $0005,y : AND #$0007 : STA $18
back:
	LDA $18 : BIT #$0001 : BEQ redBACK
	JMP REDSUB
redBACK:
	BIT #$0002 : BEQ greenBACK
	JMP GREENSUB
greenBACK:
	BIT #$0004 : BEQ SUBBLUEBACK
	JMP BLUESUB
SUBBLUEBACK:
	INX : INX : CPX $16 : BMI back						;Increase until max. palette bit
	LDX $1A : INC !timer2
	LDA $0006,y : AND #$00FF : CMP !timer2 : BNE +		;intensity
	STZ !timer2
	LDA !timer : AND #$10FF : STA !timer
+
	RTS 
}


;substractions: 
{
REDSUB: 
	{
	LDA $7EC000,x : AND #%0000000000011111 : BEQ NORED					;check if an substraction would go under the limit
	SEC : SBC #%0000000000000001 : BEQ NORED
	CMP #%0000000000000001 : BMI NORED
	LDA $7EC000,x : SEC : SBC #%0000000000000001 : STA $7EC000,x
NORED:
	LDA $18 : JMP redBACK 
	}

GREENSUB: 
	{
	LDA $7EC000,x : AND #%0000001111100000 : BEQ NOGREEN
	SEC : SBC #%0000000000100000 : BEQ NOGREEN
	CMP #%0000000000100000 : BMI NOGREEN
	LDA $7EC000,x : SEC : SBC #%0000000000100000 : STA $7EC000,x
NOGREEN:
	LDA $18 : JMP greenBACK 
	}

BLUESUB: 
	{
	LDA $7EC000,x : AND #%0111110000000000 : BEQ NOBLUE
	SEC : SBC #%0000010000000000 : BEQ NOBLUE
	CMP #%0000010000000000 : BMI NOBLUE
	LDA $7EC000,x : SEC : SBC #%0000010000000000 : STA $7EC000,x
NOBLUE:
	LDA $18 : JMP SUBBLUEBACK 
	}
}
}


; ============================================= [TABLES] ============================================= 

;									 -------- TABLE FORMAT --------


; the table consists of a number for how many glows to process, followed by the glow setup, which takes 7 bytes per glow.
; Format:

; [XX]											;
; [TT] [MM] [00] [PP] [NN] [CC] [GG]			;first glow
; [TT] [MM] [00] [PP] [NN] [CC] [GG]			;second glow etc.
; ..

; X - number of glows per setup (max of 15 per room)
; T - Timer: 
;		- defines number of frames to wait for the next gradient to process (max. of 0xFF (255 frames))
; M - Mode: 
;		- lets you choose what to do with the palette bits
;		- Possible modes are:
;						00 = add color first, then subtract again
;						01 = subract color first, then add again
;						02 = cycle forwards through the palettes chosen (only makes sense with 2 or more palettes bits chosen)
;						03 = cycle backwards through the palettes chosen (only makes sense with 2 or more palettes bits chosen)
; 00 - always 00, don't change it!																	
; P - Palette bit address:
;		- this is where "Palette Table.png" comes in handy!
;		  Each palette bit in Super Metroid has a certain address (Palette line and palette row, which you can determine using the table picture.
;
; N - Number of palette bits to process, this affects the palette bits that are following right after the address
; C - (ignored if M is 02 or 03) Color to use for addition/subtraction, in bits.
;		- 01 is red, 02 is green, 04 is blue, 
;		- adding these numbers together results in the colors being added ingame
;		- example: 01 (red) + 02 (green) = 03 (yellow)
;		- up to 07 (white)
; G - (ignored if M is 02 or 03) Number of gradients to process, basically how often you want to add/subtract a color before reversing the process
;	  total time for one glow period =  2 * G * T (for M being either 00 or 01)

;									 -------- PALETTE TABLE --------


; this will help, each line has palette bits going from 0 to F:
; (also keep 'Palette Table.png' handy!)

; 7E:C000 - 7E:C01F    Line 0	area color palette line 0
; 7E:C020 - 7E:C03F    Line 1	area color palette line 1
; 7E:C040 - 7E:C05F    Line 2	area color palette line 2
; 7E:C060 - 7E:C07F    Line 3	area color palette line 3
; 7E:C080 - 7E:C0AF    Line 4	area color palette line 4
; 7E:C0A0 - 7E:C0BF    Line 5	area color palette line 5
; 7E:C0C0 - 7E:C0DF    Line 6	area color palette line 6
; 7E:C0E0 - 7E:C0FF    Line 7	area color palette line 7
; 7E:C100 - 7E:C11F    Line 8	White palette for flashing enemies and pickups
; 7E:C120 - 7E:C13F    Line 9	Enemy color palette line 0001
; 7E:C140 - 7E:C15F    Line A	Enemy color palette line 0002
; 7E:C160 - 7E:C17F    Line B	Enemy color palette line 0003
; 7E:C180 - 7E:C1AF    Line C	Samus' palette
; 7E:C1A0 - 7E:C1BF    Line D	Most common sprites (item drops, smoke, explosions, bombs, power bombs, missiles, gates(wall part), water splashes, grapple beam)
; 7E:C1C0 - 7E:C1DF    Line E	Beam Color palette line
; 7E:C1E0 - 7E:C1FF    Line F	Enemy color palette line 0007 

print " "
print " "										;use print command to print text in the command prompt window
print " the below pointers need to be put into 'unknown/RoomVAR' in pointers window"
print " example: offset is printed as 85ab00 >> use AB00 as pointer"
print " "
;================================ ROOM 1 =================================================
print " Table pointer Sammer Guy Miniboss: ", pc

namespace "SAMMERGUY_"									;namespace puts additional tags before the lables (prefixes), in this case, it renames START to ROOM1_START
													;that way you just have to change the ROOM_1 to anything else when copypasting instead of renaming every label by itself
													;so there are no conflicts with identical labels due to namespaces
	DB END-START/7	;don't touch this, it calculates the value everytime by itself!!
													;actually read by xkas as "ROOM1_END-ROOM1_START/7", also left to right math
START:												;actually read by xkas as "ROOM1_START"
	DB $0A, $00 : DW $009C : DB $01, $07, $06		;Glow white outline of Sammer Guy
	DB $05, $01 : DW $00B1 : DB $03, $07, $09		;Glowing shield
											;see 'Palette Table.png'
											;substract ($01) green ($02) every $04 frames, do that $08 times, then add green again every 4 frames, 8 times
											;so the entire glow period is 8*4*2 = 64 frames = about a second
									
; 	DB $00, $00 : DW $0000 : DB $00, $00, $00		;uncomment and copy/paste if you want more glows per room (max. of 16 lines)
; 	DB $00, $00 : DW $0000 : DB $00, $00, $00		;always include them between the START and END labels
END:													;actually read by xkas as "ROOM1_END"

namespace off					;no more lables renamed after this command until a new namespace is defined

print " --------------- "
;---------------------- END OF ROOM 1 ----------------------


