# Programming Exercises 답안

---

## 1. mReadkey Macro

Create a macro that waits for a keystroke and returns the key that was pressed. The macro should include parameters for the ASCII code and keyboard scan code. _Hint:_ Call ReadChar from the book’s link library. Write a program that tests your macro. For example, the following code waits for a key; when it returns, the two arguments contain the ASCII code and scan code:

```asm
.data
ascii BYTE ?
scan BYTE ?
.code
mReadkey ascii, scan
```

키 입력을 기다렸다가 눌린 키를 반환하는 매크로를 작성하시오. 매크로에는 ASCII 코드와 키보드 스캔 코드를 저장할 매개변수가 포함되어야 한다. 힌트: 교재의 링크 라이브러리에 있는 ReadChar를 호출하시오. 매크로를 테스트하는 프로그램도 작성하시오. 예시 코드는 키 입력을 기다린 후 두 인수에 ASCII 코드와 스캔 코드를 저장한다.

**답:**

```asm
mReadkey MACRO asciiArg, scanArg
    call ReadChar
    mov  asciiArg, al       ; ASCII 코드
    mov  scanArg, ah        ; 키보드 스캔 코드
ENDM
```

테스트 프로그램:

```asm
INCLUDE Irvine32.inc

mReadkey MACRO asciiArg, scanArg
    call ReadChar
    mov  asciiArg, al
    mov  scanArg, ah
ENDM

.data
ascii BYTE ?
scan  BYTE ?

.code
main PROC
    mReadkey ascii, scan

    movzx eax, ascii
    call WriteHex
    call Crlf

    movzx eax, scan
    call WriteHex
    call Crlf

    exit
main ENDP
END main
```

**풀이:**

1. `ReadChar`는 키 입력을 기다린 다음 입력한 문자의 값을 `AL`에 반환한다.
2. 확장 키를 입력한 경우에는 `AL`이 0이고, 키보드 스캔 코드가 `AH`에 반환된다.
3. 따라서 ASCII 코드 매개변수에는 `AL`을, 스캔 코드 매개변수에는 `AH`를 저장하면 된다.[^1]
4. 테스트 프로그램은 매크로를 호출한 뒤 두 BYTE 변수에 저장된 값을 `WriteHex`로 출력한다.

---

## 2. mWritestringAttr Macro

(Requires reading ahead to Section 11.1.11.) Create a macro that writes a null-terminated string to the console with a given text color. The macro parameters should include the string name and the color. _Hint:_ Call SetTextColor from the book’s link library. Write a program that tests your macro with several strings in different colors. Sample call:

```asm
.data
myString db "Here is my string",0
.code
mWritestring myString, white
```

(11.1.11절을 미리 읽어야 한다.) 지정한 글자색으로 널 종료 문자열을 콘솔에 출력하는 매크로를 작성하시오. 매크로 매개변수에는 문자열 이름과 색상이 포함되어야 한다. 힌트: 교재의 링크 라이브러리에 있는 SetTextColor를 호출하시오. 서로 다른 색상의 여러 문자열을 사용하여 매크로를 테스트하는 프로그램도 작성하시오. 예시 호출은 다음과 같다.

**답:**

```asm
mWritestringAttr MACRO stringName, textColor
    mov  eax, textColor
    call SetTextColor
    mov  edx, OFFSET stringName
    call WriteString
ENDM
```

테스트 프로그램:

```asm
INCLUDE Irvine32.inc

mWritestringAttr MACRO stringName, textColor
    mov  eax, textColor
    call SetTextColor
    mov  edx, OFFSET stringName
    call WriteString
ENDM

.data
str1 BYTE "Red text",0
str2 BYTE "Green text",0
str3 BYTE "White text",0

.code
main PROC
    mWritestringAttr str1, red
    call Crlf

    mWritestringAttr str2, lightGreen
    call Crlf

    mWritestringAttr str3, white
    call Crlf

    mov eax, white
    call SetTextColor

    exit
main ENDP
END main
```

**풀이:**

1. `SetTextColor`는 EAX에 전달된 색상 속성을 사용하여 콘솔의 글자색을 변경한다.
2. `WriteString`은 EDX가 가리키는 널 종료 문자열을 출력한다.
3. 따라서 매크로에서 먼저 색상 값을 EAX에 넣고 `SetTextColor`를 호출한다.
4. 문자열의 주소를 EDX에 넣은 다음 `WriteString`을 호출하면 지정한 색상으로 문자열이 출력된다.
5. 문제의 예시 호출은 `mWritestring`이라고 적혀 있지만, 문제에서 지정한 매크로 이름은 `mWritestringAttr`이므로 테스트 코드에서는 `mWritestringAttr`로 호출하였다.

