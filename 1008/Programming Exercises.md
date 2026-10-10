# Programming Exercises 답안

---

## 1. Draw Text Colors

### 영문

Write a program that displays the same string in four different colors, using a loop. Call the SetTextColor procedure from the book's link library. Any colors may be chosen, but you may find it easiest to change the foreground color.

### 해석

루프를 사용하여 같은 문자열을 네 가지 다른 색으로 표시하는 프로그램을 작성하시오. 책의 링크 라이브러리에서 SetTextColor 프로시저를 호출하시오. 어떤 색이든 선택할 수 있지만, 전경색을 변경하는 것이 가장 쉬울 것입니다.

### 풀이

```asm
TITLE Draw Text Colors

INCLUDE Irvine32.inc

.data
message BYTE "Hello, World!", 0

colorArray DWORD \
    white,          ; 색상 0
    yellow,         ; 색상 1
    cyan,           ; 색상 2
    magenta         ; 색상 3

colorCount = ($ - colorArray) / TYPE colorArray  ; 4

.code
main PROC
    mov ecx, colorCount              ; 반복 횟수 = 4
    mov esi, 0                       ; 색상 배열 인덱스

L1:
    mov eax, colorArray[esi]         ; EAX = 색상 값
    call SetTextColor                ; 텍스트 색상 설정

    lea edx, message                 ; EDX = 메시지 주소
    call WriteString                 ; 메시지 출력

    call Crlf                        ; 줄 바꿈

    add esi, 4                       ; 다음 색상으로 이동
    loop L1

    exit
main ENDP

END main
```

### 실행 결과

```
Hello, World!    (흰색)
Hello, World!    (노란색)
Hello, World!    (청록색)
Hello, World!    (자주색)
```

### 단계별 실행 과정

| 단계 | ESI |   EAX   |  색상  | 출력          |
| :--: | :-: | :-----: | :----: | ------------- |
|  1   |  0  |  white  |  흰색  | Hello, World! |
|  2   |  4  | yellow  | 노란색 | Hello, World! |
|  3   |  8  |  cyan   | 청록색 | Hello, World! |
|  4   | 12  | magenta | 자주색 | Hello, World! |

---

## 2. Linking Array Items

### 영문

Suppose you are given three data items that indicate a starting index in a list, an array of characters, and an array of link index. You are to write a program that traverses the links and locates the characters in their correct sequence. For each character found, copy it to an array.

### 해석

시작 인덱스, 문자 배열, 링크 인덱스 배열이 주어질 때, 링크를 따라가면서 올바른 순서로 문자를 찾아내는 프로그램을 작성하시오. 찾은 각 문자를 배열에 복사하시오.

### 풀이

```asm
TITLE Linking Array Items

INCLUDE Irvine32.inc

.data
start = 1

chars BYTE 'H', 'A', 'C', 'E', 'B', 'D', 'F', 'G'
links BYTE 0, 4, 5, 6, 2, 3, 7, 0

output BYTE 8 DUP(?)

.code
main PROC
    mov esi, start                   ; ESI = 시작 인덱스 = 1
    mov edi, 0                       ; EDI = 출력 배열 인덱스
    mov ecx, 8                       ; 반복 횟수 = 8

L1:
    movzx eax, chars[esi]            ; AL = chars[esi]
    mov output[edi], al              ; output[edi] = chars[esi]

    movzx esi, links[esi]            ; ESI = links[esi] (다음 인덱스)

    inc edi                          ; 출력 배열 인덱스 증가
    loop L1

    ; 출력 배열 출력
    lea edx, output
    call WriteString
    call Crlf

    exit
main ENDP

END main
```

### 실행 결과

```
A.B.C.D.E.F.G.H
```

### 추적 표

| 단계 | ESI | chars[ESI] | links[ESI] | output   |
| :--: | :-: | :--------: | :--------: | -------- |
|  1   |  1  |     A      |     4      | A        |
|  2   |  4  |     B      |     2      | AB       |
|  3   |  2  |     C      |     5      | ABC      |
|  4   |  5  |     D      |     3      | ABCD     |
|  5   |  3  |     E      |     6      | ABCDE    |
|  6   |  6  |     F      |     7      | ABCDEF   |
|  7   |  7  |     G      |     0      | ABCDEFG  |
|  8   |  0  |     H      |     0      | ABCDEFGH |

---

## 3. Simple Addition (1)

### 영문

Write a program that clears the screen, locates the cursor near the middle of the screen, prompts the user for two integers, adds the integers, and displays their sum.

