# Algorithm Workbench 답안

---

## 1. ASCII Digit to Binary Conversion

### 문제 설명

AL에 포함된 ASCII 숫자를 해당하는 이진값으로 변환하는 단일 명령어를 작성하시오. AL이 이미 이진값(00h ~ 09h)을 포함하고 있으면 변경하지 않으시오.

### 영문

Write a single instruction that converts an ASCII digit in AL to its corresponding binary value. If AL already contains a binary value (00h to 09h), leave it unchanged.

### 풀이

```asm
sub al, '0'          ; ASCII 문자 '0'(30h)을 빼서 이진값으로 변환
```

### 단계별 분석

| 상황           | AL 입력 | ASCII값 | 10진값 | 연산      |     결과      | 설명        |
| -------------- | :-----: | :-----: | :----: | --------- | :-----------: | ----------- |
| ASCII 숫자 '0' |   '0'   |   30h   |   48   | 30h - 30h |      00h      | 이진값 0    |
| ASCII 숫자 '5' |   '5'   |   35h   |   53   | 35h - 30h |      05h      | 이진값 5    |
| ASCII 숫자 '9' |   '9'   |   39h   |   57   | 39h - 30h |      09h      | 이진값 9    |
| 이진값 범위    |   00h   |   00h   |   0    | 00h - 30h | -30h (유효 X) | 변경 불필요 |

### 답

**AL = 이진값 (00h ~ 09h)**

---

## 2. Calculate Parity of 32-bit Memory Operand

### 문제 설명

32비트 메모리 오퍼랜드의 패리티를 계산하는 명령어들을 작성하시오. 힌트: B0 XOR B1 XOR B2 XOR B3 공식을 사용하시오.

### 영문

Write instructions that calculate the parity of a 32-bit memory operand. Hint: Use the formula presented earlier in this section: B0 XOR B1 XOR B2 XOR B3.

### 풀이

```asm
.data
memValue DWORD 12345678h

.code
mov eax, memValue        ; EAX = 32비트 메모리값
mov ebx, eax
shr ebx, 8               ; EBX = B1 (바이트 1)
xor al, bl               ; AL = B0 XOR B1

mov ebx, eax
shr ebx, 16              ; EBX = B2 (바이트 2)
xor al, bl               ; AL = (B0 XOR B1) XOR B2

mov ebx, eax
shr ebx, 24              ; EBX = B3 (바이트 3)
xor al, bl               ; AL = (B0 XOR B1 XOR B2) XOR B3
```

### 단계별 분석

| 단계 | 연산                | EAX       | EBX       | AL              | 설명               |
| ---- | ------------------- | --------- | --------- | --------------- | ------------------ |
| 초기 | `mov eax, memValue` | 12345678h | -         | -               | 메모리값 로드      |
| 1    | `shr ebx, 8`        | 12345678h | 01234567h | -               | B1 추출            |
| 2    | `xor al, bl`        | 12345678h | 01234567h | 78h XOR 67h     | B0 XOR B1          |
| 3    | `shr ebx, 16`       | 12345678h | 00001234h | -               | B2 추출            |
| 4    | `xor al, bl`        | 12345678h | 00001234h | (결과) XOR 34h  | (B0 XOR B1) XOR B2 |
| 5    | `shr ebx, 24`       | 12345678h | 00000012h | -               | B3 추출            |
| 6    | `xor al, bl`        | 12345678h | 00000012h | **최종 패리티** | 모든 바이트 XOR    |

### 예시 계산

```
메모리값: 12345678h
B0 = 78h = 01111000b
B1 = 56h = 01010110b
B2 = 34h = 00110100b
B3 = 12h = 00010010b

B0 XOR B1 = 01111000 XOR 01010110 = 00101110 (2Eh)
(B0 XOR B1) XOR B2 = 00101110 XOR 00110100 = 00011010 (1Ah)
((B0 XOR B1) XOR B2) XOR B3 = 00011010 XOR 00010010 = 00001000 (08h)

최종 AL = 08h
```

### 답

**AL = 모든 바이트의 XOR 결과 (패리티 비트)**

