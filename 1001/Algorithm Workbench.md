# Algorithm Workbench 답안

---

### 1. Write a sequence of MOV instructions that will exchange the upper and lower words in a doubleword variable named three.

`three`라는 더블워드 변수의 상위 워드와 하위 워드를 서로 교환하는 MOV 명령어들을 작성하시오.

**답:**

```asm
.data
three DWORD 12345678h

.code
mov ax, WORD PTR three          ; AX = 5678h (하위 워드)
mov bx, WORD PTR three+2        ; BX = 1234h (상위 워드)
mov WORD PTR three, bx          ; 하위 워드 ← 1234h
mov WORD PTR three+2, ax        ; 상위 워드 ← 5678h
```

실행 후 `three` = `56781234h`

`WORD PTR` 연산자로 DWORD 변수를 16비트 단위로 나누어 접근한다. 오프셋 0이 하위 워드, 오프셋 +2가 상위 워드이다(리틀엔디안).

---

### 2. Using the XCHG instruction no more than three times, reorder the values in four 8-bit registers from the order A,B,C,D to B,C,D,A.

XCHG 명령어를 3번 이하로 사용하여, 4개의 8비트 레지스터에 들어있는 값의 순서를 A,B,C,D에서 B,C,D,A로 바꾸시오.

**답:**

```asm
xchg al, bl        ; AL=B, BL=A
xchg bl, cl        ; BL=C, CL=A
xchg cl, dl        ; CL=D, DL=A
```

| 단계 | AL | BL | CL | DL |
|---|:-:|:-:|:-:|:-:|
| 시작 | A | B | C | D |
| `xchg al,bl` | **B** | A | C | D |
| `xchg bl,cl` | B | **C** | A | D |
| `xchg cl,dl` | B | C | **D** | **A** |

A를 한 칸씩 오른쪽으로 밀어내면서 나머지 값들이 자연스럽게 왼쪽으로 당겨지는 방식이다.

---

### 3. Transmitted messages often include a parity bit whose value is combined with a data byte to produce an even number of 1 bits. Suppose a message byte in the AL register contains 01110101. Show how you could use the Parity flag combined with an arithmetic instruction to determine if this message byte has even or odd parity.

전송되는 메시지에는 데이터 바이트와 결합하여 1인 비트의 개수를 짝수로 만드는 패리티 비트가 포함되는 경우가 많다. AL 레지스터의 메시지 바이트가 01110101이라고 가정하자. 패리티 플래그와 산술 명령어를 함께 사용하여 이 메시지 바이트의 패리티가 짝수인지 홀수인지 판별하는 방법을 보이시오.

**답:**

```asm
mov al, 01110101b
and al, al              ; AL 값은 변하지 않지만 PF가 갱신됨
jp  EvenParity          ; PF=1 이면 짝수 패리티
jmp OddParity           ; PF=0 이면 홀수 패리티
```

`and al, al`(또는 `or al, al`, `add al, 0`)은 **값을 바꾸지 않으면서 플래그만 갱신**하는 전형적인 기법이다.

| 항목 | 값 |
|---|---|
| AL | `01110101b` |
| 1인 비트 개수 | 5개 (홀수) |
| Parity flag | **0** |
| 판정 | **홀수 패리티 (odd parity)** |

따라서 `jp`는 분기하지 않고 `OddParity`로 간다. 패리티를 짝수로 맞추려면 패리티 비트를 1로 설정해야 한다.

---

### 4. Write code using byte operands that adds two negative integers and causes the Overflow flag to be set.

바이트 오퍼랜드를 사용하여 두 개의 음수를 더해 오버플로 플래그가 설정되게 하는 코드를 작성하시오.

**답:**

```asm
mov al, -128            ; AL = 80h
add al, -1              ; AL = 7Fh (+127),  OF = 1
```

| 항목 | 값 |
|---|---|
| 기대 결과 | -128 + (-1) = **-129** |
| 부호 있는 바이트 범위 | -128 ~ +127 |
| 실제 AL | `7Fh` = **+127** |
| Overflow flag | **1** |

음수 + 음수인데 결과가 양수로 나왔으므로 부호 있는 오버플로가 발생했고, CPU가 OF를 1로 설정한다.

---

### 5. Write a sequence of two instructions that use addition to set the Zero and Carry flags at the same time.

덧셈을 사용하여 제로 플래그와 캐리 플래그를 동시에 설정하는 두 개의 명령어를 작성하시오.

**답:**

```asm
mov al, 0FFh
add al, 1               ; AL = 00h,  ZF = 1,  CF = 1
```

`FFh + 01h = 100h`인데 바이트에 담을 수 있는 것은 하위 8비트뿐이다. 결과 `00h`이므로 **ZF = 1**, 9번째 비트로 자리올림이 발생했으므로 **CF = 1**이다.

---

### 6. Write a sequence of two instructions that set the Carry flag using subtraction.

뺄셈을 사용하여 캐리 플래그를 설정하는 두 개의 명령어를 작성하시오.

