# Short Answer 답안 - 비트 연산 및 조건 분기

---

## 1. What will be the value of BX after the following instructions execute?

```asm
mov bx,0FFFFh
and bx,6Bh
```

### 풀이

```
  0FFFFh = 1111 1111 1111 1111b
  00006Bh = 0000 0000 0110 1011b
  ─────────────────────────────
  AND결과 = 0000 0000 0110 1011b = 006Bh
```

### 답: **BX = 006Bh**

AND 연산은 양쪽 모두 1인 비트만 1이 되므로, BX의 하위 8비트만 6Bh가 되고 상위 8비트는 모두 0이 된다.

---

## 2. What will be the value of BX after the following instructions execute?

```asm
mov bx,91BAh
and bx,92h
```

### 풀이

```
  91BAh = 1001 0001 1011 1010b
  0092h = 0000 0000 1001 0010b
  ─────────────────────────────
  AND결과 = 0000 0000 1001 0010b = 0092h
```

| 비트 위치 |   91BAh   |   0092h   |    AND    |
| :-------: | :-------: | :-------: | :-------: |
|    7-0    | 1011 1010 | 1001 0010 | 1001 0010 |
|   15-8    | 1001 0001 | 0000 0000 | 0000 0000 |

### 답: **BX = 0092h**

상위 바이트는 0092h와 0000h의 AND이므로 0이고, 하위 바이트는 1001 0010b = 92h이다.

---

## 3. What will be the value of BX after the following instructions execute?

```asm
mov bx,0649Bh
or bx,3Ah
```

### 풀이

```
  0649Bh = 0000 0110 0100 1011b
  0003Ah = 0000 0000 0011 1010b
  ─────────────────────────────
  OR 결과 = 0000 0110 0111 1011b = 067Bh
```

| 비트 위치 |  0649Bh   |  0003Ah   |    OR     |
| :-------: | :-------: | :-------: | :-------: |
|    7-0    | 0100 1011 | 0011 1010 | 0111 1011 |
|   15-8    | 0000 0110 | 0000 0000 | 0000 0110 |

### 답: **BX = 067Bh**

OR 연산은 하나라도 1이면 1이므로, 4Bh | 3Ah = 7Bh가 된다.

---

## 4. What will be the value of BX after the following instructions execute?

```asm
mov bx,029D6h
xor bx,8181h
```

### 풀이

```
  029D6h = 0000 0010 1001 1101 0110b
  8181h  = 1000 0001 1000 0001b
  ─────────────────────────────────
  XOR결과= 1000 0011 0001 1100b = 831Ch
```

| 연산          | 값                       |
| ------------- | ------------------------ |
| 원본 BX       | 029D6h                   |
| 상위 바이트   | 02h                      |
| 하위 바이트   | 9D6h → 하위 바이트는 D6h |
| 0x02 XOR 0x81 | 83h                      |
| 0xD6 XOR 0x81 | 57h                      |
| **최종 결과** | **831Ch**                |

### 답: **BX = 831Ch**

XOR 연산에서 같으면 0, 다르면 1이다.

---

## 5. What will be the value of EBX after the following instructions execute?

```asm
mov ebx,0AFAF649Bh
or ebx,3A219604h
```

### 풀이

```
  0AFAF649Bh = 1010 1111 1010 1111 0110 0100 1001 1011b
  03A219604h = 0011 1010 0010 0001 1001 0110 0000 0100b
  ──────────────────────────────────────────────────
  OR 결과     = 1011 1111 1010 1111 1111 0110 1001 1111b = 0BFAFFB9Fh
```

### 답: **EBX = 0BFAFFB9Fh**

| 바이트 위치 | 0AFAF649Bh | 03A219604h | OR 결과 |
| :---------: | :--------: | :--------: | :-----: |
|   Byte 3    |    0Ah     |    03h     |   0Bh   |
|   Byte 2    |    AFh     |    A2h     |   AFh   |
|   Byte 1    |    64h     |    96h     |   F6h   |
|   Byte 0    |    9Bh     |    04h     |   9Fh   |

---

## 6. What will be the value of RBX after the following instructions execute?

```asm
mov rbx,0AFAF649Bh
xor rbx,0FFFFFFFFh
```

### 풀이

64비트 연산이지만, 0FFFFFFFFh는 32비트이므로 상위 32비트는 0으로 확장된다.

