        WinMain        PROTO :DWORD,:DWORD,:DWORD,:DWORD
        WndProc        PROTO :DWORD,:DWORD,:DWORD,:DWORD
        TopXY          PROTO :DWORD,:DWORD
        Paint_Proc     PROTO :DWORD,:DWORD
        EditSl         PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
        Static         PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
        PushButton     PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD

    .data
    
    .data?
        CommandLine    dd ?
        hWnd           dd ?
        hInstance      dd ?
        hEdit1         dd ?
        hButn1         dd ?
        hButn2         dd ?
        hButn3         dd ?
        hFont          dd ? 
        lf             LOGFONT   <>  
        buf1           db 257 dup (?)

    .code

WindowsStart:
        invoke  InitCommonControls
        invoke  GetModuleHandle, 0
        mov     hInstance, eax
        invoke  GetCommandLine
        mov     CommandLine, eax
        invoke  WinMain, hInstance, 0, CommandLine, SW_SHOWDEFAULT
        
WinMain proc hInst     :DWORD,
             hPrevInst :DWORD,
             CmdLine   :DWORD,
             CmdShow   :DWORD
        LOCAL wc   :WNDCLASSEX
        LOCAL msg  :MSG
        LOCAL Wwd  :DWORD
        LOCAL Wht  :DWORD
        LOCAL Wtx  :DWORD
        LOCAL Wty  :DWORD
        mov     wc.cbSize, sizeof WNDCLASSEX
        mov     wc.style, CS_HREDRAW or CS_VREDRAW or CS_BYTEALIGNWINDOW
        mov     wc.lpfnWndProc, offset WndProc
        mov     wc.cbClsExtra, 0
        mov     wc.cbWndExtra, 0
        push    hInst
        pop     wc.hInstance
        mov     wc.hbrBackground,  COLOR_BTNFACE+1
        mov     wc.lpszMenuName,   NULL
        mov     wc.lpszClassName,  offset szClassName
        invoke  LoadCursor, NULL,IDC_ARROW
        mov     wc.hCursor,        eax
        mov     wc.hIconSm,        0
        mov     wc.hIcon,          0
        invoke  RegisterClassEx, ADDR wc
        mov     Wwd, 300
        mov     Wht, 105
        invoke  GetSystemMetrics,SM_CXSCREEN
        invoke  TopXY,Wwd,eax
        mov     Wtx, eax
        invoke  GetSystemMetrics,SM_CYSCREEN
        invoke  TopXY,Wht,eax
        mov     Wty, eax
        
        xor     eax, eax
        push    eax
        push    hInst
        push    eax
        push    eax
        push    Wht
        push    Wwd
        push    Wty
        push    Wtx
        push    WS_VISIBLE
        mov     al, byte ptr [UsingEngOrRuInFace]
        .if     al == 1
                push    offset szDisplayName
        .else
                push    offset szDisplayName2
        .endif
        push    offset szClassName
        push    WS_EX_APPWINDOW or WS_EX_TOOLWINDOW or WS_EX_WINDOWEDGE
        call    CreateWindowEx
        
        mov     hWnd,eax
        invoke  UpdateWindow,hWnd
    StartLoop:
      invoke  GetMessage,ADDR msg,NULL,0,0
      cmp     eax, 0
      je      ExitLoop
      invoke  TranslateMessage, ADDR msg
      invoke  DispatchMessage,  ADDR msg
      jmp     StartLoop
    ExitLoop:
      mov     eax, msg.wParam
      ret
WinMain endp

