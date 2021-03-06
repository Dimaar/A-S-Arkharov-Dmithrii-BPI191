; BPI 191, Var 3: Arkharov Dmithry
; The application compares two strings and returns if the first is "greater" than second

format  PE Console
include "WIN32AX.INC"

entry main

section '.data' data readable writeable ; here is the data stored

        endl FIX 10, 13 ; \n

        ; Fields to store necessary data
        argc dd ?
        argv dd ?
        env dd ?

        str_buffer  DB  256 dup (0) ; str buffer
        mb_title    db  "BPI191 Arkharov Dmithry strcmp.exe", 0 ; messagebox title (just not to rewrite it several times)

section '.text' code readable executable ; here is were the executable code starts

proc main
        invoke GetCommandLine  ; getting args
        cinvoke __getmainargs,argc,argv,env,0 ;
        mov esi,[argv] ; storing from argv

        mov eax, dword[esi+4] ;first str
        mov ebx, dword[esi+8] ;second str

        ;checking if lengths are equal
        mov ecx, eax
        push ecx
        call strlen
        mov edx, EAX
        mov ecx, ebx
        push ecx
        call strlen
        cmp edx, EAX
        je .compare ;if lengths are equal we can call strcmp
        jl .lower   ;otherwise comparing lengths
        jg .greater

        .compare:
        mov eax, dword[esi+4]
        mov ebx, dword[esi+8]
        push eax
        push ebx

        call strcmp

        cmp ecx, 0
        je .equal

        cmp ecx, 1
        je .lower

        cmp ecx, -1
        je .greater
endp

.equal:

invoke  wsprintf,str_buffer, "%s", "Equal"; buffer for messagebox
invoke  MessageBox,0,str_buffer, mb_title,MB_OK ; displaying messagebox
jmp .finish

.greater:

invoke  wsprintf,str_buffer, "%s", "Greater"; buffer for messagebox
invoke  MessageBox,0,str_buffer, mb_title,MB_OK ; displaying messagebox
jmp .finish

.lower:

invoke  wsprintf,str_buffer, "%s", "Lower"; buffer for messagebox
invoke  MessageBox,0,str_buffer, mb_title,MB_OK ; displaying messagebox
jmp .finish

; finish section
.finish:
        invoke ExitProcess,0

; Show results and other information
proc show_info
        enter 0, 0
        invoke  wsprintf,str_buffer, str_format, [num], [answer]; getting correct buffer for MessageBox to show in
        invoke  MessageBox,0,str_buffer, mb_title,MB_OK ; Showing messagebox
        leave
        ret
endp

;returns length of str
proc    strlen lpStr:DWORD
        push    edi ecx
 
        cld
        mov     edi,[lpStr]
        xor     ecx,ecx
        dec     ecx
        xor     eax,eax
        repne   scasb
        not     ecx
        dec     ecx
        mov     eax,ecx
 
        pop     ecx edi
        ret
endp

;strcmp func
proc strcmp
    mov ecx, 0
    strcmp_loop:
        mov byte dl,[eax+ecx]
        mov byte dh,[ebx+ecx]
        inc ecx
        cmp dl,0
        je strcmp_end_0
        cmp byte dl,dh
        je strcmp_loop
        jl strcmp_end_1
        jg strcmp_end_2
    strcmp_end_0:
        cmp dh,0
        jne strcmp_end_1
        xor ecx,ecx
        ret
    strcmp_end_1:
        mov ecx,1
        ret
    strcmp_end_2:
        mov ecx,-1
        ret
endp

section '.idata' import data readable ; section for imports
        library user32,'user32.dll',kernel32,'kernel32.dll',msvcrt,'msvcrt.dll',shell32,'shell32.dll'

        include '\API\USER32.INC'
        include '\API\KERNEL32.INC'
        include '\API\SHELL32.INC'

        import msvcrt,\__getmainargs,'__getmainargs',sscanf,'sscanf';,strcmp,'strcmp'