---

## 3. Bit-Mapped Set Operations

### 문제 설명

두 개의 비트맵 세트 SetX와 SetY가 주어졌을 때, SetY의 멤버가 아닌 SetX의 멤버를 나타내는 비트 문자열을 EAX에서 생성하는 명령어 시퀀스를 작성하시오.

### 영문

Given two bit-mapped sets named SetX and SetY, write a sequence of instructions that generate a bit string in EAX that represents members in SetX that are not members of SetY.

### 풀이

```asm
.data
SetX DWORD 11110000b
SetY DWORD 10101010b

.code
mov eax, SetX            ; EAX = SetX
mov edx, SetY            ; EDX = SetY

not edx                  ; EDX = NOT SetY (SetY의 여집합)
and eax, edx             ; EAX = SetX AND (NOT SetY)
                         ; = SetX - SetY (SetX에만 속하는 멤버)
```

### 단계별 분석

| 단계 | 연산            | EAX           | EDX       | 설명              |
| ---- | --------------- | ------------- | --------- | ----------------- |
| 초기 | -               | -             | -         | -                 |
| 1    | `mov eax, SetX` | 11110000b     | -         | SetX 로드         |
| 2    | `mov edx, SetY` | 11110000b     | 10101010b | SetY 로드         |
| 3    | `not edx`       | 11110000b     | 01010101b | SetY의 여집합     |
| 4    | `and eax, edx`  | **01010000b** | 01010101b | SetX ∩ (NOT SetY) |

### 집합론 설명

- **SetX** = {비트가 1인 위치의 요소들}
- **SetY** = {비트가 1인 위치의 요소들}
- **원하는 결과** = SetX - SetY = SetX ∩ SetY^c

논리식: `EAX = SetX AND (NOT SetY)`

### 답

**EAX = SetX에만 속하는 멤버들의 비트마스크**

---

## 4. Unsigned Integer Comparison and Jump

### 문제 설명

DX의 부호 없는 정수가 CX의 정수 이하일 때 레이블 L1로 분기하는 명령어들을 작성하시오.

### 영문

Write instructions that jump to label L1 when the unsigned integer in DX is less than or equal to the integer in CX.

### 풀이

```asm
cmp dx, cx              ; DX와 CX 비교 (DX - CX)
jbe L1                  ; DX <= CX이면 분기 (부호 없음)
```

### 플래그 분석 표

| 조건    | DX vs CX | CF  | ZF  | 명령어   | 결과       |
| ------- | -------- | :-: | :-: | -------- | ---------- |
| DX < CX | 5 < 10   |  1  |  0  | `jbe L1` | **분기 O** |
| DX = CX | 10 = 10  |  0  |  1  | `jbe L1` | **분기 O** |
| DX > CX | 15 > 10  |  0  |  0  | `jbe L1` | 분기 X     |

### 명령어 선택 이유

- `jbe` (Jump if Below or Equal): 부호 없는 비교
- `CF=1` (빌림 발생) 또는 `ZF=1` (같음) 일 때 분기
- `jle`는 **부호 있는** 비교이므로 사용 불가

### 답

```asm
cmp dx, cx
jbe L1
```

---

## 5. Signed Integer Comparison and Jump

### 문제 설명

AX의 부호 있는 정수가 CX의 정수보다 클 때 레이블 L2로 분기하는 명령어들을 작성하시오.

### 영문

Write instructions that jump to label L2 when the signed integer in AX is greater than the integer in CX.

### 풀이

```asm
cmp ax, cx              ; AX와 CX 비교 (AX - CX)
jg L2                   ; AX > CX이면 분기 (부호 있음)
```

### 플래그 분석 표

| 조건           | AX vs CX | SF  | OF  | ZF  | 결과       |
| -------------- | -------- | :-: | :-: | :-: | ---------- |
| AX > CX (음수) | -5 > -10 |  0  |  0  |  0  | **분기 O** |
| AX > CX (양수) | 10 > 5   |  0  |  0  |  0  | **분기 O** |
| AX = CX        | 10 = 10  |  0  |  0  |  1  | 분기 X     |
| AX < CX        | 5 < 10   |  1  |  0  |  0  | 분기 X     |

