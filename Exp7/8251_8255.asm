SOURCE_ADDR EQU 3000H
TARGET_ADDR EQU 4000H
DATA_8251 EQU 0600H
CTR_8251 EQU 0602H
PORT2_8254 EQU 06C4H
CTR_8254 EQU 06C6H
PB_8255 EQU 0642H
CTR_8255 EQU 0646H

CODE SEGMENT
    ASSUME CS:CODE
START:
    ;8255 INIT
    MOV DX, CTR_8255
    MOV AL, 10000000B
    OUT DX, AL
    MOV DX, PB_8255
    MOV AL, 00000000B
    OUT DX, AL    
    
    ;8254 INIT
    MOV DX, CTR_8254
    MOV AL, 10110110B
    OUT DX, AL
    
    MOV DX, PORT2_8254
    MOV AL, 0CH		; 12D
    OUT DX, AL
    MOV AL, 00H
    OUT DX, AL
    
    ; MEM INIT
    MOV SI, SOURCE_ADDR
    MOV DI, TARGET_ADDR
    MOV CX, 26
    MOV AL, 'a'
    
INIT:
    MOV [SI], AL
    MOV [DI], 0
    INC SI
    INC DI
    INC AL
    LOOP INIT
    
    ;RESET 8251
    MOV DX, CTR_8251
    MOV AL, 00H
    OUT DX, AL
    CALL DELAY
    ;OUT DX, AL
    ;CALL DELAY
    ;OUT DX, AL
    ;CALL DELAY
    ;OUT DX, AL
    ;CALL DELAY
    ;OUT DX, AL
    ;CALL DELAY
    MOV AL, 40H
    OUT DX, AL
    CALL DELAY
    
    MOV AL, 01111110B
    OUT DX, AL
    CALL DELAY			; DELAY 这里必须
    MOV AL, 00110100B   ; 00110101B
    OUT DX, AL
    CALL DELAY			; DELAY 这里必须
    
    MOV SI, SOURCE_ADDR
    MOV DI, TARGET_ADDR
    MOV CX, 26
    
LOP:
    MOV AL, [SI]
    MOV DX, DATA_8251
    
    PUSH AX
    PUSH DX
    MOV AL, 00110111B   ;37H
    MOV DX, CTR_8251
    OUT DX, AL
    POP DX
    POP AX
    
    OUT DX, AL
    CALL DELAY
    
AA1:
    MOV DX, CTR_8251
    IN AL, DX
    AND AL, 00000001B   ;01H
    JZ AA1
    CALL DELAY
    
AA2:
    MOV DX, CTR_8251
    IN AL, DX
    TEST AL, 00000010B   ;02H
    JZ AA2
    
    PUSH AX
    MOV DX, DATA_8251
    IN AL, DX
    MOV [DI], AL
    POP AX
    
    ;MOV AL, 00001000B
    
    TEST AL, 00111000B
    JNZ ERR
    
    INC SI
    INC DI
    LOOP LOP
        
    JMP EXIT
    
ERR:
    MOV DX, PB_8255
    OUT DX, AL
    JMP EXIT
    
DELAY:
    PUSH CX
    MOV CX, 00FFH
    LOOP $
    POP CX
    RET
    
EXIT:
    JMP EXIT
    MOV AH, 4CH
    INT 21H
CODE ENDS
    END START
    