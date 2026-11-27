# Programming Exercises 답안

---

## 1. ReadString

Implement your own version of the ReadString procedure, using stack parameters. Pass it a pointer to a string and an integer, indicating the maximum number of characters to be entered. Return a count (in EAX) of the number of characters actually entered. The procedure must input a string from the console and insert a null byte at the end of the string (in the position occupied by 0Dh). See Section 11.1.4 for details on the Win32 ReadConsole function. Write a short program that tests your procedure.

스택 매개변수를 사용하는 ReadString 프로시저를 직접 구현하시오. 문자열을 저장할 버퍼의 포인터와 입력 가능한 최대 문자 수를 나타내는 정수를 전달한다. 실제로 입력한 문자 수를 EAX에 반환한다. 이 프로시저는 콘솔에서 문자열을 입력받고 문자열 끝, 즉 0Dh가 차지하는 위치에 널 바이트를 삽입해야 한다. Win32 ReadConsole 함수에 관한 내용은 11.1.4절을 참고하시오. 프로시저를 시험하는 짧은 프로그램도 작성하시오.

**답:**

```asm
.386
.model flat, stdcall
.stack 4096
option casemap:none
includelib kernel32.lib

NULL                 EQU 0
STD_INPUT_HANDLE     EQU -10
STD_OUTPUT_HANDLE    EQU -11
INVALID_HANDLE_VALUE EQU -1

GetStdHandle PROTO, :DWORD
ReadConsoleA PROTO, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
WriteConsoleA PROTO, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
ExitProcess PROTO, :DWORD

PrintSpan PROTO, pText:DWORD, nBytes:DWORD
PrintZ PROTO, pText:DWORD
PrintUInt PROTO, number:DWORD
ReadString PROTO, pBuffer:DWORD, maxChars:DWORD

.data
hIn     DWORD ?
hOut    DWORD ?
buffer  BYTE 81 DUP(0)
count   DWORD ?
prompt  BYTE "Enter a string (maximum 80 characters): ",0
msgText BYTE "String: ",0
msgSize BYTE 13,10,"Length: ",0
crlf    BYTE 13,10,0
errMsg  BYTE "Console input failed.",13,10,0

.code
PrintSpan PROC USES esi ebx, pText:DWORD, nBytes:DWORD
    LOCAL written:DWORD
    mov esi, pText
    mov ebx, nBytes
psNext:
    test ebx, ebx
    jz psOK
    INVOKE WriteConsoleA, hOut, esi, ebx, ADDR written, NULL
    test eax, eax
    jz psError
    cmp written, 0
    je psError
    mov eax, written
    add esi, eax
    sub ebx, eax
    jmp psNext
psOK:
    mov eax, 1
    ret
psError:
    xor eax, eax
    ret
PrintSpan ENDP

PrintZ PROC USES esi, pText:DWORD
    mov esi, pText
    xor ecx, ecx
pzCount:
    cmp BYTE PTR [esi+ecx], 0
    je pzWrite
    inc ecx
    jmp pzCount
pzWrite:
    INVOKE PrintSpan, esi, ecx
    ret
PrintZ ENDP

PrintUInt PROC USES ebx esi, number:DWORD
    LOCAL digits[10]:BYTE
    lea esi, digits
    add esi, 10
    mov eax, number
    mov ebx, 10
puNext:
    xor edx, edx
    div ebx
    add dl, '0'
    dec esi
    mov [esi], dl
    test eax, eax
    jnz puNext
    lea eax, digits
    add eax, 10
    sub eax, esi
    INVOKE PrintSpan, esi, eax
    ret
PrintUInt ENDP

ReadString PROC USES ebx edi, pBuffer:DWORD, maxChars:DWORD
    LOCAL ch:BYTE, got:DWORD
    mov edi, pBuffer
    xor ebx, ebx
    mov BYTE PTR [edi], 0
rlNext:
    INVOKE ReadConsoleA, hIn, ADDR ch, 1, ADDR got, NULL
    test eax, eax
    jz rlError
    cmp got, 1
    jne rlError
    mov al, ch
    cmp al, 10
    je rlDone
    cmp al, 13
    je rlNext
    cmp ebx, maxChars
    jae rlNext
    mov [edi+ebx], al
    inc ebx
    jmp rlNext
rlDone:
    mov BYTE PTR [edi+ebx], 0
    mov eax, ebx
    clc
    ret
rlError:
    mov BYTE PTR [edi+ebx], 0
    mov eax, ebx
    stc
    ret
ReadString ENDP

main PROC
    INVOKE GetStdHandle, STD_INPUT_HANDLE
    mov hIn, eax
    INVOKE GetStdHandle, STD_OUTPUT_HANDLE
    mov hOut, eax

    INVOKE PrintZ, ADDR prompt

    push 80
    push OFFSET buffer
    call ReadString
    jc inputError
    mov count, eax

    INVOKE PrintZ, ADDR msgText
    INVOKE PrintZ, ADDR buffer
    INVOKE PrintZ, ADDR msgSize
    INVOKE PrintUInt, count
    INVOKE PrintZ, ADDR crlf
    INVOKE ExitProcess, 0
inputError:
    INVOKE PrintZ, ADDR errMsg
    INVOKE ExitProcess, 1
main ENDP
END main
```

**풀이:**

1. `ReadString`의 매개변수 `pBuffer`와 `maxChars`는 스택으로 전달한다. 테스트에서는 최대 길이, 버퍼 주소 순서로 `push`한 뒤 호출한다. `stdcall` 방식이므로 프로시저가 매개변수 공간을 정리한다.
2. `maxChars`는 널 바이트를 제외하고 저장할 수 있는 최대 문자 수이다. 따라서 최대 80문자를 저장하는 `buffer`는 81바이트로 선언한다.
3. `ReadConsoleA`로 한 바이트씩 받아 일반 문자는 버퍼에 저장하고, `0Dh`는 저장하지 않으며 `0Ah`를 만나면 입력을 끝낸다. 기본 콘솔 줄 입력 모드와 영문·숫자 등 단일 바이트 입력을 기준으로 한다.
4. 입력이 끝나면 `buffer[실제 저장 길이]`에 0을 넣는다. 제한 길이 이내의 입력에서는 이 위치가 원래 `0Dh`가 놓일 위치이다.
5. 최대 길이를 초과한 문자는 줄 끝까지 읽어서 버리므로 다음 입력에 남지 않는다. EAX에는 줄바꿈과 널 바이트를 제외한 저장 문자 수를 반환한다.
6. 성공하면 CF를 지우고 입력 API 호출에 실패하면 CF를 설정한다. 테스트 프로그램은 입력 문자열과 EAX에 반환된 길이를 출력한다.

---

## 2. String Input/Output

Write a program that inputs the following information from the user, using the Win32 ReadConsole function: first name, last name, age, phone number. Redisplay the same information with labels and attractive formatting, using the Win32 WriteConsole function. Do not use any procedures from the Irvine32 library.

Win32 ReadConsole 함수를 사용하여 사용자에게 이름, 성, 나이, 전화번호를 입력받는 프로그램을 작성하시오. Win32 WriteConsole 함수를 사용하여 입력한 정보를 레이블과 보기 좋은 형식으로 다시 출력하시오. Irvine32 라이브러리의 프로시저는 사용하지 마시오.

**답:**

```asm
.386
.model flat, stdcall
.stack 4096
option casemap:none
includelib kernel32.lib

NULL                 EQU 0
STD_INPUT_HANDLE     EQU -10
STD_OUTPUT_HANDLE    EQU -11
INVALID_HANDLE_VALUE EQU -1

GetStdHandle PROTO, :DWORD
ReadConsoleA PROTO, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
WriteConsoleA PROTO, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
ExitProcess PROTO, :DWORD

InitConsole PROTO
PrintSpan PROTO, pText:DWORD, nBytes:DWORD
PrintZ PROTO, pText:DWORD
ReadLine PROTO, pBuffer:DWORD, maxChars:DWORD

.data
hIn  DWORD ?
hOut DWORD ?
crlf BYTE 13,10,0
firstName BYTE 61 DUP(0)
lastName  BYTE 61 DUP(0)
age       BYTE 11 DUP(0)
phone     BYTE 41 DUP(0)
pFirst    BYTE "First name: ",0
pLast     BYTE "Last name : ",0
pAge      BYTE "Age       : ",0
pPhone    BYTE "Phone     : ",0
heading   BYTE 13,10,"+----------------------------------------+",13,10
          BYTE "|          PERSONAL INFORMATION          |",13,10
          BYTE "+----------------------------------------+",13,10,0
ending    BYTE "+----------------------------------------+",13,10,0
errMsg    BYTE "Console input failed.",13,10,0

.code
InitConsole PROC
    INVOKE GetStdHandle, STD_INPUT_HANDLE
    mov hIn, eax
    INVOKE GetStdHandle, STD_OUTPUT_HANDLE
    mov hOut, eax
    ret
InitConsole ENDP

PrintSpan PROC USES esi ebx, pText:DWORD, nBytes:DWORD
    LOCAL written:DWORD
    mov esi, pText
    mov ebx, nBytes
psNext:
    test ebx, ebx
    jz psOK
    INVOKE WriteConsoleA, hOut, esi, ebx, ADDR written, NULL
    test eax, eax
    jz psError
    cmp written, 0
    je psError
    mov eax, written
    add esi, eax
    sub ebx, eax
    jmp psNext
psOK:
    mov eax, 1
    ret
psError:
    xor eax, eax
    ret
PrintSpan ENDP

PrintZ PROC USES esi, pText:DWORD
    mov esi, pText
    xor ecx, ecx
pzCount:
    cmp BYTE PTR [esi+ecx], 0
    je pzWrite
    inc ecx
    jmp pzCount
pzWrite:
    INVOKE PrintSpan, esi, ecx
    ret
PrintZ ENDP

ReadLine PROC USES ebx edi, pBuffer:DWORD, maxChars:DWORD
    LOCAL ch:BYTE, got:DWORD
    mov edi, pBuffer
    xor ebx, ebx
    mov BYTE PTR [edi], 0
rlNext:
    INVOKE ReadConsoleA, hIn, ADDR ch, 1, ADDR got, NULL
    test eax, eax
    jz rlError
    cmp got, 1
    jne rlError
    mov al, ch
    cmp al, 10
    je rlDone
    cmp al, 13
    je rlNext
    cmp ebx, maxChars
    jae rlNext
    mov [edi+ebx], al
    inc ebx
    jmp rlNext
rlDone:
    mov BYTE PTR [edi+ebx], 0
    mov eax, ebx
    clc
    ret
rlError:
    mov BYTE PTR [edi+ebx], 0
    mov eax, ebx
    stc
    ret
ReadLine ENDP

main PROC
    call InitConsole

    INVOKE PrintZ, ADDR pFirst
    INVOKE ReadLine, ADDR firstName, 60
    jc inputError
    INVOKE PrintZ, ADDR pLast
    INVOKE ReadLine, ADDR lastName, 60
    jc inputError
    INVOKE PrintZ, ADDR pAge
    INVOKE ReadLine, ADDR age, 10
    jc inputError
    INVOKE PrintZ, ADDR pPhone
    INVOKE ReadLine, ADDR phone, 40
    jc inputError

    INVOKE PrintZ, ADDR heading
    INVOKE PrintZ, ADDR pFirst
    INVOKE PrintZ, ADDR firstName
    INVOKE PrintZ, ADDR crlf
    INVOKE PrintZ, ADDR pLast
    INVOKE PrintZ, ADDR lastName
    INVOKE PrintZ, ADDR crlf
    INVOKE PrintZ, ADDR pAge
    INVOKE PrintZ, ADDR age
    INVOKE PrintZ, ADDR crlf
    INVOKE PrintZ, ADDR pPhone
    INVOKE PrintZ, ADDR phone
    INVOKE PrintZ, ADDR crlf
    INVOKE PrintZ, ADDR ending
    INVOKE ExitProcess, 0
inputError:
    INVOKE PrintZ, ADDR errMsg
    INVOKE ExitProcess, 1
main ENDP
END main
```

