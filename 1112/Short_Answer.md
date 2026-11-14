# Short Answer 답안

---

## 1. Which Direction flag setting causes index registers to move backward through memory when executing string primitives?

문자열 기본 명령어를 실행할 때 인덱스 레지스터가 메모리의 역방향으로 이동하게 하는 Direction 플래그 설정은 무엇인가?

**답:**

Direction 플래그가 **1로 설정된 상태(`DF = 1`)**입니다.

**풀이:**

1. Direction 플래그는 문자열 명령어에서 인덱스 레지스터의 이동 방향을 결정합니다.
2. `DF = 1`이면 주소가 감소하여 낮은 주소 방향으로 이동합니다.
3. `STD` 명령으로 Direction 플래그를 1로 설정합니다.[^1]

```asm
std                 ; DF = 1: 역방향으로 처리
```

---

## 2. When a repeat prefix is used with STOSW, what value is added to or subtracted from the index register?

STOSW에 반복 접두사를 사용할 때 인덱스 레지스터에 더하거나 빼는 값은 얼마인가?

**답:**

한 번 실행할 때마다 인덱스 레지스터 `EDI`에 **2바이트**를 더하거나 뺍니다.

**풀이:**

- `STOSW`는 AX의 WORD 값, 즉 2바이트를 메모리에 저장합니다.
- `DF = 0`이면 EDI가 2 증가하고, `DF = 1`이면 EDI가 2 감소합니다.
- 반복 접두사를 사용해도 한 번의 저장에 따른 이동량은 2바이트입니다.[^1]

| Direction 플래그 | EDI의 변화      |
| ---------------- | --------------- |
| `DF = 0`         | `EDI = EDI + 2` |
| `DF = 1`         | `EDI = EDI - 2` |

---

## 3. In what way is the CMPS instruction ambiguous?

CMPS 명령어는 어떤 점에서 모호한가?

**답:**

명시적으로 피연산자를 적을 수 있지만, 실제 비교 대상의 주소는 그 이름이 아니라 `ESI`와 `EDI`에 의해 결정된다는 점에서 모호합니다.

**풀이:**

1. `CMPS`의 명시적 피연산자 형식은 비교 대상의 자료형과 의도를 표시하는 용도로 사용할 수 있습니다.
2. 그러나 적어 놓은 변수 이름이 실제 접근 주소를 지정하는 것은 아닙니다.
3. 32비트 주소 크기에서는 실제로 `DS:[ESI]`와 `ES:[EDI]`의 값을 비교하므로, ESI와 EDI를 올바르게 설정해야 합니다.[^2]

```asm
mov esi, OFFSET source
mov edi, OFFSET target
cmpsb                   ; DS:[ESI]와 ES:[EDI]의 바이트를 비교
```

---

## 4. When the Direction flag is clear and SCASB has found a matching character, where does EDI point?

Direction 플래그가 0이고 SCASB가 일치하는 문자를 찾았다면, EDI는 어디를 가리키는가?

**답:**

일치한 문자 바로 다음 바이트, 즉 **일치한 문자의 주소보다 1바이트 큰 위치**를 가리킵니다.

**풀이:**

1. `SCASB`는 AL과 EDI가 가리키는 바이트를 비교합니다.
2. `DF = 0`이면 비교 직후 EDI가 1 증가합니다.
3. 따라서 일치한 문자의 주소는 검색 종료 후의 `EDI - 1`입니다.[^2]

```asm
; DF = 0이고 일치하는 문자를 찾은 직후
lea eax, [edi-1]         ; EAX = 일치한 문자의 주소
```

---

## 5. When scanning an array for the first occurrence of a particular character, which repeat prefix would be best?

배열에서 특정 문자가 처음 나타나는 위치를 검색할 때 가장 적절한 반복 접두사는 무엇인가?

**답:**

`REPNE` 또는 같은 의미의 `REPNZ`가 가장 적절합니다.

**풀이:**

- `REPNE`는 비교 결과가 같지 않은 동안 반복합니다.
- `SCASB`와 함께 사용하면 문자가 일치하여 ZF가 1이 되거나 ECX가 0이 될 때 종료합니다.
- 배열의 시작부터 검색하려면 `CLD`로 정방향을 설정합니다.[^2][^3]

```asm
cld
mov edi, OFFSET array
mov ecx, LENGTHOF array
mov al, targetChar
repne scasb
; 검색 성공 여부는 ZF로 확인
```

