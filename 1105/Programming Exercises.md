# Programming Exercises

---

## 1. FindLargest Procedure

Create a procedure named FindLargest that receives two parameters: a pointer to a signed doubleword array, and a count of the array’s length. The procedure must return the value of the largest array member in EAX. Use the PROC directive with a parameter list when declaring the procedure. Preserve all registers (except EAX) that are modified by the procedure. Write a test program that calls FindLargest and passes three different arrays of different lengths. Be sure to include negative values in your arrays. Create a PROTO declaration for FindLargest.

**한글 해석:**

FindLargest라는 프로시저를 작성하시오. 이 프로시저는 부호 있는 더블워드 배열의 포인터와 배열의 길이를 매개변수로 받는다. 배열에서 가장 큰 원소의 값을 EAX에 반환해야 한다. 프로시저를 선언할 때 매개변수 목록이 있는 PROC 지시어를 사용한다. 프로시저에서 변경하는 레지스터 중 EAX를 제외한 모든 레지스터를 보존한다.

서로 길이가 다른 세 개의 배열을 전달하여 FindLargest를 호출하는 테스트 프로그램을 작성한다. 배열에는 음수도 포함해야 한다. FindLargest의 PROTO 선언도 작성한다.

**답:**

```asm
INCLUDE Irvine32.inc

FindLargest PROTO, pArray:PTR SDWORD, arraySize:DWORD

.data
array1 SDWORD -8, 12, -3, 7
array2 SDWORD -25, -4, -17
array3 SDWORD 10, -30, 45, 2, -1, 18

msg1 BYTE "Array 1 largest: ",0
msg2 BYTE "Array 2 largest: ",0
msg3 BYTE "Array 3 largest: ",0

.code
main PROC
    INVOKE FindLargest, ADDR array1, LENGTHOF array1
    mov edx, OFFSET msg1
    call WriteString
    call WriteInt
    call Crlf

    INVOKE FindLargest, ADDR array2, LENGTHOF array2
    mov edx, OFFSET msg2
    call WriteString
    call WriteInt
    call Crlf

    INVOKE FindLargest, ADDR array3, LENGTHOF array3
    mov edx, OFFSET msg3
    call WriteString
    call WriteInt
    call Crlf

    exit
main ENDP

FindLargest PROC USES esi ecx edx,
    pArray:PTR SDWORD,
    arraySize:DWORD

    mov esi, pArray
    mov ecx, arraySize

    ; 배열 길이가 0이면 0 반환
    xor eax, eax
    cmp ecx, 0
    je FL_Done

    mov eax, [esi]             ; 첫 번째 원소를 최댓값으로 설정
    add esi, TYPE SDWORD
    dec ecx
    jz FL_Done

FL_Loop:
    mov edx, [esi]
    cmp edx, eax
    jle FL_Next                ; signed 비교
    mov eax, edx

FL_Next:
    add esi, TYPE SDWORD
    loop FL_Loop

FL_Done:
    ret
FindLargest ENDP

END main
```

**풀이:**

1. `pArray`에는 배열의 첫 번째 원소 주소가 전달되고, `arraySize`에는 원소 개수가 전달된다.
2. `ESI`를 배열의 시작 주소로 설정하고 `ECX`를 반복 횟수로 사용한다.
3. 첫 번째 원소를 `EAX`에 저장하여 현재 최댓값으로 지정한다.
4. 나머지 원소를 하나씩 `EDX`에 읽어 `EAX`와 비교한다.
5. `SDWORD`는 부호 있는 정수이므로 `JLE` 같은 부호 있는 조건 분기를 사용한다. 현재 원소가 더 크면 `EAX`를 갱신한다.
6. `USES esi ecx edx`가 프로시저에서 변경하는 ESI, ECX, EDX를 자동으로 저장하고 복원한다. 반환값인 EAX는 보존하지 않는다.
7. 테스트 프로그램은 길이가 서로 다른 세 배열을 전달하고 `WriteInt`로 반환된 부호 있는 정수를 출력한다.

---

## 2. Chess Board

Write a program that draws an 8 X 8 chess board, with alternating gray and white squares. You can use the SetTextColor and Gotoxy procedures from the Irvine32 library. Avoid the use of global variables, and use declared parameters in all procedures. Use short procedures that are focused on a single task.

**한글 해석:**

회색과 흰색 칸이 번갈아 나타나는 8×8 체스판을 그리는 프로그램을 작성하시오. Irvine32 라이브러리의 SetTextColor와 Gotoxy 프로시저를 사용할 수 있다. 전역 변수를 사용하지 말고, 모든 프로시저에서 선언된 매개변수를 사용한다. 각 프로시저는 하나의 작업에 집중하도록 짧게 작성한다.

**답:**