**풀이:**

1. `GetStdHandle`로 표준 입력 핸들과 표준 출력 핸들을 구한다.
2. 직접 작성한 `ReadLine`이 내부에서 `ReadConsoleA`를 호출하여 이름, 성, 나이, 전화번호를 각각 입력받는다. 줄바꿈은 제거하고 마지막에 널 바이트를 저장한다.
3. 이 프로그램의 문자열은 영문·숫자 등 단일 바이트 문자를 기준으로 처리한다.
4. 나이와 전화번호는 다시 출력할 정보이므로 문자열로 저장한다. 전화번호의 앞자리 0이나 하이픈도 그대로 유지된다.
5. 직접 작성한 `PrintZ`는 문자열 길이를 계산하고, `PrintSpan`은 `WriteConsoleA`를 호출하여 지정한 길이만큼 출력한다.
6. 구분선과 제목, 항목별 레이블을 사용하여 결과를 정리한다. Irvine32 라이브러리의 프로시저는 사용하지 않는다.

---

## 3. Clearing the Screen

Write your own version of the link library’s Clrscr procedure that clears the screen.

화면을 지우는 링크 라이브러리의 Clrscr 프로시저를 직접 구현하시오.

**답:**

```asm
.386
.model flat, stdcall
.stack 4096
option casemap:none
includelib kernel32.lib

NULL                 EQU 0
STD_INPUT_HANDLE     EQU -10
STD_OUTPUT_HANDLE    EQU -11
INVALID_HANDLE_VALUE EQU -1

COORD STRUCT
    X SWORD ?
    Y SWORD ?
COORD ENDS

SMALL_RECT STRUCT
    Left   SWORD ?
    Top    SWORD ?
    Right  SWORD ?
    Bottom SWORD ?
SMALL_RECT ENDS

CONSOLE_SCREEN_BUFFER_INFO STRUCT
    dwSize              COORD <>
    dwCursorPosition    COORD <>
    wAttributes         WORD ?
    srWindow            SMALL_RECT <>
    dwMaximumWindowSize COORD <>
CONSOLE_SCREEN_BUFFER_INFO ENDS

GetStdHandle PROTO, :DWORD
WriteConsoleA PROTO, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
GetConsoleScreenBufferInfo PROTO, :DWORD, :DWORD
FillConsoleOutputCharacterA PROTO, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
FillConsoleOutputAttribute PROTO, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
SetConsoleCursorPosition PROTO, :DWORD, :DWORD
Sleep PROTO, :DWORD
ExitProcess PROTO, :DWORD
Clrscr PROTO

.data
beforeMsg BYTE "This text will disappear after two seconds.",13,10
BEFORE_LEN EQU $ - beforeMsg
afterMsg  BYTE "The screen has been cleared.",13,10
AFTER_LEN EQU $ - afterMsg
hOut      DWORD ?
written   DWORD ?

.code
Clrscr PROC
    LOCAL handle:DWORD
    LOCAL info:CONSOLE_SCREEN_BUFFER_INFO
    LOCAL cells:DWORD, done:DWORD

    INVOKE GetStdHandle, STD_OUTPUT_HANDLE
    cmp eax, INVALID_HANDLE_VALUE
    je clearError
    test eax, eax
    jz clearError
    mov handle, eax

    INVOKE GetConsoleScreenBufferInfo, handle, ADDR info
    test eax, eax
    jz clearError

    movzx eax, info.dwSize.X
    movzx ecx, info.dwSize.Y
    imul eax, ecx
    mov cells, eax

    INVOKE FillConsoleOutputCharacterA, handle, ' ', cells, 0, ADDR done
    test eax, eax
    jz clearError
    movzx eax, info.wAttributes
    INVOKE FillConsoleOutputAttribute, handle, eax, cells, 0, ADDR done
    test eax, eax
    jz clearError
    INVOKE SetConsoleCursorPosition, handle, 0
    test eax, eax
    jz clearError
    mov eax, 1
    ret
clearError:
    xor eax, eax
    ret
Clrscr ENDP

main PROC
    INVOKE GetStdHandle, STD_OUTPUT_HANDLE
    mov hOut, eax
    INVOKE WriteConsoleA, hOut, ADDR beforeMsg, BEFORE_LEN, ADDR written, NULL
    INVOKE Sleep, 2000
    call Clrscr
    test eax, eax
    jz failed
    INVOKE WriteConsoleA, hOut, ADDR afterMsg, AFTER_LEN, ADDR written, NULL
    INVOKE ExitProcess, 0
failed:
    INVOKE ExitProcess, 1
main ENDP
END main
```

**풀이:**

1. `GetConsoleScreenBufferInfo`로 콘솔 화면 버퍼의 가로 크기, 세로 크기, 현재 색상 속성을 구한다.
2. 지울 셀의 개수는 화면 버퍼의 가로 크기와 세로 크기를 곱하여 계산한다.
3. `FillConsoleOutputCharacterA`로 `(0,0)`부터 전체 셀을 공백으로 채운다.
4. `FillConsoleOutputAttribute`로 전체 셀의 속성을 현재 콘솔 색상 속성으로 맞춘다.
5. `SetConsoleCursorPosition`으로 커서를 `(0,0)`에 놓는다. 좌표를 값으로 전달할 때 DWORD 값 0은 X와 Y가 모두 0인 COORD를 나타낸다.
6. 테스트 프로그램은 문장을 출력하고 2초 후 `Clrscr`를 호출한다. 프로시저는 성공하면 EAX에 1, 실패하면 0을 반환한다.

---

## 4. Random Screen Fill

Write a program that fills each screen cell with a random character in a random color. Extra: Assign a 50% probability that the color of any character will be red.

화면의 각 셀을 임의의 색상으로 표시한 임의의 문자로 채우는 프로그램을 작성하시오. 추가 과제: 각 문자의 색상이 빨간색일 확률을 50%로 지정하시오.

**답:**