```
  RBX = 0000 0000 AFAF 649Bh
  XOR와 = 0000 0000 FFFF FFFFh
  ───────────────────────────
  결과  = 0000 0000 5050 B664h
```

|  바이트   | AFAF649Bh | FFFFFFFFh | XOR 결과 |
| :-------: | :-------: | :-------: | :------: |
| AF XOR FF |    50h    |
| AF XOR FF |    50h    |
| 64 XOR FF |    9Bh    |
| 9B XOR FF |    64h    |

### 답: **RBX = 0x00000000_5050B664h** (또는 **50B664h**)

XOR 연산에서 FFh와 XOR하면 비트를 모두 반전시키는 것과 같다. (NOT 효과)

---

## 7. In the following instruction sequence, show the resulting value of AL where indicated, in binary:

### a.

```asm
mov al,01101111b
and al,00101101b
```

```
  01101111b
  00101101b
  ─────────
  00101101b = 2Dh
```

**답 (a): `00101101b`**

---

### b.

```asm
mov al,6Dh          ; 0110 1101b
and al,4Ah          ; 0100 1010b
```

```
  0110 1101b = 6Dh
  0100 1010b = 4Ah
  ──────────
  0100 1000b = 48h
```

**답 (b): `01001000b`**

---

### c.

```asm
mov al,00001111b
or al,61h           ; 0110 0001b
```

```
  0000 1111b
  0110 0001b
  ──────────
  0110 1111b = 6Fh
```

**답 (c): `01101111b`**

---

### d.

```asm
mov al,94h          ; 1001 0100b
xor al,37h          ; 0011 0111b
```

```
  1001 0100b
  0011 0111b
  ──────────
  1010 0011b = A3h
```

**답 (d): `10100011b`**

---

## 8. In the following instruction sequence, show the resulting value of AL where indicated, in hexadecimal:

### a.

```asm
mov al,7Ah
not al
```

NOT 연산은 모든 비트를 반전시킨다.

```
  7Ah = 0111 1010b
  NOT = 1000 0101b = 85h
```

**답 (a): `85h`**

---

### b.

```asm
mov al,3Dh          ; 0011 1101b
and al,74h          ; 0111 0100b
```

```
  0011 1101b = 3Dh
  0111 0100b = 74h
  ───────────
  0011 0100b = 34h
```

**답 (b): `34h`**

---

### c.

```asm
mov al,9Bh          ; 1001 1011b
or al,35h           ; 0011 0101b
```

```
  1001 1011b = 9Bh
  0011 0101b = 35h
  ───────────
  1011 1111b = BFh
```

**답 (c): `BFh`**

---

### d.

```asm
mov al,72h          ; 0111 0010b
xor al,0DCh         ; 1101 1100b
```

```
  0111 0010b = 72h
  1101 1100b = DCh
  ───────────
  1010 1110b = AEh
```

**답 (d): `AEh`**

---

## 9. In the following instruction sequence, show the values of the Carry, Zero, and Sign flags where indicated:

### a.

```asm
mov al,00001111b
test al,00000010b
```

TEST는 AND 연산을 하지만 결과를 저장하지 않고 플래그만 변경한다.

```
  0000 1111b
  0000 0010b
  ──────────
  0000 0000b = 0 (결과)
```

결과가 0이므로 **ZF = 1**
결과의 MSB(비트 7) = 0이므로 **SF = 0**
TEST는 CF를 변경하지 않음 (또는 0으로 설정)

**답 (a): CF = 0, ZF = 1, SF = 0**

---

### b.

```asm
mov al,00000110b    ; 6
cmp al,00000101b    ; 5와 비교
```

CMP는 al - 00000101b를 계산: 6 - 5 = 1

```
  결과 = 1 (0이 아님) → ZF = 0
  MSB = 0 → SF = 0
  빌림 없음 → CF = 0 (6 >= 5)
```

**답 (b): CF = 0, ZF = 0, SF = 0**

---

### c.

```asm
mov al,00000101b    ; 5
cmp al,00000111b    ; 7과 비교
```

CMP는 al - 00000111b를 계산: 5 - 7 = -2

```
  결과 = -2 (FEh)
  결과가 0이 아님 → ZF = 0
  MSB(비트 7) = 1 → SF = 1 (음수)
  빌림 발생 (5 < 7) → CF = 1
```

**답 (c): CF = 1, ZF = 0, SF = 1**

