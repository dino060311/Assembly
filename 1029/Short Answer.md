# Short Answer

## 1. In the following code sequence, show the value of AL after each shift or rotate instruction

has executed:

```asm
mov al,0D4h
shr al,1 ; a.
mov al,0D4h
sar al,1 ; b.
mov al,0D4h
sar al,4 ; c.
mov al,0D4h
rol al,1 ; d.
```

다음 코드에서 각 시프트 또는 회전 명령어가 실행된 후 AL의 값을 구하시오.

**답:**

- **a. `AL = 6Ah`**
- **b. `AL = EAh`**
- **c. `AL = FDh`**
- **d. `AL = A9h`**

**풀이:**

초기값 `D4h`는 2진수로 `11010100`이다.

- **a. `SHR AL, 1`**: 오른쪽으로 1비트 이동하고 왼쪽 빈자리는 0으로 채운다.
  - `11010100` → `01101010` = `6Ah`
- **b. `SAR AL, 1`**: 부호 비트를 유지하면서 오른쪽으로 1비트 이동한다.
  - `11010100` → `11101010` = `EAh`
- **c. `SAR AL, 4`**: 부호 비트인 1을 유지하면서 오른쪽으로 4비트 이동한다.
  - `11010100` → `11111101` = `FDh`
- **d. `ROL AL, 1`**: 왼쪽으로 1비트 회전하며 왼쪽 끝 비트를 오른쪽 끝으로 보낸다.
  - `11010100` → `10101001` = `A9h`

---

## 2. In the following code sequence, show the value of AL after each shift or rotate instruction

has executed:

```asm
mov al,0D4h
ror al,3 ; a.
mov al,0D4h
rol al,7 ; b.
stc
mov al,0D4h
rcl al,1 ; c.
stc
mov al,0D4h
rcr al,3 ; d.
```

다음 코드에서 각 시프트 또는 회전 명령어가 실행된 후 AL의 값을 구하시오.

**답:**

- **a. `AL = 9Ah`**
- **b. `AL = 6Ah`**
- **c. `AL = A9h`**
- **d. `AL = 3Ah`**

**풀이:**

초기값 `D4h`는 2진수로 `11010100`이다.

- **a. `ROR AL, 3`**: 오른쪽으로 3비트 회전한다. 오른쪽으로 밀려 나간 비트는 왼쪽으로 들어온다.
  - `11010100` → `10011010` = `9Ah`
- **b. `ROL AL, 7`**: 왼쪽으로 7비트 회전한다. 이는 오른쪽으로 1비트 회전하는 것과 같다.
  - `11010100` → `01101010` = `6Ah`
- **c. `RCL AL, 1`**: Carry Flag(CF)를 포함하여 왼쪽으로 1비트 회전한다. `STC`로 CF가 1이므로 오른쪽 끝에 1이 들어간다.
  - `CF=1`, `AL=11010100` → `AL=10101001` = `A9h`
- **d. `RCR AL, 3`**: Carry Flag를 포함하여 오른쪽으로 3비트 회전한다. `STC`로 시작 CF는 1이다.
  - 처음 `CF:AL = 1:11010100`
  - 3비트 회전 후 `CF:AL = 1:00111010`
  - `AL = 00111010` = `3Ah`

---

## 3. What will be the contents of AX and DX after the following operation?

```asm
mov dx,0
mov ax,222h
mov cx,100h
mul cx
```

다음 연산이 실행된 후 AX와 DX의 내용은 무엇인가?

**답:**

- **AX = `2200h`**
- **DX = `0002h`**

**풀이:**

`MUL CX`는 AX와 CX를 곱한 결과를 32비트로 만들고, 상위 16비트는 DX에 하위 16비트는 AX에 저장한다.

- AX = `0222h`
- CX = `0100h`
- `0222h × 0100h = 022200h`
- 상위 16비트: DX = `0002h`
- 하위 16비트: AX = `2200h`

---

## 4. What will be the contents of AX after the following operation?

```asm
mov ax,63h
mov bl,10h
div bl
```

다음 연산이 실행된 후 AX의 내용은 무엇인가?

**답:**

- **AX = `0306h`**
- **AL = `06h` (몫)**
- **AH = `03h` (나머지)**

**풀이:**

8비트 레지스터로 나누는 `DIV BL`은 AX를 피제수로 사용한다. 나눗셈 결과의 몫은 AL에, 나머지는 AH에 저장한다.

- 피제수 AX = `0063h` = 99
- 제수 BL = `10h` = 16
- `99 ÷ 16 = 6`, 나머지 3
- AL = `06h`, AH = `03h`
- 따라서 AX = `0306h`

---

## 5. What will be the contents of EAX and EDX after the following operation?

```asm
mov eax,123400h
mov edx,0
mov ebx,10h
div ebx
```

다음 연산이 실행된 후 EAX와 EDX의 내용은 무엇인가?

**답:**

- **EAX = `00012340h`**
- **EDX = `00000000h`**

**풀이:**

32비트 레지스터로 나누는 `DIV EBX`는 EDX:EAX를 64비트 피제수로 사용한다. 몫은 EAX에, 나머지는 EDX에 저장한다.

- 피제수 EDX:EAX = `00000000:00123400h`
- 제수 EBX = `10h`
- `123400h ÷ 10h = 12340h`
- 나머지는 0이다.
- 따라서 EAX = `00012340h`, EDX = `00000000h`

---

## 6. What will be the contents of AX and DX after the following operation?

```asm
mov ax,4000h
mov dx,500h
mov bx,10h
div bx
```

다음 연산이 실행된 후 AX와 DX의 내용은 무엇인가?

