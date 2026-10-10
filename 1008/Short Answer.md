# Short Answer 답안 (제5장: 절차 호출)

---

## 1. Which instruction pushes all of the 32-bit general-purpose registers on the stack?

모든 32비트 범용 레지스터를 스택에 푸시하는 명령은?

**답:** **PUSHAD**

`PUSHAD`는 EAX, ECX, EDX, EBX, ESP, EBP, ESI, EDI를 이 순서대로 스택에 푸시한다.

---

## 2. Which instruction pushes the 32-bit EFLAGS register on the stack?

32비트 EFLAGS 레지스터를 스택에 푸시하는 명령은?

**답:** **PUSHFD**

`PUSHFD`는 EFLAGS 레지스터의 값을 스택에 푸시한다.

---

## 3. Which instruction pops the stack into the EFLAGS register?

스택을 EFLAGS 레지스터로 팝하는 명령은?

**답:** **POPFD**

`POPFD`는 스택의 최상위 값을 팝해서 EFLAGS 레지스터에 저장한다.

---

## 4. Challenge: Another assembler (called NASM) permits the PUSH instruction to list multiple specific registers. Why might this approach be better than the PUSHAD instruction in MASM?

NASM 어셈블러는 PUSH 명령이 여러 개의 특정 레지스터를 나열할 수 있다. 이 접근법이 MASM의 PUSHAD 명령보다 나을 수 있는 이유는?

**답:** **스택 효율성과 선택적 저장**

| 항목          | PUSHAD          | NASM PUSH                       |
| ------------- | --------------- | ------------------------------- |
| 푸시 레지스터 | 8개 (모두 강제) | 필요한 것만 선택                |
| 스택 공간     | 32바이트        | 4 × n바이트 (n = 레지스터 개수) |
| 장점          | 간단함          | 스택 사용 최소화                |

예를 들어 `PUSH EAX EBX ECX`는 12바이트만 사용하지만, `PUSHAD`는 불필요한 EDX, ESP, EBP, ESI, EDI까지 16바이트 더 낭비한다.

---

## 5. Challenge: Suppose there were no PUSH instruction. Write a sequence of two other instructions that would accomplish the same as push eax.

PUSH 명령이 없다고 가정하면, `push eax`와 같은 동작을 하는 2개 명령의 시퀀스를 작성하시오.

**답:**

```asm
sub esp,4      ; ESP를 4바이트만큼 감소 (스택 공간 할당)
mov [esp],eax  ; EAX를 새로운 스택 위치에 저장
```

**설명:**

1. `sub esp,4`: ESP를 4만큼 줄여서 스택에 4바이트 공간을 만든다
2. `mov [esp],eax`: EAX 값을 그 위치에 쓴다
3. 결과적으로 `push eax`와 동일하게 작동한다

---

## 6. (True/False): The RET instruction pops the top of the stack into the instruction pointer.

(참/거짓) RET 명령은 스택의 최상위 값을 명령 포인터로 팝한다.

**답:** **True (참)**

`RET`은 스택의 최상위에서 반환 주소를 팝해서 EIP(또는 RIP)에 저장한다. 이것이 호출 프로시저로부터의 반환을 가능하게 한다.

---

## 7. (True/False): Nested procedure calls are not permitted by the Microsoft assembler unless the NESTED operator is used in the procedure definition.

(참/거짓) Microsoft 어셈블러는 프로시저 정의에서 NESTED 연산자를 사용하지 않으면 중첩된 프로시저 호출을 허용하지 않는다.

**답:** **False (거짓)**

Microsoft 어셈블러(MASM)는 NESTED 연산자 없이도 중첩 프로시저 호출을 자유롭게 허용한다. NESTED는 USES와 함께 사용할 때만 의미가 있다.

---

## 8. (True/False): In protected mode, each procedure call uses a minimum of 4 bytes of stack space.

(참/거짓) 보호 모드에서 각 프로시저 호출은 최소 4바이트의 스택 공간을 사용한다.

**답:** **True (참)**

프로시저 호출(`CALL`)은 반환 주소(32비트 = 4바이트)를 스택에 푸시한다. 이것이 최소한의 스택 사용이다.

---

## 9. (True/False): The ESI and EDI registers cannot be used when passing 32-bit parameters to procedures.

(참/거짓) 32비트 매개변수를 프로시저에 전달할 때 ESI와 EDI 레지스터를 사용할 수 없다.

**답:** **False (거짓)**

ESI와 EDI는 범용 레지스터이므로 매개변수 전달에 자유롭게 사용할 수 있다. 관례에 따라 사용하면 된다.

---

## 10. (True/False): The ArraySum procedure (Section 5.2.5) receives a pointer to any array of doublewords.

(참/거짓) ArraySum 프로시저는 어떤 더블워드 배열의 포인터든 받을 수 있다.

**답:** **True (참)**