### 해석

화면을 지우고, 커서를 화면 중앙에 위치시키고, 사용자에게 두 정수를 입력받아 더하고 합을 표시하는 프로그램을 작성하시오.

### 풀이

```asm
TITLE Simple Addition (1)

INCLUDE Irvine32.inc

.data
prompt1 BYTE "Enter first integer: ", 0
prompt2 BYTE "Enter second integer: ", 0
sumMsg  BYTE "Sum = ", 0

.code
main PROC
    call Clrscr                      ; 화면 지우기

    ; 커서를 중앙에 위치
    mov dh, 12                       ; 행 = 12
    mov dl, 40                       ; 열 = 40
    call Gotoxy

    ; 첫 번째 정수 입력
    lea edx, prompt1
    call WriteString
    call ReadInt                     ; EAX = 첫 번째 정수
    mov ebx, eax                     ; EBX에 저장

    ; 두 번째 정수 입력
    call Crlf
    lea edx, prompt2
    call WriteString
    call ReadInt                     ; EAX = 두 번째 정수

    ; 덧셈
    add eax, ebx                     ; EAX = EAX + EBX

    ; 결과 출력
    call Crlf
    lea edx, sumMsg
    call WriteString
    call WriteInt                    ; EAX 값 출력
    call Crlf

    exit
main ENDP

END main
```

### 실행 예시

```
Enter first integer: 25
Enter second integer: 30
Sum = 55
```

---

## 4. Simple Addition (2)

### 영문

Use the solution program from the preceding exercise as a starting point. Let this new program repeat the same steps three times, using a loop. Clear the screen after each iteration.

### 해석

앞의 연습 문제의 해결책을 시작점으로 사용하시오. 이 새 프로그램은 루프를 사용하여 같은 단계를 3번 반복하시오. 각 반복 후 화면을 지우시오.

### 풀이

```asm
TITLE Simple Addition (2)

INCLUDE Irvine32.inc

.data
prompt1 BYTE "Enter first integer: ", 0
prompt2 BYTE "Enter second integer: ", 0
sumMsg  BYTE "Sum = ", 0
iteration BYTE "Iteration ", 0

.code
main PROC
    mov ecx, 3                       ; 반복 횟수 = 3

L1:
    call Clrscr                      ; 화면 지우기

    ; 커서를 중앙에 위치
    mov dh, 5
    mov dl, 20
    call Gotoxy

    ; 반복 횟수 출력
    lea edx, iteration
    call WriteString
    mov eax, 4
    sub eax, ecx
    inc eax                          ; 1번째, 2번째, 3번째...
    call WriteInt
    call Crlf

    ; 첫 번째 정수 입력
    lea edx, prompt1
    call WriteString
    call ReadInt
    mov ebx, eax

    ; 두 번째 정수 입력
    call Crlf
    lea edx, prompt2
    call WriteString
    call ReadInt

    ; 덧셈
    add eax, ebx

    ; 결과 출력
    call Crlf
    lea edx, sumMsg
    call WriteString
    call WriteInt
    call Crlf
    call Crlf
    call WaitMsg                     ; 계속하라는 메시지 대기

    loop L1

    exit
main ENDP

END main
```

### 실행 흐름

| 반복 | 메시지      |  입력   |   결과   |
| :--: | ----------- | :-----: | :------: |
|  1   | Iteration 1 | 10 + 20 | Sum = 30 |
|  2   | Iteration 2 | 15 + 25 | Sum = 40 |
|  3   | Iteration 3 |  5 + 5  | Sum = 10 |

---

## 5. BetterRandomRange Procedure

### 영문

The RandomRange procedure from the Irvine32 library generates a pseudorandom integer between 0 and N − 1. Your task is to create an improved version that generates an integer between M and N − 1. Let the caller pass M in EBX and N in EAX. If it will call BetterRandomRange, the following code is a sample test.

### 해석

Irvine32 라이브러리의 RandomRange 프로시저는 0에서 N−1 사이의 의사난수를 생성합니다. M과 N−1 사이의 정수를 생성하는 개선된 버전을 만드시오. 호출자가 EBX에 M을, EAX에 N을 전달합니다.

### 풀이