```asm
.386
.model flat, stdcall
.stack 4096
option casemap:none
includelib kernel32.lib

NULL                 EQU 0
STD_INPUT_HANDLE     EQU -10
STD_OUTPUT_HANDLE    EQU -11
INVALID_HANDLE_VALUE EQU -1

COORD STRUCT
    X SWORD ?
    Y SWORD ?
COORD ENDS

SMALL_RECT STRUCT
    Left   SWORD ?
    Top    SWORD ?
    Right  SWORD ?
    Bottom SWORD ?
SMALL_RECT ENDS

CONSOLE_SCREEN_BUFFER_INFO STRUCT
    dwSize              COORD <>
    dwCursorPosition    COORD <>
    wAttributes         WORD ?
    srWindow            SMALL_RECT <>
    dwMaximumWindowSize COORD <>
CONSOLE_SCREEN_BUFFER_INFO ENDS

GetStdHandle PROTO, :DWORD
GetConsoleScreenBufferInfo PROTO, :DWORD, :DWORD
WriteConsoleOutputCharacterA PROTO, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
FillConsoleOutputAttribute PROTO, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
GetTickCount PROTO
ExitProcess PROTO, :DWORD
RandomBelow PROTO, upperBound:DWORD

EXTRA_RED EQU 1

.data
hOut      DWORD ?
info      CONSOLE_SCREEN_BUFFER_INFO <>
pos       COORD <0,0>
rngState  DWORD ?
done      DWORD ?
character BYTE ?
color     DWORD ?
nonRed    BYTE 1,2,3,5,6,7,8,9,10,11,13,14,15

.code
RandomBelow PROC, upperBound:DWORD
    mov eax, rngState
    imul eax, eax, 1664525
    add eax, 1013904223
    mov rngState, eax
    mul upperBound
    mov eax, edx
    ret
RandomBelow ENDP

main PROC
    INVOKE GetStdHandle, STD_OUTPUT_HANDLE
    mov hOut, eax
    INVOKE GetConsoleScreenBufferInfo, hOut, ADDR info
    test eax, eax
    jz failed
    INVOKE GetTickCount
    mov rngState, eax

    mov pos.Y, 0
rowLoop:
    mov pos.X, 0
cellLoop:
    INVOKE RandomBelow, 95
    add al, 32
    mov character, al

IF EXTRA_RED
    INVOKE RandomBelow, 2
    test eax, eax
    jnz otherColor
    mov color, 4
    jmp colorReady
otherColor:
    INVOKE RandomBelow, LENGTHOF nonRed
    movzx eax, nonRed[eax]
    mov color, eax
colorReady:
ELSE
    INVOKE RandomBelow, 15
    inc eax
    mov color, eax
ENDIF

    INVOKE WriteConsoleOutputCharacterA, hOut, ADDR character, 1, DWORD PTR pos, ADDR done
    test eax, eax
    jz failed
    INVOKE FillConsoleOutputAttribute, hOut, color, 1, DWORD PTR pos, ADDR done
    test eax, eax
    jz failed

    inc pos.X
    mov ax, pos.X
    cmp ax, info.dwSize.X
    jl cellLoop
    inc pos.Y
    mov ax, pos.Y
    cmp ax, info.dwSize.Y
    jl rowLoop
    INVOKE ExitProcess, 0
failed:
    INVOKE ExitProcess, 1
main ENDP
END main
```

**풀이:**

1. `GetConsoleScreenBufferInfo`로 화면 버퍼의 크기를 구하고, 행과 열의 중첩 반복문으로 모든 셀을 방문한다.
2. `RandomBelow`는 선형 합동 방식의 의사 난수 상태를 갱신하고 0부터 `upperBound-1`까지의 값을 반환한다. 시작 상태는 `GetTickCount`로 설정한다.
3. 문자는 32부터 126까지의 출력 가능한 단일 바이트 문자 중에서 선택한다.
4. `WriteConsoleOutputCharacterA`로 해당 셀에 문자를 쓰고, `FillConsoleOutputAttribute`로 그 셀의 전경색을 지정한다. 배경색은 검은색이다.
5. `EXTRA_RED EQU 1`이면 추가 과제 방식이다. 0과 1 중 하나를 생성하여 한 분기에서는 빨간색 4를 선택하고, 나머지 분기에서는 빨간색 계열인 4와 12를 제외한 색상 중 하나를 선택한다. 따라서 빨간색 선택 확률을 50%로 설정한다.
6. `EXTRA_RED`를 0으로 바꾸면 기본 과제로 동작하며, 검은 배경에서 보이도록 전경색 1부터 15까지를 무작위로 선택한다. 50%는 선택 확률이며, 실제 화면에서 빨간색 셀 수가 반드시 정확히 절반이라는 뜻은 아니다.

---

## 5. DrawBox

Draw a box on the screen using line-drawing characters from the character set listed on the inside back cover of the book. Hint: Use the WriteConsoleOutputCharacter function.

교재 뒤표지 안쪽에 있는 문자 집합의 선 그리기 문자를 사용하여 화면에 상자를 그리시오. 힌트: WriteConsoleOutputCharacter 함수를 사용하시오.

**답:**

```asm
.386
.model flat, stdcall
.stack 4096
option casemap:none
includelib kernel32.lib

NULL                 EQU 0
STD_INPUT_HANDLE     EQU -10
STD_OUTPUT_HANDLE    EQU -11
INVALID_HANDLE_VALUE EQU -1

COORD STRUCT
    X SWORD ?
    Y SWORD ?
COORD ENDS

SMALL_RECT STRUCT
    Left   SWORD ?
    Top    SWORD ?
    Right  SWORD ?
    Bottom SWORD ?
SMALL_RECT ENDS

CONSOLE_SCREEN_BUFFER_INFO STRUCT
    dwSize              COORD <>
    dwCursorPosition    COORD <>
    wAttributes         WORD ?
    srWindow            SMALL_RECT <>
    dwMaximumWindowSize COORD <>
CONSOLE_SCREEN_BUFFER_INFO ENDS

GetStdHandle PROTO, :DWORD
GetConsoleScreenBufferInfo PROTO, :DWORD, :DWORD
WriteConsoleOutputCharacterA PROTO, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
GetConsoleOutputCP PROTO
SetConsoleOutputCP PROTO, :DWORD
ExitProcess PROTO, :DWORD
DrawBox PROTO, x:DWORD, y:DWORD, boxWidth:DWORD, boxHeight:DWORD

.data
hOut     DWORD ?
oldCP    DWORD ?
result   DWORD ?
info     CONSOLE_SCREEN_BUFFER_INFO <>

.code
DrawBox PROC USES ebx, x:DWORD, y:DWORD, boxWidth:DWORD, boxHeight:DWORD
    LOCAL pos:COORD, done:DWORD
    LOCAL topLine[80]:BYTE, midLine[80]:BYTE, botLine[80]:BYTE

    cmp boxWidth, 2
    jb boxError
    cmp boxWidth, 80
    ja boxError
    cmp boxHeight, 2
    jb boxError

    mov eax, x
    add eax, boxWidth
    jc boxError
    movzx ecx, info.dwSize.X
    cmp eax, ecx
    ja boxError
    mov eax, y
    add eax, boxHeight
    jc boxError
    movzx ecx, info.dwSize.Y
    cmp eax, ecx
    ja boxError

    mov topLine[0], 0DAh
    mov midLine[0], 0B3h
    mov botLine[0], 0C0h
    mov ebx, 1
buildLine:
    mov eax, boxWidth
    dec eax
    cmp ebx, eax
    jae endLine
    mov topLine[ebx], 0C4h
    mov midLine[ebx], ' '
    mov botLine[ebx], 0C4h
    inc ebx
    jmp buildLine
endLine:
    mov topLine[ebx], 0BFh
    mov midLine[ebx], 0B3h
    mov botLine[ebx], 0D9h

    mov eax, x
    mov pos.X, ax
    mov eax, y
    mov pos.Y, ax
    INVOKE WriteConsoleOutputCharacterA, hOut, ADDR topLine, boxWidth, DWORD PTR pos, ADDR done
    test eax, eax
    jz boxError

    mov ebx, 1
drawMiddle:
    mov eax, boxHeight
    dec eax
    cmp ebx, eax
    jae drawBottom
    inc pos.Y
    INVOKE WriteConsoleOutputCharacterA, hOut, ADDR midLine, boxWidth, DWORD PTR pos, ADDR done
    test eax, eax
    jz boxError
    inc ebx
    jmp drawMiddle
drawBottom:
    inc pos.Y
    INVOKE WriteConsoleOutputCharacterA, hOut, ADDR botLine, boxWidth, DWORD PTR pos, ADDR done
    test eax, eax
    jz boxError
    mov eax, 1
    ret
boxError:
    xor eax, eax
    ret
DrawBox ENDP

main PROC
    INVOKE GetStdHandle, STD_OUTPUT_HANDLE
    mov hOut, eax
    INVOKE GetConsoleScreenBufferInfo, hOut, ADDR info
    test eax, eax
    jz failed
    INVOKE GetConsoleOutputCP
    mov oldCP, eax
    INVOKE SetConsoleOutputCP, 437
    test eax, eax
    jz failed

    movzx eax, info.srWindow.Left
    movzx ecx, info.srWindow.Top
    INVOKE DrawBox, eax, ecx, 20, 8
    mov result, eax
    INVOKE SetConsoleOutputCP, oldCP
    cmp result, 0
    je failed
    INVOKE ExitProcess, 0
failed:
    INVOKE ExitProcess, 1
main ENDP
END main
```

**풀이:**

1. `DrawBox`는 왼쪽 위 좌표, 너비, 높이를 스택 매개변수로 받는다. 예제는 현재 창의 왼쪽 위 위치에 너비 20, 높이 8인 상자를 그린다.
2. 코드 페이지 437의 선 그리기 문자를 사용한다. `DAh`, `BFh`, `C0h`, `D9h`는 네 모서리, `C4h`는 가로선, `B3h`는 세로선이다.
3. 위쪽 행은 왼쪽 위 모서리·가로선·오른쪽 위 모서리로 만들고, 중간 행은 세로선·공백·세로선으로 만든다. 아래쪽 행은 아래 모서리와 가로선으로 만든다.
4. `WriteConsoleOutputCharacterA`는 지정한 좌표부터 문자를 기록한다. COORD는 주소가 아니라 4바이트 값으로 전달하므로 `DWORD PTR pos`를 사용한다.
5. 너비는 2~80, 높이는 2 이상이어야 하며 상자가 화면 버퍼를 벗어나지 않는지 검사한다.
6. 출력 전에 콘솔 출력 코드 페이지를 437로 설정하고, 상자를 그린 후 원래 코드 페이지로 복원한다.

---

## 6. Student Records

Write a program that creates a new text file. Prompt the user for a student identification number, last name, first name, and date of birth. Write this information to the file. Input several more records in the same manner and close the file.

새 텍스트 파일을 생성하는 프로그램을 작성하시오. 사용자에게 학번, 성, 이름, 생년월일을 입력받고 이 정보를 파일에 기록하시오. 같은 방법으로 여러 레코드를 더 입력받은 뒤 파일을 닫으시오.

**답:**

