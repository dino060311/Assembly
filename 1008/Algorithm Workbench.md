# Algorithm Workbench 답안

---

### 1. Write a sequence of statements that use only PUSH and POP instructions to exchange the values in the EAX and EBX registers (or RAX and RBX in 64-bit mode).

PUSH와 POP 명령어만을 사용하여 EAX와 EBX 레지스터의 값을 교환하는 명령어 시퀀스를 작성하시오. (64비트 모드에서는 RAX와 RBX)

**답:**

```asm
; 32-bit mode
push eax                ; 스택에 EAX 저장
push ebx                ; 스택에 EBX 저장
pop eax                 ; EAX ← EBX (스택에서 팝)
pop ebx                 ; EBX ← EAX (스택에서 팝)
```

또는 더 간단하게:

```asm
push eax                ; 스택에 EAX 저장
mov eax, ebx            ; EAX ← EBX
pop ebx                 ; EBX ← EAX (스택에서 팝)
```

**스택 상태 추적:**

| 단계       | EAX     | EBX     | 스택 (하단→상단) |
| ---------- | ------- | ------- | ---------------- |
| 초기       | 10h     | 20h     | [비어있음]       |
| `push eax` | 10h     | 20h     | [10h]            |
| `push ebx` | 10h     | 20h     | [10h, 20h]       |
| `pop eax`  | **20h** | 20h     | [10h]            |
| `pop ebx`  | 20h     | **10h** | [비어있음]       |

**최종 결과:**

- EAX = 20h (원래 EBX의 값)
- EBX = 10h (원래 EAX의 값)

LIFO(Last In First Out) 특성을 이용하여 스택을 임시 저장소로 사용한다.

---

### 2. Suppose you wanted a subroutine to return to an address that was 3 bytes higher in memory than the return address currently on the stack. Write a sequence of instructions that would be inserted just before the subroutine's RET instruction that accomplish this task.

서브루틴이 현재 스택에 있는 반환 주소보다 메모리에서 3바이트 높은 주소로 돌아가길 원한다면, 서브루틴의 RET 명령어 직전에 삽입할 명령어 시퀀스를 작성하시오.

**답:**

```asm
MySubroutine PROC
    ; ... 서브루틴 본체 ...

    pop eax                 ; 스택에서 반환 주소 팝
    add eax, 3              ; 반환 주소에 3을 더함
    push eax                ; 수정된 주소를 다시 스택에 넣음
    ret                     ; 수정된 주소로 돌아감

MySubroutine ENDP
```

**스택 상태 추적:**

| 단계         | ESP   | 스택 [ESP] | EAX            |
| ------------ | ----- | ---------- | -------------- |
| RET 직전     | 1000h | 1005h      | ???            |
| `pop eax`    | 1004h | ???        | **1005h**      |
| `add eax, 3` | 1004h | ???        | **1008h**      |
| `push eax`   | 1000h | **1008h**  | 1008h          |
| `ret`        | 1004h | -          | (1008h로 점프) |

**핵심:**

- `pop`: 스택에서 반환 주소를 꺼냄
- `add`: 3을 더해서 주소를 조정
- `push`: 조정된 주소를 다시 스택에 넣음
- `ret`: 수정된 주소로 제어 이동

---

### 3. Functions in high-level languages often declare local variables just below the return address on the stack. Write an instruction that you could put at the beginning of an assembly language subroutine that would reserve space for two integer doubleword variables. Then, assign the values 1000h and 2000h to the two local variables.

고급 언어의 함수들은 반환 주소 아래에 로컬 변수를 선언하는 경우가 많다. 두 개의 정수 더블워드 변수를 위한 공간을 예약하는 명령어를 서브루틴의 시작 부분에 작성하시오. 그 다음 두 로컬 변수에 각각 1000h와 2000h 값을 할당하시오.

**답:**

```asm
MySubroutine PROC
    sub esp, 8              ; 8바이트 (2 × DWORD) 예약

    ; 로컬 변수 초기화
    mov DWORD PTR [esp], 1000h      ; 첫 번째 DWORD (오프셋 0)
    mov DWORD PTR [esp+4], 2000h    ; 두 번째 DWORD (오프셋 4)

    ; ... 서브루틴 본체 ...

    add esp, 8              ; 스택 정리
    ret

MySubroutine ENDP
```

**스택 레이아웃:**

```
ESP → [1000h]       ← 첫 번째 로컬 변수 (offset 0)
      [2000h]       ← 두 번째 로컬 변수 (offset 4)
      [반환주소]
      [이전 ESP]
```

**단계별 실행:**

| 단계                 | ESP   | [ESP]     | [ESP+4]   |
| -------------------- | ----- | --------- | --------- |
| 서브루틴 진입 후     | 1000h | 반환주소  | ?         |
| `sub esp, 8`         | 0FF8h | ?         | ?         |
| `mov [esp], 1000h`   | 0FF8h | **1000h** | ?         |
| `mov [esp+4], 2000h` | 0FF8h | 1000h     | **2000h** |