### 명령어 선택 이유

- `jg` (Jump if Greater): 부호 있는 비교
- `ZF=0` AND `(SF XOR OF)=0` 일 때 분기
- `ja`는 **부호 없는** 비교이므로 사용 불가

### 답

```asm
cmp ax, cx
jg L2
```

---

## 6. Clear Bits and Conditional Jump

### 문제 설명

AL의 비트 0과 1을 먼저 클리어하시오. 그 다음, 결과 오퍼랜드가 0과 같으면 L3으로 분기하고, 그렇지 않으면 L4로 분기하시오.

### 영문

Write instructions that first clear bits 0 and 1 in AL. Then, if the destination operand is equal to zero, the code should jump to label L3. Otherwise, it should jump to label L4.

### 풀이

```asm
and al, 11111100b       ; AL의 비트 0, 1 클리어 (마스크 FCh)
jz L3                   ; ZF=1이면 (AL=0) L3로 분기
jmp L4                  ; 그렇지 않으면 L4로 분기
```

또는

```asm
and al, 0FCh            ; AL의 비트 0, 1 클리어 (16진수)
je L3                   ; AL = 0이면 L3로 분기
jmp L4                  ; AL ≠ 0이면 L4로 분기
```

### 단계별 분석

| AL 입력 | 이진      | 마스크    | AND 결과 | 이진      | ZF  | 분기   |
| ------- | --------- | --------- | -------- | --------- | :-: | ------ |
| 0A7h    | 10100111b | 11111100b | A4h      | 10100100b |  0  | L4     |
| 0A3h    | 10100011b | 11111100b | A0h      | 10100000b |  0  | L4     |
| 03h     | 00000011b | 11111100b | 00h      | 00000000b |  1  | **L3** |

### 플래그 해석

- `and` 명령어는 **ZF를 갱신**
- ZF=1 ⟹ 결과가 0 ⟹ `jz` 또는 `je` 분기
- ZF=0 ⟹ 결과가 0이 아님 ⟹ `jmp L4`

### 답

```asm
and al, 0FCh
jz L3
jmp L4
```

---

## 7. Short-Circuit AND Evaluation

### 문제 설명

다음 의사코드를 어셈블리어로 구현하시오. 단락(Short-Circuit) 평가를 사용하고, val1과 X는 32비트 변수라고 가정하시오.

```
if( val1 > ecx ) AND ( ecx > edx )
 X = 1
else
 X = 2
```

### 영문

Implement the following pseudocode in assembly language. Use short-circuit evaluation and assume that val1 and X are 32-bit variables.

### 풀이

```asm
.data
val1 DWORD 100
X DWORD 0

.code
mov eax, val1           ; EAX = val1
cmp eax, ecx            ; val1 > ecx 비교
jle ElseLabel           ; val1 <= ecx이면 Else로 분기 (단락)

cmp ecx, edx            ; ecx > edx 비교
jle ElseLabel           ; ecx <= edx이면 Else로 분기

mov X, 1                ; 둘 다 참이면 X = 1
jmp EndIf

ElseLabel:
mov X, 2                ; 하나라도 거짓이면 X = 2

EndIf:
```

### 단계별 실행 (val1=100, ecx=50, edx=30)

| 단계 | 조건                       | 결과   | 다음  |
| ---- | -------------------------- | ------ | ----- |
| 1    | `cmp 100, 50` (val1 > ecx) | **참** | 계속  |
| 2    | `cmp 50, 30` (ecx > edx)   | **참** | X=1   |
| 3    | -                          | -      | EndIf |

### 단락 평가의 장점

- 첫 번째 조건이 거짓이면 두 번째 조건을 검사하지 않음
- CPU 사이클 절약

### 답

```asm
mov eax, val1
cmp eax, ecx
jle ElseLabel
cmp ecx, edx
jle ElseLabel
mov X, 1
jmp EndIf
ElseLabel:
mov X, 2
EndIf:
```