```asm
INCLUDE Irvine32.inc

DrawSquare PROTO, xPos:DWORD, yPos:DWORD, bgColor:DWORD
DrawBoard PROTO, grayColor:DWORD, whiteColor:DWORD

.code
main PROC
    call Clrscr
    INVOKE DrawBoard, 7, 15       ; 회색(7), 흰색(15)
    mov eax, 0
    call SetTextColor
    exit
main ENDP

; 지정한 위치에 4칸 너비 × 2줄 높이의 정사각형을 출력한다.
DrawSquare PROC USES eax ecx edx esi,
    xPos:DWORD,
    yPos:DWORD,
    bgColor:DWORD

    mov eax, bgColor
    shl eax, 4                    ; 배경색은 상위 4비트
    call SetTextColor

    mov esi, 0
DS_Row:
    mov eax, yPos
    add eax, esi
    mov dh, al
    mov eax, xPos
    mov dl, al
    call Gotoxy

    mov ecx, 4
DS_Column:
    mov al, ' '
    call WriteChar
    loop DS_Column

    inc esi
    cmp esi, 2
    jb DS_Row
    ret
DrawSquare ENDP

; 8×8 체스판의 각 칸 위치와 색을 결정한다.
DrawBoard PROC USES eax,
    grayColor:DWORD,
    whiteColor:DWORD

    LOCAL row:DWORD
    LOCAL col:DWORD
    LOCAL xPos:DWORD
    LOCAL yPos:DWORD
    LOCAL squareColor:DWORD

    mov row, 0
DB_Row:
    mov col, 0
DB_Column:
    ; 각 칸의 화면 좌표: 가로 4칸, 세로 2줄
    mov eax, col
    shl eax, 2
    mov xPos, eax

    mov eax, row
    shl eax, 1
    mov yPos, eax

    ; 행 번호와 열 번호의 합이 짝수이면 회색, 홀수이면 흰색
    mov eax, row
    add eax, col
    test eax, 1
    jnz DB_White

    mov eax, grayColor
    mov squareColor, eax
    jmp DB_Draw

DB_White:
    mov eax, whiteColor
    mov squareColor, eax

DB_Draw:
    INVOKE DrawSquare, xPos, yPos, squareColor

    inc col
    cmp col, 8
    jb DB_Column

    inc row
    cmp row, 8
    jb DB_Row
    ret
DrawBoard ENDP

END main
```

**풀이:**

1. 체스판은 가로 8칸, 세로 8칸으로 구성한다. 각 칸을 화면에서 4문자 너비와 2줄 높이로 출력한다.
2. `DrawSquare`는 전달받은 좌표와 배경색에 해당하는 한 칸만 그린다. `SetTextColor`의 색상 속성에서 배경색은 상위 4비트이므로 색상값을 4비트 왼쪽으로 이동한다.
3. `Gotoxy`는 `DH`에 행 좌표, `DL`에 열 좌표를 전달받는다. 해당 위치로 이동한 뒤 공백 문자 4개를 두 줄에 출력한다.
4. `DrawBoard`는 중첩 반복문으로 행과 열을 각각 0부터 7까지 순회한다.
5. `row + col`이 짝수이면 회색, 홀수이면 흰색을 선택하여 인접한 칸의 색이 달라지도록 한다.
6. `DrawBoard`는 각 칸을 그리는 작업을 `DrawSquare`에 맡긴다. 배열이나 전역 변수를 사용하지 않고 매개변수와 지역 변수로 처리한다.

---

## 3. Chess Board with Alternating Colors

This exercise extends Exercise 2. Every 500 milliseconds, change the color of the colored squares and redisplay the board. Continue until you have shown the board 16 times, using all possible 4-bit background colors. (The white squares remain white throughout.)

**한글 해석:**

이 문제는 연습문제 2를 확장한 것이다. 500밀리초마다 색상이 지정된 칸의 색을 변경하고 체스판을 다시 출력한다. 가능한 모든 4비트 배경색을 사용하여 체스판을 총 16번 보여줄 때까지 반복한다. 흰색 칸은 계속 흰색으로 유지한다.

**답:**

