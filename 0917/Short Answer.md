# Short Answer 답안

---

### 1. Provide examples of three different instruction mnemonics.

서로 다른 명령어 니모닉의 예를 세 가지 제시하시오.

**답:** **MOV, ADD, SUB**

| 니모닉 | 의미 |
|---|---|
| MOV | 데이터 이동 |
| ADD | 덧셈 |
| SUB | 뺄셈 |
| MUL | 곱셈 |
| JMP | 분기(점프) |
| CALL | 프로시저 호출 |

---

### 2. What is a calling convention, and how is it used in assembly language declarations?

호출 규약(calling convention)이란 무엇이며, 어셈블리어 선언에서 어떻게 사용되는가?

**답:** **프로시저에 인수를 전달하는 방법과 스택을 정리하는 주체를 정한 약속**이다.

`.MODEL` 지시어 뒤에 `STDCALL`, `C` 등으로 지정하며, 이 규약에 따라 인수를 스택에 넣는 순서와 호출 후 스택을 호출자가 정리할지 피호출자가 정리할지가 결정된다.

```asm
.MODEL flat, STDCALL
```

---

### 3. How do you reserve space for the stack in a program?

프로그램에서 스택 공간은 어떻게 확보하는가?

**답:** **`.STACK` 지시어**를 사용한다.

```asm
.STACK 4096
```

---

### 4. Explain why the term assembler language is not quite correct.

'assembler language'라는 용어가 정확하지 않은 이유를 설명하시오.

**답:** **assembler는 언어가 아니라 프로그램(도구)의 이름이기 때문이다.**

어셈블러는 소스 코드를 기계어로 번역하는 프로그램이고, 그 프로그램이 번역하는 대상 언어가 어셈블리어(assembly language)이다. 따라서 언어를 가리킬 때는 'assembly language'라고 해야 한다.

---

### 5. Explain the difference between big endian and little endian. Also, look up the origins of this term on the Web.

빅 엔디언과 리틀 엔디언의 차이를 설명하고, 이 용어의 유래도 조사하시오.

**답:** **여러 바이트로 이루어진 값을 메모리에 저장할 때 바이트 순서가 반대이다.**

| 방식 | 저장 순서 | `12345678h` 저장 결과 |
|---|---|---|
| 빅 엔디언 | 최상위 바이트(MSB)를 낮은 주소에 | `12 34 56 78` |
| 리틀 엔디언 | 최하위 바이트(LSB)를 낮은 주소에 | `78 56 34 12` |

x86 프로세서는 리틀 엔디언을 사용한다.

**유래:** 조너선 스위프트의 소설 『걸리버 여행기』에서 삶은 달걀을 넓은 쪽(big end)으로 깨야 하는지 뾰족한 쪽(little end)으로 깨야 하는지를 두고 다투는 두 세력이 등장한다. 1980년 대니 코언(Danny Cohen)이 바이트 순서 논쟁을 이 이야기에 빗대어 사용하면서 컴퓨터 용어로 자리 잡았다.

---

### 6. Why might you use a symbolic constant rather than an integer literal in your code?

코드에서 정수 리터럴 대신 기호 상수를 사용하는 이유는 무엇인가?

**답:** **값을 바꿀 때 정의한 한 곳만 수정하면 되기 때문이다.**

같은 숫자가 프로그램 여러 곳에 흩어져 있으면 값을 바꿀 때 전부 찾아 고쳐야 하고 빠뜨리기 쉽다. 또한 이름이 붙어 있어 그 숫자가 무엇을 뜻하는지 알기 쉬워 가독성도 좋아진다.

```asm
COUNT = 500
```

---

### 7. How is a source file different from a listing file?

소스 파일과 리스팅 파일은 어떻게 다른가?

**답:**

| 파일 | 내용 |
|---|---|
| 소스 파일 (`.asm`) | 프로그래머가 직접 작성한 어셈블리어 원본 |
| 리스팅 파일 (`.lst`) | 어셈블러가 생성하며, 소스에 더해 기계어 코드, 오프셋 주소, 심볼 테이블이 함께 들어 있음 |

---

### 8. How are data labels and code labels different?

데이터 레이블과 코드 레이블은 어떻게 다른가?

**답:**

| 구분 | 데이터 레이블 | 코드 레이블 |
|---|---|---|
| 콜론 | 붙이지 않음 | 반드시 붙임 (`:`) |
| 위치 | 데이터 세그먼트 | 코드 세그먼트 |
| 용도 | 변수의 위치를 가리킴 | 점프·호출의 목적지를 가리킴 |

```asm
count DWORD 100      ; 데이터 레이블
target:              ; 코드 레이블
```

---

### 9. (True/False): An identifier cannot begin with a numeric digit.

(참/거짓) 식별자는 숫자로 시작할 수 없다.

**답:** **True (참)**

---

### 10. (True/False): A hexadecimal literal may be written as 0x3A.

(참/거짓) 16진수 리터럴은 `0x3A`와 같이 쓸 수 있다.

**답:** **True (참)** — `3Ah`, `0x3A` 두 형식 모두 사용할 수 있다.

---

### 11. (True/False): Assembly language directives execute at runtime.

(참/거짓) 어셈블리어 지시어는 실행 시간에 실행된다.

**답:** **False (거짓)** — 지시어는 어셈블 시간에 어셈블러에게 지시를 내릴 뿐이며, 실행 시간에 수행되는 것은 명령어(instruction)이다.

---

### 12. (True/False): Assembly language directives can be written in any combination of uppercase and lowercase letters.

(참/거짓) 어셈블리어 지시어는 대문자와 소문자를 섞어서 써도 된다.

