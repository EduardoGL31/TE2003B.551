;
; Practica 7.asm
;
;------------------------------------------------------INSTRUCCIONES------------------------
;(10puntos) Desarrollaun contador ascendente de 8 bits. El valor debe ser mostrado en el módulo de LEDs. El contador debe cambiar automáticamente de valor cada 250ms.
;(15puntos) Modifica el  programa  anterior  tal  que el  contador  cuente  ascendentemente únicamente  cuando  el push-button  conectado  a  C0  sea  presionado.  Cuando  no  haya  nada presionadoel contador debe mantenerse fijo. No olvides incluir rutinas anti rebote.
;(15puntos) Agrega   al   programa   anterior la   funcionalidad   de   contardescendentemente únicamente cuando el push-button conectado a C1sea presionado. No olvides incluir rutinas anti rebote.
;(10 puntos) Agrega al programa anterior la funcionalidad de master resetúnicamente cuando el push-button  conectado  a  C2sea  presionado.Esta  funcionalidad  implica que  el  contador  debe fijarse en un valor de 0.
;No olvides incluir rutinas anti rebote.
;(10  puntos) Agrega  al  programa  anterior la  funcionalidad  de master setúnicamente  cuando  el push-button  conectado  a  C3
;sea  presionado.Esta  funcionalidad  implica que  el  contador  debe fijarse en un valor de 0xFF.No olvides incluir rutinas anti rebote.
;--------------------------------------------------------------------------------------------
; Replace with your application code
.INCLUDE "M16DEF.INC"    ;Librería ATM16
.DSEG					 ; Segmento de datos
.ORG SRAM_START		     ; Set SRAM address to hex SRAM_START
; .BTYE Reserves bytes for a variable. The BYTE directive reserves memory resources in the SRAM or EEPROM.
STORE_SRAM: .BYTE 20	 ; TABLA STORE_SRAM DE TAMAÑO 20 BYTES
.CSEG ;Code segment
.ORG 0  ;Set Program Counter to 0
MAIN:						;ETIQUETA DE MAIN 


;----------------------------STACK POINTER-------------------------------------------
LDI R16, HIGH(RAMEND)		;Loads an 8-bit constant directly to register 16 to 31.
OUT SPH, R16				;Stores data from register Rr in the Register File to I/O Space (Ports, Timers, Configuration Registers,etc.).
LDI R16, LOW(RAMEND)		;Loads an 8-bit constant directly to register 16 to 31.
OUT SPL, R16				;Stores data from register Rr in the Register File to I/O Space (Ports, Timers, Configuration Registers,etc.).
;------------------------------------------------------------------------------------
;-------------------------------PUERTOS----------------------------------------------
;Puerto A –módulo de7 segmentos de 4 dígitos
;Puerto B –módulo de LEDs activo en bajo
;Puerto C –módulo de push-buttonsen configuración pull-up
; 1 Salida, 0 Entrada
SER R16				;Loads $FF directly to register Rd.
OUT DDRA, R16		;Puerto A como "1" SALIDA (MÓDULO 7 SEGMENTOS)  

;---------->NUMERO(0-3)<-----------(BCD)----
;---------->HABILITACIÓN (4-7)<-------------

OUT DDRB, R16		;Puerto B como "1" SALIDA (LED)
CLR R16				;Clears a register.
OUT DDRC, R16		;Puerto C como "0" ENTRADA (PUSH BUTTON)
;------------------------------------------------------------------------------------
NOP						 ;NO OPERATION

;-----------------------MAIN-------------------------------
;                       S,R -> I,D    def(R,$00)
; 1PB <- INCREMENTA    
; 2PB <- DECREMENTA
; 3PB <- 0 RESET CONTADOR
; 4PB <- $FF
CLR COUNT			;DEFINE COUNT COMO $00 POR DEFECTO
CLR COUNTU			;DEFINE UNIDADES EN 0 POR DEFECTO
CLR COUNTD			;DEFINE DECENAS EN 0 POR DEFECTO
CLR COUNTC			;DEFINE CENTENAS EN 0 POR DEFECTO

LOOP_MAIN:          ;ETIQUETA LOOP_MAIN
	CALL EXTERN_LOOP_START_3
	;-----------------REVISA SET OPTIONS--------------
		CALL POLLING_2		;REVISA (CLR)
		CALL POLLING_3		;REVISA (SET)
	;-------------------------------------------------
CHECK:
	;-----------------CHECK SELECTION MODE------------
		CALL POLLING_0		;REVISA (INC)
		CALL POLLING_1		;REVISA (DEC)
	;-------------------------------------------------
RJMP LOOP_MAIN		;Relative jump to an address within PC - 2K +1 and PC + 2K (words).
;----------------------------------------------------------