```asm
INCLUDE Irvine32.inc

DrawSquare PROTO, xPos:DWORD, yPos:DWORD, bgColor:DWORD
DrawBoard PROTO, coloredColor:DWORD, whiteColor:DWORD

.code
main PROC
    mov ebx, 0                    ; 0~15의 배경색 번호

CB_Loop:
    call Clrscr
    INVOKE DrawBoard, ebx, 15     ; 흰색 칸은 항상 15
    mov eax, 500
    call Delay

    inc ebx
    cmp ebx, 16
    jb CB_Loop

    mov eax, 0
    call SetTextColor
    exit
main ENDP

DrawSquare PROC USES eax ecx edx esi,
    xPos:DWORD,
    yPos:DWORD,
    bgColor:DWORD

    mov eax, bgColor
    shl eax, 4
    call SetTextColor

    mov esi, 0
CBS_Row:
    mov eax, yPos
    add eax, esi
    mov dh, al
    mov eax, xPos
    mov dl, al
    call Gotoxy

    mov ecx, 4
CBS_Column:
    mov al, ' '
    call WriteChar
    loop CBS_Column

    inc esi
    cmp esi, 2
    jb CBS_Row
    ret
DrawSquare ENDP

DrawBoard PROC USES eax,
    coloredColor:DWORD,
    whiteColor:DWORD

    LOCAL row:DWORD
    LOCAL col:DWORD
    LOCAL xPos:DWORD
    LOCAL yPos:DWORD
    LOCAL squareColor:DWORD

    mov row, 0
CDB_Row:
    mov col, 0
CDB_Column:
    mov eax, col
    shl eax, 2
    mov xPos, eax

    mov eax, row
    shl eax, 1
    mov yPos, eax

    mov eax, row
    add eax, col
    test eax, 1
    jnz CDB_White

    mov eax, coloredColor
    mov squareColor, eax
    jmp CDB_Draw

CDB_White:
    mov eax, whiteColor
    mov squareColor, eax

CDB_Draw:
    INVOKE DrawSquare, xPos, yPos, squareColor

    inc col
    cmp col, 8
    jb CDB_Column

    inc row
    cmp row, 8
    jb CDB_Row
    ret
DrawBoard ENDP

END main
```

**풀이:**

1. 4비트 배경색은 0부터 15까지 총 16가지이다.
2. `EBX`를 색상 번호로 사용하고 0부터 15까지 반복한다.
3. 반복할 때마다 `Clrscr`로 이전 체스판을 지우고 `DrawBoard`를 호출한다.
4. `DrawBoard`에는 현재 색상 번호와 흰색 번호 15를 전달한다. 따라서 색상이 바뀌는 칸만 매번 다른 색으로 출력되고 흰색 칸은 그대로 유지된다.
5. `Delay`에 500을 전달하면 500밀리초 동안 대기한다.
6. 색상 번호가 16이 되면 반복을 종료한다. 결과적으로 가능한 16가지 배경색을 각각 한 번씩 사용한다.

---

## 4. FindThrees Procedure

Create a procedure named FindThrees that returns 1 if an array has three consecutive values of 3 somewhere in the array. Otherwise, return 0. The procedure’s input parameter list contains a pointer to the array and the array’s size. Use the PROC directive with a parameter list when declaring the procedure. Preserve all registers (except EAX) that are modified by the procedure. Write a test program that calls FindThrees several times with different arrays.

**한글 해석:**

배열의 어느 위치에든 값 3이 연속으로 세 번 나타나면 1을 반환하고, 그렇지 않으면 0을 반환하는 FindThrees 프로시저를 작성하시오. 입력 매개변수 목록에는 배열의 포인터와 배열의 크기가 포함된다. 프로시저를 선언할 때 매개변수 목록이 있는 PROC 지시어를 사용한다. 프로시저에서 변경하는 레지스터 중 EAX를 제외한 모든 레지스터를 보존한다.

서로 다른 배열을 사용하여 FindThrees를 여러 번 호출하는 테스트 프로그램을 작성하시오.

**답:**

```asm
INCLUDE Irvine32.inc

FindThrees PROTO, pArray:PTR SDWORD, arraySize:DWORD

.data
array1 SDWORD 1, 3, 3, 3, 8
array2 SDWORD 3, 3, 2, 3, 3
array3 SDWORD 3, 3, 3
array4 SDWORD 1, 2, 3, 4, 5

msg BYTE "FindThrees result: ",0

.code
main PROC
    INVOKE FindThrees, ADDR array1, LENGTHOF array1
    call DisplayResult

    INVOKE FindThrees, ADDR array2, LENGTHOF array2
    call DisplayResult

    INVOKE FindThrees, ADDR array3, LENGTHOF array3
    call DisplayResult

    INVOKE FindThrees, ADDR array4, LENGTHOF array4
    call DisplayResult

    exit
main ENDP

DisplayResult PROC
    mov edx, OFFSET msg
    call WriteString
    call WriteDec
    call Crlf
    ret
DisplayResult ENDP

FindThrees PROC USES esi ecx edx,
    pArray:PTR SDWORD,
    arraySize:DWORD

    mov esi, pArray
    mov ecx, arraySize
    xor edx, edx                 ; 연속된 3의 개수
    xor eax, eax                 ; 기본 반환값은 0

FT_Loop:
    cmp ecx, 0
    je FT_Done

    cmp DWORD PTR [esi], 3
    jne FT_Reset

    inc edx
    cmp edx, 3
    je FT_Found
    jmp FT_Next

FT_Reset:
    xor edx, edx

FT_Next:
    add esi, TYPE SDWORD
    dec ecx
    jmp FT_Loop

FT_Found:
    mov eax, 1

FT_Done:
    ret
FindThrees ENDP

END main
```

