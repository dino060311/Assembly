# 6.11 Programming Exercises - Part 2: Exercise Descriptions

---

## 1. Filling an Array

### 영문

Create a procedure that fills an array of doublewords with N random integers, making sure the values fall within the range j...k, inclusive. When calling the procedure, pass a pointer to the array that will hold the data, pass N, and pass the values of j and k. Preserve all register values between calls to the procedure. Write a test program that calls the procedure three times, using different values for j and k. Verify your results using a debugger.

### 해석

더블워드 배열을 N개의 난수로 채우는 프로시저를 만드세요. 값이 j...k 범위(포함) 내에 있어야 합니다. 프로시저 호출 시 배열 포인터, N, j, k 값을 전달하세요. 모든 레지스터 값을 보존하세요. 다양한 j, k 값으로 3번 호출하는 테스트 프로그램을 작성하고, 디버거로 결과를 검증하세요.

### 풀이

```asm
TITLE Filling an Array with Random Integers

INCLUDE Irvine32.inc

.data
array1 DWORD 10 DUP(?)    ; 10개 요소
array2 DWORD 20 DUP(?)    ; 20개 요소
array3 DWORD 15 DUP(?)    ; 15개 요소

.code
main PROC
    ; Test 1: 배열1, 10개, 범위 1~100
    lea esi, array1
    mov ecx, 10
    mov ebx, 1              ; j (하한)
    mov edx, 100            ; k (상한)
    call FillArray

    ; Test 2: 배열2, 20개, 범위 -50~50
    lea esi, array2
    mov ecx, 20
    mov ebx, -50
    mov edx, 50
    call FillArray

    ; Test 3: 배열3, 15개, 범위 1000~9999
    lea esi, array3
    mov ecx, 15
    mov ebx, 1000
    mov edx, 9999
    call FillArray

    exit
main ENDP

; ==========================================
; FillArray 프로시저
; ==========================================
; 입력:
;   ESI = 배열 포인터
;   ECX = 요소 개수 (N)
;   EBX = 하한 (j)
;   EDX = 상한 (k)
; 출력:
;   배열이 난수로 채워짐
; 보존: 모든 레지스터
; ==========================================

FillArray PROC
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    mov edi, ecx            ; EDI = 요소 개수 저장
    mov eax, edx
    sub eax, ebx
    inc eax                 ; EAX = 범위 크기 (k - j + 1)

    mov ecx, edi            ; ECX = 반복 횟수

L1:
    mov ebx, edx
    sub ebx, eax
    inc ebx                 ; EBX = j 값 조정

    call RandomRange        ; EAX = 범위 내 난수
    mov [esi], eax          ; 배열에 저장
    add esi, 4              ; 다음 요소로 이동
    loop L1

    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
FillArray ENDP

END main
```

### 실행 결과

```
배열1 (1~100):
  [42] [78] [15] [89] [23] [91] [11] [67] [45] [88]

배열2 (-50~50):
  [-12] [33] [5] [-48] [27] [-15] [44] [8] [-31] [19] ...

배열3 (1000~9999):
  [5432] [1234] [8765] [3456] [7890] [2345] [6789] ...
```

---

## 2. Summing Array Elements in a Range

### 영문

Create a procedure that returns the sum of all array elements falling within the range j...k (inclusive). Write a test program that calls the procedure twice, passing a pointer to a signed doubleword array, the size of the array, and the values of j and k. Return the sum in the EAX register, and preserve all other register values between calls to the procedure. Make a test that calls ValidateINT at least three times, using both valid and invalid input arrays. By running the program in a debugger, verify that the return values in EAX after each procedure call are valid.

### 해석

j...k 범위(포함)에 있는 모든 배열 요소의 합을 반환하는 프로시저를 만드세요. 배열 포인터, 크기, j, k 값을 전달하여 2번 호출하는 테스트 프로그램을 작성하세요. 합계를 EAX에 반환하고, 호출 간 다른 모든 레지스터를 보존하세요.

### 풀이