---

## 3. mMove32 Macro

Write a macro named mMove32 that receives two 32-bit memory operands. The macro should move the source operand to the destination operand. Write a program that tests your macro.

두 개의 32비트 메모리 피연산자를 전달받는 mMove32라는 매크로를 작성하시오. 매크로는 원본 피연산자의 값을 목적지 피연산자로 이동해야 한다. 매크로를 테스트하는 프로그램도 작성하시오.

**답:**

```asm
mMove32 MACRO destination, source
    push eax
    mov  eax, source
    mov  destination, eax
    pop  eax
ENDM
```

테스트 프로그램:

```asm
INCLUDE Irvine32.inc

mMove32 MACRO destination, source
    push eax
    mov  eax, source
    mov  destination, eax
    pop  eax
ENDM

.data
sourceVal DWORD 12345678h
destVal   DWORD ?

.code
main PROC
    mMove32 destVal, sourceVal

    mov eax, destVal
    call WriteHex
    call Crlf

    exit
main ENDP
END main
```

**풀이:**

1. x86의 `MOV` 명령어는 메모리에서 메모리로 값을 직접 이동할 수 없다.
2. 따라서 임시 레지스터인 EAX를 이용하여 원본 메모리 값을 먼저 읽는다.
3. EAX의 값을 목적지 메모리에 저장하면 메모리 간 이동을 구현할 수 있다.
4. 문제에서 EAX 보존을 요구하지는 않았지만, 매크로 실행 전후의 EAX 값을 유지하도록 `PUSH`와 `POP`을 사용하였다.

---

## 4. mMult32 Macro

Create a macro named mMult32 that multiplies two 32-bit memory operands and produces a 32-bit product. Write a program that tests your macro.

두 개의 32비트 메모리 피연산자를 곱하여 32비트 결과를 만드는 mMult32라는 매크로를 작성하시오. 매크로를 테스트하는 프로그램도 작성하시오.

**답:**

결과를 저장할 목적지까지 포함하여 `mMult32 destination, operand1, operand2` 형식으로 작성한다.

```asm
mMult32 MACRO destination, operand1, operand2
    push eax
    push edx

    mov  eax, operand1
    mul  DWORD PTR operand2
    mov  destination, eax

    pop  edx
    pop  eax
ENDM
```

테스트 프로그램:

```asm
INCLUDE Irvine32.inc

mMult32 MACRO destination, operand1, operand2
    push eax
    push edx
    mov  eax, operand1
    mul  DWORD PTR operand2
    mov  destination, eax
    pop  edx
    pop  eax
ENDM

.data
value1  DWORD 1200
value2  DWORD 30
product DWORD ?

.code
main PROC
    mMult32 product, value1, value2

    mov eax, product
    call WriteDec
    call Crlf

    exit
main ENDP
END main
```

**풀이:**

1. `MUL` 명령어는 EAX와 지정한 32비트 피연산자를 곱한다.
2. 곱셈 결과는 64비트이며, 상위 32비트는 EDX에, 하위 32비트는 EAX에 저장된다.
3. 문제에서 32비트 결과를 요구하므로 하위 32비트인 EAX를 목적지 메모리에 저장한다.
4. `MUL`이 EAX와 EDX를 사용하므로 매크로 호출 전의 값을 보존하기 위해 두 레지스터를 스택에 저장하고 복원한다.
5. 이 매크로는 부호 없는 곱셈을 사용한다. 부호 있는 피연산자를 처리하려면 `MUL` 대신 `IMUL`을 사용해야 한다.

---

## 5. mReadInt Macro

Create a macro named mReadInt that reads a 16- or 32-bit signed integer from standard input and returns the value in an argument. Use conditional operators to allow the macro to adapt to the size of the desired result. Write a program that tests the macro, passing it operands of various sizes.

표준 입력에서 16비트 또는 32비트 부호 있는 정수를 읽고, 그 값을 인수에 반환하는 mReadInt라는 매크로를 작성하시오. 원하는 결과의 크기에 맞게 매크로가 동작하도록 조건부 연산자를 사용하시오. 다양한 크기의 피연산자를 전달하여 매크로를 테스트하는 프로그램도 작성하시오.