ArraySum은 배열의 시작 주소(포인터)와 요소 개수를 받으므로, 어떤 더블워드 배열이든 처리할 수 있다.

---

## 11. (True/False): The USES operator lets you name all registers that are modified within a procedure.

(참/거짓) USES 연산자는 프로시저 내에서 수정되는 모든 레지스터를 명시할 수 있다.

**답:** **True (참)**

```asm
myProc PROC USES eax ebx ecx
  ; 코드
myProc ENDP
```

USES로 나열한 레지스터는 자동으로 푸시/팝된다.

---

## 12. (True/False): The USES operator only generates PUSH instructions, so you must code POP instructions yourself.

(참/거짓) USES 연산자는 PUSH 명령만 생성하므로 POP 명령은 직접 작성해야 한다.

**답:** **False (거짓)**

USES는 프로시저 시작 시 자동으로 PUSH를 생성하고, 프로시저 끝(RET 전)에 자동으로 POP을 생성한다.

---

## 13. (True/False): The register list in the USES directive must use commas to separate the register names.

(참/거짓) USES 지시자의 레지스터 목록은 레지스터 이름을 쉼표로 구분해야 한다.

**답:** **False (거짓)**

USES에서 레지스터는 **공백**으로 구분한다:

```asm
PROC USES eax ebx ecx    ; 쉼표 없음
```

---

## 14. Which statement(s) in the ArraySum procedure (Section 5.2.5) would have to be modified so it could accumulate an array of 16-bit words? Create such a version of ArraySum and test it.

ArraySum 프로시저가 16비트 워드 배열을 누적할 수 있도록 하려면 어떤 문장(들)을 수정해야 하는가? 이런 버전의 ArraySum을 작성하고 테스트하시오.

**답:**

**수정 사항:**

1. `add eax, [esi]` → `add eax, [esi]` (2바이트만 더함)
2. `add esi, 4` → `add esi, 2` (워드는 2바이트씩 이동)

**WORD 배열용 ArraySum:**

```asm
ArraySumWords PROC
; ECX = 배열 요소 개수
; ESI = 배열 주소
; 반환값: EAX = 합계
  mov eax,0
  test ecx,ecx
  jz done
L1:
  movzx edx, WORD PTR [esi]  ; 부호 없는 확장
  add eax,edx
  add esi,2                  ; 워드는 2바이트
  loop L1
done:
  ret
ArraySumWords ENDP
```

**테스트 코드:**

```asm
.data
myWords WORD 100h, 200h, 300h, 400h
count = 4
.code
main PROC
  mov esi, OFFSET myWords
  mov ecx, count
  call ArraySumWords
  ; EAX = 0A00h (2560)
  INVOKE ExitProcess,0
main ENDP
```

---

## 15. What will be the final value in EAX after these instructions execute?

```asm
push 5
push 6
pop eax
pop eax
```

이 명령들이 실행된 후 EAX의 최종값은?

**답:** **EAX = 5**

| 단계 | 명령      | ESP   | 스택 (높은 주소 → 낮은 주소) | EAX   |
| ---- | --------- | ----- | ---------------------------- | ----- |
| 1    | `push 5`  | ESP-4 | [5]                          | -     |
| 2    | `push 6`  | ESP-8 | [5, 6]                       | -     |
| 3    | `pop eax` | ESP-4 | [5]                          | **6** |
| 4    | `pop eax` | ESP   | []                           | **5** |

마지막에 5가 팝되므로 최종 EAX = 5

---

## 16. Which statement is true about what will happen when the example code runs?

다음 코드가 실행될 때 어떻게 되는지에 대해 참인 문장은?

```asm
 1: main PROC
 2:   push 10
 3:   push 20
 4:   call Ex2Sub
 5:   pop eax
 6:   INVOKE ExitProcess,0
 7: main ENDP
 8:
 9: Ex2Sub PROC
10:   pop eax
11:   ret
12: Ex2Sub ENDP
```

**답:** **d. The program will halt with a runtime error on Line 11**

**스택 분석:**

| 줄  | 스택 상태              | 주소                                    |
| --- | ---------------------- | --------------------------------------- |
| 2   | [10]                   |                                         |
| 3   | [10, 20]               |                                         |
| 4   | [10, 20, **반환주소**] | ← ESP                                   |
| 10  | [10, 20]               | (반환주소 팝됨)                         |
| 11  | [10, **20**]           | RET가 20을 코드 주소로 해석 → 실행 오류 |

**오류 원인:** Ex2Sub에서 `pop eax`가 반환 주소 대신 20을 팝하므로, `ret`에서 잘못된 주소로 점프한다.

---

## 17. Which statement is true about what will happen when the example code runs?

다음 코드가 실행될 때 어떻게 되는지에 대해 참인 문장은?

```asm
 1: main PROC
 2:   mov eax,30
 3:   push eax
 4:   push 40
 5:   call Ex3Sub
 6:   INVOKE ExitProcess,0
 7: main ENDP
 8:
 9: Ex3Sub PROC
10:   pusha
11:   mov eax,80
12:   popa
13:   ret
14: Ex3Sub ENDP
```

