DATA SEGMENT
	;���ݶ�Ĭ����ʼ��ַΪ0200H
	DATA1 DW 16 DUP(1H)
DATA ENDS
CODE SEGMENT
	ASSUME CS:CODE, DS:DATA
START:
	;ʹ�������������öε�ַ
	MOV AX, 8000H
	MOV DS, AX
	
	MOV AX, 00H
	MOV CX, 15
	MOV BX, 0
	
	;�ǹ����� �ȴ����һ����ַΪż����ͷ���ֽ�
	MOV BYTE PTR [BX], AL
	INC BX
	INC AH
	
LOP:
	MOV WORD PTR [BX], AX
	INC BX
	INC BX
	;�ǹ����� ���Ӹ�λ
	INC AH
	LOOP LOP
	
	;�ǹ����� �������һ���ֽ�
	MOV BYTE PTR [BX], 0
	
	MOV AH, 4CH
	INT 21H
CODE ENDS
END START