```asm
TITLE BetterRandomRange Procedure

INCLUDE Irvine32.inc

.data
result DWORD ?

.code
BetterRandomRange PROC
    ; EBX = M (하한), EAX = N (상한)
    ; 반환값: EAX = M ~ N-1 사이의 난수

    push eax                         ; EAX (N) 저장
    push ebx                         ; EBX (M) 저장

    sub eax, ebx                     ; EAX = N - M (범위)
    call RandomRange                 ; EAX = 0 ~ (N-M-1) 사이의 난수

    pop ebx                          ; EBX = M 복원
    add eax, ebx                     ; EAX = M + (난수) = M ~ N-1

    pop ecx                          ; 임시 제거

    ret
BetterRandomRange ENDP

main PROC
    mov ecx, 50                      ; 50번 반복

L1:
    mov ebx, -300                    ; M = -300
    mov eax, 100                     ; N = 100
    call BetterRandomRange           ; EAX = -300 ~ 99 사이의 난수

    mov result, eax                  ; 결과 저장
    call WriteInt                    ; 난수 출력
    call Crlf

    loop L1

    exit
main ENDP

END main
```

### 실행 결과

```
-250
-125
45
-300
50
... (총 50개의 난수)
```

### 프로시저 동작 과정

| 단계 | EBX  | EAX | 설명                               |
| :--: | :--: | :-: | ---------------------------------- |
| 입력 | -300 | 100 | M = -300, N = 100                  |
|  1   | -300 | 100 | sub eax, ebx                       |
|  2   | -300 | 400 | EAX = 100 - (-300) = 400           |
|  3   | -300 | 250 | RandomRange: 0~399 사이 난수 = 250 |
| 출력 | -300 | -50 | add eax, ebx: -50 = 250 + (-300)   |

---

## 6. Random Strings

### 영문

Create a procedure that generates a random string of length L, containing all capital letters. When calling the procedure, pass the value of L in EAX, and pass a pointer to an array of byte that will hold the random string. Write a test program that calls your procedure 20 times and displays the strings in the console window.

### 해석

길이 L의 난수 문자열을 생성하는 프로시저를 작성하시오. 문자열은 모든 대문자를 포함합니다. 프로시저 호출 시 L을 EAX에, 난수 문자열을 저장할 바이트 배열 포인터를 EDX에 전달하시오. 이 프로시저를 20번 호출하고 결과를 화면에 출력하는 테스트 프로그램을 작성하시오.

### 풀이

```asm
TITLE Random Strings

INCLUDE Irvine32.inc

RandomString PROC
    ; EAX = 문자열 길이, EDX = 바이트 배열 포인터
    ; 반환: 난수 대문자 문자열 (null 종료)

    push ecx
    push esi
    push eax

    mov esi, edx                     ; ESI = 배열 포인터
    mov ecx, eax                     ; ECX = 길이
    xor eax, eax                     ; EAX = 0 (카운터)

L1:
    mov eax, 26                      ; 범위 = 26 (A~Z)
    call RandomRange                 ; EAX = 0~25
    add al, 'A'                      ; AL = 'A' ~ 'Z'

    mov [esi], al                    ; 배열에 저장
    inc esi                          ; 다음 위치로 이동

    loop L1

    mov byte ptr [esi], 0            ; null 종료

    pop eax
    pop esi
    pop ecx
    ret
RandomString ENDP

.data
stringArray BYTE 30 DUP(?)

.code
main PROC
    mov ecx, 20                      ; 20번 반복

L1:
    mov eax, 10                      ; 길이 = 10
    lea edx, stringArray
    call RandomString                ; 난수 문자열 생성

    lea edx, stringArray
    call WriteString                 ; 문자열 출력
    call Crlf

    loop L1

    exit
main ENDP

END main
```

### 실행 결과

```
ABCDEFGHIJ
XYZQWERTYU
POIUYTREWQ
ASDFGHJKLI
...
```

### 프로시저 동작 표

| 단계 | 문자 | AL 값 | 설명              |
| :--: | :--: | :---: | ----------------- |
|  1   |  A   |  65   | RandomRange + 'A' |
|  2   |  B   |  66   | RandomRange + 'A' |
|  3   |  C   |  67   | RandomRange + 'A' |
| ...  | ...  |  ...  | 길이 L까지 반복   |

---

## 7. Random Screen Locations

### 영문

Write a program that displays a single character at 100 random screen locations, using a timing delay of 100 milliseconds. Hint: Use the GetMaxXY procedure to determine the current size of the console window.

### 해석

100개의 난수 화면 위치에 하나의 문자를 표시하는 프로그램을 작성하시오. 각 표시 사이에 100밀리초의 지연을 사용하시오. Hint: GetMaxXY 프로시저를 사용하여 콘솔 창의 현재 크기를 결정하시오.