**답:**

```asm
mReadInt MACRO destination
    call ReadInt

    IF TYPE destination EQ 2
        mov WORD PTR destination, ax
    ELSEIF TYPE destination EQ 4
        mov DWORD PTR destination, eax
    ENDIF
ENDM
```

테스트 프로그램:

```asm
INCLUDE Irvine32.inc

mReadInt MACRO destination
    call ReadInt
    IF TYPE destination EQ 2
        mov WORD PTR destination, ax
    ELSEIF TYPE destination EQ 4
        mov DWORD PTR destination, eax
    ENDIF
ENDM

.data
shortValue SWORD ?
longValue  SDWORD ?

.code
main PROC
    mReadInt shortValue
    mReadInt longValue

    movsx eax, shortValue
    call WriteInt
    call Crlf

    mov eax, longValue
    call WriteInt
    call Crlf

    exit
main ENDP
END main
```

**풀이:**

1. Irvine32의 `ReadInt`는 표준 입력에서 부호 있는 정수를 읽어 EAX에 반환한다.
2. MASM의 `TYPE` 연산자는 피연산자의 크기를 바이트 단위로 반환한다.
3. `TYPE destination EQ 2`이면 목적지가 WORD이므로 AX를 저장한다.
4. `TYPE destination EQ 4`이면 목적지가 DWORD이므로 EAX 전체를 저장한다.
5. `IF`와 `ELSEIF`를 사용하면 목적지 변수의 크기에 따라 서로 다른 명령어가 어셈블된다.[^2]
6. WORD 변수에 저장하는 입력값은 부호 있는 16비트 범위에 들어가야 한다. 범위를 벗어난 값을 입력하면 하위 16비트만 저장되므로 값이 잘릴 수 있다.

---

## 6. mWriteInt Macro

Create a macro named mWriteInt that writes a signed integer to standard output by calling the WriteInt library procedure. The argument passed to the macro can be a byte, word, or doubleword. Use conditional operators in the macro so it adapts to the size of the argument. Write a program that tests the macro, passing it arguments of different sizes.

WriteInt 라이브러리 프로시저를 호출하여 부호 있는 정수를 표준 출력에 표시하는 mWriteInt라는 매크로를 작성하시오. 매크로에 전달되는 인수는 BYTE, WORD 또는 DWORD가 될 수 있다. 인수의 크기에 맞게 동작하도록 매크로에서 조건부 연산자를 사용하시오. 서로 다른 크기의 인수를 전달하여 매크로를 테스트하는 프로그램도 작성하시오.

**답:**

```asm
mWriteInt MACRO source
    IF TYPE source EQ 1
        movsx eax, BYTE PTR source
    ELSEIF TYPE source EQ 2
        movsx eax, WORD PTR source
    ELSEIF TYPE source EQ 4
        mov eax, DWORD PTR source
    ENDIF

    call WriteInt
ENDM
```

테스트 프로그램:

```asm
INCLUDE Irvine32.inc

mWriteInt MACRO source
    IF TYPE source EQ 1
        movsx eax, BYTE PTR source
    ELSEIF TYPE source EQ 2
        movsx eax, WORD PTR source
    ELSEIF TYPE source EQ 4
        mov eax, DWORD PTR source
    ENDIF
    call WriteInt
ENDM

.data
byteValue  SBYTE -12
wordValue  SWORD -1234
dwordValue SDWORD -123456

.code
main PROC
    mWriteInt byteValue
    call Crlf

    mWriteInt wordValue
    call Crlf

    mWriteInt dwordValue
    call Crlf

    exit
main ENDP
END main
```

**풀이:**

1. `WriteInt`는 EAX에 전달된 32비트 부호 있는 정수를 출력한다.
2. BYTE 크기의 값은 `MOVSX`로 부호 확장하여 EAX에 저장한다.
3. WORD 크기의 값도 `MOVSX`로 부호 확장하여 EAX에 저장한다.
4. DWORD 크기의 값은 이미 32비트이므로 EAX에 그대로 복사한다.
5. `TYPE`을 이용한 조건부 어셈블리로 인수의 크기에 맞는 명령어를 선택한 다음 `WriteInt`를 호출한다.[^2]

---

## 7. The Professor’s Lost Phone