**답:**

```asm
mov al, 1
sub al, 2               ; AL = FFh,  CF = 1
```

부호 없는 뺄셈에서 피감수가 감수보다 작으면 **빌림(borrow)** 이 발생하고, 이때 캐리 플래그가 1로 설정된다.

---

### 7. Implement the following arithmetic expression in assembly language: EAX = –val2 + 7 – val3 + val1. Assume that val1, val2, and val3 are 32-bit integer variables.

다음 산술식을 어셈블리어로 구현하시오: `EAX = -val2 + 7 - val3 + val1`. val1, val2, val3는 32비트 정수 변수라고 가정한다.

**답:**

```asm
.data
val1 DWORD 10
val2 DWORD 20
val3 DWORD 30

.code
mov eax, val2           ; EAX = val2
neg eax                 ; EAX = -val2
add eax, 7              ; EAX = -val2 + 7
sub eax, val3           ; EAX = -val2 + 7 - val3
add eax, val1           ; EAX = -val2 + 7 - val3 + val1
```

예시 값으로 계산하면 `-20 + 7 - 30 + 10 = -33` 이므로 EAX = `FFFFFFDFh`

---

### 8. Write a loop that iterates through a doubleword array and calculates the sum of its elements using a scale factor with indexed addressing.

더블워드 배열을 순회하면서 인덱스 주소 지정과 배율 인수(scale factor)를 사용하여 원소들의 합을 계산하는 루프를 작성하시오.

**답:**

```asm
.data
array DWORD 10, 20, 30, 40, 50
ArraySize = LENGTHOF array

.code
mov eax, 0                              ; 합계 초기화
mov esi, 0                              ; 인덱스 초기화
mov ecx, ArraySize                      ; 반복 횟수 = 5

L1:
    add eax, array[esi*TYPE array]      ; 배율 인수 4를 적용한 인덱스 주소 지정
    inc esi
    loop L1
```

- `TYPE array` = 4 이므로 `array[esi*4]` 형태가 된다.
- ESI를 1씩 증가시키면 실제 주소는 4바이트씩 이동한다.
- 실행 후 EAX = 150

---

### 9. Implement the following expression in assembly language: AX = (val2 + BX) – val4. Assume that val2 and val4 are 16-bit integer variables.

다음 식을 어셈블리어로 구현하시오: `AX = (val2 + BX) - val4`. val2와 val4는 16비트 정수 변수라고 가정한다.

**답:**

```asm
.data
val2 WORD 1000h
val4 WORD 0200h

.code
mov ax, val2            ; AX = val2
add ax, bx              ; AX = val2 + BX
sub ax, val4            ; AX = (val2 + BX) - val4
```

모든 오퍼랜드가 16비트로 크기가 일치해야 한다.

---

### 10. Write a sequence of two instructions that set both the Carry and Overflow flags at the same time.

캐리 플래그와 오버플로 플래그를 동시에 설정하는 두 개의 명령어를 작성하시오.

**답:**

```asm
mov al, 80h             ; AL = 80h  (부호 있는 -128)
add al, 80h             ; AL = 00h,  CF = 1,  OF = 1
```

| 관점 | 해석 | 결과 | 플래그 |
|---|---|---|---|
| 부호 없음 | 128 + 128 = 256 | 바이트 초과 | **CF = 1** |
| 부호 있음 | (-128) + (-128) = -256 | 범위 초과 | **OF = 1** |

같은 연산이라도 부호 없는 관점과 부호 있는 관점에서 모두 범위를 벗어나므로 두 플래그가 함께 설정된다.

---

### 11. Write a sequence of instructions showing how the Zero flag could be used to indicate unsigned overflow after executing INC and DEC instructions.

INC와 DEC 명령어를 실행한 후, 제로 플래그를 사용하여 부호 없는 오버플로를 나타내는 방법을 보여주는 명령어들을 작성하시오.

**답:**

INC와 DEC는 **캐리 플래그를 변경하지 않으므로**, 제로 플래그로 부호 없는 범위 초과를 판별한다.

```asm
; INC — 최댓값에서 1 증가하면 0으로 되돌아감
mov al, 0FFh
inc al                  ; AL = 00h,  ZF = 1  → 부호 없는 오버플로 발생
jz  IncOverflow

; DEC — 0에서 1 감소하면 FFh로 되돌아감
mov al, 00h
or  al, al              ; 현재 값이 0인지 확인
jz  DecOverflow         ; ZF = 1 이면 DEC 시 언더플로가 발생할 것임
dec al
```

| 명령어 | 상황 | ZF | 의미 |
|---|---|:-:|---|
| `inc al` | `FFh` → `00h` | 1 | 부호 없는 오버플로 (값이 0으로 되돌아감) |
| `dec al` | `00h` → `FFh` | 0 | 감소 **전**에 ZF=1 이었다면 언더플로가 일어남 |

INC는 결과가 0이 되는 것 자체가 오버플로의 신호이고, DEC는 감소하기 전 값이 0인지(ZF=1) 확인하는 방식으로 판별한다.