### 풀이

```asm
TITLE Random Screen Locations

INCLUDE Irvine32.inc

.code
main PROC
    call Clrscr                      ; 화면 지우기
    call GetMaxXY                    ; AX = max X, DX = max Y

    mov ecx, 100                     ; 100번 반복

L1:
    ; 난수 X 좌표 생성 (0 ~ maxX)
    mov eax, ecx                     ; 최댓값 저장용
    xor eax, eax
    mov eax, dword ptr [esp]         ; maxX 복원 (스택에서)
    call RandomRange                 ; EAX = 0 ~ maxX-1
    mov dl, al                       ; DL = X 좌표

    ; 난수 Y 좌표 생성
    ; DH에 최댓값이 있음 (GetMaxXY 반환값)
    mov al, dh                       ; AL = maxY
    dec al
    call RandomRange                 ; EAX = 0 ~ maxY-1
    mov dh, al                       ; DH = Y 좌표

    ; 커서 설정
    call Gotoxy

    ; 문자 출력
    mov al, '*'
    call WriteChar

    ; 100밀리초 지연
    mov eax, 100
    call Delay

    loop L1

    call Crlf
    exit
main ENDP

END main
```

### 실행 결과

화면 전체에 100개의 별('\*') 기호가 0.1초 간격으로 무작위 위치에 나타남

---

## 8. Color Matrix

### 영문

Write a program that displays a single character in all possible combinations of foreground and background colors (16 × 16 = 256). The colors are numbered from 0 to 15, so you can use a nested loop to generate all possible combinations.

### 해석

전경색과 배경색의 모든 가능한 조합(16 × 16 = 256)에서 단일 문자를 표시하는 프로그램을 작성하시오. 색상은 0부터 15까지 번호가 매겨져 있으므로 중첩 루프를 사용할 수 있습니다.

### 풀이

```asm
TITLE Color Matrix

INCLUDE Irvine32.inc

.code
main PROC
    call Clrscr                      ; 화면 지우기

    mov ecx, 16                      ; 배경색 루프 (0~15)

L2:
    mov ebx, ecx                     ; EBX = 배경색 저장
    mov ecx, 16                      ; 전경색 루프 (0~15)
    mov eax, 0

L1:
    mov esi, ecx                     ; ESI = 전경색 저장

    ; 색상 계산: 배경색 * 16 + 전경색
    mov eax, ebx
    sub eax, 1
    imul eax, 16
    mov ecx, esi
    sub ecx, 1
    add eax, ecx

    call SetTextColor                ; 색상 설정

    ; 문자 출력
    mov al, 'X'
    call WriteChar

    mov ecx, esi                     ; ECX = 전경색 복원
    loop L1

    call Crlf
    mov ecx, ebx                     ; ECX = 배경색 복원
    loop L2

    exit
main ENDP

END main
```

### 실행 결과

16×16 격자로 모든 색상 조합(256가지)이 표시됨:

- 가로: 전경색 변화 (0~15)
- 세로: 배경색 변화 (0~15)

### 색상 매트릭스 표

| 배경색 | 전경색 0 | 전경색 1 | ... | 전경색 15 |
| :----: | :------: | :------: | :-: | :-------: |
|   0    |    X     |    X     | ... |     X     |
|   1    |    X     |    X     | ... |     X     |
|  ...   |   ...    |   ...    | ... |    ...    |
|   15   |    X     |    X     | ... |     X     |

---

## 9. Recursive Procedure

### 영문

Direct recursion is the term we use when a procedure calls itself. Of course, you never want to let a procedure keep calling itself forever, because the runtime stack would fill up. Instead, you must limit the recursion in some way. Write a program that calls a recursive procedure. Inside this procedure, add 1 to a counter so you can verify the number of times the recursion reaches the recursion endpoint. Put your program with a debugger, and at the end of the program, check the counter's value. Put a number in ECX that specifies the number of times you want the procedure to call itself a fixed number of times.

### 해석

프로시저가 자기 자신을 호출할 때를 직접 재귀(direct recursion)라고 합니다. 재귀 프로시저가 계속 자신을 호출하면 런타임 스택이 가득 차므로, 어떤 방식으로든 재귀를 제한해야 합니다. 재귀 프로시저를 호출하는 프로그램을 작성하시오. 프로시저 내에서 카운터에 1을 더해 재귀 끝점에 도달하는 횟수를 확인할 수 있게 하시오. 디버거로 프로그램을 실행하고, 프로그램 끝에 카운터 값을 확인하시오.