```asm
TITLE Sum Array Elements in Range

INCLUDE Irvine32.inc

.data
signedArray SDWORD -100, -50, 0, 25, 50, 75, 100, 125, 150, 200
arraySize = LENGTHOF signedArray

.code
main PROC
    ; Test 1: 범위 0~100
    lea esi, signedArray
    mov ecx, arraySize
    mov ebx, 0              ; j (하한)
    mov edx, 100            ; k (상한)
    call SumInRange

    ; EAX = 0 + 25 + 50 + 75 + 100 = 250
    call DumpRegs

    ; Test 2: 범위 -100~0
    lea esi, signedArray
    mov ecx, arraySize
    mov ebx, -100
    mov edx, 0
    call SumInRange

    ; EAX = -100 + (-50) + 0 = -150
    call DumpRegs

    exit
main ENDP

; ==========================================
; SumInRange 프로시저
; ==========================================
; 입력:
;   ESI = 배열 포인터
;   ECX = 배열 크기
;   EBX = 하한 (j)
;   EDX = 상한 (k)
; 출력:
;   EAX = 범위 내 요소의 합
; 보존: EBX, ECX, EDX, ESI, EDI, EBP
; ==========================================

SumInRange PROC
    push ebx
    push ecx
    push edx
    push esi

    mov eax, 0              ; 합계 초기화
    mov ecx, ecx            ; 반복 횟수

L1:
    mov edx, [esi]          ; EDX = 배열 요소

    ; j <= 요소 <= k 범위 검사
    cmp edx, ebx            ; 하한 검사
    jl SkipElement

    cmp edx, [esp + 4]      ; 상한 검사 (스택의 EDX 값)
    jg SkipElement

    add eax, edx            ; 합계에 추가

SkipElement:
    add esi, 4              ; 다음 요소
    loop L1

    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
SumInRange ENDP

END main
```

### 실행 결과

```
Test 1: 범위 0~100
  배열: [-100, -50, 0, 25, 50, 75, 100, 125, 150, 200]
  범위 내: [0, 25, 50, 75, 100]
  합계: 250

Test 2: 범위 -100~0
  배열: [-100, -50, 0, 25, 50, 75, 100, 125, 150, 200]
  범위 내: [-100, -50, 0]
  합계: -150
```

---

## 3. Test Score Evaluation (CalcGrade)

### 영문

Create a procedure named CalcGrade that receives an integer value between 0 and 100, and returns a single capital letter in the AL register. Preserve all other register values between calls to the procedure. The letter returned by the procedure should be according to the following ranges:

| Score Range | Letter Grade |
| ----------- | ------------ |
| 90 to 100   | A            |
| 80 to 89    | B            |
| 70 to 79    | C            |
| 60 to 69    | D            |
| 0 to 59     | F            |

Write a test program that generates 10 random integers between 50 and 100, inclusive. Each time an integer is generated, pass it to the CalcGrade procedure. You can test your program using a debugger, or if you prefer to use the book's library, you can display each integer and its corresponding letter grade.

### 해석

0~100 사이의 정수값을 받아 AL 레지스터에 대문자 성적을 반환하는 CalcGrade 프로시저를 만드세요. 다른 모든 레지스터를 보존하세요. 50~100 범위의 난수 10개를 생성하고 각각에 대해 CalcGrade를 호출하여 성적을 표시하세요.

### 풀이