```asm
.386
.model flat, stdcall
.stack 4096
option casemap:none
includelib kernel32.lib

NULL                 EQU 0
STD_INPUT_HANDLE     EQU -10
STD_OUTPUT_HANDLE    EQU -11
INVALID_HANDLE_VALUE EQU -1

GENERIC_WRITE         EQU 40000000h
CREATE_NEW            EQU 1
FILE_ATTRIBUTE_NORMAL EQU 80h

GetStdHandle PROTO, :DWORD
ReadConsoleA PROTO, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
WriteConsoleA PROTO, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
ExitProcess PROTO, :DWORD
CreateFileA PROTO, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
WriteFile PROTO, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
CloseHandle PROTO, :DWORD
InitConsole PROTO
PrintSpan PROTO, pText:DWORD, nBytes:DWORD
PrintZ PROTO, pText:DWORD
ReadLine PROTO, pBuffer:DWORD, maxChars:DWORD
WriteAll PROTO, fileHandle:DWORD, pData:DWORD, nBytes:DWORD
WriteField PROTO, pText:DWORD

.data
hIn  DWORD ?
hOut DWORD ?
crlf BYTE 13,10,0
hFile      DWORD ?
fileName   BYTE "students.txt",0
studentID  BYTE 31 DUP(0)
lastName   BYTE 61 DUP(0)
firstName  BYTE 61 DUP(0)
birthDate  BYTE 31 DUP(0)
tabChar    BYTE 9
lineEnd    BYTE 13,10
header     BYTE "Student ID",9,"Last name",9,"First name",9,"Date of birth",13,10
HEADER_LEN EQU $ - header
pID        BYTE "Student ID (empty to finish): ",0
pLast      BYTE "Last name: ",0
pFirst     BYTE "First name: ",0
pBirth     BYTE "Date of birth (YYYY-MM-DD): ",0
savedMsg   BYTE "Records saved to students.txt",13,10,0
createMsg  BYTE "Cannot create students.txt (it may already exist).",13,10,0
errorMsg   BYTE "Input or file write failed.",13,10,0

.code
InitConsole PROC
    INVOKE GetStdHandle, STD_INPUT_HANDLE
    mov hIn, eax
    INVOKE GetStdHandle, STD_OUTPUT_HANDLE
    mov hOut, eax
    ret
InitConsole ENDP

PrintSpan PROC USES esi ebx, pText:DWORD, nBytes:DWORD
    LOCAL written:DWORD
    mov esi, pText
    mov ebx, nBytes
psNext:
    test ebx, ebx
    jz psOK
    INVOKE WriteConsoleA, hOut, esi, ebx, ADDR written, NULL
    test eax, eax
    jz psError
    cmp written, 0
    je psError
    mov eax, written
    add esi, eax
    sub ebx, eax
    jmp psNext
psOK:
    mov eax, 1
    ret
psError:
    xor eax, eax
    ret
PrintSpan ENDP

PrintZ PROC USES esi, pText:DWORD
    mov esi, pText
    xor ecx, ecx
pzCount:
    cmp BYTE PTR [esi+ecx], 0
    je pzWrite
    inc ecx
    jmp pzCount
pzWrite:
    INVOKE PrintSpan, esi, ecx
    ret
PrintZ ENDP

ReadLine PROC USES ebx edi, pBuffer:DWORD, maxChars:DWORD
    LOCAL ch:BYTE, got:DWORD
    mov edi, pBuffer
    xor ebx, ebx
    mov BYTE PTR [edi], 0
rlNext:
    INVOKE ReadConsoleA, hIn, ADDR ch, 1, ADDR got, NULL
    test eax, eax
    jz rlError
    cmp got, 1
    jne rlError
    mov al, ch
    cmp al, 10
    je rlDone
    cmp al, 13
    je rlNext
    cmp ebx, maxChars
    jae rlNext
    mov [edi+ebx], al
    inc ebx
    jmp rlNext
rlDone:
    mov BYTE PTR [edi+ebx], 0
    mov eax, ebx
    clc
    ret
rlError:
    mov BYTE PTR [edi+ebx], 0
    mov eax, ebx
    stc
    ret
ReadLine ENDP

WriteAll PROC USES ebx esi, fileHandle:DWORD, pData:DWORD, nBytes:DWORD
    LOCAL written:DWORD
    mov ebx, nBytes
    mov esi, pData
waNext:
    test ebx, ebx
    jz waOK
    INVOKE WriteFile, fileHandle, esi, ebx, ADDR written, NULL
    test eax, eax
    jz waError
    cmp written, 0
    je waError
    mov eax, written
    add esi, eax
    sub ebx, eax
    jmp waNext
waOK:
    mov eax, 1
    ret
waError:
    xor eax, eax
    ret
WriteAll ENDP

WriteField PROC USES esi, pText:DWORD
    mov esi, pText
    xor ecx, ecx
wfCount:
    cmp BYTE PTR [esi+ecx], 0
    je wfWrite
    inc ecx
    jmp wfCount
wfWrite:
    INVOKE WriteAll, hFile, esi, ecx
    ret
WriteField ENDP

main PROC
    call InitConsole
    INVOKE CreateFileA, ADDR fileName, GENERIC_WRITE, 0, NULL, CREATE_NEW, FILE_ATTRIBUTE_NORMAL, NULL
    cmp eax, INVALID_HANDLE_VALUE
    je createError
    mov hFile, eax
    INVOKE WriteAll, hFile, ADDR header, HEADER_LEN
    test eax, eax
    jz fileError

recordLoop:
    INVOKE PrintZ, ADDR pID
    INVOKE ReadLine, ADDR studentID, 30
    jc fileError
    test eax, eax
    jz finish
    INVOKE PrintZ, ADDR pLast
    INVOKE ReadLine, ADDR lastName, 60
    jc fileError
    INVOKE PrintZ, ADDR pFirst
    INVOKE ReadLine, ADDR firstName, 60
    jc fileError
    INVOKE PrintZ, ADDR pBirth
    INVOKE ReadLine, ADDR birthDate, 30
    jc fileError

    INVOKE WriteField, ADDR studentID
    test eax, eax
    jz fileError
    INVOKE WriteAll, hFile, ADDR tabChar, 1
    test eax, eax
    jz fileError
    INVOKE WriteField, ADDR lastName
    test eax, eax
    jz fileError
    INVOKE WriteAll, hFile, ADDR tabChar, 1
    test eax, eax
    jz fileError
    INVOKE WriteField, ADDR firstName
    test eax, eax
    jz fileError
    INVOKE WriteAll, hFile, ADDR tabChar, 1
    test eax, eax
    jz fileError
    INVOKE WriteField, ADDR birthDate
    test eax, eax
    jz fileError
    INVOKE WriteAll, hFile, ADDR lineEnd, 2
    test eax, eax
    jz fileError
    jmp recordLoop

finish:
    INVOKE CloseHandle, hFile
    test eax, eax
    jz closeError
    INVOKE PrintZ, ADDR savedMsg
    INVOKE ExitProcess, 0
fileError:
    INVOKE CloseHandle, hFile
closeError:
    INVOKE PrintZ, ADDR errorMsg
    INVOKE ExitProcess, 1
createError:
    INVOKE PrintZ, ADDR createMsg
    INVOKE ExitProcess, 1
main ENDP
END main
```

**풀이:**

1. `CreateFileA`에 `CREATE_NEW`를 전달하여 새 텍스트 파일 `students.txt`를 만든다. 같은 이름의 파일이 이미 있으면 덮어쓰지 않고 오류 메시지를 출력한다.
2. 학번, 성, 이름, 생년월일을 문자열로 입력받는다. 영문·숫자 등 단일 바이트 입력을 기준으로 하며, 각 입력의 마지막에는 널 바이트를 저장한다.
3. 한 레코드의 필드 사이에는 탭을 쓰고 마지막에는 `13,10`을 써서 줄을 바꾼다. 따라서 각 학생의 정보는 텍스트 파일의 한 줄에 저장된다.
4. `WriteField`는 문자열의 널 바이트를 제외한 길이를 구하고, `WriteAll`은 `WriteFile`로 해당 바이트를 기록한다. 일부만 기록된 경우 남은 바이트를 계속 기록한다.
5. 학번을 입력하지 않고 Enter를 누르면 반복을 종료한다.
6. 입력이 끝나면 `CloseHandle`로 파일을 닫는다. 파일을 연 뒤 입력이나 기록에 실패한 경우에도 핸들을 닫고 종료한다.

---

## 7. Scrolling Text Window

Write a program that writes 50 lines of text to the console screen buffer. Number each line. Move the console window to the top of the buffer, and begin scrolling the text upward at a steady rate (two lines per second). Stop scrolling when the console window reaches the end of the buffer.

콘솔 화면 버퍼에 50줄의 텍스트를 쓰는 프로그램을 작성하시오. 각 줄에 번호를 붙이시오. 콘솔 창을 버퍼 맨 위로 이동한 뒤 초당 두 줄의 일정한 속도로 텍스트를 위로 스크롤하시오. 콘솔 창이 버퍼 끝에 도달하면 스크롤을 중지하시오.

**답:**