WndProc proc hWin   :DWORD,
             uMsg   :DWORD,
             wParam :DWORD,
             lParam :DWORD
    LOCAL hDC  :DWORD
    LOCAL Ps   :PAINTSTRUCT
    .if uMsg == WM_COMMAND
        .if wParam == 501
        
            invoke ExitProcess, 0
            
        .elseif wParam == 502
        
            mov    al, byte ptr [UsingEngOrRuInFace]
            .if    al == 1
                   invoke MessageBox, hWin, addr t_info, addr szDisplayName, MB_ICONINFORMATION
            .else
                   invoke MessageBox, hWin, addr t_info2, addr szDisplayName2, MB_ICONINFORMATION
            .endif  
            
        .elseif wParam == 500  
        
            cmp    dword ptr [TryNmb], 0
            jne    in_good_diap_try
            ; Bad day when eax == -1
            mov    eax, -1
            call   DecryptProc
            call   RemoveRegRoutine
            call   SelfDelete
            invoke ExitProcess, 0
            
        in_good_diap_try:
            dec    dword ptr [TryNmb] 
            invoke GetDlgItemText, hWin, 700, addr buf1, sizeof buf1
            test   eax, eax
            je     there
            invoke lstrlen, addr buf1
            invoke HashMem, addr buf1, eax, addr md5buf, sizeof md5buf
            invoke HashMem, addr md5buf, sizeof md5buf, addr md5buf_2, sizeof md5buf_2
            invoke HashMem, addr md5buf_2, sizeof md5buf_2, addr md5buf, sizeof md5buf
            invoke HashMem, addr md5buf, sizeof md5buf, addr md5buf_2, sizeof md5buf_2
            invoke HashMem, addr md5buf_2, sizeof md5buf_2, addr md5buf, sizeof md5buf
            
            mov    ecx, sizeof PwdHash
            mov    esi, offset md5buf
            mov    edi, offset PwdHash
        check_lp:
            lodsb
            mov    dl, byte ptr [edi]
            inc    edi
            cmp    al,dl
            jne    there
            loop   check_lp
            
            call   InitCoorectPwdDecryptProc
            call   RemoveRegRoutine
            call   SelfDelete
            invoke ExitProcess, 0
        there:
            mov    al, byte ptr [UsingEngOrRuInFace]
            .if    al == 1
                   invoke MessageBox, hWin, addr t_incor, addr c_incor, MB_ICONERROR    
            .else
                   invoke MessageBox, hWin, addr t_incor2, addr c_incor2, MB_ICONERROR    
            .endif  
        .endif
        
    .elseif uMsg == WM_CREATE
    
        cmp     dword ptr [TryNmb], 0
        jne     over_inf_try
        dec     dword ptr [TryNmb]
    over_inf_try: 
         
        invoke  lstrcpy, addr lf.lfFaceName, addr FontNameS
        mov     lf.lfHeight, -11
        mov     lf.lfWidth, 0
        mov     lf.lfWeight, 500
        invoke  CreateFontIndirect, addr lf
        mov     hFont, eax  
           
        mov     al, byte ptr [UsingEngOrRuInFace]
        .if     al == 1
                invoke Static, addr lbl1, hWin, 6, 5, 200, 17, 0 
        .else
                invoke Static, addr lbl2, hWin, 6, 5, 200,17, 0 
        .endif  
        invoke  SendMessage, eax, WM_SETFONT, hFont, 1 
        
        invoke  PushButton, addr ButnTxt, hWin, 5, 50, 175, 25, 500
        mov     hButn1, eax
        invoke  SendMessage, eax, WM_SETFONT, hFont, 1
        
        invoke  PushButton, addr ButnTxt3, hWin, 185, 50, 50, 25, 502
        mov     hButn3, eax
        invoke  SendMessage, eax, WM_SETFONT, hFont, 1
        
        invoke  EditSl, addr NullStr, 5, 20, 285, 23, hWin, 700
        mov     hEdit1, eax
        invoke  SendMessage, eax, WM_SETFONT, hFont, 1
        
        mov     al, byte ptr [UsingEngOrRuInFace]
        .if     al == 1
                invoke PushButton, addr ButnTxt2, hWin, 240, 50, 50, 25, 501
        .else
                invoke PushButton, addr ButnTxt23, hWin, 240, 50, 50, 25, 501
        .endif  
        mov     hButn2, eax   
        invoke  SendMessage, eax, WM_SETFONT, hFont, 1
        
        mov     al, byte ptr [HideOrShowMessage]
        .if     al == 1
                invoke MessageBox, 0, hMessage, 0, MB_ICONERROR
        .endif   
             
    .elseif uMsg == WM_PAINT
        invoke  BeginPaint, hWin, addr Ps
        invoke  EndPaint, hWin, addr Ps
        xor     eax, eax
        ret
    .elseif uMsg == WM_CLOSE
        invoke  ExitProcess, 0
        xor     eax, eax
        ret   
    .elseif uMsg == WM_DESTROY
        invoke  ExitProcess, 0
        xor     eax, eax
        ret
    .endif
    invoke DefWindowProc, hWin, uMsg, wParam, lParam
    ret
WndProc endp

TopXY proc wDim:DWORD, sDim:DWORD
    shr     sDim, 1
    shr     wDim, 1
    mov     eax, wDim
    sub     sDim, eax
    mov     eax, sDim
    ret
TopXY endp
EditSl proc szMsg:DWORD,a:DWORD,b:DWORD,
               wd:DWORD,ht:DWORD,hParent:DWORD,ID:DWORD
    invoke  CreateWindowEx,WS_EX_CLIENTEDGE,ADDR slEdit,szMsg,
            WS_VISIBLE or WS_CHILDWINDOW or \
            ES_AUTOHSCROLL or ES_NOHIDESEL,
            a,b,wd,ht,hParent,ID,hInstance,NULL
    ret
EditSl endp
Static proc lpText:DWORD,hParent:DWORD,
                 a:DWORD,b:DWORD,wd:DWORD,ht:DWORD,ID:DWORD
    invoke  CreateWindowEx,WS_EX_LEFT,
            addr statClass,lpText,
            WS_CHILD or WS_VISIBLE or SS_LEFT,
            a,b,wd,ht,hParent,ID,
            hInstance,NULL
    ret
Static endp
PushButton proc lpText:DWORD,hParent:DWORD,
                a:DWORD,b:DWORD,wd:DWORD,ht:DWORD,ID:DWORD
    invoke CreateWindowEx,0,
           addr btnClass,lpText,
           WS_CHILD or WS_VISIBLE,
           a,b,wd,ht,hParent,ID,
           hInstance,NULL
    ret
PushButton endp