**풀이:**

1. `ESI`는 현재 배열 원소의 주소를 가리키고, `ECX`는 남은 원소의 개수를 나타낸다.
2. `EDX`에는 연속해서 발견한 3의 개수를 저장한다.
3. 현재 원소가 3이면 `EDX`를 1 증가시킨다.
4. `EDX`가 3이 되면 연속된 3을 세 개 찾은 것이므로 `EAX`에 1을 저장하고 종료한다.
5. 현재 원소가 3이 아니면 연속 횟수를 0으로 초기화한다.
6. 배열을 끝까지 검사했는데 연속된 3을 찾지 못했다면 처음 설정한 반환값 0을 유지한다.
7. `USES esi ecx edx`를 사용하여 EAX를 제외한 변경 레지스터를 보존한다.

---

## 5. DifferentInputs Procedure

Write a procedure named DifferentInputs that returns EAX = 1 if the values of its three input parameters are all different; otherwise, return with EAX = 0. Use the PROC directive with a parameter list when declaring the procedure. Create a PROTO declaration for your procedure, and call it five times from a test program that passes different inputs.

**한글 해석:**

세 개의 입력 매개변수 값이 모두 서로 다르면 EAX에 1을 반환하고, 그렇지 않으면 EAX에 0을 반환하는 DifferentInputs 프로시저를 작성하시오. 프로시저를 선언할 때 매개변수 목록이 있는 PROC 지시어를 사용한다. 해당 프로시저의 PROTO 선언을 작성하고, 서로 다른 입력값을 전달하여 테스트 프로그램에서 다섯 번 호출하시오.

**답:**

```asm
INCLUDE Irvine32.inc

DifferentInputs PROTO, value1:DWORD, value2:DWORD, value3:DWORD

.data
resultMsg BYTE "Result: ",0

.code
main PROC
    INVOKE DifferentInputs, 10, 20, 30
    call ShowAnswer

    INVOKE DifferentInputs, 10, 10, 30
    call ShowAnswer

    INVOKE DifferentInputs, 5, 8, 5
    call ShowAnswer

    INVOKE DifferentInputs, 1, 2, 3
    call ShowAnswer

    INVOKE DifferentInputs, 7, 7, 7
    call ShowAnswer

    exit
main ENDP

ShowAnswer PROC
    mov edx, OFFSET resultMsg
    call WriteString
    call WriteDec
    call Crlf
    ret
ShowAnswer ENDP

DifferentInputs PROC,
    value1:DWORD,
    value2:DWORD,
    value3:DWORD

    mov eax, 0

    mov edx, value1
    cmp edx, value2
    je DI_Done

    cmp edx, value3
    je DI_Done

    mov edx, value2
    cmp edx, value3
    je DI_Done

    mov eax, 1

DI_Done:
    ret
DifferentInputs ENDP

END main
```

**풀이:**

1. 세 값이 모두 다르려면 `value1`과 `value2`, `value1`과 `value3`, `value2`와 `value3`가 각각 달라야 한다.
2. 먼저 EAX를 0으로 초기화한다. 이는 값이 중복되는 경우의 반환값이다.
3. 세 쌍을 차례로 비교한다.
4. 어느 한 쌍이라도 같으면 `DI_Done`으로 이동하여 0을 반환한다.
5. 세 쌍이 모두 다르면 EAX에 1을 저장한다.
6. 테스트 프로그램은 서로 다른 조합 다섯 개를 전달하여 결과를 출력한다.

---

## 6. Exchanging Integers

Create an array of randomly ordered integers. Using the Swap procedure from Section 8.4.6 as a tool, write a loop that exchanges each consecutive pair of integers in the array.

**한글 해석:**

무작위 순서로 정렬된 정수 배열을 생성하시오. 8.4.6절의 Swap 프로시저를 도구로 사용하여 배열에서 서로 이웃한 정수 쌍을 교환하는 반복문을 작성하시오.

**답:**