---

## 6. What Direction flag setting is used in the Str_trim procedure from Section 9.3?

9.3절의 Str_trim 프로시저에서는 Direction 플래그를 어떻게 설정하는가?

**답:**

`STD` 명령으로 **Direction 플래그를 1로 설정(`DF = 1`)**합니다.

**풀이:**

1. 이 문제에서 다루는 `Str_trim`은 문자열 끝에서부터 제거할 문자를 검색합니다.
2. `STD`로 역방향을 설정한 뒤 `REPE SCASB`를 사용합니다.
3. 따라서 비교할 때마다 EDI가 1씩 감소합니다.[^4]

```asm
std                     ; DF = 1: 역방향
repe scasb              ; 제거할 문자와 같은 동안 반복
```

---

## 7. Why does the Str_trim procedure from Section 9.3 use the JNE instruction?

9.3절의 Str_trim 프로시저는 왜 JNE 명령어를 사용하는가?

**답:**

제거할 문자와 다른 문자를 만나 검색이 끝났는지 확인하여, EDI의 추가 보정을 건너뛰고 올바른 위치에 널 문자를 넣기 위해 사용합니다.

**풀이:**

1. `REPE SCASB`는 문자가 다르거나 ECX가 0이 되면 종료합니다.
2. 다른 문자를 만났다면 `ZF = 0`이므로 `JNE L1`이 실행됩니다.
3. 이때 EDI는 보존할 마지막 문자보다 한 바이트 앞을 가리키므로 `[EDI+2]`에 널 문자를 넣습니다.
4. 모든 문자가 제거 대상이었다면 `ZF = 1`로 종료합니다. 이 경우 `DEC EDI`로 한 번 더 보정하여 문자열 시작 위치에 널 문자를 넣습니다.[^4]

```asm
    repe scasb
    jne  L1
    dec  edi
L1: mov  BYTE PTR [edi+2],0
```

---

## 8. What happens in the Str_ucase procedure from Section 9.3 if the target string contains a digit?

9.3절의 Str_ucase 프로시저에서 대상 문자열에 숫자가 포함되어 있으면 어떻게 되는가?

**답:**

숫자는 변환되지 않고 **그대로 유지됩니다**.

**풀이:**

- `Str_ucase`는 문자가 소문자 `'a'`부터 `'z'` 사이에 있는 경우에만 대문자로 변환합니다.
- 숫자 `'0'`부터 `'9'`는 이 범위에 속하지 않으므로 변환을 건너뜁니다.[^4]

```asm
; 변환 전: "abc123"
; 변환 후: "ABC123"
```

---

## 9. If the Str_length procedure from Section 9.3 used SCASB, which repeat prefix would be most appropriate?

9.3절의 Str_length 프로시저가 SCASB를 사용한다면 가장 적절한 반복 접두사는 무엇인가?

**답:**

`REPNE` 또는 `REPNZ`입니다.

**풀이:**

1. 문자열 길이를 구하려면 문자열 끝의 널 문자인 0을 찾아야 합니다.
2. AL에 0을 넣고 `REPNE SCASB`를 실행합니다.
3. 널 문자와 일치할 때까지 검색하되, ECX에는 충분한 검색 횟수를 설정해야 합니다.[^2][^3]

```asm
xor al, al              ; AL = 0: 널 문자 검색
repne scasb
```

---

## 10. If the Str_length procedure from Section 9.3 used SCASB, how would it calculate and return the string length?

9.3절의 Str_length 프로시저가 SCASB를 사용한다면 문자열 길이를 어떻게 계산하고 반환하는가?

**답:**

정방향으로 널 문자를 찾은 뒤, 최종 EDI에서 문자열 시작 주소를 빼고 다시 1을 뺀 값을 `EAX`로 반환합니다.

$$\text{문자열 길이} = EDI_{\text{final}} - EDI_{\text{initial}} - 1$$

**풀이:**

1. `CLD`로 정방향을 설정하고 EDI에 문자열 시작 주소를 넣습니다.
2. AL에 0을 넣고 `REPNE SCASB`로 널 문자를 찾습니다.
3. 검색 후 EDI는 널 문자 다음을 가리키므로 주소 차이에서 1을 빼야 합니다.[^2]
4. 아래는 그 원리를 적용한 예시입니다. 유효한 널 종료 문자열이 전달된다고 가정합니다.