---

## 8. Short-Circuit OR Evaluation

### 문제 설명

다음 의사코드를 어셈블리어로 구현하시오. 단락 평가를 사용하고, X는 32비트 변수라고 가정하시오.

```
if( ebx > ecx ) OR ( ebx > val1 )
 X = 1
else
 X = 2
```

### 영문

Implement the following pseudocode in assembly language. Use short-circuit evaluation and assume that X is a 32-bit variable.

### 풀이

```asm
.data
val1 DWORD 100
X DWORD 0

.code
cmp ebx, ecx            ; ebx > ecx 비교
jg ThenLabel            ; 참이면 ThenLabel로 분기 (단락)

cmp ebx, val1           ; ebx > val1 비교
jle ElseLabel           ; 거짓이면 ElseLabel로 분기

ThenLabel:
mov X, 1                ; 하나라도 참이면 X = 1
jmp EndIf

ElseLabel:
mov X, 2                ; 둘 다 거짓이면 X = 2

EndIf:
```

### 단계별 실행 (ebx=60, ecx=50, val1=100)

| 단계 | 조건                     | 결과   | 다음             |
| ---- | ------------------------ | ------ | ---------------- |
| 1    | `cmp 60, 50` (ebx > ecx) | **참** | ThenLabel (단락) |
| 2    | -                        | -      | X=1              |

### OR의 특성

- 첫 번째 조건이 참이면 두 번째를 검사하지 않음
- 하나라도 참이면 전체 결과는 참

### 답

```asm
cmp ebx, ecx
jg ThenLabel
cmp ebx, val1
jle ElseLabel
ThenLabel:
mov X, 1
jmp EndIf
ElseLabel:
mov X, 2
EndIf:
```

---

## 9. Complex Boolean Expression

### 문제 설명

다음 의사코드를 어셈블리어로 구현하시오. 단락 평가를 사용하고, X는 32비트 변수라고 가정하시오.

```
if( ebx > ecx AND ebx > edx) OR ( edx > eax )
 X = 1
else
 X = 2
```

### 영문

Implement the following pseudocode in assembly language. Use short-circuit evaluation and assume that X is a 32-bit variable.

### 풀이

```asm
.data
X DWORD 0

.code
; 첫 번째 조건: (ebx > ecx AND ebx > edx)
cmp ebx, ecx            ; ebx > ecx 비교
jle Condition2          ; 거짓이면 Condition2로 분기

cmp ebx, edx            ; ebx > edx 비교
jg ThenLabel            ; 참이면 ThenLabel로 분기

; 두 번째 조건: (edx > eax)
Condition2:
cmp edx, eax            ; edx > eax 비교
jle ElseLabel           ; 거짓이면 ElseLabel로 분기

ThenLabel:
mov X, 1                ; 조건 참이면 X = 1
jmp EndIf

ElseLabel:
mov X, 2                ; 조건 거짓이면 X = 2

EndIf:
```

### 단계별 실행 (ebx=60, ecx=50, edx=55, eax=40)

| 단계 | 조건                     | 결과   | 다음          |
| ---- | ------------------------ | ------ | ------------- |
| 1    | `cmp 60, 50` (ebx > ecx) | **참** | 계속          |
| 2    | `cmp 60, 55` (ebx > edx) | **참** | **ThenLabel** |
| 3    | -                        | -      | X=1           |

### 논리 구조

```
(ebx > ecx AND ebx > edx) → 둘 다 참이면 ThenLabel
↓
거짓이면 두 번째 OR 조건 검사
↓
(edx > eax) → 참이면 ThenLabel, 거짓이면 ElseLabel
```

### 답

```asm
cmp ebx, ecx
jle Condition2
cmp ebx, edx
jg ThenLabel
Condition2:
cmp edx, eax
jle ElseLabel
ThenLabel:
mov X, 1
jmp EndIf
ElseLabel:
mov X, 2
EndIf:
```

---

## 10. While Loop with Complex Conditions

### 문제 설명