**답:** **True (참)** — 지시어는 대소문자를 구분하지 않는다. (`.data`, `.DATA`, `.Data` 모두 동일)

---

### 13. Name the four basic parts of an assembly language instruction.

어셈블리어 명령어를 구성하는 네 가지 기본 요소를 말하시오.

**답:** **Label(레이블), Mnemonic(니모닉), Operand(오퍼랜드), Comment(주석)**

```asm
target:  mov   eax, ebx   ; 값 복사
;  ↑       ↑      ↑          ↑
; 레이블  니모닉  오퍼랜드    주석
```

---

### 14. (True/False): MOV is an example of an instruction mnemonic.

(참/거짓) MOV는 명령어 니모닉의 예이다.

**답:** **True (참)**

---

### 15. (True/False): A code label is followed by a colon (:), but a data label does not end with a colon.

(참/거짓) 코드 레이블 뒤에는 콜론(:)이 붙지만, 데이터 레이블은 콜론으로 끝나지 않는다.

**답:** **True (참)**

---

### 16. Show an example of a block comment.

블록 주석의 예를 보이시오.

**답:** **`COMMENT` 지시어**와 임의의 구분 문자를 사용한다.

```asm
COMMENT !
    이 부분은 전부 주석입니다.
    여러 줄을 한 번에 주석 처리할 수 있습니다.
!
```

---

### 17. Why is it not a good idea to use numeric addresses when writing instructions that access variables?

변수에 접근하는 명령어를 작성할 때 숫자 주소를 사용하는 것이 왜 좋지 않은가?

**답:** **프로그램이 바뀌면 주소도 함께 바뀌기 때문이다.**

변수를 추가하거나 순서를 바꾸면 모든 주소가 밀려 해당 명령어를 전부 수정해야 한다. 또한 숫자만 봐서는 어떤 변수인지 알 수 없어 코드를 이해하기 어렵다. 레이블(이름)을 사용하면 어셈블러가 주소를 알아서 계산해 준다.

---

### 18. What type of argument must be passed to the ExitProcess procedure?

`ExitProcess` 프로시저에는 어떤 형식의 인수를 전달해야 하는가?

**답:** **32비트 정수(종료 코드)** — 보통 정상 종료를 뜻하는 0을 전달한다.

```asm
INVOKE ExitProcess, 0
```

---

### 19. Which directive ends a procedure?

프로시저를 끝내는 지시어는 무엇인가?

**답:** **`ENDP`**

```asm
main PROC
    ; ...
main ENDP
```

---

### 20. In 32-bit mode, what is the purpose of the identifier in the END directive?

32비트 모드에서 `END` 지시어에 붙는 식별자의 용도는 무엇인가?

**답:** **프로그램의 시작 지점(진입점)을 어셈블러에게 알려 주는 것이다.**

```asm
END main
```

---

### 21. What is the purpose of the PROTO directive?

`PROTO` 지시어의 용도는 무엇인가?

**답:** **프로시저의 원형(prototype)을 미리 선언하는 것이다.**

프로시저의 이름과 인수를 미리 알려 두면, 실제 정의보다 앞에서 호출하더라도 어셈블러가 인수의 개수와 형식을 검사할 수 있다. `INVOKE`로 호출하려면 반드시 필요하다.

```asm
ExitProcess PROTO, dwExitCode:DWORD
```

---

### 22. (True/False): An Object file is produced by the Linker.

(참/거짓) 목적 파일(Object file)은 링커가 만든다.

**답:** **False (거짓)** — 목적 파일은 **어셈블러**가 만들고, 링커는 이를 모아 실행 파일을 만든다.

---

### 23. (True/False): A Listing file is produced by the Assembler.

(참/거짓) 리스팅 파일은 어셈블러가 만든다.

**답:** **True (참)**

---

### 24. (True/False): A link library is added to a program just before producing an Executable file.

(참/거짓) 링크 라이브러리는 실행 파일을 만들기 직전에 프로그램에 추가된다.

**답:** **True (참)** — 링커가 목적 파일과 링크 라이브러리를 결합하여 실행 파일을 생성한다.

---

### 25. Which data directive creates a 32-bit signed integer variable?

32비트 부호 있는 정수 변수를 만드는 데이터 지시어는 무엇인가?

**답:** **`SDWORD`**

---

### 26. Which data directive creates a 16-bit signed integer variable?

16비트 부호 있는 정수 변수를 만드는 데이터 지시어는 무엇인가?

**답:** **`SWORD`**

---

### 27. Which data directive creates a 64-bit unsigned integer variable?

64비트 부호 없는 정수 변수를 만드는 데이터 지시어는 무엇인가?

**답:** **`QWORD`**

---

### 28. Which data directive creates an 8-bit signed integer variable?

8비트 부호 있는 정수 변수를 만드는 데이터 지시어는 무엇인가?

**답:** **`SBYTE`**

---

### 29. Which data directive creates a 10-byte packed BCD variable?

10바이트 팩드 BCD 변수를 만드는 데이터 지시어는 무엇인가?

**답:** **`TBYTE`**

---

### 데이터 지시어 정리 (25~29번)

| 지시어 | 크기 | 자료형 |
|---|---:|---|
| `SBYTE` | 8비트 | 부호 있는 정수 |
| `BYTE` | 8비트 | 부호 없는 정수 |
| `SWORD` | 16비트 | 부호 있는 정수 |
| `WORD` | 16비트 | 부호 없는 정수 |
| `SDWORD` | 32비트 | 부호 있는 정수 |
| `DWORD` | 32비트 | 부호 없는 정수 |
| `QWORD` | 64비트 | 정수 |
| `TBYTE` | 80비트 (10바이트) | 팩드 BCD |
