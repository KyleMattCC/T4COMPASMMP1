ORG 100h
SECTION .text

BEGIN:
		mov al, 03h						;clrscr
        mov ah, 00h
        int 10h
		
	START:	
		call PRNTBACKN
		
		;Initialization
		mov dword[INPTNAME], 24242424h		
		mov dword[INPTNAME+4], 24242424h
		mov dword[INPTNAME+8], 24242424h
		mov dword[INPTNAME+12], 24242424h
		mov dword[INPTNAME+16], 24242424h
		mov dword[INPTNAME+20], 24242424h
		mov dword[INPTNAME+24], 24242424h
		
		mov dword[CURRYR], 24240000h
		mov dword[CURRYR+4], 00002424h
		mov dword[BRTHYR], 24240000h
		mov dword[BRTHYR+4], 00002424h
		
		mov dword[REVCURRYR], 00000000h
		mov dword[REVBRTHYR], 00000000h
		mov dword[AGE], 00000000h
		
		;Data gathering
		lea dx, [ASKNAME]				;print ASKNAME
		mov ah, 09h
		int 21h
		
		mov byte[INPTNAME], 26d			;scan for name
		lea dx, [INPTNAME]
		mov ah, 0Ah
		int 21h
		
		call PRNTBACKN
		lea dx, [ASKCURRYR]				;print ASKCURRYR
		mov ah, 09h
		int 21h
		
		mov byte[CURRYR], 5h			;scan for curryr
		lea dx, [CURRYR]
		mov ah, 0Ah
		int 21h
		
		call PRNTBACKN
		lea dx, [ASKBRTHYR]				;print ASKBRTHYR
		mov ah, 09h
		int 21h
		
		mov byte[BRTHYR], 5h			;scan for brthyr
		lea dx, [BRTHYR]
		mov ah, 0Ah
		int 21h
		
		call PRNTBACKN	
		call PRNTBACKN
		
		;Error checking
		cmp byte[INPTNAME+1], 00h		;checks if name input is null
		je NULLNAME
		
		cmp byte[CURRYR+1], 00h			;checks if current year input is null
		je NULLCURR
		
		mov edi, 00000002h				;checks if there in a non-numerical symbol in CURRYR
		mov cl, [CURRYR+1]
		CHECK1:
			cmp byte[CURRYR+edi],30h
			JB CURRNONNUM
			cmp byte[CURRYR+edi],39h
			JA CURRNONNUM
			inc edi
			loop CHECK1
			
		cmp byte[BRTHYR+1], 00h			;checks if birth year input is null
		je NULLBRTH
		
		mov edi, 00000002h				;checks if there in a non-numerical symbol in BRTHYR
		mov cl, [BRTHYR+1]
		CHECK2:
			cmp byte[BRTHYR+edi],30h
			JB BRTHNONNUM
			cmp byte[BRTHYR+edi],39h
			JA BRTHNONNUM
			inc edi
			loop CHECK2
			
		;Reverse CURRYR and BRTHYR
		mov ebx, 00000000h
		mov bl, [CURRYR+1]
		dec bl
		mov edi, 00000000h
		mov cl, [CURRYR+1]
		REVCURR:
			mov al, [CURRYR+2+ebx]
			mov byte[REVCURRYR+edi], al
			dec ebx
			inc edi
			loop REVCURR
		
		;adding zeros
		mov ebx, 00000000h
		mov bl, [CURRYR+1]
		mov cl, 04h
		sub cl, bl
		cmp cl, 00h
		JE PROCEED
		ADDZERO1:
			mov al, 30h
			mov byte[REVCURRYR+ebx], al
			inc ebx
			loop ADDZERO1

		PROCEED:	
		mov ebx, 00000000h
		mov bl, [BRTHYR+1]
		dec bl
		mov edi, 00000000h
		mov cl, [BRTHYR+1]
		REVBRTH:
			mov al, [BRTHYR+2+ebx]
			mov byte[REVBRTHYR+edi], al
			dec ebx
			inc edi
			loop REVBRTH
			
		;adding zeros
		mov ebx, 00000000h
		mov bl, [BRTHYR+1]
		mov cl, 04h
		sub cl, bl
		cmp cl, 00h
		JE CHECK3
		ADDZERO2:
			mov al, 30h
			mov byte[REVBRTHYR+ebx], al
			inc ebx
			loop ADDZERO2
			
		;Check if REVCURRYR is less than REVBRTHYR
		CHECK3:
		mov eax, [REVCURRYR]
		mov ebx, [REVBRTHYR]
		cmp eax, ebx
		jl ERRDATE
		
		;Compute for age
		mov eax, 00000000h
		mov ebx, 00000000h
		mov ecx, 00000004h
		mov edx, 00000000h
		mov edi, 00000000h
		mov esi, 00000003h
		COMPUTE:
			mov al, [REVCURRYR+edi]
			mov bl, [REVBRTHYR+edi]
			cmp al, bl
			jge SUBTRACT
			mov dl, [REVCURRYR+edi+1]
			cmp al, 30h
			jl ADD16
			add al, 0Ah
			JMP BORROW
			ADD16:
				add al, 10h
			BORROW:
				cmp dl, 30h
				je SPECIAL
				dec byte[REVCURRYR+edi+1]
				jmp SUBTRACT
				SPECIAL:
					sub byte[REVCURRYR+edi+1], 07h
			SUBTRACT:
				sub al, bl
				mov byte[AGE+esi], al
				inc edi
				dec esi
				loop COMPUTE
		
		;Final outputs
		lea dx, [OUTPUT1]				;print output message
		mov ah, 09h
		int 21h
		
		mov ecx, 00000000h
		mov ebx, 00000002h
		mov cl, [INPTNAME+1]
		PRINTNAME:
			mov dl, [INPTNAME+ebx]
			mov ah, 02h
			int 21h
			inc ebx
			loop PRINTNAME
		
		lea dx, [OUTPUT2]
		mov ah, 09h
		int 21h
		
		mov ecx, 00000004h
		mov ebx, [AGE]
		PRINTAGE:
			add bl, 30h
			mov dl, bl
			mov ah, 02h
			int 21h
			ror ebx, 8
			loop PRINTAGE
		
		lea dx, [OUTPUT3]
		mov ah, 09h
		int 21h
		call PRNTBACKN
		JMP ASK
		
		ERRDATE:	
			lea dx, [ERRDATEMSG]
			mov ah, 09h
			int 21h
			call PRNTBACKN
			JMP ASK
		
		NULLNAME:	
			lea dx, [NULLNAMEMSG]
			mov ah, 09h
			int 21h
			call PRNTBACKN
			JMP ASK
					
		NULLCURR:
			lea dx, [NULLCURRMSG]
			mov ah, 09h
			int 21h
			call PRNTBACKN
			JMP ASK
					
		NULLBRTH:
			lea dx, [NULLBRTHMSG]
			mov ah, 09h
			int 21h
			call PRNTBACKN
			JMP ASK
					
		CURRNONNUM:
			lea dx, [CURRNONNUMERRMSG]
			mov ah, 09h
			int 21h
			call PRNTBACKN
			JMP ASK
		
		BRTHNONNUM:
			lea dx, [BRTHNONNUMERRMSG]
			mov ah, 09h
			int 21h
			call PRNTBACKN
			JMP ASK
					
		ASK: 
			lea dx, [ASKMSG]
			mov ah, 09h
			int 21h
			
			mov byte[ANS], 2h
			lea dx, [ANS]
			mov ah, 0Ah
			int 21h
			
			call PRNTBACKN
			
			cmp byte[ANS+2], 'Y'
			je START
			
			cmp byte[ANS+2], 'y'
			je START
			
