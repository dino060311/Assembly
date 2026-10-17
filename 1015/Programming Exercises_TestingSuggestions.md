# 6.11 Programming Exercises - Part 1: Suggestions for Testing Your Code

---

## 개요

프로그래밍 연습에서 작성한 코드를 테스트할 때 사용해야 할 모범 사례 및 제안사항입니다.

---

## 1. 디버거 사용 기본

### 영문

Always step through your program with a debugger the first time you test it. It's so easy to forget a small detail, and the debugger let's you see exactly what's going on.

### 해석

처음 테스트할 때는 항상 디버거로 프로그램을 단계별로 실행하세요. 작은 세부사항을 잊기 쉽고, 디버거는 정확히 무엇이 진행되고 있는지 볼 수 있게 해줍니다.

### 권장사항

```asm
; 디버거에서 단계별 실행(Step Into) 활용
; - F10: 다음 라인 실행
; - F11: 함수 내부로 들어가기
; - Ctrl+Shift+F5: 프로그램 재시작

main PROC
    mov eax, 10
    mov ebx, 20
    add eax, ebx      ; 여기서 F10으로 일시 중지하여 값 확인
    call DumpRegs     ; 레지스터 상태 확인
    exit
main ENDP
```

---

## 2. 부호 있는 배열 테스트

### 영문

If the specifications call for a signed array, be sure to include some negative values.

### 해석

사양에서 부호 있는 배열을 요구하면, 반드시 일부 음수 값을 포함하세요.

### 테스트 케이스

```asm
.data
; 부호 있는 배열: 양수, 음수, 0 포함
signedArray SDWORD -100, -50, 0, 50, 100, -200, 75

.code
main PROC
    mov esi, OFFSET signedArray
    mov ecx, LENGTHOF signedArray  ; 7개 요소
    mov eax, 0                      ; 합계

L1:
    add eax, [esi]                  ; 부호 있는 덧셈
    add esi, 4
    loop L1

    call DumpRegs                   ; EAX 결과 확인 (-175)
    exit
main ENDP
```

### 테스트 항목

| 테스트 항목 | 예시 값          |
| ----------- | ---------------- |
| 모두 양수   | {1, 5, 10}       |
| 모두 음수   | {-1, -5, -10}    |
| 혼합        | {-10, 5, -3, 20} |
| 0 포함      | {0, 10, -5, 0}   |

---

## 3. 입력 범위 경계값 테스트

### 영문

When a range of input values is specified, include test data that falls before, on, and after these boundaries.

### 해석

입력값의 범위가 지정되면, 이 경계 전, 경계상, 경계 후에 떨어진 테스트 데이터를 포함하세요.

### 테스트 케이스

```asm
; 범위 지정: 1 ≤ N ≤ 100

.data
testValues SDWORD -5, 0, 1, 50, 100, 101, 150

.code
main PROC
    ; 각 값에 대해 범위 검사
    mov ecx, LENGTHOF testValues
    mov esi, 0

L1:
    mov eax, testValues[esi]

    ; 범위 검사: 1 ≤ EAX ≤ 100
    cmp eax, 1
    jl OutOfRange        ; < 1: 범위 미만
    cmp eax, 100
    jg OutOfRange        ; > 100: 범위 초과

    ; 범위 내 처리
    mov edx, 1
    jmp Next

OutOfRange:
    mov edx, 0           ; 범위 외

Next:
    add esi, 4
    loop L1

    exit
main ENDP
```

### 경계값 테이블

| 경계 유형 | 범위 1~100  | 테스트 값 |
| --------- | ----------- | --------- |
| 범위 미만 | < 1         | -5, 0     |
| 하한 경계 | = 1         | 1         |
| 범위 내   | 1 < N < 100 | 50        |
| 상한 경계 | = 100       | 100       |
| 범위 초과 | > 100       | 101, 150  |

---

## 4. 다양한 길이의 배열 테스트

### 영문

Create multiple test cases, using arrays of different lengths.

### 해석

다양한 길이의 배열을 사용하여 여러 테스트 케이스를 만드세요.

### 테스트 코드

```asm
.data
; 서로 다른 길이의 배열들
array1 DWORD 10              ; 길이 1
array2 DWORD 10, 20          ; 길이 2
array3 DWORD 10, 20, 30      ; 길이 3
array10 DWORD 1,2,3,4,5,6,7,8,9,10  ; 길이 10
array100 DWORD 100 DUP(?)    ; 길이 100

.code
main PROC
    ; Test 1: 길이 1 배열
    lea esi, array1
    mov ecx, 1
    call ProcessArray

    ; Test 2: 길이 10 배열
    lea esi, array10
    mov ecx, 10
    call ProcessArray

    ; Test 3: 길이 100 배열
    lea esi, array100
    mov ecx, 100
    call ProcessArray

    exit
main ENDP

ProcessArray PROC
    ; ECX = 배열 길이, ESI = 배열 포인터
    mov eax, 0              ; 합계
L1:
    add eax, [esi]
    add esi, 4
    loop L1

    call DumpRegs
    ret
ProcessArray ENDP
```

