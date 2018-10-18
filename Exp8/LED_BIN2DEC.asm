PA_8255 EQU 0600H
PB_8255 EQU 0602H
PC_8255 EQU 0604H
CTR_8255 EQU 0606H

DATA SEGMENT
    LEDTABLE    DB 03FH
                DB 006H
                DB 05BH
                DB 04FH
                DB 066H
                DB 06DH
                DB 07DH
                DB 007H
                DB 07FH
                DB 06FH
                DB 077H
                DB 07CH
                DB 039H
                DB 05EH
                DB 079H
                DB 071H
DATA ENDS
CODE SEGMENT
    ASSUME CS: CODE, DS: DATA
START:
    MOV AX, DATA
    MOV DS, AX
    
    ; 8255 INIT
    MOV DX, CTR_8255
    MOV AL, 10000000B
    OUT DX, AL
    
AA1:    
    MOV DX, PC_8255 ;´Ó8255C¿Ú¶ÁK7~K0
    IN AL, DX
    MOV AL, 211
    CALL DECODE
    JMP AA1
    
DECODE:
    
    MOV AH, 0
A100:
    CMP AL, 100
    JB DP100
    INC AH
    SUB AL, 100
    JMP A100
    
DP100:
    CMP AH, 0
    JE T1
    MOV CL, 11110111B
    CALL DISPLAY

T1:    
    MOV AH, 0
A10:
    CMP AL, 10
    JB DP10
    INC AH
    SUB AL, 10
    JMP A10
    
DP10:
    CMP AH, 0
    JE T2
    MOV CL, 11101111B
    CALL DISPLAY
    
T2:
    MOV AH, AL
    MOV CL, 11011111B    
    CALL DISPLAY 
    
    RET

DISPLAY:
    ;CL:LEDMAP, AH:NUMBER
    PUSH AX
    PUSH BX
    PUSH DX
    
    MOV DX, PA_8255
    MOV AL, CL
    OUT DX, AL
    
    LEA BX, LEDTABLE
    MOV AL, AH
    AND AH, 0
    MOV SI, AX
    
    MOV AL, [BX + SI]
    MOV DX, PB_8255
    OUT DX, AL
    
    POP DX
    POP BX
    POP AX
    RET
    
DELAY:
    PUSH CX
    MOV CX, 0FFFFH
    LOOP $
    MOV CX, 0FFFFH
    LOOP $
    POP CX
    RET
      
CODE ENDS
    END START
