# Algorithm Workbench 답안

---

## 1. Show an example of a base-index operand in 32-bit mode.

32비트 모드에서 베이스-인덱스 피연산자의 예를 보이시오.

**답:**

```asm
mov eax, [ebx+esi]
```

**풀이:**

1. `[EBX+ESI]`는 두 레지스터의 값을 더하여 메모리 주소를 계산하는 베이스-인덱스 피연산자이다.
2. EBX에 기준 주소를, ESI에 바이트 단위의 오프셋을 넣어 사용할 수 있다.
3. 위 명령은 해당 주소의 DWORD 값을 EAX에 읽어 온다.[^1]

---

## 2. Show an example of a base-index-displacement operand in 32-bit mode.

32비트 모드에서 베이스-인덱스-변위 피연산자의 예를 보이시오.

**답:**

```asm
mov eax, [ebx+esi+8]
```

**풀이:**

1. EBX는 베이스 레지스터, ESI는 인덱스 레지스터이고, 상수 8은 변위이다.
2. 실제 접근 주소는 EBX와 ESI의 합에 8바이트를 더한 값이다.
3. 위 명령은 계산된 주소의 DWORD 값을 EAX로 가져온다.[^1]

---

## 3. Suppose a two-dimensional array of doublewords has three logical rows and four logical columns. Write an expression using ESI and EDI that addresses the third column in the second row. (Numbering for rows and columns starts at zero.)

더블워드로 이루어진 2차원 배열이 논리적으로 3개의 행과 4개의 열을 가진다고 가정하시오. ESI와 EDI를 사용하여 행 인덱스 2, 열 인덱스 3의 원소를 참조하는 표현식을 작성하시오. 행과 열의 번호는 0부터 시작한다.

**답:**

배열 이름을 `myArray`라고 하면 다음과 같이 작성할 수 있다.

```asm
mov esi, 2 * (4 * TYPE myArray)   ; 행 2의 바이트 오프셋: 32
mov edi, 3                       ; 열 인덱스: 3

mov eax, myArray[esi+edi*4]
```

요구한 피연산자 표현식은 다음과 같다.

```asm
myArray[esi+edi*4]
```

**풀이:**

1. 배열은 행 우선 순서(row-major order)로 저장된다고 가정한다.[^1]
2. DWORD 하나는 4바이트이므로 한 행의 크기는 $4 \times 4 = 16$바이트이다.
3. 문제에서 번호가 0부터 시작하므로, 여기서는 행 번호 2와 열 번호 3을 사용한다.
4. ESI에는 $2 \times 16 = 32$를 넣고, EDI에는 3을 넣는다.
5. 배열 시작 주소로부터의 바이트 오프셋은 다음과 같다.

$$2 \times 16 + 3 \times 4 = 44$$

즉, 이 코드는 `myArray[2][3]`에 해당하는 마지막 행의 마지막 원소를 참조한다. 일상적인 순서 표현인 “두 번째 행, 세 번째 열”을 뜻하는 `myArray[1][2]`와 구별해야 한다.

---

## 4. Write instructions using CMPSW that compare two arrays of 16-bit values named sourcew and targetw.

CMPSW를 사용하여 sourcew와 targetw라는 두 개의 16비트 값 배열을 비교하는 명령문을 작성하시오.

**답:**

두 배열의 원소 개수가 같고 1개 이상이라고 가정한다.

```asm
cld
mov esi, OFFSET sourcew
mov edi, OFFSET targetw
mov ecx, LENGTHOF sourcew

repe cmpsw
jne ArraysDifferent

; 두 배열의 모든 원소가 같음
jmp CompareDone

ArraysDifferent:
; 서로 다른 원소가 있음

CompareDone:
```

**풀이:**

1. ESI와 EDI에 각각 비교할 배열의 시작 주소를 넣는다.
2. ECX에는 비교할 WORD 원소의 개수를 넣는다. 바이트 수가 아니라 원소 개수이다.
3. `CLD`는 비교 후 ESI와 EDI가 증가하도록 설정한다.
4. `REPE CMPSW`는 대응하는 WORD 값이 같은 동안 반복하며, 한 번 비교할 때마다 ESI와 EDI가 2씩 증가한다.
5. 종료 후 ZF가 0이면 서로 다른 원소를 발견한 것이다.[^2]

배열 길이가 다를 수 있다면 길이를 별도로 비교해야 한다. 또한 빈 배열에서는 반복이 실행되지 않으므로 별도 처리가 필요하다.

---

## 5. Write instructions that use SCASW to scan for the 16-bit value 0100h in an array named wordArray, and copy the offset of the matching member into the EAX register.

SCASW를 사용하여 wordArray 배열에서 16비트 값 0100h를 찾고, 일치하는 원소의 오프셋 주소를 EAX 레지스터에 복사하는 명령문을 작성하시오.

**답:**

```asm
cld
mov edi, OFFSET wordArray
mov ecx, LENGTHOF wordArray
mov ax, 0100h

jecxz NotFound
repne scasw
jne NotFound

lea eax, [edi-2]             ; 일치한 원소의 오프셋 주소
jmp ScanDone

NotFound:
mov eax, -1                 ; 찾지 못한 경우의 반환값

ScanDone:
```