**답: `DIV BX` 명령어에서 나눗셈 오류(#DE, Divide Error)가 발생한다.**

**풀이:**

16비트 레지스터로 나누는 `DIV BX`는 DX:AX를 32비트 피제수로 사용한다. 몫은 AX에, 나머지는 DX에 저장한다.

- 피제수 DX:AX = `0500:4000h` = `05004000h`
- 제수 BX = `0010h`
- `05004000h ÷ 0010h = 00500400h`
- 계산된 몫 `00500400h`는 16비트 레지스터 AX에 저장할 수 있는 범위(`0000h`~`FFFFh`)를 초과한다.
- 따라서 **Divide Error(#DE)** 예외가 발생하며, 정상적인 AX와 DX 결과값은 저장되지 않는다.

---

## 7. What will be the contents of BX after the following instructions execute?

```asm
mov bx,5
stc
mov ax,60h
adc bx,ax
```

다음 명령어들이 실행된 후 BX의 내용은 무엇인가?

**답: `BX = 0066h`**

**풀이:**

`STC`는 Carry Flag(CF)를 1로 설정한다. `ADC`는 두 피연산자에 CF까지 더하는 명령어이다.

- BX = 5
- AX = `60h` = 96
- CF = 1
- `BX = 5 + 96 + 1 = 102`
- 102를 16진수로 변환하면 `66h`이다.
- 따라서 BX = `0066h`

---

## 8. Describe the output when the following code executes in 64-bit mode:

```asm
.data
dividend_hi QWORD 00000108h
dividend_lo QWORD 33300020h
divisor QWORD 00000100h
.code
mov rdx,dividend_hi
mov rax,dividend_lo
div divisor
```

다음 코드가 64비트 모드에서 실행될 때 어떤 결과가 발생하는지 설명하시오.

**답: `DIV` 명령어에서 나눗셈 오류(#DE, Divide Error)가 발생한다.**

**풀이:**

64비트 `DIV` 명령어는 RDX:RAX를 128비트 피제수로 사용하고, 몫은 RAX에 나머지는 RDX에 저장한다.

- 피제수 상위 64비트(RDX) = `00000108h`
- 피제수 하위 64비트(RAX) = `33300020h`
- 제수 = `00000100h`

64비트 나눗셈에서 몫이 RAX에 저장될 수 있으려면 RDX가 제수보다 작아야 한다. 하지만 `108h`는 `100h`보다 크므로 몫이 64비트 범위를 초과한다.

따라서 **Divide Error(#DE)** 예외가 발생한다.

---

## 9. The following program is supposed to subtract val2 from val1. Find and correct all logic

errors (CLC clears the Carry flag):

```asm
.data
val1 QWORD 20403004362047A1h
val2 QWORD 055210304A2630B2h
result QWORD 0
.code
mov cx,8 ; loop counter
mov esi,val1 ; set index to start
mov edi,val2
clc ; clear Carry flag
top:
mov al,BYTE PTR[esi] ; get first number
sbb al,BYTE PTR[edi] ; subtract second
mov BYTE PTR[esi],al ; store the result
dec esi
dec edi
loop top
```

다음 프로그램은 val1에서 val2를 빼도록 작성되었다. 모든 논리적 오류를 찾아 수정하시오. (CLC는 Carry Flag를 0으로 초기화한다.)

**답: 수정된 코드는 다음과 같다.**

```asm
.data
val1 QWORD 20403004362047A1h
val2 QWORD 055210304A2630B2h
result QWORD 0

.code
mov cx,8
mov esi,OFFSET val1
mov edi,OFFSET val2
mov ebx,OFFSET result
clc

top:
    mov al,BYTE PTR [esi]
    sbb al,BYTE PTR [edi]
    mov BYTE PTR [ebx],al

    inc esi
    inc edi
    inc ebx
    loop top
```

**풀이:**

원래 코드에는 다음과 같은 오류가 있다.

1. **주소 지정 오류:** `mov esi,val1`과 `mov edi,val2`는 변수의 주소가 아니라 메모리의 값을 레지스터에 가져오려고 한다. 변수의 시작 주소를 저장하려면 `OFFSET`을 사용해야 한다.
2. **결과 저장 위치 오류:** `mov BYTE PTR[esi],al`은 계산 결과를 val1에 덮어쓴다. 결과를 별도로 저장해야 하므로 `[ebx]`에 저장한다.
3. **결과 주소 설정 누락:** 결과를 저장할 주소인 `result`의 시작 주소를 EBX에 넣어야 한다.
4. **인덱스 방향 오류:** x86은 리틀 엔디안 방식으로 데이터를 저장한다. 가장 낮은 주소에 최하위 바이트가 있으므로 `dec`가 아니라 `inc`를 사용해야 한다.

`CLC`는 첫 번째 바이트의 뺄셈 전에 Carry Flag를 0으로 만든다. 이후 `SBB`가 이전 바이트의 빌림(borrow)을 반영하므로 반복문 안에서 다시 `CLC`를 실행하면 안 된다. `INC` 명령어는 Carry Flag를 변경하지 않으므로 빌림 상태를 유지할 수 있다.

---

## 10. What will be the hexadecimal contents of RAX after the following instructions execute in

64-bit mode?

```asm
.data
multiplicand QWORD 0001020304050000h
.code
imul rax,multiplicand, 4
```

다음 명령어들이 64비트 모드에서 실행된 후 RAX의 16진수 값은 무엇인가?

**답: `RAX = 0004080C10140000h`**

**풀이:**

`IMUL`은 부호 있는 곱셈 명령어이다. 세 피연산자 형식에서는 두 번째 피연산자와 세 번째 피연산자를 곱한 결과를 첫 번째 피연산자에 저장한다.

- multiplicand = `0001020304050000h`
- 곱하는 값 = 4
- `0001020304050000h × 4 = 0004080C10140000h`
- 따라서 RAX = `0004080C10140000h`
