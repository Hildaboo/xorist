align dword
TEAInit proc pKey:DWORD
	mov eax,pKey
	mov ecx,[eax+0*4]
	mov edx,[eax+1*4]
	bswap ecx
	bswap edx
	mov [TEA_KEY_origin+0*4],ecx
	mov [TEA_KEY_origin+1*4],edx
	mov ecx,[eax+2*4]
	mov edx,[eax+3*4]
	bswap ecx
	bswap edx
	mov [TEA_KEY_origin+2*4],ecx
	mov [TEA_KEY_origin+3*4],edx
	ret
TEAInit endp

TEAROUND macro y,z,k,enc
	mov ecx,z
	shl ecx,4
	mov edi,z
	lea esi,[z+ebx]
	add ecx,[TEA_KEY+(k+0)*4]
	shr edi,5
	xor ecx,esi
	add edi,[TEA_KEY+(k+1)*4]
	xor ecx,edi
	if enc eq 1 
	add y,ecx
	else
	sub y,ecx
	endif
endm

align dword
TEAEncrypt proc uses edi esi ebx pBlockIn:DWORD,pBlockOut:DWORD
	mov esi,pBlockIn
	mov eax,[esi+0*4];y
	mov edx,[esi+1*4];z
	xor ebx,ebx
	bswap eax
	bswap edx
	.repeat
		add ebx,TEA_DELTA
		TEAROUND eax,edx,0,1
		TEAROUND edx,eax,2,1
		add ebx,TEA_DELTA
		TEAROUND eax,edx,0,1
		TEAROUND edx,eax,2,1
		mov ecx, TEA_DELTA
		imul ecx, dword ptr [TEA_ROUNDS]
	.until ebx == ecx
	bswap eax
	bswap edx
	mov esi,pBlockOut
	mov [esi+0*4],eax
	mov [esi+1*4],edx
	ret
TEAEncrypt endp

align dword
TEADecrypt proc uses edi esi ebx pBlockIn:DWORD,pBlockOut:DWORD
	mov esi,pBlockIn
	mov eax,[esi+0*4]
	mov edx,[esi+1*4]
	mov ebx,TEA_DELTA
	imul ebx, dword ptr [TEA_ROUNDS]
	bswap eax
	bswap edx
	.repeat
		TEAROUND edx,eax,2,0
		TEAROUND eax,edx,0,0
		sub ebx,TEA_DELTA
		TEAROUND edx,eax,2,0
		TEAROUND eax,edx,0,0
		sub ebx,TEA_DELTA
	.until zero?
	bswap eax
	bswap edx
	mov esi,pBlockOut
	mov [esi+0*4],eax
	mov [esi+1*4],edx
	ret
TEADecrypt endp