When the professor took the drunkard's walk around campus in Section 10.1.6, we discovered that he lost his cell phone somewhere along the path. When you simulate the drunken walk, your program must drop the phone wherever the professor is standing at some random time interval. Each time you run the program, the cell phone will be lost at a different time interval (and location).

10.1.6절에서 교수가 캠퍼스에서 무작위 보행을 했을 때, 이동 경로 어딘가에서 휴대전화를 잃어버린 것을 확인했다. 무작위 보행을 시뮬레이션할 때 프로그램은 임의의 시간 간격이 지난 순간 교수가 서 있는 위치에 휴대전화를 떨어뜨려야 한다. 프로그램을 실행할 때마다 휴대전화를 잃어버리는 시간과 위치가 달라져야 한다.

**답:**

아래 코드는 기존 DrunkardWalk 프로그램에 추가하는 코드이다. `professorX`, `professorY`는 현재 교수의 좌표를 저장하는 변수라고 가정한다.

```asm
.data
MAX_STEPS EQU 100
stepCount DWORD 0
dropStep  DWORD ?
professorX SDWORD ?
professorY SDWORD ?
phoneX     SDWORD ?
phoneY     SDWORD ?
phoneLost  BYTE 0

.code
; 보행을 시작하기 전에 한 번 실행
call Randomize
mov eax, MAX_STEPS
call RandomRange          ; EAX = 0 ~ MAX_STEPS-1
inc eax                   ; 1 ~ MAX_STEPS
mov dropStep, eax
mov stepCount, 0
mov phoneLost, 0

; 기존 보행 반복문 안에서 교수의 위치를 한 번 이동한 직후 실행
inc stepCount
mov eax, stepCount
cmp eax, dropStep
jne ContinueWalk

mov eax, professorX
mov phoneX, eax
mov eax, professorY
mov phoneY, eax
mov phoneLost, 1

ContinueWalk:
; 기존 보행 반복문의 나머지 부분
```

**풀이:**

1. `Randomize`는 난수 생성기를 초기화한다.
2. `RandomRange`에 `MAX_STEPS`를 전달하면 0부터 `MAX_STEPS - 1`까지의 난수가 EAX에 반환된다.
3. `INC EAX`를 실행하여 휴대전화를 떨어뜨릴 걸음 수가 1부터 `MAX_STEPS` 사이가 되도록 한다.
4. 교수의 위치를 한 번 이동한 뒤 현재 걸음 수와 `dropStep`을 비교한다.
5. 두 값이 같으면 현재 좌표를 `phoneX`, `phoneY`에 복사하여 휴대전화를 떨어뜨린 위치를 기록한다.
6. `phoneLost`를 1로 설정하면 휴대전화를 잃어버렸는지 확인할 수 있다.
7. 위 예시의 `MAX_STEPS`는 기존 보행 프로그램의 최대 걸음 수에 맞춰야 한다. 사진에는 10.1.6절의 실제 좌표 변수명과 반복문 코드가 없으므로, `professorX`, `professorY` 및 반복문 위치는 기존 프로그램에 맞게 바꿔야 한다.

---

## 8. Drunkard’s Walk with Probabilities

When testing the DrunkardWalk program, you may have noticed that the professor doesn’t seem to wander very far from the starting point. This is no doubt caused by an equal probability of the professor moving in any direction. Modify the program so there is a 50% probability the professor will continue to walk in the same direction as he or she did when taking the previous step. There should be a 10% probability that he or she will reverse direction and a 20% probability that he or she will turn either right or left. Assign a default starting direction before the loop begins.

DrunkardWalk 프로그램을 테스트할 때 교수가 출발 지점에서 그다지 멀리 이동하지 않는 것처럼 보일 수 있다. 이는 교수가 모든 방향으로 동일한 확률로 이동하기 때문일 것이다. 이전 걸음에서 이동한 방향을 50%의 확률로 계속 유지하도록 프로그램을 수정하시오. 10%의 확률로 반대 방향으로 이동하고, 20%의 확률로 오른쪽 또는 왼쪽으로 방향을 바꾸도록 하시오. 반복문이 시작되기 전에 기본 시작 방향을 지정하시오.

**답:**

방향을 북쪽 0, 동쪽 1, 남쪽 2, 서쪽 3으로 표현한다. 각 방향 선택 코드를 기존 보행 반복문 안에서 실제 좌표를 이동시키는 코드보다 먼저 실행한다.

