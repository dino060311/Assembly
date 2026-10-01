# Short Answer 답안

---

### 1. What will be the value in EDX after each of the lines marked (a) and (b) execute?

```asm
.data
one WORD 8002h
two WORD 4321h
.code
mov edx,21348041h
movsx edx,one      ; (a)
movsx edx,two      ; (b)
```

(a)와 (b)로 표시된 줄이 실행된 뒤 EDX의 값은 각각 얼마인가?

**답:**

| 줄 | EDX 값 | 이유 |
|---|---|---|
| (a) | `FFFF8002h` | `8002h`의 최상위 비트가 1(음수)이므로 상위 16비트를 1로 채운다 |
| (b) | `00004321h` | `4321h`의 최상위 비트가 0(양수)이므로 상위 16비트를 0으로 채운다 |

`MOVSX`는 부호 확장(sign extension)을 수행하므로, 원본의 부호 비트를 상위 비트에 그대로 복사한다.

---

### 2. What will be the value in EAX after the following lines execute?

```asm
mov eax,1002FFFFh
inc ax
```

다음 줄들이 실행된 뒤 EAX의 값은 얼마인가?

**답:** **`10020000h`**

`AX = FFFFh`에 1을 더하면 `0000h`으로 되돌아간다(wrap around). `INC`는 AX만 변경하므로 상위 16비트 `1002h`는 그대로 유지된다.

---

### 3. What will be the value in EAX after the following lines execute?

```asm
mov eax,30020000h
dec ax
```

다음 줄들이 실행된 뒤 EAX의 값은 얼마인가?

**답:** **`3002FFFFh`**

`AX = 0000h`에서 1을 빼면 `FFFFh`가 된다. 상위 16비트 `3002h`는 영향을 받지 않는다.

---

### 4. What will be the value in EAX after the following lines execute?

```asm
mov eax,1002FFFFh
neg ax
```

다음 줄들이 실행된 뒤 EAX의 값은 얼마인가?

**답:** **`10020001h`**

`AX = FFFFh`는 부호 있는 수로 -1이므로, 부호를 바꾸면 +1, 즉 `0001h`이 된다. 상위 16비트는 그대로이다.

---

### 5. What will be the value of the Parity flag after the following lines execute?

```asm
mov al,1
add al,3
```

다음 줄들이 실행된 뒤 Parity 플래그의 값은 얼마인가?

**답:** **PF = 0 (clear)**

결과 `AL = 4 = 00000100b`이며 1인 비트가 1개(홀수)이다. Parity 플래그는 하위 바이트의 1인 비트가 짝수 개일 때 1이 되므로, 여기서는 0이 된다.

---

### 6. What will be the value of EAX and the Sign flag after the following lines execute?

```asm
mov eax,5
sub eax,6
```

다음 줄들이 실행된 뒤 EAX와 Sign 플래그의 값은 얼마인가?

**답:** **EAX = `FFFFFFFFh` (-1), SF = 1**

5 - 6 = -1이고, 결과의 최상위 비트가 1이므로 Sign 플래그가 설정된다.

---

### 7. In the following code, the value in AL is intended to be a signed byte. Explain how the Overflow flag helps, or does not help you, to determine whether the final value in AL falls within a valid signed range.

```asm
mov al,-1
add al,130
```

다음 코드에서 AL의 값은 부호 있는 바이트로 의도된 것이다. AL의 최종 값이 유효한 부호 있는 범위에 들어가는지 판단하는 데 Overflow 플래그가 어떤 도움이 되는지(또는 되지 않는지) 설명하시오.

**답:** **OF = 0이며, 이 경우 Overflow 플래그가 도움이 된다.**

| 항목 | 값 |
|---|---|
| `AL = -1` | `FFh` |
| `130` (8비트) | `82h` = 부호 있는 수로 **-126** |
| 연산 | `FFh + 82h = 181h` → `AL = 81h` |
| 부호 있는 해석 | -1 + (-126) = **-127** |
| Overflow flag | **0** |