다음 의사코드를 어셈블리어로 구현하시오. 단락 평가를 사용하고, A, B, N은 32비트 부호 있는 정수라고 가정하시오.

```
while N > 0
 if N != 3 AND (N < A OR N > B)
  N = N – 2
 else
  N = N – 1
end while
```

### 영문

Implement the following pseudocode in assembly language. Use short-circuit evaluation and assume that A, B, and N are 32-bit signed integers.

### 풀이

```asm
.data
A SDWORD 5
B SDWORD 20
N SDWORD 15

.code
WhileLoop:
cmp N, 0                ; N > 0 확인
jle EndWhile            ; N <= 0이면 루프 종료

; 조건: N != 3
cmp N, 3                ; N = 3인지 확인
je Else                 ; N = 3이면 Else로 분기 (조건 거짓)

; 조건: (N < A OR N > B)
mov eax, N
cmp eax, A              ; N < A 비교
jl ThenBranch           ; 참이면 ThenBranch로 분기

mov eax, N
cmp eax, B              ; N > B 비교
jg ThenBranch           ; 참이면 ThenBranch로 분기

; OR 조건이 거짓이면 Else로
jmp Else

ThenBranch:
sub N, 2                ; N = N - 2
jmp WhileLoop           ; 루프 재개

Else:
sub N, 1                ; N = N - 1
jmp WhileLoop           ; 루프 재개

EndWhile:
```

### 단계별 추적 (A=5, B=20, N=15)

| 반복 |  N  | N>0 | N!=3 | N<A\|N>B  | 연산 |   새 N   |
| :--: | :-: | :-: | :--: | :-------: | ---- | :------: |
|  1   | 15  |  ✓  |  ✓   | ✓ (15>20) | N-2  |    13    |
|  2   | 13  |  ✓  |  ✓   | ✓ (13>20) | N-2  |    11    |
|  3   | 11  |  ✓  |  ✓   | ✓ (11>20) | N-2  |    9     |
|  4   |  9  |  ✓  |  ✓   | ✓ (9>20)  | N-2  |    7     |
|  5   |  7  |  ✓  |  ✓   | ✓ (7>20)  | N-2  |    5     |
|  6   |  5  |  ✓  |  ✓   |     ✗     | N-1  |    4     |
|  7   |  4  |  ✓  |  ✓   |     ✗     | N-1  |    3     |
|  8   |  3  |  ✓  |  ✗   |     -     | N-1  |    2     |
|  9   |  2  |  ✓  |  ✓   |  ✓ (2<5)  | N-2  |    0     |
|  10  |  0  |  ✗  |  -   |     -     | -    | **종료** |

### 조건 해석

- **N != 3**: N이 3이 아닌가?
- **N < A OR N > B**: N이 범위 [A, B] 밖에 있는가?
- 둘 다 참이어야 `N = N - 2`
- 하나라도 거짓이면 `N = N - 1`

### 답

```asm
WhileLoop:
cmp N, 0
jle EndWhile
cmp N, 3
je Else
mov eax, N
cmp eax, A
jl ThenBranch
mov eax, N
cmp eax, B
jg ThenBranch
jmp Else
ThenBranch:
sub N, 2
jmp WhileLoop
Else:
sub N, 1
jmp WhileLoop
EndWhile:
```

---

## 요약표

| 문제 | 핵심 기법              | 답변 유형   |
| :--: | ---------------------- | ----------- |
|  1   | 산술 연산 (SUB)        | 단일 명령어 |
|  2   | XOR 패리티             | 루프 + 이동 |
|  3   | 비트 연산 (AND, NOT)   | 2-3줄 코드  |
|  4   | 부호 없는 비교 (JBE)   | 조건 분기   |
|  5   | 부호 있는 비교 (JG)    | 조건 분기   |
|  6   | 마스킹 + 조건 분기     | 3줄 코드    |
|  7   | 단락 AND 평가          | 루프 없음   |
|  8   | 단락 OR 평가           | 루프 없음   |
|  9   | 복잡한 boolean         | 중첩 조건   |
|  10  | while 루프 + 복합 조건 | 루프 제어   |