```asm
NORTH EQU 0
EAST  EQU 1
SOUTH EQU 2
WEST  EQU 3

.data
direction DWORD ?

.code
; 반복문을 시작하기 전에 난수 생성기와 기본 방향 지정
call Randomize
mov direction, NORTH

WalkLoop:
    mov eax, 100
    call RandomRange          ; 0 ~ 99

    cmp eax, 50
    jb KeepDirection          ; 0~49: 50% 그대로 이동

    cmp eax, 60
    jb ReverseDirection       ; 50~59: 10% 반대 방향

    cmp eax, 80
    jb TurnRight              ; 60~79: 20% 오른쪽

    ; 80~99: 20% 왼쪽
TurnLeft:
    mov eax, direction
    add eax, 3
    and eax, 3
    mov direction, eax
    jmp MoveProfessor

ReverseDirection:
    mov eax, direction
    add eax, 2
    and eax, 3
    mov direction, eax
    jmp MoveProfessor

TurnRight:
    mov eax, direction
    inc eax
    and eax, 3
    mov direction, eax
    jmp MoveProfessor

KeepDirection:
    ; direction 값을 변경하지 않음

MoveProfessor:
    ; 기존 프로그램의 방향별 좌표 이동 코드를 실행
    ; 이동 후 기존 반복문으로 돌아감
```

**풀이:**

1. 난수 범위를 0부터 99까지로 설정하면 총 100개의 동일한 확률 구간을 만들 수 있다.
2. 0~49는 50개이므로 50% 확률로 기존 방향을 유지한다.
3. 50~59는 10개이므로 10% 확률로 반대 방향으로 바꾼다.
4. 60~79와 80~99는 각각 20개이므로 오른쪽과 왼쪽으로 방향을 바꿀 확률은 각각 20%이다.
5. 방향을 0~3으로 표현했기 때문에 `AND EAX, 3`을 사용하면 방향 번호가 0~3 범위에서 순환한다.
6. 시작 방향은 반복문 전에 `NORTH`로 지정한다. `MoveProfessor` 다음에는 기존 프로그램의 방향별 이동 코드를 연결해야 한다.

---

## 9. Shifting Multiple Doublewords

Create a macro that shifts an array of 32-bit integers a variable number of bits in either direction, using the SHRD and SHLD instructions. Write a test program that tests your macro by shifting the same array in both directions and displaying the resulting values. You can assume that the array is in little-endian order. Here is a sample macro declaration:

```asm
mShiftDoublewords MACRO arrayName, direction, numberOfBits

Parameters:
    arrayName       Name of the array
    direction       Right (R) or Left (L)
    numberOfBits    Number of bit positions to shift
```

SHRD와 SHLD 명령어를 사용하여 32비트 정수 배열을 지정한 비트 수만큼 왼쪽 또는 오른쪽으로 이동시키는 매크로를 작성하시오. 같은 배열을 양쪽 방향으로 이동시키고 결과 값을 출력하여 매크로를 테스트하는 프로그램도 작성하시오. 배열은 리틀 엔디안 순서로 저장되어 있다고 가정한다. 예시 매크로 선언과 매개변수의 의미는 위와 같다.

**답:**

다음 매크로는 `direction`에 `L` 또는 `R`을 전달한다. 한 번의 SHLD/SHRD 명령에서 사용할 수 있는 이동량은 1~31비트이므로, 31비트씩 나누어 반복하면 32비트보다 큰 이동량도 처리할 수 있다.

```asm
mShiftDoublewords MACRO arrayName, direction, numberOfBits
    LOCAL chunkLoop, chunkReady, leftLoop, leftLow, rightLoop, rightHigh, shiftDone

    push eax
    push ecx
    push edx
    push esi

    mov edx, numberOfBits
    test edx, edx
    jz shiftDone

chunkLoop:
    mov ecx, edx
    cmp ecx, 31
    jbe chunkReady
    mov ecx, 31

chunkReady:
    IFIDNI <direction>, <L>
        ; 왼쪽 이동: 높은 인덱스부터 낮은 인덱스 순으로 처리
        mov esi, LENGTHOF arrayName - 1

leftLoop:
        cmp esi, 0
        je leftLow
        mov eax, arrayName[esi*4-4]
        shld arrayName[esi*4], eax, cl
        dec esi
        jmp leftLoop

leftLow:
        shl arrayName[0], cl

    ELSE
        ; 오른쪽 이동: 낮은 인덱스부터 높은 인덱스 순으로 처리
        xor esi, esi

rightLoop:
        cmp esi, LENGTHOF arrayName - 1
        jae rightHigh
        mov eax, arrayName[esi*4+4]
        shrd arrayName[esi*4], eax, cl
        inc esi
        jmp rightLoop

rightHigh:
        shr arrayName[esi*4], cl
    ENDIF

    sub edx, ecx
    jnz chunkLoop

shiftDone:
    pop esi
    pop edx
    pop ecx
    pop eax
ENDM
```