```asm
INCLUDE Irvine32.inc

Swap PROTO, pValue1:PTR DWORD, pValue2:PTR DWORD

.data
intArray DWORD 8, 3, 12, 5, 1, 10, 6, 2
arraySize = LENGTHOF intArray

beforeMsg BYTE "Before swapping: ",0
afterMsg  BYTE "After swapping:  ",0

.code
main PROC
    mov edx, OFFSET beforeMsg
    call WriteString
    mov esi, OFFSET intArray
    mov ecx, arraySize
    call DisplayArray
    call Crlf

    mov esi, 0
    mov ecx, arraySize / 2

EX_Loop:
    ; ESI는 교환할 첫 번째 원소의 인덱스
    mov eax, OFFSET intArray
    lea edx, [eax + esi * TYPE DWORD]
    lea edi, [edx + TYPE DWORD]

    INVOKE Swap, edx, edi

    add esi, 2
    loop EX_Loop

    mov edx, OFFSET afterMsg
    call WriteString
    mov esi, OFFSET intArray
    mov ecx, arraySize
    call DisplayArray
    call Crlf

    exit
main ENDP

; 두 주소가 가리키는 DWORD 값을 서로 교환한다.
Swap PROC USES eax esi edi,
    pValue1:PTR DWORD,
    pValue2:PTR DWORD

    mov esi, pValue1
    mov edi, pValue2

    mov eax, [esi]
    xchg eax, [edi]
    mov [esi], eax
    ret
Swap ENDP

; 배열의 모든 원소를 출력한다.
DisplayArray PROC USES eax ecx esi
DA_Loop:
    mov eax, [esi]
    call WriteDec
    mov al, ' '
    call WriteChar
    add esi, TYPE DWORD
    loop DA_Loop
    ret
DisplayArray ENDP

END main
```

**풀이:**

1. `intArray`에는 순서가 섞인 정수 8개를 저장한다.
2. 서로 이웃한 두 원소를 교환해야 하므로 인덱스는 0, 2, 4, 6 순서로 증가한다.
3. 배열의 시작 주소에 인덱스×4를 더해 첫 번째 원소의 주소를 구한다. DWORD는 4바이트이므로 두 번째 원소의 주소는 첫 번째 주소에 4를 더하면 된다.
4. `Swap`은 두 원소의 주소를 매개변수로 전달받는다. 첫 번째 값을 EAX에 임시 저장하고 `XCHG`와 대입을 이용해 두 값을 교환한다.
5. 배열 길이가 8이므로 교환 횟수는 8÷2인 4회이다.
6. `DisplayArray`를 교환 전후에 호출하여 결과를 확인한다.
7. 배열의 원소 개수가 홀수라면 마지막 원소는 짝이 없으므로 `arraySize / 2`번만 교환하면 된다.

---

## 7. Greatest Common Divisor

Write a recursive implementation of Euclid’s algorithm for finding the greatest common divisor (GCD) of two integers. Descriptions of this algorithm are available in algebra books and on the Web. Write a test program that calls your GCD procedure five times, using the following pairs of integers: (5,20), (24,18), (11,7), (432,226), (26,13). After each procedure call, display the GCD.

**한글 해석:**

두 정수의 최대공약수(GCD)를 구하는 유클리드 알고리즘을 재귀적으로 구현하시오. 이 알고리즘에 대한 설명은 대수학 교재나 웹에서 찾아볼 수 있다.

다음 다섯 쌍의 정수를 사용하여 GCD 프로시저를 다섯 번 호출하는 테스트 프로그램을 작성하시오.

- (5, 20)
- (24, 18)
- (11, 7)
- (432, 226)
- (26, 13)

각 프로시저 호출이 끝난 후 최대공약수를 출력하시오.

**답:**

```asm
INCLUDE Irvine32.inc

GCD PROTO, num1:DWORD, num2:DWORD

.data
msg BYTE "GCD = ",0

.code
main PROC
    INVOKE GCD, 5, 20
    call DisplayGCD

    INVOKE GCD, 24, 18
    call DisplayGCD

    INVOKE GCD, 11, 7
    call DisplayGCD

    INVOKE GCD, 432, 226
    call DisplayGCD

    INVOKE GCD, 26, 13
    call DisplayGCD

    exit
main ENDP

DisplayGCD PROC
    mov edx, OFFSET msg
    call WriteString
    call WriteDec
    call Crlf
    ret
DisplayGCD ENDP

; Euclid's algorithm:
; GCD(a, b) = GCD(b, a MOD b)
; GCD(a, 0) = a
GCD PROC USES edx,
    num1:DWORD,
    num2:DWORD

    LOCAL remainder:DWORD

    mov eax, num2
    cmp eax, 0
    jne GCD_Recurse

    mov eax, num1
    ret

GCD_Recurse:
    mov eax, num1
    xor edx, edx
    div num2
    mov remainder, edx

    INVOKE GCD, num2, remainder
    ret
GCD ENDP

END main
```

**풀이:**

1. 유클리드 알고리즘은 다음 규칙을 사용한다.

   \[
   GCD(a,b)=GCD(b,a \bmod b)
   \]

   나머지가 0이 되면 현재의 첫 번째 값이 최대공약수이다.

2. `num2`가 0인지 확인한다. 0이면 재귀 호출을 끝내고 `num1`을 EAX에 반환한다.
3. `num2`가 0이 아니면 `num1`을 `num2`로 나눈다.
4. `DIV` 명령어 실행 후 나머지는 EDX에 저장된다. 이 나머지를 지역 변수 `remainder`에 보관한다.
5. `GCD(num2, remainder)`를 다시 호출한다.
6. 재귀 호출이 반복되다가 나머지가 0이 되면 가장 안쪽 호출에서 최대공약수가 반환되고, 그 값이 이전 호출을 거쳐 최종적으로 EAX에 전달된다.
7. 주어진 입력 쌍의 결과는 차례대로 5, 6, 1, 2, 13이다.

