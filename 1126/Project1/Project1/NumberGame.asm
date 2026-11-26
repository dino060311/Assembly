.386
.model flat, stdcall
option casemap:none

; ==========================================
; Windows API 선언
; ==========================================
GetStdHandle PROTO :DWORD
ReadConsoleA PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
WriteConsoleA PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
GetTickCount PROTO
ExitProcess PROTO :DWORD

includelib kernel32.lib

.data
    ; 안내 메시지
    titleMsg BYTE "=== NUMBER GUESSING GAME ===", 13, 10
             BYTE "Guess a number between 1 and 100.", 13, 10
             BYTE "You have 7 chances.", 13, 10, 13, 10, 0

    chanceMsg BYTE "Chances left: ", 0
    promptMsg BYTE "Your guess: ", 0

    ; 힌트 메시지
    upMsg BYTE "UP!", 13, 10, 13, 10, 0
    downMsg BYTE "DOWN!", 13, 10, 13, 10, 0

    ; 결과 메시지
    correctMsg BYTE "Correct! You win!", 13, 10, 0
    failMsg BYTE "Game over! The answer was ", 0

    ; 잘못된 입력 안내
    invalidMsg BYTE "Enter an integer from 1 to 100.", 13, 10
               BYTE "This input does not use a chance.", 13, 10, 13, 10, 0

    newLine BYTE 13, 10, 0

    ; 남은 기회를 출력하기 위한 문자열
    chanceText BYTE "7", 0

    ; 게임 데이터
    answer DWORD ?
    remaining DWORD 7

    ; 콘솔 핸들
    hInput DWORD ?
    hOutput DWORD ?

    ; 실제 입출력 문자 수
    bytesRead DWORD ?
    written DWORD ?

    ; 입력 버퍼
    inputBuffer BYTE 128 DUP(?)

    ; 정수를 문자열로 바꿀 때 사용하는 버퍼
    numberBuffer BYTE 11 DUP(0)

.code

; ==========================================
; PrintText
; 기능: 0으로 끝나는 문자열 출력
; 인수: pText = 문자열 주소
; ==========================================
PrintText PROC USES eax ecx edx, pText:DWORD

    mov edx, pText
    xor ecx, ecx

CountLength:
    cmp BYTE PTR [edx + ecx], 0
    je WriteText

    inc ecx
    jmp CountLength

WriteText:
    invoke WriteConsoleA, hOutput, pText, ecx, ADDR written, 0
    ret

PrintText ENDP

; ==========================================
; PrintNumber
; 기능: 부호 없는 정수를 문자열로 바꾸어 출력
; 인수: value = 출력할 정수
; ==========================================
PrintNumber PROC USES eax ebx edx edi, value:DWORD

    mov eax, value
    mov ebx, 10

    ; 버퍼 끝에서부터 숫자 저장
    mov edi, OFFSET numberBuffer
    add edi, 10
    mov BYTE PTR [edi], 0

ConvertDigit:
    xor edx, edx
    div ebx

    ; 나머지를 숫자 문자로 변환
    add dl, '0'

    dec edi
    mov BYTE PTR [edi], dl

    ; 몫이 0이 아니면 계속 변환
    test eax, eax
    jnz ConvertDigit

    invoke PrintText, edi
    ret

PrintNumber ENDP

; ==========================================
; ReadGuess
; 기능: 입력 문자열을 정수로 변환
;
; 반환:
;   EAX = 1~100 : 정상 입력
;   EAX = -1    : 잘못된 입력
; ==========================================
ReadGuess PROC USES ecx edx esi

    invoke ReadConsoleA, hInput, ADDR inputBuffer, \
           LENGTHOF inputBuffer, ADDR bytesRead, 0

    ; 입력 API 실패 시 프로그램 종료
    test eax, eax
    jz InputFailed

    cmp bytesRead, 0
    je InputFailed

    mov esi, OFFSET inputBuffer
    mov ecx, bytesRead
    xor eax, eax

ConvertLoop:
    ; 버퍼 범위를 벗어나지 않도록 검사
    test ecx, ecx
    jz InvalidNumber

    movzx edx, BYTE PTR [esi]

    ; 줄바꿈 문자를 만나면 변환 종료
    cmp edx, 13
    je CheckRange

    cmp edx, 10
    je CheckRange

    ; 숫자 문자만 허용
    cmp edx, '0'
    jb InvalidNumber

    cmp edx, '9'
    ja InvalidNumber

    ; ASCII 문자 → 정수 숫자
    sub edx, '0'

    ; 누적값 = 누적값 * 10 + 현재 숫자
    imul eax, eax, 10
    add eax, edx

    ; 매 자리마다 상한 검사
    cmp eax, 100
    ja InvalidNumber

    inc esi
    dec ecx
    jmp ConvertLoop

CheckRange:
    ; 0과 빈 입력도 거부
    cmp eax, 1
    jb InvalidNumber

    ret

InvalidNumber:
    mov eax, -1
    ret

InputFailed:
    invoke ExitProcess, 1

ReadGuess ENDP

; ==========================================
; main
; 기능: 초기화, 정답 생성, 게임 진행
; ==========================================
main PROC

    ; 표준 입력 핸들 얻기
    invoke GetStdHandle, -10
    mov hInput, eax

    ; 표준 출력 핸들 얻기
    invoke GetStdHandle, -11
    mov hOutput, eax

    ; ======================================
    ; 학습용 의사난수 계산
    ; 실행 시점의 시간값을 시작값으로 사용
    ; ======================================
    invoke GetTickCount

    imul eax, eax, 214013
    add eax, 2531011

    shr eax, 16
    and eax, 7FFFh

    ; 100으로 나눈 나머지: 0~99
    xor edx, edx
    mov ecx, 100
    div ecx

    ; 정답 범위: 1~100
    inc edx
    mov answer, edx

    ; 시도 횟수 초기화
    mov remaining, 7

    ; 게임 안내 출력
    invoke PrintText, ADDR titleMsg

GameLoop:
    ; 남은 기회 출력
    invoke PrintText, ADDR chanceMsg

    ; 1~7의 숫자를 문자로 변환
    mov eax, remaining
    add al, '0'
    mov chanceText, al

    invoke PrintText, ADDR chanceText
    invoke PrintText, ADDR newLine

    ; 입력 안내
    invoke PrintText, ADDR promptMsg

    ; 입력값을 EAX로 받음
    call ReadGuess

    ; 잘못된 입력이면 재입력
    cmp eax, -1
    je BadInput

    ; 정상 입력일 때만 기회 차감
    dec remaining

    ; 정답 비교
    cmp eax, answer
    je GameWin
    jl ShowUp
    jg ShowDown

ShowUp:
    invoke PrintText, ADDR upMsg
    jmp CheckRemaining

ShowDown:
    invoke PrintText, ADDR downMsg
    jmp CheckRemaining

CheckRemaining:
    ; 기회를 모두 사용했는지 확인
    cmp remaining, 0
    je GameLose

    jmp GameLoop

BadInput:
    ; 기회는 차감하지 않음
    invoke PrintText, ADDR invalidMsg
    jmp GameLoop

GameWin:
    invoke PrintText, ADDR correctMsg
    jmp GameEnd

GameLose:
    ; 실제 정답을 숫자로 출력
    invoke PrintText, ADDR failMsg
    invoke PrintNumber, answer
    invoke PrintText, ADDR newLine

GameEnd:
    invoke ExitProcess, 0

main ENDP
END main