---

## 5. Visual Studio 디버거 활용

### 영문

When you've written a program that writes to an array, the Visual Studio debugger is the best tool for evaluating your program's correctness. Use the debugger's Memory window to display the array, choosing either hexadecimal or decimal representation.

### 해석

배열에 쓰는 프로그램을 작성했을 때, Visual Studio 디버거는 프로그램의 정확성을 평가하기에 가장 좋은 도구입니다. 디버거의 메모리 창을 사용하여 배열을 표시하고, 16진수 또는 10진수 표현을 선택할 수 있습니다.

### 디버거 사용 방법

| 기능        | 방법                         | 용도                    |
| ----------- | ---------------------------- | ----------------------- |
| 메모리 보기 | Debug > Windows > Memory     | 배열 메모리 직접 검사   |
| 조사식      | Debug > Windows > Watch      | 변수 값 실시간 모니터링 |
| 로컬 변수   | Debug > Windows > Locals     | 로컬 레지스터/변수 추적 |
| 호출 스택   | Debug > Windows > Call Stack | 함수 호출 순서 확인     |

### 메모리 창 설정

```
메모리 주소: array (배열 시작 주소)
형식: 선택
- 1바이트 (BYTE)
- 2바이트 (WORD)
- 4바이트 (DWORD)
- 표시 진법: 10진수 또는 16진수
```

### 배열 검사 예시

```asm
.data
myArray DWORD 10, 20, 30, 40, 50

.code
main PROC
    ; 디버거: 메모리 창에서 myArray 주소 입력
    ; 0x00401000: 0A 00 00 00 14 00 00 00 1E 00 00 00 28 00 00 00 32 00 00 00
    ; (10진수로 보기)

    mov esi, OFFSET myArray
    mov eax, [esi]        ; EAX = 10 (여기서 일시 중지)

    exit
main ENDP
```

---

## 6. 프로시저 호출 시 레지스터 보존 검증

### 영문

Immediately after calling the procedure you're testing, call it a second time to verify that the procedure has preserved all registers. Here's an example:

```asm
mov esi,OFFSET array
mov ecx,count
call CalcSum ; returns sum in EAX
call CalcSum ; call second time to see if registers are preserved
```

### 해석

테스트 중인 프로시저를 호출한 직후, 프로시저가 모든 레지스터를 보존했는지 확인하기 위해 두 번째로 호출하세요.

### 테스트 코드

```asm
.data
myArray DWORD 10, 20, 30, 40, 50
count = LENGTHOF myArray

.code
main PROC
    ; 첫 번째 호출 전 레지스터 초기화
    mov esi, OFFSET myArray
    mov ecx, count
    mov ebx, 12345678h    ; 보존되어야 할 값
    mov edx, 87654321h    ; 보존되어야 할 값

    call CalcSum          ; EAX에 합계 반환

    ; 검증: EBX, EDX, ESI, ECX이 변경되지 않았나?
    cmp ebx, 12345678h
    jne RegisterNotPreserved

    cmp edx, 87654321h
    jne RegisterNotPreserved

    ; 두 번째 호출로 재검증
    call CalcSum          ; 동일한 결과 반환하나?

    jmp Success

RegisterNotPreserved:
    mov eax, 0            ; 오류 상태
    jmp Done

Success:
    mov eax, 1            ; 성공 상태

Done:
    exit
main ENDP

CalcSum PROC
    ; ECX = 요소 개수, ESI = 배열 포인터
    ; 반환: EAX = 합계
    ; 보존: EBX, ECX, EDX, ESI, EDI, EBP, ESP

    push ebx              ; 레지스터 보존
    push ecx
    push edx
    push esi

    mov eax, 0            ; 합계 초기화
    mov ecx, count
    mov esi, OFFSET myArray

L1:
    add eax, [esi]
    add esi, 4
    loop L1

    pop esi               ; 레지스터 복원
    pop edx
    pop ecx
    pop ebx

    ret
CalcSum ENDP
```

### 레지스터 보존 검증 표

| 검사 항목           | 확인 방법            | 예상 결과 |
| ------------------- | -------------------- | --------- |
| 첫 번째 호출 후 EBX | `cmp ebx, 12345678h` | 같음      |
| 첫 번째 호출 후 EDX | `cmp edx, 87654321h` | 같음      |
| 두 번째 호출 결과   | EAX 값 동일          | 동일      |

---

## 7. EAX 반환값 관례 주의

### 영문

Usually there is a single return value in EAX, which of course, cannot be preserved. For that reason, you usually should not use EAX as an input parameter.

### 해석