**답:** **c. EAX will equal 30 on line 6**

**분석:**

| 줄  | EAX    | 설명                    |
| --- | ------ | ----------------------- |
| 2   | 30     | 초기값                  |
| 3   | 30     | 스택에 푸시             |
| 10  | 30     | PUSHA로 저장 (EAX 포함) |
| 11  | 80     | 변경됨                  |
| 12  | **30** | POPA로 원래값 복원      |
| 6   | **30** | 30 반환                 |

`PUSHA`/`POPA`가 EAX를 저장했다가 복원하므로, 스택에 푸시된 30이 유지된다.

---

## 18. Which statement is true about what will happen when the example code runs?

다음 코드가 실행될 때 어떻게 되는지에 대해 참인 문장은?

```asm
 1: main PROC
 2:   mov eax,40
 3:   push offset Here
 4:   jmp Ex4Sub
 5: Here:
 6:   mov eax,30
 7:   INVOKE ExitProcess,0
 8: main ENDP
 9:
10: Ex4Sub PROC
11:   ret
12: Ex4Sub ENDP
```

**답:** **a. EAX will equal 30 on line 7**

**분석:**

| 줄  | 스택        | 설명                          |
| --- | ----------- | ----------------------------- |
| 3   | [Here 주소] | 수동으로 푸시                 |
| 4   | [Here 주소] | JMP로 이동 (스택 안 건드림)   |
| 11  | []          | RET가 Here 주소를 팝해서 복원 |
| 5-6 | -           | Here 레이블로 돌아와 EAX=30   |

수동으로 반환 주소를 푸시했으므로 RET이 정상 동작한다.

---

## 19. Which statement is true about what will happen when the example code runs?

다음 코드가 실행될 때 어떻게 되는지에 대해 참인 문장은?

```asm
 1: main PROC
 2:   mov edx,0
 3:   mov eax,40
 4:   push eax
 5:   call Ex5Sub
 6:   INVOKE ExitProcess,0
 7: main ENDP
 8:
 9: Ex5Sub PROC
10:   pop eax        ; 반환주소 팝 (40이 아니라 반환주소!)
11:   pop edx        ; 뭔가를 팝
12:   push eax
13:   ret
14: Ex5Sub ENDP
```

**답:** **a. EDX will equal 40 on line 6**

**스택 분석:**

| 줄  | 스택               | EDX    |
| --- | ------------------ | ------ | ------------------- |
| 2   | -                  | 0      |
| 4   | [40]               | 0      |
| 5   | [40, **반환주소**] | 0      |
| 10  | [40]               | 0      | (반환주소 팝 → EAX) |
| 11  | []                 | **40** | (40 팝 → EDX)       |
| 12  | [반환주소]         | 40     |
| 13  | -                  | 40     | (정상 복귀)         |

10번 줄에서 반환주소를 팝했으므로, 11번에서 40이 EDX에 들어간다.

---

## 20. What values will be written to the array when the following code executes?

```asm
.data
array DWORD 4 DUP(0)
.code
main PROC
  mov eax,10
  mov esi,0
  call proc_1
  add esi,4
  add eax,10
  mov array[esi],eax
  INVOKE ExitProcess,0
main ENDP

proc_1 PROC
  call proc_2
  add esi,4
  add eax,10
  mov array[esi],eax
  ret
proc_1 ENDP

proc_2 PROC
  call proc_3
  add esi,4
  add eax,10
  mov array[esi],eax
  ret
proc_2 ENDP

proc_3 PROC
  mov array[esi],eax
  ret
proc_3 ENDP
```

다음 코드가 실행될 때 배열에 기록될 값은?

**답:** **array = [10, 20, 30, 40]**

**실행 순서 추적:**

| 호출   | 위치                       | ESI | EAX | 쓰기         | 배열 상태         |
| ------ | -------------------------- | --- | --- | ------------ | ----------------- |
| main   | proc_3 진입 전             | 0   | 10  | -            | [0,0,0,0]         |
| proc_3 | `mov array[esi],eax`       | 0   | 10  | array[0]=10  | **[10,0,0,0]**    |
| proc_2 | `add esi,4` → `add eax,10` | 4   | 20  | array[4]=20  | **[10,20,0,0]**   |
| proc_1 | `add esi,4` → `add eax,10` | 8   | 30  | array[8]=30  | **[10,20,30,0]**  |
| main   | `add esi,4` → `add eax,10` | 12  | 40  | array[12]=40 | **[10,20,30,40]** |

---

**정리:**

- proc_3에서 ESI=0에 10 저장
- proc_2로 복귀 후 ESI=4에 20 저장
- proc_1로 복귀 후 ESI=8에 30 저장
- main으로 복귀 후 ESI=12에 40 저장

최종 배열: **[10, 20, 30, 40]**