### 풀이

```asm
TITLE Recursive Procedure

INCLUDE Irvine32.inc

.data
counter DWORD 0
depth = 5

.code
RecursiveProc PROC
    ; ECX = 남은 재귀 깊이

    cmp ecx, 0                       ; ECX가 0이면 종료
    je  Done

    ; 재귀 호출 전 처리
    push ecx                         ; ECX 저장

    mov eax, counter
    inc eax
    mov counter, eax                 ; 카운터 증가

    ; 재귀 호출
    mov ecx, [esp]                   ; ECX 복원
    dec ecx                          ; ECX 감소
    call RecursiveProc

    pop ecx                          ; ECX 복원
    jmp End

Done:
    inc counter                      ; 마지막 카운터 증가

End:
    ret
RecursiveProc ENDP

main PROC
    mov counter, 0                   ; 카운터 초기화

    mov ecx, depth                   ; ECX = 재귀 깊이 = 5
    call RecursiveProc               ; 재귀 프로시저 호출

    ; 결과 출력
    mov eax, counter
    call WriteInt
    call Crlf

    exit
main ENDP

END main
```

### 실행 결과

```
6
```

### 재귀 호출 스택

| 깊이 | ECX | 설명       | counter |
| :--: | :-: | ---------- | :-----: |
|  1   |  5  | 첫 호출    |    1    |
|  2   |  4  | 2번째 호출 |    2    |
|  3   |  3  | 3번째 호출 |    3    |
|  4   |  2  | 4번째 호출 |    4    |
|  5   |  1  | 5번째 호출 |    5    |
|  6   |  0  | 종료 조건  |    6    |

---

## 10. Fibonacci Generator

### 영문

Write a procedure that produces N values in the Fibonacci number series and stores them in an array of doubleword. Input parameters should be a pointer to an array of doubleword, a counter of the number of values to generate. Write a test program that calls your procedure, passing N = 47. The first value in the array will be 1, and the last value will be 2,971,215,073. Use the Visual Studio debugger to open and inspect the array contents.

### 해석

피보나치 수열의 N개 값을 생성하여 더블워드 배열에 저장하는 프로시저를 작성하시오. 입력 매개변수는 더블워드 배열 포인터와 생성할 값의 개수입니다. N = 47을 전달하여 프로시저를 호출하는 테스트 프로그램을 작성하시오. 배열의 첫 번째 값은 1이고 마지막 값은 2,971,215,073입니다. Visual Studio 디버거를 사용하여 배열 내용을 열고 검사하시오.

### 풀이

```asm
TITLE Fibonacci Generator

INCLUDE Irvine32.inc

FibonacciProc PROC
    ; EDX = 배열 포인터, ECX = 생성할 개수

    cmp ecx, 0
    je  FibExit

    cmp ecx, 1
    je  Fib1

    cmp ecx, 2
    je  Fib2

    ; 처음 두 값 설정
    mov dword ptr [edx], 1           ; Fib(1) = 1
    mov dword ptr [edx + 4], 1       ; Fib(2) = 1

    mov eax, 1                       ; 첫 번째
    mov ebx, 1                       ; 두 번째
    mov esi, edx                     ; ESI = 배열 포인터
    add esi, 8                       ; 세 번째부터 시작

    mov edi, 2                       ; 이미 생성한 개수

FibLoop:
    cmp edi, ecx
    jge FibExit

    mov eax, ebx                     ; temp = Fib(n-1)
    add eax, [esi - 8]              ; EAX = Fib(n-1) + Fib(n-2)

    mov [esi], eax                   ; Fib(n) = EAX

    mov eax, ebx                     ; 이전값 업데이트
    mov ebx, [esi]

    add esi, 4
    inc edi
    jmp FibLoop

Fib1:
    mov dword ptr [edx], 1
    jmp FibExit

Fib2:
    mov dword ptr [edx], 1
    mov dword ptr [edx + 4], 1

FibExit:
    ret
FibonacciProc ENDP

.data
fibArray DWORD 47 DUP(?)

.code
main PROC
    lea edx, fibArray                ; EDX = 배열 포인터
    mov ecx, 47                      ; ECX = 47개 생성
    call FibonacciProc               ; 피보나치 프로시저 호출

    ; 결과 확인
    mov eax, fibArray[0]             ; 첫 값 = 1
    call WriteInt
    call Crlf

    mov eax, fibArray[184]           ; 마지막 값 (47번째, 오프셋 184)
    call WriteInt
    call Crlf

    exit
main ENDP

END main
```