테스트 프로그램:

```asm
INCLUDE Irvine32.inc

; 위의 mShiftDoublewords 매크로 정의를 이 위치에 넣는다.

.data
values DWORD 12345678h, 9ABCDEF0h, 13579BDFh, 2468ACE0h

.code
main PROC
    ; 같은 배열을 왼쪽으로 4비트 이동
    mShiftDoublewords values, L, 4
    mov esi, OFFSET values
    mov ecx, LENGTHOF values
    mov ebx, TYPE values
    call DumpMem

    ; 원래 값으로 배열을 다시 초기화
    mov values[0], 12345678h
    mov values[4], 9ABCDEF0h
    mov values[8], 13579BDFh
    mov values[12], 2468ACE0h

    ; 같은 배열을 오른쪽으로 4비트 이동
    mShiftDoublewords values, R, 4
    mov esi, OFFSET values
    mov ecx, LENGTHOF values
    mov ebx, TYPE values
    call DumpMem

    exit
main ENDP
END main
```

**풀이:**

1. 배열이 리틀 엔디안 순서이므로 `arrayName[0]`이 가장 낮은 32비트 부분이고, 인덱스가 커질수록 더 높은 부분이 된다.
2. 왼쪽으로 이동할 때는 높은 인덱스부터 처리한다. `SHLD`로 현재 DWORD를 왼쪽으로 이동시키면서 바로 아래 인덱스 DWORD의 상위 비트를 가져온다. 마지막으로 가장 낮은 DWORD에는 `SHL`을 적용한다.
3. 오른쪽으로 이동할 때는 낮은 인덱스부터 처리한다. `SHRD`로 현재 DWORD를 오른쪽으로 이동시키면서 바로 위 인덱스 DWORD의 하위 비트를 가져온다. 마지막으로 가장 높은 DWORD에는 `SHR`을 적용한다.
4. 이동 방향에 따라 처리 순서를 반대로 해야 아직 변경되지 않은 인접 DWORD의 비트를 정확하게 가져올 수 있다.
5. EDX에는 남은 이동 비트 수를 저장하고, ECX에는 한 번에 이동할 비트 수를 저장한다. 한 번의 이동량이 31을 넘으면 31비트씩 나누어 처리한다.
6. 매크로에서 사용하는 EAX, ECX, EDX, ESI는 호출 전 값이 유지되도록 스택에 저장하고 복원한다.
7. 테스트에서는 같은 `values` 배열을 왼쪽으로 이동한 뒤 원래 값으로 초기화하고, 다시 오른쪽으로 이동한다. `DumpMem`은 ESI가 가리키는 메모리의 값을 출력한다.
8. `numberOfBits`는 0 이상의 값이어야 하며, 배열은 DWORD 원소를 하나 이상 포함해야 한다.

---

## 10. Three-Operand Instructions

Some computer instruction sets permit arithmetic instructions with three operands. Such operations sometimes appear in simple virtual assemblers used to introduce students to the concept of assembly language or using intermediate language in compilers. In the following macros, assume EAX is reserved for macro operations and is not preserved. Other registers modified by the macro must be preserved. All parameters are signed memory doublewords. Write macros that simulate the following operations:

a. `add3 destination, source1, source2`

b. `sub3 destination, source1, source2` (destination = source1 – source2)

c. `mul3 destination, source1, source2`

d. `div3 destination, source1, source2` (destination = source1 / source2)

For example, the following macro calls implement the expression **x = (w + y) \* z**:

```asm
.data
temp DWORD ?
.code
add3 temp, w, y                 ; temp = w + y
mul3 x, temp, z                 ; x = temp * z
```

Write a program that tests your macros by implementing four arithmetic expressions, each involving multiple operations.