**풀이:**

1. AX에는 검색할 16비트 값 `0100h`를 넣는다.
2. EDI에는 배열 시작 주소, ECX에는 WORD 원소 개수를 넣는다.
3. `REPNE SCASW`는 값이 일치하거나 검색 횟수가 소진될 때까지 반복한다.
4. `DF = 0`이므로 비교 직후 EDI가 2 증가한다. 따라서 일치한 원소의 주소는 `EDI - 2`이다.[^3]
5. `LEA EAX, [EDI-2]`는 원소의 값이 아니라 주소를 EAX에 넣는다.
6. 빈 배열이거나 값이 없으면 위 예시에서는 EAX에 -1을 넣는다.

---

## 6. Write a sequence of instructions that use the Str_compare procedure to determine the larger of two input strings and write it to the console window.

Str_compare 프로시저를 사용하여 두 입력 문자열 중 더 큰 문자열을 판별하고 콘솔 창에 출력하는 명령문을 작성하시오.

**답:**

입력 문자열이 널 종료 문자열 `string1`과 `string2`에 저장되어 있다고 가정한다.

```asm
INVOKE Str_compare, ADDR string1, ADDR string2
ja PrintString1

; string1 <= string2인 경우
mov edx, OFFSET string2
jmp PrintSelected

PrintString1:
mov edx, OFFSET string1

PrintSelected:
call WriteString
call Crlf
```

**풀이:**

1. `Str_compare`는 두 문자열의 비교 결과에 따라 Carry 플래그와 Zero 플래그를 설정한다.
2. 첫 번째 문자열이 더 크면 CF와 ZF가 모두 0이므로 `JA`로 분기한다.
3. `WriteString`은 EDX가 가리키는 널 종료 문자열을 출력한다.[^4]
4. 두 문자열이 같으면 어느 쪽을 출력해도 된다. 위 코드는 `string2`를 출력한다.
5. 여기서 “더 크다”는 문자열 길이가 아니라 대소문자를 구분하는 문자 코드 순서에 따른 비교를 의미한다.[^4]

---

## 7. Show how to call the Str_trim procedure and remove all trailing "@" characters from a string.

Str_trim 프로시저를 호출하여 문자열 끝의 모든 "@" 문자를 제거하는 방법을 보이시오.

**답:**

```asm
.data
myString BYTE "Hello@@@",0

.code
INVOKE Str_trim, ADDR myString, '@'
cld                         ; 이후 문자열 명령은 정방향으로 사용

; 결과: myString = "Hello",0
```

**풀이:**

1. 첫 번째 인수는 수정할 문자열의 주소이다.
2. 두 번째 인수는 끝에서 제거할 문자 `'@'`이다.
3. `Str_trim`은 문자열 끝에 연속해서 나타나는 해당 문자만 제거한다. 문자열 중간의 `'@'`는 유지된다.[^4]
4. 일부 교재 버전의 구현은 DF를 1로 남기므로, 호출 후 `CLD`로 정방향을 복원한다.[^5]

---

## 8. Show how to modify the Str_ucase procedure from the Irvine32 library so it changes all characters to lower case.

Irvine32 라이브러리의 Str_ucase 프로시저를 수정하여 문자열을 소문자로 변환하도록 하시오.

**답:**

```asm
Str_lcase PROC USES eax esi,
    pString:PTR BYTE

    mov esi, pString

L1:
    mov al, [esi]
    cmp al, 0
    je  L3

    cmp al, 'A'
    jb  L2
    cmp al, 'Z'
    ja  L2

    or BYTE PTR [esi], 00100000b

L2:
    inc esi
    jmp L1

L3:
    ret

Str_lcase ENDP
```

**풀이:**

1. 기존 `Str_ucase`의 소문자 범위 검사를 대문자 `'A'`부터 `'Z'`까지의 검사로 바꾼다.[^5]
2. 대문자일 때만 비트 5를 1로 설정하는 `OR 00100000b`를 수행한다.
3. ASCII 대문자와 대응하는 소문자의 코드 차이는 32이므로, 이 연산으로 소문자가 된다.
4. 숫자, 기호, 기존 소문자는 변경하지 않는다.
5. 널 문자를 만나면 종료하며, 원래 문자열을 직접 수정한다.

호출 예시:

```asm
INVOKE Str_lcase, ADDR myString
```

---

## 9. Create a 64-bit version of the Str_trim procedure.

Str_trim 프로시저의 64비트 버전을 작성하시오.

**답:**

Windows x64 호출 규약에 따라 RCX로 문자열 주소를, DL로 제거할 문자 1바이트를 전달받는다.[^6] 문자열은 쓰기 가능한 널 종료 바이트 문자열이라고 가정한다.