보통 단일 반환값이 EAX에 있으므로 EAX는 보존할 수 없습니다. 그 이유로 일반적으로 EAX를 입력 매개변수로 사용하지 않아야 합니다.

### 올바른 예시

```asm
.code
main PROC
    ; EAX를 입력으로 사용하지 않음
    mov esi, OFFSET array   ; ESI = 배열 주소 (입력)
    mov ecx, count          ; ECX = 요소 개수 (입력)
    call CalcSum            ; EAX = 합계 (반환)

    call DumpRegs
    exit
main ENDP
```

### 잘못된 예시

```asm
.code
main PROC
    ; ❌ EAX를 입력으로 사용 - 반환값과 충돌
    mov eax, OFFSET array   ; EAX 입력값
    mov ecx, count
    call CalcSum            ; EAX = 합계 (입력값 덮어씀)

    ; EAX에 저장된 원래 배열 주소 손실!
    exit
main ENDP
```

---

## 8. 프로시저 내부 로컬 변수

### 영문

If you need to create a variable for use only inside the procedure, you can use the data directive before the variable, and then follow it with the code: Here's an example:

```asm
MyCoolProcedure PROC
 .data
 sum SDWORD ?
 .code
 mov sum,0
 (etc.)
```

### 해석

프로시저 내부에서만 사용할 변수가 필요하면, 변수 앞에 데이터 지시어를 사용하고 뒤에 코드를 따르세요.

### 사용 예시

```asm
.code
ProcessArray PROC
    ; 프로시저 내부에서만 사용할 로컬 변수
    .data
    localSum SDWORD ?
    localCount SDWORD ?

    .code
    mov localSum, 0
    mov localCount, 0

    mov ecx, [ebp + 8]      ; 매개변수: 배열 크기
    mov esi, [ebp + 12]     ; 매개변수: 배열 포인터

L1:
    add localSum, [esi]
    add localCount, 1
    add esi, 4
    loop L1

    mov eax, localSum       ; 반환값
    ret
ProcessArray ENDP
```

### 주의사항

| 항목   | 설명                             |
| ------ | -------------------------------- |
| 범위   | 프로시저 내에서만 접근 가능      |
| 초기화 | 프로시저 호출 시마다 초기화 필요 |
| 가시성 | 공개적이지 않음 (private)        |

---

## 9. 변수 초기화 중요성

### 영문

The variable will still be publicly visible, unlike local variables in languages like C++ or Java. But when you declare it inside a procedure, you're making it obvious that you do not plan to use it anywhere else. Of course, you must use a runtime instruction to initialize variables used inside a procedure, because you will call this procedure more than once. You don't want it to have any leftover value the second time the procedure is called.

### 해석

변수는 여전히 공개적으로 접근 가능하지만, 프로시저 내에서 선언하면 다른 곳에서 사용하지 않을 것임을 명확히 합니다. 프로시저를 두 번 이상 호출할 경우, 런타임 명령어로 변수를 초기화해야 합니다.

### 올바른 초기화 방식

```asm
.code
CalculateSum PROC
    .data
    sum SDWORD ?          ; 선언만 함 (아직 초기화 안 됨)

    .code
    mov sum, 0            ; ⭐ 런타임 초기화 필수!

    mov ecx, 10
L1:
    add sum, ecx
    dec ecx
    jnz L1

    mov eax, sum
    ret
CalculateSum ENDP

main PROC
    call CalculateSum     ; 첫 번째 호출: sum = 0 + (10+9+...+1) = 55
    call DumpRegs

    call CalculateSum     ; 두 번째 호출: sum = 0 + (10+9+...+1) = 55
    call DumpRegs         ; 잔여값 없음 (초기화되었으므로)

    exit
main ENDP
```

### 잘못된 방식 (초기화 없음)

```asm
CalculateSum PROC
    .data
    sum SDWORD 0          ; 컴파일 타임 초기화 (한 번만)

    .code
    ; ❌ 런타임 초기화 없음
    mov ecx, 10
L1:
    add sum, ecx          ; sum = 0 + 10 = 10, sum = 10 + 9 = 19 ...
    dec ecx
    jnz L1

    mov eax, sum
    ret
CalculateSum ENDP

main PROC
    call CalculateSum     ; 첫 번째: sum = 55
    call CalculateSum     ; 두 번째: sum = 55 + 55 = 110 (❌ 잔여값!)
    exit
main ENDP
```

### 비교 표

| 항목         | 올바른 방식          | 잘못된 방식         |
| ------------ | -------------------- | ------------------- |
| 초기화 시점  | 런타임 (매 호출마다) | 컴파일 타임 (한 번) |
| 첫 번째 호출 | sum = 55             | sum = 55            |
| 두 번째 호출 | sum = 55             | sum = 110           |
| 결과         | ✅ 정확함            | ❌ 오류             |
