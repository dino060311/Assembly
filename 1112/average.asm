.386
.model flat, C
.stack 4096

.data
    num1 DWORD ?
    num2 DWORD ?
    num3 DWORD ?
    num4 DWORD ?
    num5 DWORD ?

    sum DWORD ?
    avg DWORD ?

    inputMsg BYTE "Enter 5 integers: ", 0
    inputFmt BYTE "%d", 0
    outputFmt BYTE "Sum = %d, Average = %d", 13, 10, 0

.code

EXTERN _scanf:PROC
EXTERN _printf:PROC

main PROC

    ; 숫자 5개 입력 안내
    push OFFSET inputMsg
    call _printf
    add esp, 4

    ; 첫 번째 숫자 입력
    push OFFSET num1
    push OFFSET inputFmt
    call _scanf
    add esp, 8

    ; 두 번째 숫자 입력
    push OFFSET num2
    push OFFSET inputFmt
    call _scanf
    add esp, 8

    ; 세 번째 숫자 입력
    push OFFSET num3
    push OFFSET inputFmt
    call _scanf
    add esp, 8

    ; 네 번째 숫자 입력
    push OFFSET num4
    push OFFSET inputFmt
    call _scanf
    add esp, 8

    ; 다섯 번째 숫자 입력
    push OFFSET num5
    push OFFSET inputFmt
    call _scanf
    add esp, 8

    ; 다섯 숫자의 합 계산
    mov eax, num1
    add eax, num2
    add eax, num3
    add eax, num4
    add eax, num5

    mov sum, eax

    ; 평균 계산
    cdq
    mov ebx, 5
    idiv ebx

    mov avg, eax

    ; 합계와 평균 출력
    push avg
    push sum
    push OFFSET outputFmt
    call _printf
    add esp, 12

    ret

main ENDP
END