```asm
Str_length PROC USES ecx edi,
    pString:PTR BYTE

    cld
    mov edi, pString
    mov ecx, -1
    xor eax, eax
    repne scasb

    mov eax, edi
    sub eax, pString
    dec eax                 ; 널 문자는 길이에서 제외
    ret

Str_length ENDP
```

---

## 11. What is the maximum number of comparisons needed by the binary search algorithm when an array contains 1,024 elements?

배열에 원소가 1,024개 있을 때 이진 검색 알고리즘에 필요한 최대 비교 횟수는 몇 번인가?

**답:**

**11번**입니다.

**풀이:**

1. 중간 원소와 검색값을 비교하는 횟수를 기준으로 합니다.
2. 원소가 n개인 일반적인 이진 검색의 최악 비교 횟수는 다음과 같습니다.[^4]

$$\lfloor \log_2 n \rfloor + 1$$

3. 따라서 1,024개일 때는 다음과 같습니다.

$$\lfloor \log_2 1024 \rfloor + 1 = 10 + 1 = 11$$

이는 검색 단계 수를 뜻하며, 어셈블리 코드에서 실행되는 모든 `CMP` 명령의 총횟수를 의미하지는 않습니다.

---

## 12. In the FillArray procedure from the Binary Search example in Section 9.5, why must the Direction flag be cleared by the CLD instruction?

9.5절 이진 검색 예제의 FillArray 프로시저에서는 왜 CLD 명령으로 Direction 플래그를 0으로 만들어야 하는가?

**답:**

`STOSD`가 값을 저장할 때마다 EDI를 4씩 증가시켜 배열을 정방향으로 채우도록 하기 위해서입니다.

**풀이:**

1. `STOSD`는 EAX의 DWORD 값을 EDI가 가리키는 위치에 저장합니다.
2. `CLD`는 `DF = 0`으로 설정하므로 저장 후 EDI가 4 증가합니다.
3. 반대로 `DF = 1`이면 EDI가 4 감소하여 의도한 방향과 반대로 저장하게 됩니다.[^1]

```asm
cld
; EDI는 배열의 첫 원소를 가리키도록 설정
stosd                   ; [EDI]에 저장한 후 EDI += 4
```

---

## 13. In the BinarySearch procedure from Section 9.5, why could the statement at label L2 be removed without affecting the outcome?

9.5절의 BinarySearch 프로시저에서 L2 레이블의 명령문을 제거해도 결과에 영향을 주지 않는 이유는 무엇인가?

**답:**

앞에서 이미 `CMP EDX, EDI`를 실행했고, L2로 분기하는 `JGE`는 플래그를 바꾸지 않으므로 같은 비교를 반복할 필요가 없기 때문입니다.

**풀이:**

1. 앞선 `CMP EDX, EDI`가 두 값을 비교하여 플래그를 설정합니다.
2. 조건이 맞으면 `JGE L2`로 이동합니다.
3. 이 경로에서는 플래그가 그대로 유지되므로, L2의 중복 `CMP`를 제거해도 뒤의 `JLE L3`는 기존 비교 결과를 사용할 수 있습니다.[^5]

```asm
    cmp edx, edi
    jge L2

    ; EDX < EDI인 경우의 처리
    ; ...

L2: ; cmp edx, edi      ; 중복 비교이므로 제거 가능
    jle L3
```

---

## 14. In the BinarySearch procedure from Section 9.5, how might the statement at label L4 be eliminated?

9.5절의 BinarySearch 프로시저에서 L4 레이블의 명령문은 어떻게 제거할 수 있는가?

**답:**

`JMP L4`를 모두 `JMP L1`으로 바꾸면, L4의 `JMP L1` 명령문을 제거할 수 있습니다.

**풀이:**

1. 원래 코드는 L4로 이동한 다음 다시 L1로 이동합니다.
2. 처음부터 L1으로 직접 이동하도록 바꾸면 중간 경유 지점이 필요하지 않습니다.
3. 따라서 L4로 향하는 분기를 모두 수정한 후 `L4: JMP L1`을 삭제하면 됩니다.[^5]

변경 전:

```asm
    jmp L4
    ; ...

L4: jmp L1
```

변경 후:

```asm
    jmp L1
    ; L4 레이블과 해당 JMP 명령은 삭제
```
