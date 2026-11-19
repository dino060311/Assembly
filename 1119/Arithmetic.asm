.386
.model flat, C
.stack 4096

.data
    num1 DWORD ?
    num2 DWORD ?

    addResult DWORD ?
    subResult DWORD ?
    mulResult DWORD ?
    divResult DWORD ?

    ; 레지스터 값 저장
    regAX WORD ?
    regBX WORD ?
    regCX WORD ?
    regDX WORD ?

    inputMsg BYTE "Enter two integers: ", 0
    inputFmt BYTE "%d", 0

    addFmt BYTE "Addition = %d", 13, 10, 0
    subFmt BYTE "Subtraction = %d", 13, 10, 0
    mulFmt BYTE "Multiplication = %d", 13, 10, 0
    divFmt BYTE "Division = %d", 13, 10, 0

    regFmt BYTE 13, 10, "===== Register Contents =====", 13, 10,
                "AX = %d, BX = %d, CX = %d, DX = %d", 13, 10, 0

    zeroMsg BYTE "Cannot divide by zero.", 13, 10, 0

.code

EXTERN scanf:PROC
EXTERN printf:PROC

main PROC

    push ebx

    ; 두 숫자 입력 안내
    push OFFSET inputMsg
    call printf
    add esp, 4

    ; 첫 번째 숫자 입력
    push OFFSET num1
    push OFFSET inputFmt
    call scanf
    add esp, 8

    ; 두 번째 숫자 입력
    push OFFSET num2
    push OFFSET inputFmt
    call scanf
    add esp, 8

    ; 덧셈
    mov eax, num1
    add eax, num2
    mov addResult, eax

    ; 뺄셈
    mov eax, num1
    sub eax, num2
    mov subResult, eax

    ; 곱셈
    mov eax, num1
    imul num2
    mov mulResult, eax

    ; 나눗셈
    mov eax, num1
    cdq
    mov ebx, num2

    cmp ebx, 0
    je DivideZero

    idiv ebx
    mov divResult, eax

    jmp PrintResult

DivideZero:
    push OFFSET zeroMsg
    call printf
    add esp, 4

    jmp PrintRegisters

PrintResult:

    ; 덧셈 결과 출력
    push addResult
    push OFFSET addFmt
    call printf
    add esp, 8

    ; 뺄셈 결과 출력
    push subResult
    push OFFSET subFmt
    call printf
    add esp, 8

    ; 곱셈 결과 출력
    push mulResult
    push OFFSET mulFmt
    call printf
    add esp, 8

    ; 나눗셈 결과 출력
    push divResult
    push OFFSET divFmt
    call printf
    add esp, 8

PrintRegisters:

    ; AX, BX 레지스터 설정
    mov ax, WORD PTR num1
    mov bx, WORD PTR num2

    ; CX = AX + BX
    mov cx, ax
    add cx, bx

    ; DX = AX - BX
    mov dx, ax
    sub dx, bx

    ; 레지스터 값 저장
    mov regAX, ax
    mov regBX, bx
    mov regCX, cx
    mov regDX, dx

    ; 레지스터 값 출력
    movsx eax, WORD PTR regDX
    push eax

    movsx eax, WORD PTR regCX
    push eax

    movsx eax, WORD PTR regBX
    push eax

    movsx eax, WORD PTR regAX
    push eax

    push OFFSET regFmt
    call printf
    add esp, 20

    pop ebx

    ret

main ENDP
END
