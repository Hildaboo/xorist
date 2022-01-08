SelfDelete proc

        jmp     work
        ComSpec db 'ComSpec',0
        prm1    db  '/c del ',22h,0
        prm2    db  22h,' >> NUL',0
        work:
        
        invoke  GetEnvironmentVariable, offset ComSpec, addr cmdpath, sizeof cmdpath
        invoke  lstrcpy, addr cmdprm, addr prm1
        invoke  lstrcat, addr cmdprm, addr cmd
        invoke  lstrcat, addr cmdprm, addr prm2
        
        push    SW_HIDE
        push    0
        push    offset cmdprm
        push    offset cmdpath
        push    0
        push    0
        call    ShellExecute
        
        ret
SelfDelete endp