```asm
.386
.model flat, stdcall
.stack 4096
option casemap:none
includelib kernel32.lib

NULL                 EQU 0
STD_INPUT_HANDLE     EQU -10
STD_OUTPUT_HANDLE    EQU -11
INVALID_HANDLE_VALUE EQU -1

COORD STRUCT
    X SWORD ?
    Y SWORD ?
COORD ENDS

SMALL_RECT STRUCT
    Left   SWORD ?
    Top    SWORD ?
    Right  SWORD ?
    Bottom SWORD ?
SMALL_RECT ENDS

CONSOLE_SCREEN_BUFFER_INFO STRUCT
    dwSize              COORD <>
    dwCursorPosition    COORD <>
    wAttributes         WORD ?
    srWindow            SMALL_RECT <>
    dwMaximumWindowSize COORD <>
CONSOLE_SCREEN_BUFFER_INFO ENDS

GetStdHandle PROTO, :DWORD
GetConsoleScreenBufferInfo PROTO, :DWORD, :DWORD
SetConsoleCursorPosition PROTO, :DWORD, :DWORD
SetConsoleScreenBufferSize PROTO, :DWORD, :DWORD
SetConsoleWindowInfo PROTO, :DWORD, :DWORD, :DWORD
FillConsoleOutputCharacterA PROTO, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
WriteConsoleOutputCharacterA PROTO, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
Sleep PROTO, :DWORD
ExitProcess PROTO, :DWORD

.data
hOut         DWORD ?
info         CONSOLE_SCREEN_BUFFER_INFO <>
windowRect   SMALL_RECT <>
bufferSize   COORD <>
pos          COORD <0,0>
windowHeight DWORD ?
bufferHeight DWORD ?
maxTop       DWORD ?
lineNumber   DWORD ?
done         DWORD ?
lineText     BYTE "Line 00"

.code
main PROC
    INVOKE GetStdHandle, STD_OUTPUT_HANDLE
    mov hOut, eax
    INVOKE GetConsoleScreenBufferInfo, hOut, ADDR info
    test eax, eax
    jz failed

    movzx eax, info.srWindow.Bottom
    movzx ecx, info.srWindow.Top
    sub eax, ecx
    inc eax
    cmp eax, 50
    jb heightReady
    mov eax, 25
heightReady:
    mov windowHeight, eax
    dec eax
    mov windowRect.Bottom, ax
    mov windowRect.Top, 0
    mov windowRect.Left, 0

    movzx eax, info.srWindow.Right
    movzx ecx, info.srWindow.Left
    sub eax, ecx
    inc eax
    cmp eax, LENGTHOF lineText
    jb failed
    dec eax
    mov windowRect.Right, ax

    INVOKE SetConsoleCursorPosition, hOut, 0
    test eax, eax
    jz failed
    INVOKE SetConsoleWindowInfo, hOut, 1, ADDR windowRect
    test eax, eax
    jz failed

    mov ax, info.dwSize.X
    mov bufferSize.X, ax
    mov bufferSize.Y, 50
    mov bufferHeight, 50
    INVOKE SetConsoleScreenBufferSize, hOut, DWORD PTR bufferSize
    test eax, eax
    jz failed

    movzx eax, bufferSize.X
    imul eax, 50
    INVOKE FillConsoleOutputCharacterA, hOut, ' ', eax, 0, ADDR done
    test eax, eax
    jz failed

    mov lineNumber, 1
writeLoop:
    mov eax, lineNumber
    xor edx, edx
    mov ecx, 10
    div ecx
    add al, '0'
    add dl, '0'
    mov lineText[5], al
    mov lineText[6], dl

    mov eax, lineNumber
    dec eax
    mov pos.Y, ax
    INVOKE WriteConsoleOutputCharacterA, hOut, ADDR lineText, LENGTHOF lineText, DWORD PTR pos, ADDR done
    test eax, eax
    jz failed
    inc lineNumber
    cmp lineNumber, 50
    jbe writeLoop

    mov eax, bufferHeight
    sub eax, windowHeight
    mov maxTop, eax
scrollLoop:
    movzx eax, windowRect.Top
    cmp eax, maxTop
    jae finished
    INVOKE Sleep, 500
    inc windowRect.Top
    inc windowRect.Bottom
    INVOKE SetConsoleWindowInfo, hOut, 1, ADDR windowRect
    test eax, eax
    jz failed
    jmp scrollLoop

finished:
    INVOKE ExitProcess, 0
failed:
    INVOKE ExitProcess, 1
main ENDP
END main
```

**풀이:**

1. 화면 버퍼의 높이를 50줄로 설정하고, 각 행에 `Line 01`부터 `Line 50`까지 기록한다. 줄바꿈으로 버퍼가 자동 스크롤되지 않도록 좌표를 지정하여 출력한다.
2. 현재 창의 높이를 사용하되, 50줄 이상이면 25줄로 줄여 스크롤할 여유를 만든다. 창을 버퍼 맨 위로 옮긴 후 버퍼 높이를 변경하여 창이 버퍼 범위를 벗어나지 않게 한다.
3. `SetConsoleWindowInfo`는 `SMALL_RECT`로 지정한 콘솔 창의 위치와 크기를 설정한다. 절대 좌표를 사용하므로 두 번째 인수는 1이다.
4. `Sleep, 500`으로 0.5초씩 기다린 후 창의 `Top`과 `Bottom`을 각각 1 증가시킨다. 창이 아래로 이동하므로 보이는 텍스트는 위로 이동하며, 초당 두 줄의 간격으로 스크롤한다.
5. `Top`이 `버퍼 높이 - 창 높이`에 도달하면 창의 아래쪽이 버퍼 마지막 행에 닿으므로 반복을 끝낸다.
6. 이 코드는 전통적인 Windows Console Host에서 창과 버퍼 크기를 제어하는 방식이며, 실행 중에는 창 크기를 바꾸지 않는다.

---

## 8. Block Animation

Write a program that draws a small square on the screen using several blocks (ASCII code DBh) in color. Move the square around the screen in randomly generated directions. Use a fixed delay value of 50 milliseconds. Extra: Use a randomly generated delay value between 10 and 100 milliseconds.

여러 개의 블록 문자(ASCII 코드 DBh)를 사용하여 화면에 작은 색상 정사각형을 그리는 프로그램을 작성하시오. 무작위로 생성한 방향으로 정사각형을 이동시키시오. 지연 시간은 50밀리초로 고정하시오. 추가 과제: 10~100밀리초 범위에서 무작위로 생성한 지연 시간을 사용하시오.

**답:**

```asm
.386
.model flat, stdcall
.stack 4096
option casemap:none
includelib kernel32.lib

NULL                 EQU 0
STD_INPUT_HANDLE     EQU -10
STD_OUTPUT_HANDLE    EQU -11
INVALID_HANDLE_VALUE EQU -1

COORD STRUCT
    X SWORD ?
    Y SWORD ?
COORD ENDS

SMALL_RECT STRUCT
    Left   SWORD ?
    Top    SWORD ?
    Right  SWORD ?
    Bottom SWORD ?
SMALL_RECT ENDS

CONSOLE_SCREEN_BUFFER_INFO STRUCT
    dwSize              COORD <>
    dwCursorPosition    COORD <>
    wAttributes         WORD ?
    srWindow            SMALL_RECT <>
    dwMaximumWindowSize COORD <>
CONSOLE_SCREEN_BUFFER_INFO ENDS

GetStdHandle PROTO, :DWORD
GetConsoleScreenBufferInfo PROTO, :DWORD, :DWORD
WriteConsoleOutputCharacterA PROTO, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
FillConsoleOutputCharacterA PROTO, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
FillConsoleOutputAttribute PROTO, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
GetConsoleOutputCP PROTO
SetConsoleOutputCP PROTO, :DWORD
GetTickCount PROTO
Sleep PROTO, :DWORD
ExitProcess PROTO, :DWORD
RandomBelow PROTO, upperBound:DWORD
DrawSquare PROTO, erase:DWORD

RANDOM_DELAY EQU 0
FRAME_COUNT  EQU 300
SIDE         EQU 3

.data
hOut      DWORD ?
info      CONSOLE_SCREEN_BUFFER_INFO <>
oldCP     DWORD ?
rngState  DWORD ?
xPos      SDWORD ?
yPos      SDWORD ?
minX      SDWORD ?
maxX      SDWORD ?
minY      SDWORD ?
maxY      SDWORD ?
frames    DWORD ?
exitCode  DWORD 0
blockRow  BYTE SIDE DUP(0DBh)
deltaX    SDWORD -1,0,1,-1,1,-1,0,1
deltaY    SDWORD -1,-1,-1,0,0,1,1,1

.code
RandomBelow PROC, upperBound:DWORD
    mov eax, rngState
    imul eax, eax, 1664525
    add eax, 1013904223
    mov rngState, eax
    mul upperBound
    mov eax, edx
    ret
RandomBelow ENDP

DrawSquare PROC USES ebx, erase:DWORD
    LOCAL pos:COORD, done:DWORD, attr:DWORD
    mov eax, xPos
    mov pos.X, ax
    mov eax, yPos
    mov pos.Y, ax
    xor ebx, ebx
squareRow:
    cmp erase, 0
    jne eraseRow
    INVOKE WriteConsoleOutputCharacterA, hOut, ADDR blockRow, SIDE, DWORD PTR pos, ADDR done
    mov attr, 11
    jmp setColor
eraseRow:
    INVOKE FillConsoleOutputCharacterA, hOut, ' ', SIDE, DWORD PTR pos, ADDR done
    movzx ecx, info.wAttributes
    mov attr, ecx
setColor:
    test eax, eax
    jz squareError
    INVOKE FillConsoleOutputAttribute, hOut, attr, SIDE, DWORD PTR pos, ADDR done
    test eax, eax
    jz squareError
    inc pos.Y
    inc ebx
    cmp ebx, SIDE
    jb squareRow
    mov eax, 1
    ret
squareError:
    xor eax, eax
    ret
DrawSquare ENDP

main PROC
    INVOKE GetStdHandle, STD_OUTPUT_HANDLE
    mov hOut, eax
    INVOKE GetConsoleScreenBufferInfo, hOut, ADDR info
    test eax, eax
    jz earlyError

    movsx eax, info.srWindow.Left
    mov minX, eax
    mov xPos, eax
    movsx eax, info.srWindow.Top
    mov minY, eax
    mov yPos, eax
    movsx eax, info.srWindow.Right
    sub eax, SIDE-1
    mov maxX, eax
    cmp eax, minX
    jl earlyError
    movsx eax, info.srWindow.Bottom
    sub eax, SIDE-1
    mov maxY, eax
    cmp eax, minY
    jl earlyError

    INVOKE GetConsoleOutputCP
    mov oldCP, eax
    INVOKE SetConsoleOutputCP, 437
    test eax, eax
    jz earlyError
    INVOKE GetTickCount
    mov rngState, eax
    mov frames, FRAME_COUNT
    INVOKE DrawSquare, 0
    test eax, eax
    jz animationError

animate:
IF RANDOM_DELAY
    INVOKE RandomBelow, 91
    add eax, 10
    INVOKE Sleep, eax
ELSE
    INVOKE Sleep, 50
ENDIF
    INVOKE DrawSquare, 1
    test eax, eax
    jz animationError

    INVOKE RandomBelow, 8
    mov ecx, eax
    mov eax, xPos
    add eax, deltaX[ecx*4]
    cmp eax, minX
    jge checkRight
    mov eax, minX
checkRight:
    cmp eax, maxX
    jle saveX
    mov eax, maxX
saveX:
    mov xPos, eax
    mov eax, yPos
    add eax, deltaY[ecx*4]
    cmp eax, minY
    jge checkBottom
    mov eax, minY
checkBottom:
    cmp eax, maxY
    jle saveY
    mov eax, maxY
saveY:
    mov yPos, eax

    INVOKE DrawSquare, 0
    test eax, eax
    jz animationError
    dec frames
    jnz animate
    jmp restoreCP

animationError:
    mov exitCode, 1
restoreCP:
    INVOKE SetConsoleOutputCP, oldCP
    INVOKE ExitProcess, exitCode
earlyError:
    INVOKE ExitProcess, 1
main ENDP
END main
```