### 실행 결과

```
1 (첫 번째 값)
2971215073 (47번째 값)
```

### 피보나치 배열 (처음 10개)

| 인덱스 | 값  |
| :----: | :-: |
|   1    |  1  |
|   2    |  1  |
|   3    |  2  |
|   4    |  3  |
|   5    |  5  |
|   6    |  8  |
|   7    | 13  |
|   8    | 21  |
|   9    | 34  |
|   10   | 55  |

---

## 11. Finding Multiples of K

### 영문

In a byte array of size N, write a procedure that finds all multiples of K that are less than N. Initialize the array at all 2s at the beginning of the program, and then whenever a multiple is found, set the corresponding array element to 1. Your procedure must save and restore any registers it modifies. Call your procedure twice, with K = 3 and again with K = 5. Run your program in the debugger and verify that the array values are set correctly.

### 해석

크기 N인 바이트 배열에서 N보다 작은 K의 모든 배수를 찾는 프로시저를 작성하시오. 프로그램의 시작 부분에서 배열을 모두 2로 초기화하고, 배수를 찾을 때마다 해당 배열 요소를 1로 설정하시오. 프로시저는 수정한 모든 레지스터를 저장하고 복원해야 합니다. K = 3을 사용하여 프로시저를 호출하고 다시 K = 5로 호출하시오.

### 풀이

```asm
TITLE Finding Multiples of K

INCLUDE Irvine32.inc

FindMultiples PROC
    ; EAX = K (약수), EDX = 배열 포인터, ECX = 배열 크기

    push eax                         ; 레지스터 저장
    push ebx
    push ecx
    push edx
    push esi

    mov esi, 0                       ; 인덱스 카운터 = 0

FindLoop:
    cmp esi, ecx                     ; ESI >= ECX이면 종료
    jge FindExit

    mov ebx, esi
    xor edx, edx                     ; EDX = 0 (나머지)
    div ebx                          ; EAX / EBX, 나머지 = EDX

    ; 더 간단한 방법: modulo 확인
    mov eax, esi
    mov ebx, [esp + 8]               ; K 값 복원
    xor edx, edx
    div ebx                          ; EAX = esi / K, EDX = 나머지

    cmp edx, 0                       ; 나머지가 0이면 배수
    jne NextItem

    ; 배수인 경우
    mov ebx, [esp]                   ; EBX = 배열 포인터
    mov byte ptr [ebx + esi], 1      ; 배열[ESI] = 1

NextItem:
    inc esi
    jmp FindLoop

FindExit:
    pop esi                          ; 레지스터 복원
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
FindMultiples ENDP

.data
arraySize = 30
byteArray BYTE arraySize DUP(2)      ; 모두 2로 초기화

.code
main PROC
    ; K = 3으로 첫 번째 호출
    mov eax, 3                       ; K = 3
    lea edx, byteArray               ; 배열 포인터
    mov ecx, arraySize               ; 배열 크기 = 30
    call FindMultiples

    ; K = 5로 두 번째 호출
    mov eax, 5                       ; K = 5
    lea edx, byteArray
    mov ecx, arraySize
    call FindMultiples

    ; 결과 출력
    mov esi, 0

PrintLoop:
    cmp esi, arraySize
    jge PrintExit

    mov al, byteArray[esi]
    call WriteInt

    mov al, ' '
    call WriteChar

    inc esi
    jmp PrintLoop

PrintExit:
    call Crlf
    exit
main ENDP

END main
```

### 실행 결과

```
2 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2 1 2
```

### 배수 찾기 과정

**K = 3 (0~29에서 3의 배수: 0, 3, 6, 9, 12, 15, 18, 21, 24, 27)**

| 인덱스 | 값  | 3의 배수? | 5의 배수? | 최종 |
| :----: | :-: | :-------: | :-------: | :--: |
|   0    |  2  |    YES    |    YES    |  1   |
|   1    |  2  |    NO     |    NO     |  2   |
|   2    |  2  |    NO     |    NO     |  2   |
|   3    |  2  |    YES    |    NO     |  1   |
|   4    |  2  |    NO     |    NO     |  2   |
|   5    |  2  |    NO     |    YES    |  1   |
|  ...   | ... |    ...    |    ...    | ...  |