;----------------------DELAY_3MS-------------------------
DELAY_3MS:			    ;Etiqueta de "DELAY_10MS"
	LDI R29, 3			;Loads an 8-bit constant directly to register 16 to 31.
	DELAY_3MS_1:		;CICLO
		CALL DELAY_1MS  ;DELAY 1 MS
 		DEC R29			;DECREMENTA R18
 	BRNE DELAY_3MS_1   ;Conditional relative branch. Tests the Zero Flag (Z) and branches relatively to PC if Z is cleared.
RET
;------------------------------------------------------------

;------------------------DELAY_1MS--------------------------
DELAY_1MS:						;Etiqueta de "DELAY_1MS"
	LDI R31, 8					;Loads an 8-bit constant directly to register 16 to 31.
	DELAY_1MS_1:				;Etiqueta de "DELAY_1MS"
		LDI R30, 250			;Loads an 8-bit constant directly to register 16 to 31.
		DELAY_1MS_2:			;Etiqueta de "DELAY_1MS"
			DEC R30				;Subtracts one -1- from the contents of register Rd and places the result in the destination register Rd
			NOP					;This instruction performs a single cycle No Operation
			BRNE DELAY_1MS_2	;Conditional relative branch. Tests the Zero Flag (Z) and branches relatively to PC if Z is cleared. 
		DEC R31					;Subtracts one -1- from the contents of register Rd and places the result in the destination register Rd
		BRNE DELAY_1MS_1		;Conditional relative branch. Tests the Zero Flag (Z) and branches relatively to PC if Z is cleared. 
RET								;Returns from subroutine
;----------------------------------------------------------
;----------------------DELAY_10 MS-------------------------
DELAY_10MS:			    ;Etiqueta de "DELAY_10MS"
	LDI COUNT_CLK, 10   ;Loads an 8-bit constant directly to register 16 to 31.
	DELAY_10MS_1:		;CICLO
		CALL DELAY_1MS  ;DELAY 1 MS
 		DEC COUNT_CLK	;DECREMENTA R18
 	BRNE DELAY_10MS_1   ;Conditional relative branch. Tests the Zero Flag (Z) and branches relatively to PC if Z is cleared.
RET
;------------------------------------------------------------

;-------------------------POLLING_0 (INC)--------------------
POLLING_0:				;ETIQUETA DE POLLING
	SBIC PINC, 0		;This instruction tests a single bit in an I/O Register and skips the next instruction if the bit is cleared "0". 
	RJMP END_0     		;Return if SCBIC = 1
	CALL DELAY_10MS		;DELAY 10 MS
	SBIC PINC, 0		;This instruction tests a single bit in an I/O Register and skips the next instruction if the bit is cleared "0". 
	RJMP POLLING_0		;Return if SCBIC = 1
	WAIT_0:
		CALL ROUTINE_1	;CONTADOR INC
		SBIS PINC, 0	;This instruction tests a single bit in an I/O Register and skips the next instruction if the bit is set.
	RJMP WAIT_0		    ;RETURN TO WAIT
	RJMP LOOP_MAIN		;TERMINO LA CUENTA REGRESA A INICIO
		END_0:				;END
RET						
;----------------------------------------------------------
;-------------------------POLLING_1 (DEC)------------------
POLLING_1:				;ETIQUETA DE POLLING
	SBIC PINC, 1		;This instruction tests a single bit in an I/O Register and skips the next instruction if the bit is cleared "0". 
	RJMP END_1			;Return if SCBIC = 1
	CALL DELAY_10MS		;DELAY 10 MS
	SBIC PINC, 1		;This instruction tests a single bit in an I/O Register and skips the next instruction if the bit is cleared "0". 
	RJMP POLLING_1		;Return if SCBIC = 1
	WAIT_1:
		CALL ROUTINE_2	;CONTADOR DEC
		SBIS PINC, 1	;This instruction tests a single bit in an I/O Register and skips the next instruction if the bit is set.
	RJMP WAIT_1		    ;RETURN TO WAIT
	RJMP LOOP_MAIN		;TERMINO LA CUENTA REGRESA A INICIO
	END_1:				;END
RET						
;----------------------------------------------------------
;-------------------------POLLING_2 (CLR)------------------
POLLING_2:					;ETIQUETA DE POLLING
	SBIC PINC, 2			;This instruction tests a single bit in an I/O Register and skips the next instruction if the bit is cleared "0". 
	RJMP END_2     			;Return if SCBIC = 1
	CALL DELAY_10MS			;DELAY 10 MS
	SBIC PINC, 2			;This instruction tests a single bit in an I/O Register and skips the next instruction if the bit is cleared "0". 
	RJMP POLLING_2			;Return if SCBIC = 1
	WAIT_2:
		SBIS PINC, 2		;This instruction tests a single bit in an I/O Register and skips the next instruction if the bit is set.
	RJMP WAIT_2				;RETURN TO WAIT
	CLR COUNT				;COUNT TO $00
	CLR COUNTU			
	CLR COUNTD
	CLR COUNTC
	CLR R27
	OUT PORTB, R27				;IMPRIME UN 0 EN EL PUERTO B
	CALL EXTERN_LOOP_START 
	RJMP CHECK
	END_2:				;END