---

## 8. Counting Matching Elements

Write a procedure named CountMatches that receives points to two arrays of signed doublewords, and a third parameter that indicates the length of the two arrays. For each element xi
in the first array, if the corresponding yi in the second array is equal, increment a count. At the end, return a count of the number of matching array elements in EAX. Write a test program that calls your procedure and passes pointers to two different pairs of arrays. Use the INVOKE statement to call your procedure and pass stack parameters. Create a PROTO declaration for CountMatches. Save and restore any registers (other than EAX) changed by your procedure.

**한글 해석:**

CountMatches라는 프로시저를 작성하시오. 이 프로시저는 부호 있는 더블워드 배열 두 개의 포인터와 두 배열의 길이를 나타내는 세 번째 매개변수를 받는다.

첫 번째 배열의 각 원소 \(x_i\)에 대해 두 번째 배열의 같은 위치에 있는 원소 \(y_i\)와 값이 같으면 카운트를 1 증가시킨다. 모든 원소를 확인한 후 일치하는 배열 원소의 개수를 EAX에 반환한다.

서로 다른 두 쌍의 배열 포인터를 전달하여 프로시저를 호출하는 테스트 프로그램을 작성하시오. 스택 매개변수를 전달하기 위해 INVOKE 문을 사용한다. CountMatches의 PROTO 선언을 작성한다. 프로시저에서 변경한 레지스터 중 EAX를 제외한 나머지 레지스터는 저장하고 복원한다.

**답:**

```asm
INCLUDE Irvine32.inc

CountMatches PROTO,
    pArray1:PTR SDWORD,
    pArray2:PTR SDWORD,
    arraySize:DWORD

.data
array1 SDWORD 1, 5, 3, 7, 9
array2 SDWORD 1, 2, 3, 4, 9

array3 SDWORD -5, 10, 15, 20
array4 SDWORD -5, 11, 15, 18

msg BYTE "Matching elements: ",0

.code
main PROC
    INVOKE CountMatches, ADDR array1, ADDR array2, LENGTHOF array1
    call ShowCount

    INVOKE CountMatches, ADDR array3, ADDR array4, LENGTHOF array3
    call ShowCount

    exit
main ENDP

ShowCount PROC
    mov edx, OFFSET msg
    call WriteString
    call WriteDec
    call Crlf
    ret
ShowCount ENDP

CountMatches PROC USES esi edi ecx edx,
    pArray1:PTR SDWORD,
    pArray2:PTR SDWORD,
    arraySize:DWORD

    mov esi, pArray1
    mov edi, pArray2
    mov ecx, arraySize
    xor eax, eax

CM_Loop:
    cmp ecx, 0
    je CM_Done

    mov edx, [esi]
    cmp edx, [edi]
    jne CM_Next

    inc eax

CM_Next:
    add esi, TYPE SDWORD
    add edi, TYPE SDWORD
    dec ecx
    jmp CM_Loop

CM_Done:
    ret
CountMatches ENDP

END main
```

**풀이:**

1. `ESI`와 `EDI`에 각각 첫 번째 배열과 두 번째 배열의 시작 주소를 저장한다.
2. `ECX`에는 배열의 길이를 저장하고, `EAX`는 일치하는 원소의 개수를 세기 위해 0으로 초기화한다.
3. 두 배열에서 같은 위치의 값을 각각 `EDX`와 메모리 피연산자로 읽어 비교한다.
4. 두 값이 같으면 `EAX`를 1 증가시킨다.
5. 두 포인터를 각각 4바이트씩 이동하여 다음 DWORD 원소를 비교한다.
6. 배열 길이만큼 반복한 뒤 EAX에 저장된 일치 개수를 반환한다.
7. `INVOKE`는 프로시저의 매개변수를 스택에 전달한다. `USES`는 ESI, EDI, ECX, EDX를 저장하고 복원한다.

---

## 9. Counting Nearly Matching Elements

Write a procedure named CountNearMatches that receives pointers to two arrays of signed doublewords, a parameter that indicates the length of the two arrays, and a parameter that indicates the
maximum allowed difference (called diff) between any two matching elements. For each element xi in the first array, if the difference between it and the corresponding yi in the second array is less
than or equal to diff, increment a count. At the end, return a count of the number of nearly matching array elements in EAX. Write a test program that calls CountNearMatches and passes pointers to two different pairs of arrays. Use the INVOKE statement to call your procedure and pass stack parameters. Create a PROTO declaration for CountMatches. Save and restore any registers (other than EAX) changed by your procedure.