**핵심:**

- `sub esp, 8`: 스택 포인터를 8바이트 내려서 공간 예약
- `DWORD PTR`: 4바이트 크기 지정
- `[esp]` 와 `[esp+4]`: 두 개의 로컬 변수에 접근
- `add esp, 8`: 함수 반환 전 스택 정리

---

### 4. Write a sequence of statements using indexed addressing that copies an element in a doubleword array to the previous position in the same array.

인덱스 주소 지정을 사용하여 더블워드 배열의 요소를 같은 배열의 이전 위치로 복사하는 명령어 시퀀스를 작성하시오.

**답:**

```asm
.data
array DWORD 10, 20, 30, 40, 50

.code
    mov esi, 4              ; esi = 4 (두 번째 요소부터 시작, 배열은 0부터 인덱싱)
    mov ecx, 4              ; ecx = 4 (반복 횟수, 배열 크기 - 1)

CopyLoop:
    mov eax, array[esi*4]   ; EAX ← array[esi]
    mov array[esi*4-4], eax ; array[esi-1] ← EAX (이전 위치에 복사)
    dec esi                 ; esi 감소
    loop CopyLoop
```

**배열 상태 추적:**

| 반복 | esi | 복사 연산                | 배열 상태                |
| ---- | --- | ------------------------ | ------------------------ |
| 초기 | -   | -                        | [10, 20, 30, 40, 50]     |
| 1차  | 4   | array[3] ← array[4] (50) | [10, 20, 30, 40, **50**] |
| 2차  | 3   | array[2] ← array[3] (40) | [10, 20, 30, **40**, 50] |
| 3차  | 2   | array[1] ← array[2] (30) | [10, 20, **30**, 40, 50] |
| 4차  | 1   | array[0] ← array[1] (20) | [10, **20**, 30, 40, 50] |

**최종 결과:**
배열이 한 칸씩 오른쪽으로 시프트됨: [10, 20, 30, 40, 50]

**핵심:**

- 배열[esi*4]: 배율 4를 사용한 인덱스 주소 지정
- 배열[esi*4-4]: 이전 위치(esi-1)에 해당
- 역순 루프(4→1): 데이터를 덮어쓰지 않기 위해 끝에서 처음으로 진행

---

### 5. Write a sequence of statements that display a subroutine's return address. Be sure that whatever modifications you make to the stack do not prevent the subroutine from returning to its caller.

서브루틴의 반환 주소를 표시하는 명령어 시퀀스를 작성하시오. 스택을 수정하여 서브루틴이 호출자에게 올바르게 돌아갈 수 없게 되지 않도록 주의하시오.

**답:**

```asm
MySubroutine PROC
    ; 방법 1: 스택 포인터를 사용하여 직접 접근 (스택 무손상)
    mov eax, [esp]          ; EAX ← 반환 주소 (스택에서 팝하지 않음)
    call DisplayAddress     ; EAX 값 표시
    ret                     ; 정상적으로 반환

MySubroutine ENDP

; 또는 방법 2: 팝 후 다시 푸시 (임시 저장)
MySubroutine2 PROC
    pop eax                 ; 반환 주소를 EAX에 팝
    push eax                ; 즉시 다시 스택에 푸시
    call DisplayAddress     ; EAX 값 표시
    ret                     ; 정상적으로 반환

MySubroutine2 ENDP
```

**스택 상태 비교:**

**방법 1 (권장):**

```
서브루틴 진입 직후
ESP → [반환주소]
      [이전 스택]

mov eax, [esp]  후
ESP → [반환주소]  ← EAX도 같은 값을 가짐
      [이전 스택]

ret 실행
ESP는 자동으로 조정되고 반환주소로 점프
```

**방법 2:**

```
서브루틴 진입 직후
ESP → [반환주소]

pop eax 후
ESP → [이전 스택]
EAX = 반환주소

push eax 후
ESP → [반환주소]  ← 다시 정상 상태

ret 실행
정상적으로 반환
```

**단계별 비교:**

| 단계          | 방법 1           | 방법 2      |
| ------------- | ---------------- | ----------- |
| 반환주소 획득 | `mov eax, [esp]` | `pop eax`   |
| 스택 상태     | 불변             | 일시적 변경 |
| 복잡도        | 낮음             | 중간        |
| 성능          | 우수             | 보통        |

**핵심:**

- **방법 1**: `[ESP]`로 직접 접근 — 가장 안전하고 빠름
- **방법 2**: POP → 사용 → PUSH — 스택을 임시로 변경하지만 복구
- 두 방법 모두 `ret` 실행 시 스택이 원래 상태여야 함