---

## 12 ~ 18번 공통 데이터 정의

```asm
.data
myBytes  BYTE 10h, 20h, 30h, 40h
myWords  WORD 3 DUP(?), 2000h
myString BYTE "ABCDE"
```

---

### 12. Insert a directive in the given data that aligns myBytes to an even-numbered address.

주어진 데이터에서 myBytes를 짝수 주소에 정렬시키는 지시어를 삽입하시오.

**답:**

```asm
.data
ALIGN 2
myBytes  BYTE 10h, 20h, 30h, 40h
myWords  WORD 3 DUP(?), 2000h
myString BYTE "ABCDE"
```

`ALIGN 2`는 바로 다음에 선언되는 변수의 시작 주소를 2의 배수(짝수)가 되도록 맞춰준다. 필요하면 어셈블러가 앞에 빈 바이트를 끼워 넣는다.

---

### 13. What will be the value of EAX after each of the following instructions execute?

다음 각 명령어가 실행된 후 EAX의 값은 무엇인가?

**답:**

| 문제 | 명령어 | EAX | 이유 |
|:-:|---|---:|---|
| a | `mov eax, TYPE myBytes` | **1** | BYTE 한 개의 크기 = 1바이트 |
| b | `mov eax, LENGTHOF myBytes` | **4** | 원소 개수 4개 |
| c | `mov eax, SIZEOF myBytes` | **4** | TYPE × LENGTHOF = 1 × 4 |
| d | `mov eax, TYPE myWords` | **2** | WORD 한 개의 크기 = 2바이트 |
| e | `mov eax, LENGTHOF myWords` | **4** | `3 DUP(?)` 3개 + `2000h` 1개 |
| f | `mov eax, SIZEOF myWords` | **8** | 2 × 4 |
| g | `mov eax, SIZEOF myString` | **5** | "ABCDE" 는 5바이트 |

---

### 14. Write a single instruction that moves the first two bytes in myBytes to the DX register. The resulting value will be 2010h.

myBytes의 처음 두 바이트를 DX 레지스터로 옮기는 명령어 한 개를 작성하시오. 결과 값은 2010h가 될 것이다.

**답:**

```asm
mov dx, WORD PTR myBytes        ; DX = 2010h
```

myBytes는 BYTE형이므로 `WORD PTR`로 타입을 덮어써야 16비트로 읽을 수 있다. 메모리에는 `10h 20h` 순서로 저장되어 있고 리틀엔디안으로 읽으면 `20h`가 상위 바이트가 되어 `2010h`가 된다.

---

### 15. Write an instruction that moves the second byte in myWords to the AL register.

myWords의 두 번째 바이트를 AL 레지스터로 옮기는 명령어를 작성하시오.

**답:**

```asm
mov al, BYTE PTR [myWords+1]
```

myWords는 WORD형이므로 `BYTE PTR`로 타입을 바꾸고, 오프셋 +1로 두 번째 **바이트**에 접근한다.

---

### 16. Write an instruction that moves all four bytes in myBytes to the EAX register.

myBytes의 네 바이트 전체를 EAX 레지스터로 옮기는 명령어를 작성하시오.

**답:**

```asm
mov eax, DWORD PTR myBytes      ; EAX = 40302010h
```

`DWORD PTR`로 4바이트를 한 번에 읽는다. 리틀엔디안이므로 `10h 20h 30h 40h`가 `40302010h`로 해석된다.

---

### 17. Insert a LABEL directive in the given data that permits myWords to be moved directly to a 32-bit register.

주어진 데이터에 LABEL 지시어를 삽입하여 myWords를 32비트 레지스터로 직접 옮길 수 있게 하시오.

**답:**

```asm
.data
myBytes   BYTE 10h, 20h, 30h, 40h
myWordsD  LABEL DWORD
myWords   WORD 3 DUP(?), 2000h
myString  BYTE "ABCDE"

.code
mov eax, myWordsD               ; PTR 연산자 없이 32비트로 접근
```

LABEL 지시어는 **저장 공간을 따로 할당하지 않고**, 바로 다음 위치에 다른 타입의 별명을 붙여준다. 덕분에 `DWORD PTR` 없이도 바로 사용할 수 있다.

---

### 18. Insert a LABEL directive in the given data that permits myBytes to be moved directly to a 16-bit register.

주어진 데이터에 LABEL 지시어를 삽입하여 myBytes를 16비트 레지스터로 직접 옮길 수 있게 하시오.

**답:**

```asm
.data
myBytesW  LABEL WORD
myBytes   BYTE 10h, 20h, 30h, 40h
myWords   WORD 3 DUP(?), 2000h
myString  BYTE "ABCDE"

.code
mov ax, myBytesW                ; AX = 2010h
```

`myBytesW`는 `myBytes`와 같은 주소를 가리키지만 WORD 타입으로 선언되어 있어, 16비트 레지스터에 바로 옮길 수 있다.