130은 부호 있는 바이트 범위(-128 ~ +127)를 벗어나므로, CPU는 이를 `82h`, 즉 -126으로 취급한다. 실제 연산은 -1 + (-126) = -127이고 이는 유효 범위 안에 있으므로 OF가 0으로 유지된다. 즉 **Overflow 플래그는 연산 결과가 부호 있는 범위를 벗어났는지 정확히 알려주므로 판단에 도움이 된다.** 다만 OF는 *결과*의 유효성만 알려줄 뿐, 입력값 130이 애초에 바이트 범위를 넘었다는 사실은 알려주지 못한다.

---

### 8. What value will RAX contain after the following instruction executes?

```asm
mov rax,44445555h
```

다음 명령이 실행된 뒤 RAX에는 어떤 값이 들어 있는가?

**답:** **`0000000044445555h`**

64비트 레지스터에 32비트 상수를 넣으면 상위 32비트는 0으로 채워진다.

---

### 9. What value will RAX contain after the following instructions execute?

```asm
.data
dwordVal DWORD 84326732h
.code
mov rax,0FFFFFFFF00000000h
mov rax,dwordVal
```

다음 명령들이 실행된 뒤 RAX에는 어떤 값이 들어 있는가?

**답:** **`0000000084326732h`**

64비트 레지스터에 32비트 메모리 피연산자를 옮기면 하위 32비트에 값이 들어가고 **상위 32비트는 자동으로 0이 된다.** 따라서 앞 줄에서 넣어둔 `FFFFFFFFh`는 모두 지워진다.

> 참고: MASM은 `mov rax, dwordVal`을 피연산자 크기 불일치 오류로 처리하므로, 실제 코드에서는 `mov eax, dwordVal`로 작성해야 한다. 결과 값은 동일하다.

---

### 10. What value will EAX contain after the following instructions execute?

```asm
.data
dVal DWORD 12345678h
.code
mov ax,3
mov WORD PTR dVal+2,ax
mov eax,dVal
```

다음 명령들이 실행된 뒤 EAX에는 어떤 값이 들어 있는가?

**답:** **`00035678h`**

| 단계 | 메모리 바이트 (낮은 주소 → 높은 주소) |
|---|---|
| 초기 `dVal` | `78 56 34 12` |
| `dVal+2`에 `0003h` 저장 | `78 56 03 00` |
| 읽어온 값 | `00035678h` |

`dVal+2`는 상위 워드 위치이므로, 그 자리에 `0003h`이 덮어써진다.

---

### 11. What will EAX contain after the following instructions execute?

```asm
.data
dVal DWORD ?
.code
mov dVal,12345678h
mov ax,WORD PTR dVal+2
add ax,3
mov WORD PTR dVal,ax
mov eax,dVal
```

다음 명령들이 실행된 뒤 EAX에는 어떤 값이 들어 있는가?

**답:** **`12341237h`**

| 명령 | 결과 |
|---|---|
| `mov dVal,12345678h` | `dVal = 12345678h` |
| `mov ax,WORD PTR dVal+2` | `AX = 1234h` (상위 워드) |
| `add ax,3` | `AX = 1237h` |
| `mov WORD PTR dVal,ax` | 하위 워드가 `1237h`로 교체 |
| `mov eax,dVal` | `EAX = 12341237h` |

---

### 12. (Yes/No): Is it possible to set the Overflow flag if you add a positive integer to a negative integer?

(예/아니오) 양의 정수와 음의 정수를 더할 때 Overflow 플래그가 설정될 수 있는가?

**답:** **No (아니오)**

부호가 서로 다른 두 수를 더하면 결과의 절댓값이 두 피연산자보다 항상 작거나 같으므로, 범위를 벗어날 수 없다.

---

### 13. (Yes/No): Will the Overflow flag be set if you add a negative integer to a negative integer and produce a positive result?

(예/아니오) 음의 정수에 음의 정수를 더했는데 양수 결과가 나왔다면 Overflow 플래그가 설정되는가?

**답:** **Yes (예)**

음수끼리 더했는데 양수가 나왔다는 것은 결과가 표현 범위를 벗어났다는 뜻이므로 OF가 설정된다.

---

### 14. (Yes/No): Is it possible for the NEG instruction to set the Overflow flag?

(예/아니오) NEG 명령이 Overflow 플래그를 설정할 수 있는가?

**답:** **Yes (예)**