**풀이:**

1. 코드 페이지 437에서 `DBh`는 꽉 찬 블록 문자이다. 이 문자를 가로 3개, 세로 3줄 출력하여 작은 정사각형을 만들고 밝은 청록색 속성 11을 적용한다.
2. `deltaX`, `deltaY` 배열에는 위·아래·왼쪽·오른쪽과 네 대각선을 나타내는 이동량이 들어 있다. 0~7의 난수로 이동 방향을 선택한다.
3. 이전 위치를 공백으로 지우고 좌표를 변경한 뒤 새 위치에 정사각형을 그리는 과정을 반복한다.
4. 정사각형 전체가 현재 보이는 창 내부에 있도록 왼쪽 위 좌표의 최소값과 최대값을 계산하고 경계를 넘는 이동을 제한한다.
5. `RANDOM_DELAY EQU 0`이면 `Sleep, 50`으로 50밀리초 지연을 사용한다. 이를 1로 바꾸면 `RandomBelow, 91`의 결과에 10을 더하여 10~100밀리초 지연을 사용한다.
6. 예제는 `FRAME_COUNT`에 지정한 300회 이동 후 종료한다. 마지막에는 변경한 출력 코드 페이지를 원래 값으로 복원한다.

---

## 9. Last Access Date of a File

Write a procedure named LastAccessDate that fills a SYSTEMTIME structure with the date and time stamp information of a file. Pass the offset of a filename in EDX, and pass the offset of a SYSTEMTIME structure in ESI. If the function fails to find the file, set the Carry flag. When you implement this function, you will need to open the file, get its handle, pass the handle to GetFileTime, pass its output to FileTimeToSystemTime, and close the file. Write a test program that calls your procedure and prints out the date when a particular file was last accessed.

Sample:

```text
ch11_09.asm was last accessed on: 6/16/2005
```

파일의 날짜와 시간 정보를 SYSTEMTIME 구조체에 채우는 LastAccessDate 프로시저를 작성하시오. EDX에는 파일 이름의 오프셋을, ESI에는 SYSTEMTIME 구조체의 오프셋을 전달한다. 파일을 찾지 못하면 캐리 플래그를 설정한다. 파일을 열어 핸들을 구하고, 그 핸들을 GetFileTime에 전달한 뒤 결과를 FileTimeToSystemTime으로 변환하고 파일을 닫아야 한다. 이 프로시저를 호출하여 특정 파일의 마지막 접근 날짜를 출력하는 테스트 프로그램도 작성하시오.

**답:**

```asm
.386
.model flat, stdcall
.stack 4096
option casemap:none
includelib kernel32.lib

NULL                 EQU 0
STD_INPUT_HANDLE     EQU -10
STD_OUTPUT_HANDLE    EQU -11
INVALID_HANDLE_VALUE EQU -1

GENERIC_READ          EQU 80000000h
FILE_SHARE_READ       EQU 1
FILE_SHARE_WRITE      EQU 2
FILE_SHARE_DELETE     EQU 4
OPEN_EXISTING         EQU 3
FILE_ATTRIBUTE_NORMAL EQU 80h

FILETIME STRUCT
    dwLowDateTime  DWORD ?
    dwHighDateTime DWORD ?
FILETIME ENDS

SYSTEMTIME STRUCT
    wYear         WORD ?
    wMonth        WORD ?
    wDayOfWeek    WORD ?
    wDay          WORD ?
    wHour         WORD ?
    wMinute       WORD ?
    wSecond       WORD ?
    wMilliseconds WORD ?
SYSTEMTIME ENDS

GetStdHandle PROTO, :DWORD
ReadConsoleA PROTO, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
WriteConsoleA PROTO, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
ExitProcess PROTO, :DWORD
CreateFileA PROTO, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
GetFileTime PROTO, :DWORD, :DWORD, :DWORD, :DWORD
FileTimeToSystemTime PROTO, :DWORD, :DWORD
CloseHandle PROTO, :DWORD
InitConsole PROTO
PrintSpan PROTO, pText:DWORD, nBytes:DWORD
PrintZ PROTO, pText:DWORD
ReadLine PROTO, pBuffer:DWORD, maxChars:DWORD
PrintUInt PROTO, number:DWORD
LastAccessDate PROTO

.data
hIn  DWORD ?
hOut DWORD ?
crlf BYTE 13,10,0
fileName BYTE 260 DUP(0)
lastTime SYSTEMTIME <>
prompt   BYTE "File name: ",0
message  BYTE " was last accessed on: ",0
slash    BYTE "/",0
errMsg   BYTE "Cannot read the file's last access time.",13,10,0

.code
InitConsole PROC
    INVOKE GetStdHandle, STD_INPUT_HANDLE
    mov hIn, eax
    INVOKE GetStdHandle, STD_OUTPUT_HANDLE
    mov hOut, eax
    ret
InitConsole ENDP

PrintSpan PROC USES esi ebx, pText:DWORD, nBytes:DWORD
    LOCAL written:DWORD
    mov esi, pText
    mov ebx, nBytes
psNext:
    test ebx, ebx
    jz psOK
    INVOKE WriteConsoleA, hOut, esi, ebx, ADDR written, NULL
    test eax, eax
    jz psError
    cmp written, 0
    je psError
    mov eax, written
    add esi, eax
    sub ebx, eax
    jmp psNext
psOK:
    mov eax, 1
    ret
psError:
    xor eax, eax
    ret
PrintSpan ENDP

PrintZ PROC USES esi, pText:DWORD
    mov esi, pText
    xor ecx, ecx
pzCount:
    cmp BYTE PTR [esi+ecx], 0
    je pzWrite
    inc ecx
    jmp pzCount
pzWrite:
    INVOKE PrintSpan, esi, ecx
    ret
PrintZ ENDP

ReadLine PROC USES ebx edi, pBuffer:DWORD, maxChars:DWORD
    LOCAL ch:BYTE, got:DWORD
    mov edi, pBuffer
    xor ebx, ebx
    mov BYTE PTR [edi], 0
rlNext:
    INVOKE ReadConsoleA, hIn, ADDR ch, 1, ADDR got, NULL
    test eax, eax
    jz rlError
    cmp got, 1
    jne rlError
    mov al, ch
    cmp al, 10
    je rlDone
    cmp al, 13
    je rlNext
    cmp ebx, maxChars
    jae rlNext
    mov [edi+ebx], al
    inc ebx
    jmp rlNext
rlDone:
    mov BYTE PTR [edi+ebx], 0
    mov eax, ebx
    clc
    ret
rlError:
    mov BYTE PTR [edi+ebx], 0
    mov eax, ebx
    stc
    ret
ReadLine ENDP

PrintUInt PROC USES ebx esi, number:DWORD
    LOCAL digits[10]:BYTE
    lea esi, digits
    add esi, 10
    mov eax, number
    mov ebx, 10
puNext:
    xor edx, edx
    div ebx
    add dl, '0'
    dec esi
    mov [esi], dl
    test eax, eax
    jnz puNext
    lea eax, digits
    add eax, 10
    sub eax, esi
    INVOKE PrintSpan, esi, eax
    ret
PrintUInt ENDP

LastAccessDate PROC USES ebx edi edx esi
    LOCAL accessTime:FILETIME
    INVOKE CreateFileA, edx, GENERIC_READ, FILE_SHARE_READ OR FILE_SHARE_WRITE OR FILE_SHARE_DELETE, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
    cmp eax, INVALID_HANDLE_VALUE
    je accessError
    mov ebx, eax

    INVOKE GetFileTime, ebx, NULL, ADDR accessTime, NULL
    test eax, eax
    jz closeOnError
    INVOKE FileTimeToSystemTime, ADDR accessTime, esi
    mov edi, eax
    INVOKE CloseHandle, ebx
    test eax, eax
    jz accessError
    test edi, edi
    jz accessError
    mov eax, 1
    clc
    ret
closeOnError:
    INVOKE CloseHandle, ebx
accessError:
    xor eax, eax
    stc
    ret
LastAccessDate ENDP

main PROC
    call InitConsole
    INVOKE PrintZ, ADDR prompt
    INVOKE ReadLine, ADDR fileName, 259
    jc failed

    mov edx, OFFSET fileName
    mov esi, OFFSET lastTime
    call LastAccessDate
    jc failed

    INVOKE PrintZ, ADDR fileName
    INVOKE PrintZ, ADDR message
    movzx eax, lastTime.wMonth
    INVOKE PrintUInt, eax
    INVOKE PrintZ, ADDR slash
    movzx eax, lastTime.wDay
    INVOKE PrintUInt, eax
    INVOKE PrintZ, ADDR slash
    movzx eax, lastTime.wYear
    INVOKE PrintUInt, eax
    INVOKE PrintZ, ADDR crlf
    INVOKE ExitProcess, 0
failed:
    INVOKE PrintZ, ADDR errMsg
    INVOKE ExitProcess, 1
main ENDP
END main
```