---

## 10. Which conditional jump instruction executes a branch based on the contents of ECX?

### 답: **JECXZ (Jump if ECX is Zero)** 또는 **JRCXZ (64비트 모드)**

- **JECXZ**: ECX 레지스터의 값이 0이면 분기
- **JRCXZ**: RCX 레지스터의 값이 0이면 분기 (64비트)

이들은 주로 루프 조건으로 사용된다.

```asm
mov ecx, count
L1:
    ; 루프 본체
    loop L1         ; ECX를 감소시키고 0이 아니면 L1로 분기

; 또는
jecxz SkipLoop      ; ECX = 0이면 루프 스킵
```

---

## 11. How are JA and JNBE affected by the Zero and Carry flags?

### 답

**JA (Jump if Above)** 와 **JNBE (Jump if Not Below or Equal)** 는 동일한 명령어이다.

분기 조건: **CF = 0 AND ZF = 0**

| 플래그 상태 |   분기    |
| ----------- | :-------: |
| CF=0, ZF=0  | ✅ 분기 O |
| CF=0, ZF=1  | ❌ 분기 X |
| CF=1, ZF=0  | ❌ 분기 X |
| CF=1, ZF=1  | ❌ 분기 X |

**의미:**

- **CF = 0**: 빌림 없음 = 부호 없는 피연산자1 >= 피연산자2
- **ZF = 0**: 결과가 0이 아님 = 두 값이 같지 않음
- 둘 다 만족 → 피연산자1 > 피연산자2 (부호 없는 비교)

```asm
cmp eax, ebx
ja Target       ; EAX > EBX 이면 분기 (부호 없는 비교)
```

---

## 12. What will be the final value in EDX after this code executes?

```asm
mov edx,1
mov eax,7FFFh
cmp eax,8000h
jl L1
mov edx,0
L1:
```

### 풀이

```
CMP EAX, 8000h:
  7FFFh = 0111 1111 1111 1111b
  8000h = 1000 0000 0000 0000b

부호 있는 비교:
  7FFFh = +32767 (signed)
  8000h = -32768 (signed)

  7FFFh > 8000h (32767 > -32768) → SF = 0 (OF = 0)
```

- **JL (Jump if Less)**: 부호 있는 비교에서 SF ≠ OF일 때 분기
- SF = 0, OF = 0 → SF = OF → **분기하지 않음**
- `mov edx, 0` 실행

### 답: **EDX = 0**

---

## 13. What will be the final value in EDX after this code executes?

```asm
mov edx,1
mov eax,7FFFh
cmp eax,8000h
jb L1
mov edx,0
L1:
```

### 풀이

```
CMP EAX, 8000h:
  7FFFh = 32767 (unsigned)
  8000h = 32768 (unsigned)

부호 없는 비교:
  7FFFh < 8000h → CF = 1
```

- **JB (Jump if Below)**: 부호 없는 비교에서 CF = 1일 때 분기
- CF = 1 → **분기함**
- `mov edx, 0` 실행 안 함

### 답: **EDX = 1**

---

## 14. What will be the final value in EDX after this code executes?

```asm
mov edx,1
mov eax,7FFFh
cmp eax,0FFFF8000h
jl L2
mov edx,0
L2:
```

### 풀이

```
CMP EAX, 0FFFF8000h:
  EAX   = 0000 7FFFh = 32767 (32비트 → 상위 16비트는 0)
  피연산자 = FFFF8000h = -32768 (32비트 부호 확장)

부호 있는 비교:
  32767 > -32768 → 분기하지 않음
```

- **JL 분기 조건**: SF ≠ OF
- 32767 - (-32768) = 65535 (양수) → SF = 0, OF = 0
- SF = OF → **분기하지 않음**
- `mov edx, 0` 실행

### 답: **EDX = 0**

---

## 15. (True/False): The following code will jump to the label named Target.

```asm
mov eax,-30
cmp eax,-50
jg Target
```

### 풀이

```
CMP EAX, -50:
  -30 vs -50

부호 있는 비교:
  -30 > -50 → True
```

- **JG (Jump if Greater)**: 부호 있는 비교에서 ZF = 0 AND SF = OF일 때 분기
- 결과: -30 - (-50) = 20 (양수) → SF = 0, OF = 0
- ZF = 0, SF = OF → **분기함**

### 답: **True**

---

