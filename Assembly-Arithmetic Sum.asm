**************************************
*
* Assembly program for Motorola 68HC11
*
* Program description:
* This program generates the sum of the first N elements
* in an arithmetic sequence using a subroutine.
*
* Pseudocode of Main Program:
* int NARR[4] = {}; //Each entry is one byte.
* int DIFF = 255; //One byte.
* int SUMARR[4] = {}; //Each element is four bytes.
*
* int* NPTR; 
* int* SUMPTR; // Assume this points to four bytes.
* NPTR= &NARR[0];
* SUMPTR = &SUMARR[0];
* WHILE( NPTR->item != SENTINEL )
* {	
* 	SUBSUM( NPTR->item, DIFF ) => SUMPTR->item;
*	SUMPTR++;
*	NPTR++;
* }
* 
* 
*---------------------------------------
*
* Pseudocode of Subroutine:
* // COUNTER is passed down in Register A. 
* // DIFF is passed down in Register B.
* int SUBSUM( int COUNTER, int DIFF )
* {
*      int ELEMENT; //2 bytes.
*      int I; //1 byte.
*      int TEMPC; // temp for COUNTER
*      int TEMPD; // temp for DIFF.
*      int[4] SUM;// 4 bytes.
*      TEMPC = COUNTER;
*      TEMPD = DIFF;
*      SUM = 0;
*      DO {
*
*    	ELEMENT = 1;
*    	I = TEMPC- 1;
*    	WHILE(I != 0) {
*     	  TEMPD + ELEMENT => ELEMENT;
*     	  I--;
*    	}
*    	C-FLAG = 0;
*   	ELEMENT + SUM[2 and 3]  => SUM[2 and 3];
*    	SUM[0 and 1]  + C-Flag => SUM[0 and 1];
*
*    	TEMPC--;
*      } UNTIL( TEMPC== 0 );
*      RETURN SUM;
* }
*
**************************************



* start of data section

	ORG $B000
NARR    	FCB   	1, 10, 20, 254, $FF
DIFF	FCB	1
SENTINEL	EQU	$FF

	ORG 	$B010
SUMARR  	RMB    	16



* define any variables that your MAIN program might need here
* REMEMBER: Your subroutine must not access any of the main
* program variables including NARR, DIFF and SUMARR.
SUMPTR	RMB	2
NPTR	RMB	2



	ORG $C000
	LDS	#$01FF		initialize stack pointer
* start of your main program
	LDX	#NARR
	STX	NPTR	NPTR= &NARR[0];
	LDX	#SUMARR
	STX	SUMPTR	SUMPTR = &SUMARR[0];
WHILE1	LDX	NPTR
	LDAA	0,X	
	CMPA	#SENTINEL
	BEQ	ENDWHILE1	WHILE( NPTR->item != SENTINEL ) {
	LDAA	0,X	Pass down parameters through 
	LDAB	DIFF	  call by value in register.
	JSR	SUBSUM	SUBSUM( NARRPTR->item, DIFF )
	LDX	SUMPTR
	PULA		
	STAA	0,X	      	Pull 4 bytes off 
	PULA			the stack, which
	STAA	1,X		is the return
	PULA			value (sum).
	STAA	2,X
	PULA		
	STAA	3,X	=> SUMPTR->item;
	LDX	SUMPTR
	LDAB	#4	SUMPTR++;
	ABX		Increase SUMPTR by 4 bytes.
	LDY	#SUMPTR
	STX	0,Y	
	INC	#NPTR+1	NPTR++;	
	BRA	WHILE1	}
ENDWHILE1 			
DONE	BRA	DONE


* NOTE: NO STATIC VARIABLES ALLOWED IN SUBROUTINE
*       AND SUBROUTINE MUST BE TRANSPARENT TO MAIN PROGRAM
	ORG $D000
* start of your subroutine
SUBSUM	
	DES		Open hole for return value, 4 bytes.
	DES
	DES
	DES

	PSHX		Push Contents of Registers onto stack.
	PSHY
	PSHB
	PSHA
	TPA		Condition Code Register.
	PSHA

	DES		Open hole for ELEMENT, 2 bytes.
	DES
	DES		Open hole for I, 1 byte.
	DES		Open hole for TEMPC, 1 byte.
	DES		Open hole for TEMPD, 1 byte.
	DES		Open hole for SUM, 4 bytes.
	DES
	DES
	DES
	TSX		X reserved for local var access.
	LDAA	10,X	Reset Register A back to COUNTER.
	STAA	5,X	TEMPC = COUNTER
	STAB	4,X	TEMPD = DIFF
	CLR	0,X	SUM = 0
	CLR	1,X
	CLR	2,X
	CLR	3,X			
DO	LDD	#1	DO {
	STD	7,X	  ELEMENT = 1;	
	LDAA	5,X
	DECA
	STAA	6,X	  I = TEMPC - 1;
WHILE2	TST	6,X	  WHILE (I != 0) {
	BEQ	ENDWHILE2
	CLRA
	LDAB	4,X
	ADDD	7,X	   TEMPD + ELEMENT
	STD	7,X	   => ELEMENT
	DEC	6,X	   I--;
	BRA	WHILE2	   }
ENDWHILE2	CLC		   Clear C flag.
	LDD	7,X	   ELEMENT	
	ADDD	2,X	   + SUM[2 and 3]
	STD	2,X	   => SUM[2 and 3];
	LDD	0,X	   SUM [0 and 1]
	ADCB	#0	   Ripple carry from ADDD to 2nd byte
	ADCA	#0	   Ripple carry from ADCB to 1st byte
	STD	0,X	
	DEC	5,X	   Decrement loop counter. Z-flag set.
UNTIL	BNE	DO	}
ENDDO	LDY	20,X
	STY	16,X	Move return address to correct
	LDD	0,X	position on stack.
	STD	18,X
	LDD	2,X
	STD	20,X	Copy SUM into return value.
	INS		Close hole for SUM, 4 bytes
	INS
	INS	
	INS
	INS		Close hole for TEMPD, 1 byte
	INS		Close hole for TEMPC, 1 byte
	INS		Close hole for I, 1 byte.
	INS		Close hole for ELEMENT, 2 bytes.
	INS	
	
	PULA		Restore register contents.
	TAP
	PULA
	PULB
	PULY
	PULX

	RTS		Return, end subroutine.
	