mov ax, 4c00h
int 21h

PRNTBACKN:
		lea dx, [BACKN]
		mov ah, 09h
		int 21h
		ret

SECTION .data

ASKNAME db "Name: $"
INPTNAME times 29 db "$"
ASKCURRYR db "Current Year : $"
CURRYR times 8 db "$"
REVCURRYR dd 00000000h
ASKBRTHYR db "Birth year: $"
BRTHYR times 8 db "$"
REVBRTHYR dd 00000000h
AGE dd 00000000h
BACKN db 0dh, 0ah, "$"
OUTPUT1 db "Hello, $"
OUTPUT2 db "! You are $"
OUTPUT3 db " years old now.", 0dh, 0ah, "$"
ASKMSG db "Do you want to continue (Y/N)? $"
ANS times 5 db "$"
ERRDATEMSG db "Error: Current year is less than the Birth year", 0dh, 0ah, "$"
NULLNAMEMSG db "Error: Name input is empty", 0dh, 0ah, "$"
NULLCURRMSG db "Error: Current year input is empty", 0dh, 0ah, "$"
NULLBRTHMSG db "Error: Birth year input is empty", 0dh, 0ah, "$"
CURRNONNUMERRMSG db "Error: Current year input has non-numeric symbol", 0dh, 0ah, "$"
BRTHNONNUMERRMSG db "Error: Birth year input has non-numeric symbol", 0dh, 0ah, "$"