**한글 해석:**

CountNearMatches라는 프로시저를 작성하시오. 이 프로시저는 부호 있는 더블워드 배열 두 개의 포인터, 두 배열의 길이, 그리고 두 원소 사이에 허용되는 최대 차이(diff)를 매개변수로 받는다.

첫 번째 배열의 각 원소 \(x_i\)와 두 번째 배열의 같은 위치에 있는 원소 \(y_i\)의 차이가 diff보다 작거나 같으면 카운트를 1 증가시킨다. 모든 원소를 확인한 후 거의 일치하는 배열 원소의 개수를 EAX에 반환한다.

서로 다른 두 쌍의 배열 포인터를 전달하여 CountNearMatches를 호출하는 테스트 프로그램을 작성하시오. 스택 매개변수를 전달하기 위해 INVOKE 문을 사용한다. 문제의 마지막 문장에는 CountMatches의 PROTO 선언이라고 적혀 있지만, 이 프로시저에 맞는 CountNearMatches의 PROTO 선언을 작성한다. 프로시저에서 변경한 레지스터 중 EAX를 제외한 나머지 레지스터는 저장하고 복원한다.

**답:**

```asm
INCLUDE Irvine32.inc

CountNearMatches PROTO,
    pArray1:PTR SDWORD,
    pArray2:PTR SDWORD,
    arraySize:DWORD,
    diff:DWORD

.data
array1 SDWORD 10, 20, 30, 40, 50
array2 SDWORD 12, 25, 27, 48, 60

array3 SDWORD -10, 0, 10, 20
array4 SDWORD -7, 3, 15, 30

msg BYTE "Nearly matching elements: ",0

.code
main PROC
    INVOKE CountNearMatches, ADDR array1, ADDR array2, LENGTHOF array1, 5
    call ShowNearCount

    INVOKE CountNearMatches, ADDR array3, ADDR array4, LENGTHOF array3, 5
    call ShowNearCount

    exit
main ENDP

ShowNearCount PROC
    mov edx, OFFSET msg
    call WriteString
    call WriteDec
    call Crlf
    ret
ShowNearCount ENDP

CountNearMatches PROC USES esi edi ecx edx ebx,
    pArray1:PTR SDWORD,
    pArray2:PTR SDWORD,
    arraySize:DWORD,
    diff:DWORD

    mov esi, pArray1
    mov edi, pArray2
    mov ecx, arraySize
    xor ebx, ebx                 ; 일치하는 원소 개수

CNM_Loop:
    cmp ecx, 0
    je CNM_Done

    mov eax, [esi]               ; x
    mov edx, [edi]               ; y

    ; signed 비교로 큰 값과 작은 값을 구분한다.
    cmp eax, edx
    jge CNM_XGreater

    ; x < y이면 y - x
    sub edx, eax
    mov eax, edx
    jmp CNM_Check

CNM_XGreater:
    ; x >= y이면 x - y
    sub eax, edx

CNM_Check:
    ; diff는 음수가 아닌 허용 최대 차이라고 가정한다.
    cmp eax, diff
    ja CNM_Next
    inc ebx

CNM_Next:
    add esi, TYPE SDWORD
    add edi, TYPE SDWORD
    dec ecx
    jmp CNM_Loop

CNM_Done:
    mov eax, ebx
    ret
CountNearMatches ENDP

END main
```

**풀이:**

1. `ESI`와 `EDI`는 두 배열의 현재 원소를 가리키고, `ECX`는 남은 원소 수를 나타낸다.
2. `EBX`는 차이가 허용 범위 안에 들어오는 원소 쌍의 개수를 저장한다.
3. 두 값을 부호 있는 비교(`JGE`)로 비교하여 어느 쪽이 큰지 결정한다.
4. 큰 값에서 작은 값을 빼면 두 값 사이의 절댓값 차이를 구할 수 있다. 이 방식은 음수 값이 포함된 배열도 처리한다.
5. 계산한 차이를 `diff`와 비교한다. 차이가 diff보다 크면 카운트를 증가시키지 않고, diff 이하이면 EBX를 1 증가시킨다.
6. 모든 원소를 확인한 후 EBX의 값을 EAX로 옮겨 반환한다.
7. 이 예제에서는 diff가 0 이상의 값이라고 가정한다. 문제 문장 마지막의 `CountMatches PROTO`는 프로시저 이름과 맞지 않으므로 `CountNearMatches PROTO`로 작성했다.

---

## 10. Show Procedure Parameters

Write a procedure named ShowParams that displays the address and hexadecimal value of the 32-bit parameters on the runtime stack of the procedure that called it. The parameters are to be displayed in order from the lowest address to the highest. Input to the procedure will be a single integer that indicates the number of parameters to display. For example, suppose the following statement in main calls MySample, passing three arguments: INVOKE MySample, 1234h, 5000h, 6543h Next, inside MySample, you should be able to call ShowParams, passing the number of parameters you want to display: MySample PROC first:DWORD, second:DWORD, third:DWORD paramCount = 3 call ShowParams, paramCount ShowParams should display output in the following format: Stack parameters:

