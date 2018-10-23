PA_8255 EQU 0600H
PB_8255 EQU 0602H
PC_8255 EQU 0604H
CTR_8255 EQU 0606H

DATA SEGMENT
    LEDMAP DB 10111111B
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
                
    KEYTABLE    DB 11101110B    ;0
                DB 11011110B    ;1
                DB 10111110B    ;2
                DB 01111110B    ;3
                DB 11101101B    ;4
                DB 11011101B    ;5
                DB 10111101B    ;6
                DB 01111101B    ;7
                DB 11101011B    ;8
                DB 11011011B    ;9
                DB 10111011B    ;A
                DB 01111011B    ;B
                DB 11100111B    ;C
                DB 11010111B    ;D
                DB 10110111B    ;E
                DB 01110111B    ;F
	
	DAT DB 0, 0, 0, 0, 0, 0
DATA ENDS
CODE SEGMENT
    ASSUME CS: CODE, DS: DATA
START:
    MOV AX, DATA
    MOV DS, AX
    
    ; 8255 INIT
    MOV DX, CTR_8255
    MOV AL, 10001001B
    OUT DX, AL
    
    MOV DX, PB_8255
    MOV AL, 0   ;熄灭
    OUT DX, AL    
AA1:    
    CALL DISPLAY
    MOV DX, PB_8255
    MOV AL, 0   ;熄灭
    OUT DX, AL
    ;CALL RESET
    
    MOV DX, PA_8255
    MOV AL, 00000000B
    OUT DX, AL
    
    MOV DX, PC_8255
    IN AL, DX
    AND AL, 00001111B
    
    CMP AL, 00001111B
    JE AA1
    
    CALL DELAY  ;消抖
    
    MOV DX, PB_8255
    MOV AL, 0   ;熄灭
    OUT DX, AL
    
    MOV DX, PA_8255
    MOV AL, 00000000B
    OUT DX, AL
    
    MOV DX, PC_8255
    IN AL, DX
    AND AL, 00001111B
    
    CMP AL, 00001111B
    JE AA1
    
    MOV CX, 4
    MOV AH, 11111110B
    
AA2:
    MOV DX, PA_8255
    MOV AL, AH
    OUT DX, AL
    
    MOV DX, PC_8255
    IN AL, DX
    
    AND AL, 00001111B
    CMP AL, 00001111B
    
    JNE AA3 ;已确定了行、列
    
    ROL AH, 1
    LOOP AA2
    
    JMP AA1 ;查询失败
    
AA3:
    MOV CX, 4
    SHL AH, CL  ;AH中低4位存的列号移到高4位
    OR AL, AH   ;AH的行号合并到AL，形成位置码与KEYTABLE对应
    
    LEA BX, KEYTABLE
    
    MOV SI, 0   ;设置初始键号
AA4:    
    CMP AL, [BX + SI]
    JE AA5
    INC SI
    CMP SI, 16  ;可能有重键
    JE AA1
    JMP AA4
    
AA5:
    ;ROR LEDMAP, 1
    ;MOV CL, LEDMAP
    
    LEA BX, LEDTABLE
    MOV AH, [BX + SI]	; 存段码到AH    
    
    
    
    MOV CX, 5
    
    LEA BX, DAT
    MOV SI, 0
    
    ;向左导内存
AA6:    
    MOV AL, [BX + SI + 1]
    MOV [BX + SI], AL
    INC SI
    LOOP AA6
    
    MOV [BX + SI], AH   ;存入最后一个字节
    
    MOV CX, 0FFFH
AA7:
    CALL DISPLAY
    LOOP AA7    
    
    JMP AA1
    
DISPLAY:
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
    MOV CX, 6
    MOV AL, 11111110B
    
LOP:
    PUSH AX
    
    MOV DX, PA_8255
    OUT DX, AL
    
    LEA BX, DAT
    MOV SI, 0
    
    MOV AL, [BX + SI]
    MOV DX, PB_8255
    OUT DX, AL
        
    CALL DELAY
    
    MOV DX, PB_8255
    MOV AL, 0   ;熄灭
    OUT DX, AL
    
    POP AX
    ROL AL, 1
    INC SI
    LOOP LOP
        
    POP DX
    POP CX
    POP BX
    POP AX
    RET
    
DELAY:
    PUSH CX
    MOV CX, 00FFH
    LOOP $
    POP CX
    RET
    
RESET:
	PUSH AX
	PUSH DX
	MOV DX, PA_8255
    MOV AL, 11111111B
    OUT DX, AL
    
    MOV DX, PB_8255
    MOV AL, 0   ;熄灭
    OUT DX, AL
    
    POP DX
    POP AX
    RET
      
CODE ENDS
    END START