예를 들어 `AL = -128 (80h)`에 `NEG`를 적용하면 +128이 되어야 하지만, 부호 있는 바이트의 최댓값은 +127이므로 범위를 벗어나 OF가 설정된다.

---

### 15. (Yes/No): Is it possible for both the Sign and Zero flags to be set at the same time?

(예/아니오) Sign 플래그와 Zero 플래그가 동시에 설정될 수 있는가?

**답:** **No (아니오)**

Zero 플래그가 설정되면 결과가 0이고, 0은 음수가 아니므로 Sign 플래그는 0이 된다. 두 플래그는 동시에 1이 될 수 없다.

---

## 16~19번 공통 변수 정의

```asm
.data
var1 SBYTE -4,-2,3,1
var2 WORD  1000h,2000h,3000h,4000h
var3 SWORD -16,-42
var4 DWORD 1,2,3,4,5
```

---

### 16. For each of the following statements, state whether or not the instruction is valid:

다음 각 문장에 대해 그 명령이 유효한지 아닌지 판단하시오.

**답:**

| 문제 | 명령 | 유효성 | 이유 |
|---|---|---|---|
| a | `mov ax,var1` | **무효** | `var1`은 바이트, `AX`는 워드 — 크기 불일치 |
| b | `mov ax,var2` | **유효** | 둘 다 16비트 |
| c | `mov eax,var3` | **무효** | `var3`은 워드, `EAX`는 더블워드 — 크기 불일치 |
| d | `mov var2,var3` | **무효** | 메모리에서 메모리로 직접 이동 불가 |
| e | `movzx ax,var2` | **무효** | `MOVZX`는 원본이 목적지보다 작아야 함 (워드 → 워드 불가) |
| f | `movzx var2,al` | **무효** | `MOVZX`의 목적지는 레지스터여야 함 |
| g | `mov ds,ax` | **유효** | 범용 레지스터 → 세그먼트 레지스터는 허용 |
| h | `mov ds,1000h` | **무효** | 즉시값(상수)을 세그먼트 레지스터로 직접 이동 불가 |

---

### 17. What will be the hexadecimal value of the destination operand after each of the following instructions execute in sequence?

```asm
mov al,var1        ; a.
mov ah,[var1+3]    ; b.
```

다음 명령들이 순서대로 실행된 뒤 목적지 피연산자의 16진수 값은 각각 얼마인가?

**답:**

`var1`의 메모리 내용: `FC FE 03 01` (-4, -2, 3, 1)

| 줄 | 목적지 | 값 |
|---|---|---|
| a | AL | `FCh` (-4) |
| b | AH | `01h` (1) |

최종적으로 `AX = 01FCh`이다.

---

### 18. What will be the value of the destination operand after each of the following instructions execute in sequence?

```asm
mov ax,var2        ; a.
mov ax,[var2+4]    ; b.
mov ax,var3        ; c.
mov ax,[var3-2]    ; d.
```

다음 명령들이 순서대로 실행된 뒤 목적지 피연산자의 값은 각각 얼마인가?

**답:**

| 줄 | AX 값 | 이유 |
|---|---|---|
| a | `1000h` | `var2`의 첫 번째 원소 |
| b | `3000h` | 4바이트 뒤 = 세 번째 원소 |
| c | `FFF0h` | `var3`의 첫 번째 원소 (-16) |
| d | `4000h` | `var3`보다 2바이트 앞 = `var2`의 마지막 원소 |

---

### 19. What will be the value of the destination operand after each of the following instructions execute in sequence?

```asm
mov edx,var4       ; a.
movzx edx,var2     ; b.
mov edx,[var4+4]   ; c.
movsx edx,var1     ; d.
```

다음 명령들이 순서대로 실행된 뒤 목적지 피연산자의 값은 각각 얼마인가?

**답:**

| 줄 | EDX 값 | 이유 |
|---|---|---|
| a | `00000001h` | `var4`의 첫 번째 원소 |
| b | `00001000h` | `var2 = 1000h`를 영 확장 |
| c | `00000002h` | 4바이트 뒤 = `var4`의 두 번째 원소 |
| d | `FFFFFFFCh` | `var1 = FCh` (-4)를 부호 확장 |