일부 컴퓨터 명령어 집합은 세 개의 피연산자를 사용하는 산술 명령어를 지원한다. 이러한 연산은 어셈블리 언어의 개념을 소개하거나 컴파일러에서 중간 언어를 사용하는 방법을 설명하기 위한 간단한 가상 어셈블러에서 사용되기도 한다. 다음 매크로에서는 EAX가 매크로 연산 전용으로 예약되어 있으며 보존되지 않는다고 가정한다. 매크로가 변경하는 다른 레지스터는 보존해야 한다. 모든 매개변수는 부호 있는 메모리 더블워드이다. 다음 연산을 구현하는 매크로를 작성하시오.

a. `add3 destination, source1, source2`

b. `sub3 destination, source1, source2` (destination = source1 – source2)

c. `mul3 destination, source1, source2`

d. `div3 destination, source1, source2` (destination = source1 / source2)

예를 들어 다음 매크로 호출은 **x = (w + y) \* z**라는 식을 구현한다. 또한 여러 연산을 포함하는 네 개의 산술식을 구현하여 매크로를 테스트하는 프로그램을 작성하시오.

**답:**

```asm
add3 MACRO destination, source1, source2
    mov eax, source1
    add eax, source2
    mov destination, eax
ENDM

sub3 MACRO destination, source1, source2
    mov eax, source1
    sub eax, source2
    mov destination, eax
ENDM

mul3 MACRO destination, source1, source2
    mov eax, source1
    imul eax, source2
    mov destination, eax
ENDM

div3 MACRO destination, source1, source2
    push edx
    mov eax, source1
    cdq
    idiv DWORD PTR source2
    mov destination, eax
    pop edx
ENDM
```

테스트 프로그램:

```asm
INCLUDE Irvine32.inc

; 위의 add3, sub3, mul3, div3 매크로 정의를 이 위치에 넣는다.

.data
a SDWORD 20
b SDWORD 5
c SDWORD 3

temp1 SDWORD ?
temp2 SDWORD ?
temp3 SDWORD ?
temp4 SDWORD ?

result1 SDWORD ?
result2 SDWORD ?
result3 SDWORD ?
result4 SDWORD ?

.code
main PROC
    ; result1 = (a + b) * c = (20 + 5) * 3 = 75
    add3 temp1, a, b
    mul3 result1, temp1, c

    ; result2 = (a - b) + c = (20 - 5) + 3 = 18
    sub3 temp2, a, b
    add3 result2, temp2, c

    ; result3 = (a * b) - c = (20 * 5) - 3 = 97
    mul3 temp3, a, b
    sub3 result3, temp3, c

    ; result4 = (a / b) * c = (20 / 5) * 3 = 12
    div3 temp4, a, b
    mul3 result4, temp4, c

    mov eax, result1
    call WriteInt
    call Crlf

    mov eax, result2
    call WriteInt
    call Crlf

    mov eax, result3
    call WriteInt
    call Crlf

    mov eax, result4
    call WriteInt
    call Crlf

    exit
main ENDP
END main
```

**풀이:**

1. 모든 매개변수는 부호 있는 메모리 DWORD이므로 계산은 EAX에서 수행한 뒤 목적지 메모리에 저장한다.
2. `add3`은 첫 번째 원본 값을 EAX에 넣고 두 번째 원본 값을 더한 후 목적지에 저장한다.
3. `sub3`은 첫 번째 원본 값에서 두 번째 원본 값을 빼서 목적지에 저장한다.
4. `mul3`은 `IMUL`을 사용하여 두 부호 있는 값을 곱한다. 결과 중 하위 32비트를 목적지에 저장한다. EAX는 문제에서 보존하지 않아도 된다고 지정한 레지스터이다.
5. `div3`은 EAX에 피제수를 넣고 `CDQ`로 부호를 확장하여 EDX:EAX를 만든 다음, `IDIV`로 부호 있는 나눗셈을 수행한다. 몫은 EAX에 저장된다.
6. `div3`에서 EDX를 사용하므로 `PUSH EDX`와 `POP EDX`로 기존 값을 보존한다. EAX는 문제의 조건에 따라 보존하지 않는다.
7. 나눗셈의 제수는 0이 아니어야 하며, 몫이 32비트 부호 있는 정수 범위를 벗어나면 안 된다.
8. 테스트 프로그램은 덧셈 후 곱셈, 뺄셈 후 덧셈, 곱셈 후 뺄셈, 나눗셈 후 곱셈의 네 가지 식을 계산한다.
