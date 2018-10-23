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
    LEA BX, LEDTABLE
    MOV SI, 1
    MOV CX, 6
    MOV AL, 11111110B
AA2:    
    MOV DX, PA_8255
    OUT DX, AL
    
    PUSH AX
    MOV DX, PB_8255    
    MOV AL, [BX + SI]
    OUT DX, AL
    CALL DELAY
    
    POP AX
    ROL AL, 1
    INC SI
    LOOP AA2
    JMP AA1
    
DELAY:
    PUSH CX
    MOV CX, 00FFH
    LOOP $
    POP CX
    RET
    
CODE ENDS
    END START