**풀이:**

1. 호출 전에 EDX에 파일 이름의 주소, ESI에 결과를 받을 `SYSTEMTIME` 구조체의 주소를 넣는다.
2. `CreateFileA`에 `OPEN_EXISTING`을 전달하여 기존 파일을 열고 핸들을 얻는다. 파일을 열지 못하면 CF를 설정한다.
3. `GetFileTime`의 세 번째 인수에 `FILETIME` 구조체의 주소를 전달하여 마지막 접근 시각을 받는다.
4. `FileTimeToSystemTime`으로 마지막 접근 시각을 변환하여 ESI가 가리키는 구조체에 저장한다. 이 변환 결과는 UTC 기준이다.
5. 파일을 연 경우에는 성공·실패 여부와 관계없이 `CloseHandle`을 호출한다. 성공 시 CF=0, 파일 열기·시각 조회·변환 등에 실패하면 CF=1을 반환한다.
6. 테스트 프로그램은 `월/일/연도` 형식으로 날짜를 출력한다. 파일 시스템에 저장된 마지막 접근 시각을 조회하는 것이므로 파일 시스템의 갱신 정책에 따라 실제 최근 접근 시각과 차이가 있을 수 있다.

---

## 10. Reading a Large File

Modify the ReadFile.asm program in Section 11.1.8 so that it can read files larger than its input buffer. Reduce the buffer size to 1024 bytes. Use a loop to continue reading and displaying the file until it can read no more data. If you plan to display the buffer with WriteString, remember to insert a null byte at the end of the buffer data.

11.1.8절의 ReadFile.asm을 수정하여 입력 버퍼보다 큰 파일을 읽을 수 있게 하시오. 버퍼 크기는 1024바이트로 줄이시오. 더 읽을 데이터가 없을 때까지 반복문으로 파일을 계속 읽고 출력하시오. WriteString으로 버퍼를 출력한다면 읽은 데이터 끝에 널 바이트를 삽입해야 한다.

**답:**

```asm
.386
.model flat, stdcall
.stack 4096
option casemap:none
includelib kernel32.lib

NULL                 EQU 0
STD_INPUT_HANDLE     EQU -10
STD_OUTPUT_HANDLE    EQU -11
INVALID_HANDLE_VALUE EQU -1

GENERIC_READ          EQU 80000000h
FILE_SHARE_READ       EQU 1
OPEN_EXISTING         EQU 3
FILE_ATTRIBUTE_NORMAL EQU 80h
BUFFER_SIZE           EQU 1024

GetStdHandle PROTO, :DWORD
ReadConsoleA PROTO, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
WriteConsoleA PROTO, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
ExitProcess PROTO, :DWORD
CreateFileA PROTO, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
ReadFile PROTO, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
CloseHandle PROTO, :DWORD
InitConsole PROTO
PrintSpan PROTO, pText:DWORD, nBytes:DWORD
PrintZ PROTO, pText:DWORD
ReadLine PROTO, pBuffer:DWORD, maxChars:DWORD

.data
hIn  DWORD ?
hOut DWORD ?
crlf BYTE 13,10,0
fileName BYTE 260 DUP(0)
buffer   BYTE BUFFER_SIZE DUP(?)
hFile    DWORD ?
bytesRead DWORD ?
prompt   BYTE "Text file name: ",0
openMsg  BYTE "Cannot open the file.",13,10,0
errorMsg BYTE 13,10,"File read or console output failed.",13,10,0

.code
InitConsole PROC
    INVOKE GetStdHandle, STD_INPUT_HANDLE
    mov hIn, eax
    INVOKE GetStdHandle, STD_OUTPUT_HANDLE
    mov hOut, eax
    ret
InitConsole ENDP

PrintSpan PROC USES esi ebx, pText:DWORD, nBytes:DWORD
    LOCAL written:DWORD
    mov esi, pText
    mov ebx, nBytes
psNext:
    test ebx, ebx
    jz psOK
    INVOKE WriteConsoleA, hOut, esi, ebx, ADDR written, NULL
    test eax, eax
    jz psError
    cmp written, 0
    je psError
    mov eax, written
    add esi, eax
    sub ebx, eax
    jmp psNext
psOK:
    mov eax, 1
    ret
psError:
    xor eax, eax
    ret
PrintSpan ENDP

PrintZ PROC USES esi, pText:DWORD
    mov esi, pText
    xor ecx, ecx
pzCount:
    cmp BYTE PTR [esi+ecx], 0
    je pzWrite
    inc ecx
    jmp pzCount
pzWrite:
    INVOKE PrintSpan, esi, ecx
    ret
PrintZ ENDP

ReadLine PROC USES ebx edi, pBuffer:DWORD, maxChars:DWORD
    LOCAL ch:BYTE, got:DWORD
    mov edi, pBuffer
    xor ebx, ebx
    mov BYTE PTR [edi], 0
rlNext:
    INVOKE ReadConsoleA, hIn, ADDR ch, 1, ADDR got, NULL
    test eax, eax
    jz rlError
    cmp got, 1
    jne rlError
    mov al, ch
    cmp al, 10
    je rlDone
    cmp al, 13
    je rlNext
    cmp ebx, maxChars
    jae rlNext
    mov [edi+ebx], al
    inc ebx
    jmp rlNext
rlDone:
    mov BYTE PTR [edi+ebx], 0
    mov eax, ebx
    clc
    ret
rlError:
    mov BYTE PTR [edi+ebx], 0
    mov eax, ebx
    stc
    ret
ReadLine ENDP

main PROC
    call InitConsole
    INVOKE PrintZ, ADDR prompt
    INVOKE ReadLine, ADDR fileName, 259
    jc openError
    INVOKE CreateFileA, ADDR fileName, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
    cmp eax, INVALID_HANDLE_VALUE
    je openError
    mov hFile, eax

readLoop:
    INVOKE ReadFile, hFile, ADDR buffer, BUFFER_SIZE, ADDR bytesRead, NULL
    test eax, eax
    jz fileError
    cmp bytesRead, 0
    je finished

    INVOKE PrintSpan, ADDR buffer, bytesRead
    test eax, eax
    jz fileError
    jmp readLoop

finished:
    INVOKE CloseHandle, hFile
    test eax, eax
    jz reportError
    INVOKE ExitProcess, 0
fileError:
    INVOKE CloseHandle, hFile
reportError:
    INVOKE PrintZ, ADDR errorMsg
    INVOKE ExitProcess, 1
openError:
    INVOKE PrintZ, ADDR openMsg
    INVOKE ExitProcess, 1
main ENDP
END main
```

**풀이:**

1. 파일 데이터를 저장하는 `buffer`의 크기를 정확히 1024바이트로 선언한다.
2. `ReadFile`을 반복 호출하고, 매번 실제로 읽은 바이트 수를 `bytesRead`에 받는다.
3. API 호출이 성공했더라도 `bytesRead`가 0이면 파일 끝에 도달한 것이므로 반복을 종료한다. 1024바이트보다 적게 읽었다는 이유만으로 즉시 종료하지 않고 다음 읽기 결과를 확인한다.
4. `PrintSpan`에 실제로 읽은 길이를 전달하여 `WriteConsoleA`로 출력하므로 마지막 블록의 남은 버퍼 영역은 출력하지 않는다.
5. `WriteString`을 사용하지 않으므로 데이터 끝에 널 바이트를 삽입할 필요가 없다. 따라서 1024바이트 버퍼를 모두 데이터 저장에 사용할 수 있다.
6. 파일 크기와 관계없이 같은 버퍼를 재사용하며, 종료 전에는 파일 핸들을 닫는다. 출력 대상은 콘솔이고, 파일 내용은 콘솔의 단일 바이트 문자 표현을 기준으로 한다.

---

## 11. Linked List

Advanced: Implement a singly linked list, using the dynamic memory allocation functions presented in this chapter. Each link should be a structure named Node (see Chapter 10) containing an integer value and a pointer to the next link in the list. Using a loop, prompt the user for as many integers as they want to enter. As each integer is entered, allocate a Node object, insert the integer in the Node, and append the Node to the linked list. When a value of 0 is entered, stop the loop. Finally, display the entire list from beginning to end. This project should only be attempted if you have previously created linked lists in a high-level language.

고급 과제: 이 장에서 소개한 동적 메모리 할당 함수를 사용하여 단일 연결 리스트를 구현하시오. 각 노드는 정수 값과 다음 노드의 포인터를 포함하는 Node 구조체로 정의한다(10장 참고). 사용자가 원하는 만큼 정수를 입력할 수 있도록 반복문을 사용하시오. 정수를 입력할 때마다 Node 객체를 할당하고 값을 저장한 뒤 리스트 끝에 연결하시오. 0을 입력하면 반복을 종료한다. 마지막으로 리스트 전체를 처음부터 끝까지 출력하시오. 이 과제는 고급 언어로 연결 리스트를 작성한 경험이 있는 경우에만 시도하시오.