RET						
;----------------------------------------------------------
;-----------------------POLLING_3 (SET)--------------------
POLLING_3:				;ETIQUETA DE POLLING
	SBIC PINC, 3		;This instruction tests a single bit in an I/O Register and skips the next instruction if the bit is cleared "0". 
	RJMP END_3		;Return if SCBIC = 1
	CALL DELAY_10MS		;DELAY 10 MS
	SBIC PINC, 3		;This instruction tests a single bit in an I/O Register and skips the next instruction if the bit is cleared "0". 
	RJMP POLLING_3		;Return if SCBIC = 1
	WAIT_3:
		SBIS PINC, 3	;This instruction tests a single bit in an I/O Register and skips the next instruction if the bit is set.
	RJMP WAIT_3		    ;RETURN TO WAIT
	SER COUNT			;COUNT TO $FF
	LDI COUNTU, 5				
	LDI COUNTD, 5
	LDI COUNTC, 2
	SER R27
	OUT PORTB, R27				;IMPRIME UN 0 EN EL PUERTO B
	CALL EXTERN_LOOP_START 

	RJMP CHECK
	END_3:
RET						
;----------------------------------------------------------

;----------------------ROUTINE_1---------------------------   
; 		CONTADRO ASCENEDENTE 8 BITS	
ROUTINE_1:					;Contador ascendente de 8 bits.		
	CPI COUNT, 255			;Compara si ya llegaste al maximo
	BREQ SKIP				;VE A SKIP
	RJMP EXIT_5
		SKIP:				;REINICIA EL CONTADOR A 0
			CLR COUNT
			CLR COUNTU
			CLR COUNTD
			CLR COUNTC
			RJMP EXTERN_LOOP_START
	EXIT_5: 
	INC	COUNT				;Adds one -1- to the contents of register Rd and places the result in the destination register Rd.
	MOV SALIDA_LED, COUNT			;
	COM SALIDA_LED
	OUT PORTB, SALIDA_LED		;SACA EL VAOLOR POR EL PUERTO B
	CALL ASCENDENTE_BCD			;CONTADOR ASCENDENTE BCD
	EXTERN_LOOP_START:			;INICIO A LOOP EXTERNO
		LDI R23, 25				;CARGA 25 
		LOOP_1:
			CALL ROUTINE_3
			DEC R23
			CPI R23, 0
			BREQ EXIT_1
		RJMP LOOP_1
	EXIT_1:
RET
;----------------------------------------------------------

;----------------------EXTERNAL_LOOP_START_3---------------
	EXTERN_LOOP_START_3:			;INICIO A LOOP EXTERNO
		LDI R23, 25				;CARGA 25 
		LOOP_3:
			CALL ROUTINE_3
			DEC R23
			CPI R23, 0
			BREQ EXIT_7
		RJMP LOOP_3
		EXIT_7:
	RET
;----------------------------------------------------------

;----------------------ROUTINE_2---------------------------
ROUTINE_2:					;Contador desendente de 8 bits.
	CALL DECENDENTE_BCD		;CONTADOR DECENDENTE BCD
	CPI COUNT, 0			;Compara si ya llegaste al maximo
	BREQ SKIP_2				;VE A SKIP
	RJMP EXIT_4
		SKIP_2:				;REINICIA EL CONTADOR A 0
			LDI COUNT, 255
			LDI COUNTU, 5
			LDI COUNTD, 5
			LDI COUNTC, 2 
			RJMP EXTERN_LOOP_START_2
			RJMP EXIT_3
	EXIT_4:
	DEC	COUNT				;Adds one -1- to the contents of register Rd and places the result in the destination register Rd
	MOV SALIDA_LED, COUNT			;
	COM SALIDA_LED
	OUT PORTB, SALIDA_LED		;SACA EL VAOLOR POR EL PUERTO B
	EXTERN_LOOP_START_2:
	LDI R23, 25					;CARGA 25 
	LOOP_2:
		CALL ROUTINE_3
		DEC R23
		CPI R23, 0
		BREQ EXIT_3
	RJMP LOOP_2
	EXIT_3:
RET
;----------------------------------------------------------