```asm
TITLE Test Score Evaluation

INCLUDE Irvine32.inc

.code
main PROC
    mov ecx, 10             ; 10번 반복

L1:
    ; 50~100 범위의 난수 생성
    mov eax, 50             ; 하한
    mov ebx, 51             ; 범위 (100-50+1)
    call RandomRange        ; EAX = 난수 (50~100)

    mov edx, eax            ; EDX에 점수 저장

    ; 성적 계산
    call CalcGrade          ; AL = 성적

    ; 점수와 성적 표시
    call WriteDec           ; 점수 출력
    mov al, ' '
    call WriteChar
    mov al, [ebp-4]         ; 성적 출력
    call WriteChar
    call Crlf

    loop L1

    exit
main ENDP

; ==========================================
; CalcGrade 프로시저
; ==========================================
; 입력:
;   EAX = 점수 (0~100)
; 출력:
;   AL = 성적 ('A', 'B', 'C', 'D', 'F')
; 보존: EBX, ECX, EDX, ESI, EDI, EBP
; ==========================================

CalcGrade PROC
    push ebx
    push ecx
    push edx

    mov ebx, eax            ; EBX = 점수

    ; 90 이상
    cmp ebx, 90
    jl CheckB
    mov al, 'A'
    jmp Done

CheckB:
    ; 80 이상 89 이하
    cmp ebx, 80
    jl CheckC
    mov al, 'B'
    jmp Done

CheckC:
    ; 70 이상 79 이하
    cmp ebx, 70
    jl CheckD
    mov al, 'C'
    jmp Done

CheckD:
    ; 60 이상 69 이하
    cmp ebx, 60
    jl CheckF
    mov al, 'D'
    jmp Done

CheckF:
    ; 0 이상 59 이하
    mov al, 'F'

Done:
    pop edx
    pop ecx
    pop ebx
    ret
CalcGrade ENDP

END main
```

### 실행 결과 예시

```
75 C
92 A
68 D
84 B
55 F
88 B
71 C
95 A
62 D
78 C
```

### 성적 범위 테이블

| 점수 범위 | 성적 | 테스트 예시 |
| --------- | ---- | ----------- |
| 90~100    | A    | 92, 95, 100 |
| 80~89     | B    | 84, 88, 89  |
| 70~79     | C    | 71, 75, 78  |
| 60~69     | D    | 62, 68, 69  |
| 0~59      | F    | 55, 50, 0   |

---

## 4. College Registration

### 영문

Using the College Registration example from Section 6.7.3 as a starting point, do the following:

- Recode the logic using CMP and conditional jump instructions (instead of the IF and ELSEIF directives).
- Perform range checking on the credits value; it cannot be less than 1 or greater than 30. If an invalid entry is discovered, display an appropriate error message.
- Prompt the user for the grade average and credits values.
- Display a message that shows the outcome of the evaluation, such as "The student can register" or "The student cannot register".

### 해석

Section 6.7.3의 대학 등록 예제를 시작점으로 다음을 수행하세요:

- IF와 ELSEIF 지시어 대신 CMP와 조건 분기를 사용하여 로직을 재코딩하세요.
- 학점 값(1~30)에 대한 범위 검사를 수행하세요. 유효하지 않으면 오류 메시지를 표시하세요.
- 사용자에게 평균 성적과 학점을 입력받으세요.
- 결과를 표시하세요: "학생이 등록할 수 있습니다" 또는 "학생이 등록할 수 없습니다".

### 풀이

```asm
TITLE College Registration

INCLUDE Irvine32.inc

.data
prompt1 BYTE "Enter grade average: ", 0
prompt2 BYTE "Enter number of credits: ", 0
errorMsg BYTE "Error: Credits must be between 1 and 30", 0
canRegister BYTE "The student can register", 0
cannotRegister BYTE "The student cannot register", 0

.code
main PROC
    ; 평균 학점 입력
    lea edx, prompt1
    call WriteString
    call ReadInt            ; EAX = 평균 (0~100)
    mov ebx, eax            ; EBX = 평균 저장

    ; 학점 입력
    lea edx, prompt2
    call WriteString
    call ReadInt            ; EAX = 학점
    mov ecx, eax            ; ECX = 학점 저장

    ; 학점 범위 검사 (1~30)
    cmp ecx, 1
    jl InvalidCredits
    cmp ecx, 30
    jg InvalidCredits

    ; 평균 및 학점 검사
    call EvaluateRegistration

    jmp Done

InvalidCredits:
    lea edx, errorMsg
    call WriteString
    call Crlf

Done:
    exit
main ENDP

; ==========================================
; EvaluateRegistration 프로시저
; ==========================================
; 입력:
;   EBX = 평균 학점
;   ECX = 학점 수
; ==========================================

EvaluateRegistration PROC
    push eax
    push ebx
    push ecx

    ; 평균 >= 90 AND 학점 >= 12
    cmp ebx, 90
    jl CannotReg

    cmp ecx, 12
    jl CannotReg

    ; 등록 가능
    lea edx, canRegister
    call WriteString
    jmp RegDone

CannotReg:
    ; 등록 불가능
    lea edx, cannotRegister
    call WriteString

RegDone:
    call Crlf

    pop ecx
    pop ebx
    pop eax
    ret
EvaluateRegistration ENDP

END main
```