## 16. (True/False): The following code will jump to the label named Target.

```asm
mov eax,-42
cmp eax,26
ja Target
```

### 풀이

```
부호 없는 비교:
  -42를 부호 없는 정수로 해석: 0FFFFFFD6h (32비트)
  26 = 0000001Ah

  0FFFFFFD6h > 0000001Ah → CF = 0, ZF = 0
```

- **JA (Jump if Above)**: 부호 없는 비교에서 CF = 0 AND ZF = 0일 때 분기
- 조건 만족 → **분기함**

### 답: **True**

---

## 17. What will be the value of RBX after the following instructions execute?

```asm
mov rbx,0FFFFFFFFFFFFFFFFh
and rbx,80h
```

### 풀이

```
  RBX = 1111 1111 1111 1111 ... 1111 1111b (64비트)
  AND = 0000 0000 0000 0000 ... 1000 0000b (80h)
  ──────────────────────────────────────
  결과 = 0000 0000 0000 0000 ... 1000 0000b = 80h
```

### 답: **RBX = 80h** (또는 **0x0000000000000080**)

AND 연산은 양쪽 모두 1인 비트만 1이 되므로, 80h 위치의 비트만 남고 나머지는 0이 된다.

---

## 18. What will be the value of RBX after the following instructions execute?

```asm
mov rbx,0FFFFFFFFFFFFFFFFh
and rbx,808080h
```

### 풀이

```
  RBX = 1111 1111 1111 1111 1111 1111 1111 1111 1111 1111 1111 1111 1111 1111 1111 1111b
  AND = 0000 0000 0000 0000 0000 0000 0000 0000 1000 0000 1000 0000 1000 0000b (808080h)
  ─────────────────────────────────────────────────────────────────────────────
  결과 = 0000 0000 0000 0000 0000 0000 0000 0000 1000 0000 1000 0000 1000 0000b = 808080h
```

### 답: **RBX = 808080h** (또는 **0x0000000000808080**)

---

## 19. What will be the value of RBX after the following instructions execute?

```asm
mov rbx,0FFFFFFFFFFFFFFFFh
and rbx,80808080h
```

### 풀이

```
  RBX = 1111 1111 1111 1111 1111 1111 1111 1111 1111 1111 1111 1111 1111 1111 1111 1111b (64비트)
  AND = 1000 0000 1000 0000 1000 0000 1000 0000b (80808080h 확장)
        = 0000 0000 0000 0000 0000 0000 0000 0000 1000 0000 1000 0000 1000 0000 1000 0000b (64비트)
  ─────────────────────────────────────────────────────────────────────────────
  결과 = 0000 0000 0000 0000 0000 0000 0000 0000 1000 0000 1000 0000 1000 0000 1000 0000b = 80808080h
```

### 답: **RBX = 80808080h** (또는 **0x0000000080808080**)

---

## 요약 표

| 문제 | 답               | 연산 유형        |
| :--: | ---------------- | ---------------- |
|  1   | 006Bh            | AND              |
|  2   | 0092h            | AND              |
|  3   | 067Bh            | OR               |
|  4   | 831Ch            | XOR              |
|  5   | 0BFAFFB9Fh       | OR (32비트)      |
|  6   | 50B664h          | XOR (64비트)     |
|  7a  | 00101101b        | AND              |
|  7b  | 01001000b        | AND              |
|  7c  | 01101111b        | OR               |
|  7d  | 10100011b        | XOR              |
|  8a  | 85h              | NOT              |
|  8b  | 34h              | AND              |
|  8c  | BFh              | OR               |
|  8d  | AEh              | XOR              |
|  9a  | CF=0, ZF=1, SF=0 | TEST             |
|  9b  | CF=0, ZF=0, SF=0 | CMP (a > b)      |
|  9c  | CF=1, ZF=0, SF=1 | CMP (a < b)      |
|  10  | JECXZ / JRCXZ    | 조건 분기        |
|  11  | CF=0 AND ZF=0    | JA/JNBE 분기조건 |
|  12  | 0                | JL (부호있음)    |
|  13  | 1                | JB (부호없음)    |
|  14  | 0                | JL (부호있음)    |
|  15  | True             | JG 분기          |
|  16  | True             | JA 분기          |
|  17  | 80h              | AND (64비트)     |
|  18  | 808080h          | AND (64비트)     |
|  19  | 80808080h        | AND (64비트)     |