---

Address 0012FF80 = 00001234
Address 0012FF84 = 00005000
Address 0012FF88 = 00006543

**한글 해석:**

ShowParams라는 프로시저를 작성하시오. 이 프로시저는 자신을 호출한 프로시저의 런타임 스택에 있는 32비트 매개변수의 주소와 16진수 값을 출력한다. 매개변수는 가장 낮은 주소부터 가장 높은 주소 순서로 출력해야 한다.

프로시저의 입력은 출력할 매개변수의 개수를 나타내는 정수 하나이다.

예를 들어 main에서 다음과 같이 세 개의 인수를 전달하여 MySample을 호출한다고 가정한다.

```asm
INVOKE MySample, 1234h, 5000h, 6543h
```

그다음 MySample 내부에서 출력할 매개변수의 개수를 전달하여 ShowParams를 호출할 수 있어야 한다.

```asm
MySample PROC first:DWORD, second:DWORD, third:DWORD
paramCount = 3
INVOKE ShowParams, paramCount
```

ShowParams는 다음과 같은 형식으로 출력해야 한다.

```text
Stack parameters:
---------------------------
Address 0012FF80 = 00001234
Address 0012FF84 = 00005000
Address 0012FF88 = 00006543
```

**답:**

```asm
INCLUDE Irvine32.inc

MySample PROTO, first:DWORD, second:DWORD, third:DWORD
ShowParams PROTO, paramCount:DWORD

.data
heading BYTE "Stack parameters:",0
separator BYTE "---------------------------",0
addressText BYTE "Address ",0
equalsText BYTE " = ",0

.code
main PROC
    INVOKE MySample, 1234h, 5000h, 6543h
    exit
main ENDP

MySample PROC USES eax,
    first:DWORD,
    second:DWORD,
    third:DWORD

    INVOKE ShowParams, 3
    ret
MySample ENDP

ShowParams PROC USES ebx esi edx,
    paramCount:DWORD

    ; ShowParams의 EBP 프레임에서
    ; [EBP]는 호출한 MySample의 EBP 값이다.
    mov esi, [ebp]
    add esi, 8                    ; MySample의 첫 번째 매개변수 주소

    mov edx, OFFSET heading
    call WriteString
    call Crlf

    mov edx, OFFSET separator
    call WriteString
    call Crlf

    mov ebx, paramCount

SP_Loop:
    cmp ebx, 0
    je SP_Done

    ; 매개변수의 주소 출력
    mov edx, OFFSET addressText
    call WriteString
    mov eax, esi
    call WriteHex

    ; 등호와 매개변수 값 출력
    mov edx, OFFSET equalsText
    call WriteString
    mov eax, [esi]
    call WriteHex
    call Crlf

    add esi, TYPE DWORD
    dec ebx
    jmp SP_Loop

SP_Done:
    ret
ShowParams ENDP

END main
```

**풀이:**

1. `MySample`이 호출되면 프로시저의 스택 프레임에 매개변수가 저장된다. 일반적인 32비트 MASM 프로시저 프레임에서 첫 번째 매개변수는 `[EBP+8]`, 두 번째는 `[EBP+12]`, 세 번째는 `[EBP+16]`에 위치한다.
2. `ShowParams`가 호출되면 ShowParams 자체의 스택 프레임이 만들어진다. 이때 ShowParams의 `[EBP]`에는 호출자인 MySample의 이전 EBP 값이 저장된다.
3. 따라서 `mov esi, [ebp]`로 호출자 MySample의 EBP 값을 얻을 수 있다.
4. MySample의 첫 번째 매개변수는 호출자 EBP 기준으로 8바이트 위에 있으므로 `add esi, 8`을 실행한다.
5. `ESI`는 매개변수의 주소를 가리킨다. `WriteHex`로 ESI를 출력하면 주소가 8자리 16진수로 표시된다.
6. `[ESI]`에 저장된 값을 EAX로 옮겨 `WriteHex`로 출력한다.
7. 다음 매개변수는 4바이트 뒤에 있으므로 ESI에 4를 더하고, 지정된 개수만큼 반복한다.
8. 매개변수는 주소가 낮은 순서부터 출력되며, 실제 주소값은 실행 환경과 스택 배치에 따라 달라진다. 문제에 제시된 주소는 출력 형식의 예시이다.
9. 호출 구문은 MASM에서 매개변수를 전달하는 `INVOKE ShowParams, 3`을 사용했다. 문제 예시의 `call ShowParams, paramCount`는 일반적인 MASM `CALL` 문법이 아니므로 `INVOKE`로 작성했다.