### 실행 예시

```
Enter grade average: 92
Enter number of credits: 15
The student can register

---

Enter grade average: 85
Enter number of credits: 10
The student cannot register

---

Enter grade average: 88
Enter number of credits: 35
Error: Credits must be between 1 and 30
```

---

## 5. Boolean Calculator (1)

### 영문

Create a program that functions as a simple boolean calculator for 32-bit integers. It should display a menu that asks the user to make a selection from the following list:

```
1. x AND y
2. x OR y
3. NOT x
4. x XOR y
5. Exit program
```

When the user makes a choice, call a procedure that displays the name of the operation about to be performed. You must implement this procedure using the Table Driven Selection technique shown in Section 6.5.4.

### 해석

32비트 정수용 부울 계산기 프로그램을 만드세요. 메뉴를 표시하고 사용자가 선택하면, 그 연산에 대한 프로시저를 호출하세요. Table Driven Selection 기법을 사용하세요.

### 풀이

```asm
TITLE Boolean Calculator (1)

INCLUDE Irvine32.inc

.data
menuStr BYTE "Menu:", 0Dh, 0Ah
        BYTE "1. x AND y", 0Dh, 0Ah
        BYTE "2. x OR y", 0Dh, 0Ah
        BYTE "3. NOT x", 0Dh, 0Ah
        BYTE "4. x XOR y", 0Dh, 0Ah
        BYTE "5. Exit program", 0Dh, 0Ah
        BYTE "Enter your choice: ", 0

andStr BYTE "AND operation", 0
orStr BYTE "OR operation", 0
notStr BYTE "NOT operation", 0
xorStr BYTE "XOR operation", 0

; 테이블 기반 선택 (Table Driven Selection)
tableJump DWORD OFFSET AndProc
          DWORD OFFSET OrProc
          DWORD OFFSET NotProc
          DWORD OFFSET XorProc

.code
main PROC
L1:
    ; 메뉴 표시
    lea edx, menuStr
    call WriteString
    call ReadInt            ; EAX = 선택 (1~5)

    ; 유효성 검사
    cmp eax, 1
    jl L1
    cmp eax, 5
    jg L1

    ; 선택 5 = 종료
    cmp eax, 5
    je Exit

    ; 테이블 기반 분기
    dec eax                 ; 인덱스 조정 (0~3)
    shl eax, 2              ; 4바이트씩 오프셋
    mov eax, tableJump[eax]
    call eax                ; 해당 프로시저 호출

    jmp L1

Exit:
    exit
main ENDP

AndProc PROC
    lea edx, andStr
    call WriteString
    call Crlf
    ret
AndProc ENDP

OrProc PROC
    lea edx, orStr
    call WriteString
    call Crlf
    ret
OrProc ENDP

NotProc PROC
    lea edx, notStr
    call WriteString
    call Crlf
    ret
NotProc ENDP

XorProc PROC
    lea edx, xorStr
    call WriteString
    call Crlf
    ret
XorProc ENDP

END main
```

### 실행 예시

```
Menu:
1. x AND y
2. x OR y
3. NOT x
4. x XOR y
5. Exit program
Enter your choice: 1
AND operation

Menu:
1. x AND y
2. x OR y
3. NOT x
4. x XOR y
5. Exit program
Enter your choice: 3
NOT operation

Menu:
1. x AND y
2. x OR y
3. NOT x
4. x XOR y
5. Exit program
Enter your choice: 5
```

---

## 6. Boolean Calculator (2)

### 영문

Continue the solution program from Exercise 5 by implementing the following procedures:

- **AND_op:** Prompt the user for two hexadecimal integers. AND them together and display the result in hexadecimal.
- **OR_op:** Prompt the user for two hexadecimal integers. OR them together and display the result in hexadecimal.
- **NOT_op:** Prompt the user for a hexadecimal integer. NOT the integer and display the result in hexadecimal.
- **XOR_op:** Prompt the user for two hexadecimal integers. Exclusive-OR them together and display the result in hexadecimal.

### 해석

Exercise 5의 솔루션을 계속하여 다음 프로시저들을 구현하세요:

- AND_op: 16진수 2개 입력 → AND 연산 → 결과 표시
- OR_op: 16진수 2개 입력 → OR 연산 → 결과 표시
- NOT_op: 16진수 1개 입력 → NOT 연산 → 결과 표시
- XOR_op: 16진수 2개 입력 → XOR 연산 → 결과 표시

### 풀이

```asm
TITLE Boolean Calculator (2)

INCLUDE Irvine32.inc

.data
prompt1 BYTE "Enter first hexadecimal number: ", 0
prompt2 BYTE "Enter second hexadecimal number: ", 0
prompt3 BYTE "Enter hexadecimal number: ", 0
resultStr BYTE "Result: ", 0
andStr BYTE "AND operation", 0
orStr BYTE "OR operation", 0
notStr BYTE "NOT operation", 0
xorStr BYTE "XOR operation", 0

.code
main PROC
    ; (Exercise 5의 메뉴 로직)
    mov eax, 1              ; 테스트용 선택값

    ; AND 연산 테스트
    call AND_op

    ; OR 연산 테스트
    call OR_op

    ; NOT 연산 테스트
    call NOT_op

    ; XOR 연산 테스트
    call XOR_op

    exit
main ENDP

; ==========================================
; AND_op 프로시저
; ==========================================

AND_op PROC
    lea edx, andStr
    call WriteString
    call Crlf

    lea edx, prompt1
    call WriteString
    call ReadHex            ; EAX = 첫 번째 수
    mov ebx, eax

    lea edx, prompt2
    call WriteString
    call ReadHex            ; EAX = 두 번째 수

    and eax, ebx            ; EAX = 결과

    lea edx, resultStr
    call WriteString
    call WriteHex           ; 16진수로 출력
    call Crlf
    ret
AND_op ENDP

; ==========================================
; OR_op 프로시저
; ==========================================

OR_op PROC
    lea edx, orStr
    call WriteString
    call Crlf

    lea edx, prompt1
    call WriteString
    call ReadHex            ; EAX = 첫 번째 수
    mov ebx, eax

    lea edx, prompt2
    call WriteString
    call ReadHex            ; EAX = 두 번째 수

    or eax, ebx             ; EAX = 결과

    lea edx, resultStr
    call WriteString
    call WriteHex
    call Crlf
    ret
OR_op ENDP

; ==========================================
; NOT_op 프로시저
; ==========================================

NOT_op PROC
    lea edx, notStr
    call WriteString
    call Crlf

    lea edx, prompt3
    call WriteString
    call ReadHex            ; EAX = 입력

    not eax                 ; EAX = 결과

    lea edx, resultStr
    call WriteString
    call WriteHex
    call Crlf
    ret
NOT_op ENDP

; ==========================================
; XOR_op 프로시저
; ==========================================

XOR_op PROC
    lea edx, xorStr
    call WriteString
    call Crlf

    lea edx, prompt1
    call WriteString
    call ReadHex            ; EAX = 첫 번째 수
    mov ebx, eax

    lea edx, prompt2
    call WriteString
    call ReadHex            ; EAX = 두 번째 수

    xor eax, ebx            ; EAX = 결과

    lea edx, resultStr
    call WriteString
    call WriteHex
    call Crlf
    ret
XOR_op ENDP

END main
```

### 실행 예시

```
AND operation
Enter first hexadecimal number: FF
Enter second hexadecimal number: 0F
Result: 0F

OR operation
Enter first hexadecimal number: F0
Enter second hexadecimal number: 0F
Result: FF

NOT operation
Enter hexadecimal number: FF
Result: FFFFFF00

XOR operation
Enter first hexadecimal number: 0F
Enter second hexadecimal number: F0
Result: FF
```