;---------------------ROUTINE_3----------------------------
;EJECUTAR ESTA RUTINA 25 VECES 10MS*25= 250MS
; 10MS PARA EL REFRESCO  3MS ENTRE DISPLAY
ROUTINE_3:
	CLR SALIDA
	MOV SALIDA, COUNTU		;CARGA LAS UNIDADES A SALIDA
							;This instruction makes a copy of one register into another. The source register Rr is left unchanged, while
							;the destination register Rd is loaded with a copy of Rr
	ORI SALIDA, 0XE0		;PON LA PARTE ALTA DEL RESIGISTRO EN 1

	OUT PORTA, SALIDA		;SACA EL RESULTADO POR EL PUERTO A
	CALL DELAY_3MS			

	CLR SALIDA
	MOV SALIDA, COUNTD		;CARGA LAS UNIDADES A SALIDA
							;This instruction makes a copy of one register into another. The source register Rr is left unchanged, while
							;the destination register Rd is loaded with a copy of Rr
	ORI SALIDA, 0XD0		;PON LA PARTE ALTA DEL RESIGISTRO EN 1

	OUT PORTA, SALIDA		;SACA EL RESULTADO POR EL PUERTO A
	CALL DELAY_3MS

	CLR SALIDA
	MOV SALIDA, COUNTC		;CARGA LAS UNIDADES A SALIDA
							;This instruction makes a copy of one register into another. The source register Rr is left unchanged, while
							;the destination register Rd is loaded with a copy of Rr
	ORI SALIDA, 0XB0		;PON LA PARTE ALTA DEL RESIGISTRO EN 1
	
	OUT PORTA, SALIDA		;SACA EL RESULTADO POR EL PUERTO A
	CALL DELAY_3MS
RET
;----------------------------------------------------------

;----------------------ASCENDENTE BCD----------------------
ASCENDENTE_BCD:
	INC COUNTU				;INCREMENTA LAS UNIDADES
	CPI COUNTU, 10			;COMPARA CON 10;	
							;the branch will occur if and only if the unsigned or signed binary number represented 
	BREQ  ADDU				;AUMENTA LAS UNIDADES
	RJMP  EXIT				;in Rd was equal to the unsigned or signed binary number represented in Rr
	ADDU:
		CLR COUNTU
		INC COUNTD
		CPI	COUNTD, 10			;COMPARA CON 10
		BREQ ADDD				;the branch will occur if and only if the unsigned or signed binary number represented 
								;in Rd was equal to the unsigned or signed binary number represented in Rr
	RJMP  EXIT
		ADDD:
			INC COUNTC
			CLR COUNTD	
			CPI COUNT, 255
			BREQ RESET
		RJMP EXIT
		RESET:
			CLR COUNTU
			CLR COUNTD
			CLR COUNTC
			CLR COUNT
		RJMP EXIT
	EXIT:
RET
;----------------------------------------------------------

;----------------------DECENDENTE BCD----------------------
DECENDENTE_BCD:
	CPI COUNT, 0			;COMPARALO CON 0
	BREQ EXEP				;EXCEPCIÓN
	RJMP OTHER				;OTRO
	EXEP:
		LDI COUNTU, 5 
		LDI COUNTD, 5
		LDI COUNTC, 2
	RJMP EXIT_2

	OTHER:
	DEC COUNTU				;INCREMENTA LAS UNIDADES
	CPI COUNTU, 255			;COMPARA CON 255;	
							;the branch will occur if and only if the unsigned or signed binary number represented 
	BREQ  DECU				;AUMENTA LAS UNIDADES
	RJMP  EXIT_2			;in Rd was equal to the unsigned or signed binary number represented in Rr
	DECU:
		LDI COUNTU, 9
		DEC COUNTD
		CPI	COUNTD, 255			;COMPARA CON 10
		BREQ DECD				;the branch will occur if and only if the unsigned or signed binary number represented 
								;in Rd was equal to the unsigned or signed binary number represented in Rr
	RJMP  EXIT_2
		DECD:
			DEC COUNTC
			LDI COUNTD, 9	
			CPI COUNT, 255
			BREQ RESET_2
		RJMP EXIT_2
		RESET_2:
			CLR COUNTU
			CLR COUNTD
			CLR COUNTC
			CLR COUNT
		RJMP EXIT_2
	EXIT_2:
RET
;----------------------------------------------------------

;----------------------------------------------------------
.def COUNT = R17			;CONTADOR BINARIO
.def COUNTU = R16			;UNIDADES	
.def COUNTD = R20			;DECENAS
.def COUNTC = R21			;CENTENAS
.def COUNT_CLK = R18		;CONTADOR DESTINADO A RELOJ
.def SELECTION = R19		;SELECCIÓN
.def SALIDA = R22			;SALIDA 
.def SALIDA_LED = R26		;SALIDA DE LEDS