```asm
; 64비트 MASM 코드
; 입력: RCX = 문자열 주소
;       DL  = 끝에서 제거할 문자
; 동작: 문자열 끝의 해당 문자를 모두 제거
; 변경: R8, 상태 플래그
; 반환값: 없음

Str_trim PROC
    mov r8, rcx

FindEnd:
    cmp BYTE PTR [r8], 0
    je  TrimLoop
    inc r8
    jmp FindEnd

TrimLoop:
    cmp r8, rcx
    je  SetNull

    cmp BYTE PTR [r8-1], dl
    jne SetNull

    dec r8
    jmp TrimLoop

SetNull:
    mov BYTE PTR [r8], 0
    ret

Str_trim ENDP
```

**풀이:**

1. R8을 문자열 시작 주소로 초기화한 뒤 널 문자까지 이동한다.
2. R8이 문자열 시작 주소와 같으면 빈 문자열이거나 모든 문자를 제거한 경우이므로 종료한다.
3. `[R8-1]`이 제거할 문자이면 R8을 1 감소시키고 계속 검사한다.
4. 더 이상 제거할 문자가 없으면 `[R8]`에 널 문자를 저장하여 문자열을 끝낸다.
5. R8은 Windows x64에서 휘발성 레지스터이므로 별도 저장·복원이 필요 없다.[^6]
6. 다른 프로시저를 호출하지 않는 리프 프로시저이며, 스택과 DF를 변경하지 않는다. 따라서 비휘발성 레지스터 저장이나 역방향 문자열 명령에 따른 DF 복원이 필요 없다.

---

## 10. Show an example of a base-index operand in 64-bit mode.

64비트 모드에서 베이스-인덱스 피연산자의 예를 보이시오.

**답:**

```asm
mov rax, [rbx+rsi]
```

**풀이:**

1. RBX와 RSI의 합으로 메모리 주소를 계산한다.
2. RBX에 기준 주소, RSI에 바이트 단위의 오프셋을 넣어 사용할 수 있다.
3. RAX가 64비트 레지스터이므로 해당 주소의 QWORD 값 8바이트를 읽는다.[^7]

---

## 11. Assuming that EBX contains a row index into a two-dimensional array of 32-bit integers named myArray and EDI contains the index of a column, write a single statement that moves the content of the given array element into the EAX register.

EBX에 myArray라는 32비트 정수 2차원 배열의 행 인덱스가 들어 있고, EDI에 열 인덱스가 들어 있다고 가정하시오. 지정된 배열 원소의 값을 EAX로 옮기는 단일 명령문을 작성하시오.

**답:**

교재의 배열 주소 계산 방식대로, EBX에는 해당 행의 **바이트 오프셋**이 들어 있다고 가정한다.[^1]

```asm
mov eax, myArray[ebx+edi*4]
```

**풀이:**

1. `myArray`는 배열 시작 주소이고, EBX는 그 시작으로부터 해당 행까지의 바이트 오프셋이다.
2. 각 원소가 32비트, 즉 4바이트이므로 열 인덱스 EDI에 4를 곱한다.
3. 계산된 주소의 DWORD 값을 EAX로 읽는다.

$$\text{원소 주소} = \text{배열 시작 주소} + \text{행 바이트 오프셋} + \text{열 번호} \times 4$$

주의할 점은 EBX에 단순한 행 번호가 들어 있다면 먼저 `행 번호 × 한 행의 바이트 수`로 변환해야 한다는 것이다. 임의의 열 개수에 대해 이 곱셈까지 위 단일 명령이 자동으로 수행하지는 않는다.

---

## 12. Assuming that RBX contains a row index into a two-dimensional array of 64-bit integers named myArray and RDI contains the index of a column, write a single statement that moves the content of the given array element into the RAX register.

RBX에 myArray라는 64비트 정수 2차원 배열의 행 인덱스가 들어 있고, RDI에 열 인덱스가 들어 있다고 가정하시오. 지정된 배열 원소의 값을 RAX로 옮기는 단일 명령문을 작성하시오.

**답:**

RBX에는 해당 행의 **바이트 오프셋**, RDI에는 열 번호가 들어 있다고 가정한다.

```asm
mov rax, myArray[rbx+rdi*8]
```

**풀이:**

1. 각 원소가 64비트, 즉 8바이트이므로 열 번호 RDI에 8을 곱한다.
2. 배열 시작 주소, 행 바이트 오프셋, 열 바이트 오프셋을 더하여 원소 주소를 구한다.
3. 해당 주소의 QWORD 값을 RAX로 읽는다.[^7]

$$\text{원소 주소} = \text{배열 시작 주소} + \text{행 바이트 오프셋} + \text{열 번호} \times 8$$

RBX가 단순한 행 번호라면 11번과 마찬가지로 미리 행 바이트 오프셋으로 변환해야 한다.

또한 위처럼 배열 심벌과 인덱스 레지스터를 결합하는 64비트 표현식은 배열 주소가 명령의 변위로 표현 가능한 배치에서 사용한다. 임의의 64비트 주소를 일반적으로 지원하려면 배열 시작 주소를 별도 레지스터에 적재해야 한다.[^7] 예를 들어 R10에 해당 행의 시작 주소를 미리 계산해 두었다면 다음 단일 명령을 사용할 수 있다.

```asm
mov rax, [r10+rdi*8]
```