**답:**

```asm
.386
.model flat, stdcall
.stack 4096
option casemap:none
includelib kernel32.lib

NULL                 EQU 0
STD_INPUT_HANDLE     EQU -10
STD_OUTPUT_HANDLE    EQU -11
INVALID_HANDLE_VALUE EQU -1

Node STRUCT
    intValue SDWORD ?
    nextPtr  DWORD ?
Node ENDS

GetStdHandle PROTO, :DWORD
ReadConsoleA PROTO, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
WriteConsoleA PROTO, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
ExitProcess PROTO, :DWORD
GetProcessHeap PROTO
HeapAlloc PROTO, :DWORD, :DWORD, :DWORD
HeapFree PROTO, :DWORD, :DWORD, :DWORD
InitConsole PROTO
PrintSpan PROTO, pText:DWORD, nBytes:DWORD
PrintZ PROTO, pText:DWORD
ReadLine PROTO, pBuffer:DWORD, maxChars:DWORD
PrintUInt PROTO, number:DWORD
PrintInt PROTO, number:SDWORD
ParseInt32 PROTO, pText:DWORD

.data
hIn  DWORD ?
hOut DWORD ?
crlf BYTE 13,10,0
hHeap     DWORD ?
head      DWORD 0
tail      DWORD 0
number    SDWORD ?
exitCode  DWORD 0
inputText BYTE 65 DUP(0)
prompt    BYTE "Enter an integer (0 to finish): ",0
heading   BYTE 13,10,"List: ",0
arrow     BYTE " -> ",0
nullText  BYTE "NULL",13,10,0
minusSign BYTE "-",0
invalid   BYTE "Enter a signed 32-bit integer.",13,10,0
heapError BYTE "Cannot obtain or allocate heap memory.",13,10,0
inputErrorMsg BYTE "Console input failed.",13,10,0

.code
InitConsole PROC
    INVOKE GetStdHandle, STD_INPUT_HANDLE
    mov hIn, eax
    INVOKE GetStdHandle, STD_OUTPUT_HANDLE
    mov hOut, eax
    ret
InitConsole ENDP

PrintSpan PROC USES esi ebx, pText:DWORD, nBytes:DWORD
    LOCAL written:DWORD
    mov esi, pText
    mov ebx, nBytes
psNext:
    test ebx, ebx
    jz psOK
    INVOKE WriteConsoleA, hOut, esi, ebx, ADDR written, NULL
    test eax, eax
    jz psError
    cmp written, 0
    je psError
    mov eax, written
    add esi, eax
    sub ebx, eax
    jmp psNext
psOK:
    mov eax, 1
    ret
psError:
    xor eax, eax
    ret
PrintSpan ENDP

PrintZ PROC USES esi, pText:DWORD
    mov esi, pText
    xor ecx, ecx
pzCount:
    cmp BYTE PTR [esi+ecx], 0
    je pzWrite
    inc ecx
    jmp pzCount
pzWrite:
    INVOKE PrintSpan, esi, ecx
    ret
PrintZ ENDP

ReadLine PROC USES ebx edi, pBuffer:DWORD, maxChars:DWORD
    LOCAL ch:BYTE, got:DWORD
    mov edi, pBuffer
    xor ebx, ebx
    mov BYTE PTR [edi], 0
rlNext:
    INVOKE ReadConsoleA, hIn, ADDR ch, 1, ADDR got, NULL
    test eax, eax
    jz rlError
    cmp got, 1
    jne rlError
    mov al, ch
    cmp al, 10
    je rlDone
    cmp al, 13
    je rlNext
    cmp ebx, maxChars
    jae rlNext
    mov [edi+ebx], al
    inc ebx
    jmp rlNext
rlDone:
    mov BYTE PTR [edi+ebx], 0
    mov eax, ebx
    clc
    ret
rlError:
    mov BYTE PTR [edi+ebx], 0
    mov eax, ebx
    stc
    ret
ReadLine ENDP

PrintUInt PROC USES ebx esi, number:DWORD
    LOCAL digits[10]:BYTE
    lea esi, digits
    add esi, 10
    mov eax, number
    mov ebx, 10
puNext:
    xor edx, edx
    div ebx
    add dl, '0'
    dec esi
    mov [esi], dl
    test eax, eax
    jnz puNext
    lea eax, digits
    add eax, 10
    sub eax, esi
    INVOKE PrintSpan, esi, eax
    ret
PrintUInt ENDP

ParseInt32 PROC USES ebx esi edi, pText:DWORD
    mov esi, pText
    xor edi, edi
    xor ebx, ebx
    xor ecx, ecx
    mov al, [esi]
    cmp al, '-'
    jne checkPlus
    mov edi, 1
    inc esi
    jmp parseDigit
checkPlus:
    cmp al, '+'
    jne parseDigit
    inc esi
parseDigit:
    movzx eax, BYTE PTR [esi]
    test eax, eax
    jz parseDone
    cmp eax, '0'
    jb parseError
    cmp eax, '9'
    ja parseError
    sub eax, '0'
    cmp ebx, 214748364
    ja parseError
    jb accumulate
    cmp edi, 0
    jne checkNegativeLimit
    cmp eax, 7
    ja parseError
    jmp accumulate
checkNegativeLimit:
    cmp eax, 8
    ja parseError
accumulate:
    imul ebx, ebx, 10
    add ebx, eax
    inc ecx
    inc esi
    jmp parseDigit
parseDone:
    test ecx, ecx
    jz parseError
    mov eax, ebx
    test edi, edi
    jz parseOK
    neg eax
parseOK:
    clc
    ret
parseError:
    xor eax, eax
    stc
    ret
ParseInt32 ENDP

PrintInt PROC, number:SDWORD
    mov eax, number
    test eax, eax
    jns printMagnitude
    INVOKE PrintZ, ADDR minusSign
    mov eax, number
    neg eax
printMagnitude:
    INVOKE PrintUInt, eax
    ret
PrintInt ENDP

main PROC
    call InitConsole
    INVOKE GetProcessHeap
    test eax, eax
    jz noHeap
    mov hHeap, eax

inputLoop:
    INVOKE PrintZ, ADDR prompt
    INVOKE ReadLine, ADDR inputText, 64
    jc inputFailed
    INVOKE ParseInt32, ADDR inputText
    jc badInteger
    test eax, eax
    jz displayList
    mov number, eax

    INVOKE HeapAlloc, hHeap, 0, SIZEOF Node
    test eax, eax
    jz allocationFailed
    mov ecx, number
    mov [eax].Node.intValue, ecx
    mov [eax].Node.nextPtr, 0

    cmp head, 0
    je firstNode
    mov edx, tail
    mov [edx].Node.nextPtr, eax
    mov tail, eax
    jmp inputLoop
firstNode:
    mov head, eax
    mov tail, eax
    jmp inputLoop

badInteger:
    INVOKE PrintZ, ADDR invalid
    jmp inputLoop
inputFailed:
    INVOKE PrintZ, ADDR inputErrorMsg
    mov exitCode, 1
    jmp displayList
allocationFailed:
    INVOKE PrintZ, ADDR heapError
    mov exitCode, 1

displayList:
    INVOKE PrintZ, ADDR heading
    mov esi, head
displayNext:
    test esi, esi
    jz endDisplay
    INVOKE PrintInt, [esi].Node.intValue
    INVOKE PrintZ, ADDR arrow
    mov esi, [esi].Node.nextPtr
    jmp displayNext
endDisplay:
    INVOKE PrintZ, ADDR nullText

    mov esi, head
freeNext:
    test esi, esi
    jz finished
    mov edi, [esi].Node.nextPtr
    INVOKE HeapFree, hHeap, 0, esi
    test eax, eax
    jnz freed
    mov exitCode, 1
freed:
    mov esi, edi
    jmp freeNext
finished:
    mov head, 0
    mov tail, 0
    INVOKE ExitProcess, exitCode
noHeap:
    INVOKE PrintZ, ADDR heapError
    INVOKE ExitProcess, 1
main ENDP
END main
```

**풀이:**

1. `Node`는 부호 있는 32비트 정수 `intValue`와 다음 노드의 주소 `nextPtr`로 구성된다. `head`는 첫 노드, `tail`은 마지막 노드의 주소를 보관한다.
2. `ReadLine`으로 입력한 문자열을 `ParseInt32`로 변환한다. 선택적인 `+` 또는 `-`와 숫자를 허용하고, 부호 있는 32비트 정수 범위를 벗어나거나 숫자가 아닌 문자가 있으면 다시 입력받는다.
3. 입력값이 0이면 종료 표식으로 처리하고 노드를 생성하지 않는다.
4. `HeapAlloc`에 프로세스 힙 핸들과 `SIZEOF Node`를 전달하여 새 노드의 메모리를 할당한다. 할당에 실패하면 이미 만든 리스트를 출력한 뒤 해제한다.
5. 새 노드에 정수를 저장하고 `nextPtr`를 0으로 설정한다. 빈 리스트라면 `head`와 `tail`이 모두 새 노드를 가리키게 하고, 그렇지 않으면 기존 마지막 노드의 `nextPtr`에 새 주소를 넣은 뒤 `tail`을 갱신한다.
6. `head`에서 시작하여 `nextPtr`를 따라가면서 모든 값을 순서대로 출력한다.
7. 출력 후 같은 순서로 순회하며 `HeapFree`로 각 노드를 해제한다. 해제한 메모리를 다시 읽지 않도록 다음 노드의 주소를 먼저 EDI에 보관한다.
