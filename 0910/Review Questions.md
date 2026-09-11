# Review Questions 답안

---

### 1. In 32-bit mode, aside from the stack pointer (ESP), what other register points to variables on the stack?

32비트 모드에서 스택 포인터(ESP) 외에, 스택에 있는 변수를 가리키는 레지스터는 무엇인가?

**답:** **EBP** (Extended Base Pointer, 확장 베이스 포인터)

---

### 2. Name at least four CPU status flags.

CPU 상태 플래그를 최소 4개 이상 말하시오.

**답:** Carry, Overflow, Sign, Zero (그 외 Auxiliary Carry, Parity)

| 플래그 | 의미 |
|---|---|
| Carry (CF) | 부호 없는 연산에서 자리올림/빌림 발생 |
| Overflow (OF) | 부호 있는 연산에서 결과가 범위를 벗어남 |
| Sign (SF) | 결과가 음수 |
| Zero (ZF) | 결과가 0 |
| Auxiliary Carry (AF) | 비트 3에서 비트 4로 자리올림 발생 |
| Parity (PF) | 결과의 하위 바이트에 1인 비트가 짝수 개 |

---

### 3. Which flag is set when the result of an unsigned arithmetic operation is too large to fit into the destination?

부호 없는 산술 연산의 결과가 너무 커서 목적지에 담기지 못할 때 설정되는 플래그는 무엇인가?

**답:** **Carry flag (CF, 캐리 플래그)**

---

### 4. Which flag is set when the result of a signed arithmetic operation is either too large or too small to fit into the destination?

부호 있는 산술 연산의 결과가 너무 크거나 너무 작아서 목적지에 담기지 못할 때 설정되는 플래그는 무엇인가?

**답:** **Overflow flag (OF, 오버플로 플래그)**

---

### 5. (True/False): When a register operand size is 32 bits and the REX prefix is used, the R8D register is available for programs to use.

(참/거짓) 레지스터 오퍼랜드 크기가 32비트이고 REX 접두사를 사용하면, 프로그램에서 R8D 레지스터를 사용할 수 있다.

**답:** **True (참)** — R8~R15의 하위 32비트는 R8D~R15D로 접근한다.

---

### 6. Which flag is set when an arithmetic or logical operation generates a negative result?

산술 연산이나 논리 연산이 음수 결과를 만들 때 설정되는 플래그는 무엇인가?

**답:** **Sign flag (SF, 부호 플래그)**

---

### 7. Which part of the CPU performs floating-point arithmetic?

CPU의 어느 부분이 부동소수점 연산을 수행하는가?

**답:** **FPU (Floating-Point Unit, 부동소수점 연산 장치)**

---

### 8. On a 32-bit processor, how many bits are contained in each floating-point data register?

32비트 프로세서에서 각 부동소수점 데이터 레지스터는 몇 비트로 구성되는가?

**답:** **80비트**

---

### 9. (True/False): The x86-64 instruction set is backward-compatible with the x86 instruction set.

(참/거짓) x86-64 명령어 집합은 x86 명령어 집합과 하위 호환된다.

**답:** **True (참)**

---

### 10. (True/False): In current 64-bit chip implementations, all 64 bits are used for addressing.

(참/거짓) 현재의 64비트 칩 구현에서는 64비트 전체가 주소 지정에 사용된다.

**답:** **False (거짓)** — 실제로는 하위 48비트만 주소 지정에 사용된다.

---

### 11. (True/False): The Itanium instruction set is completely different from the x86 instruction set.

(참/거짓) 아이테니엄(Itanium) 명령어 집합은 x86 명령어 집합과 완전히 다르다.

**답:** **True (참)**

---

### 12. (True/False): Static RAM is usually less expensive than dynamic RAM.

(참/거짓) 정적 RAM(SRAM)은 보통 동적 RAM(DRAM)보다 저렴하다.

**답:** **False (거짓)** — SRAM이 DRAM보다 더 비싸다.

---

### 13. (True/False): The 64-bit RDI register is available when the REX prefix is used.

(참/거짓) REX 접두사를 사용하면 64비트 RDI 레지스터를 사용할 수 있다.

**답:** **True (참)**

---

### 14. (True/False): In native 64-bit mode, you can use 16-bit real mode, but not the virtual-8086 mode.

(참/거짓) 네이티브 64비트 모드에서는 16비트 리얼 모드는 사용할 수 있지만 가상 8086 모드는 사용할 수 없다.

**답:** **False (거짓)** — 64비트 모드에서는 리얼 모드와 가상 8086 모드 모두 사용할 수 없다.

---

### 15. (True/False): The x86-64 processors have 4 more general-purpose registers than the x86 processors.

(참/거짓) x86-64 프로세서는 x86 프로세서보다 범용 레지스터가 4개 더 많다.

**답:** **False (거짓)** — R8~R15까지 **8개** 더 많다.

---

### 16. (True/False): The 64-bit version of Microsoft Windows does not support virtual-8086 mode.

(참/거짓) 64비트 버전의 마이크로소프트 윈도우는 가상 8086 모드를 지원하지 않는다.

**답:** **True (참)**

---

### 17. (True/False): DRAM can only be erased using ultraviolet light.

(참/거짓) DRAM은 자외선을 이용해서만 지울 수 있다.

**답:** **False (거짓)** — 자외선으로 지우는 것은 EPROM이다.

---

### 18. (True/False): In 64-bit mode, you can use up to eight floating-point registers.

(참/거짓) 64비트 모드에서는 최대 8개의 부동소수점 레지스터를 사용할 수 있다.

**답:** **True (참)**

---

### 19. (True/False): A bus is a plastic cable that is attached to the motherboard at both ends, but does not sit directly on the motherboard.

(참/거짓) 버스는 양 끝이 메인보드에 연결된 플라스틱 케이블이며, 메인보드 위에 직접 놓이지는 않는다.

**답:** **False (거짓)** — 버스는 메인보드에 인쇄된 병렬 배선의 묶음이다.

---

### 20. (True/False): CMOS RAM is the same as static RAM, meaning that it holds its value without any extra power or refresh cycles.

(참/거짓) CMOS RAM은 정적 RAM과 같아서, 추가 전원이나 리프레시 주기 없이도 값을 유지한다.

**답:** **False (거짓)** — CMOS RAM은 값을 유지하기 위해 배터리 전원이 필요하다.

---

### 21. (True/False): PCI connectors are used for graphics cards and sound cards.

(참/거짓) PCI 커넥터는 그래픽 카드와 사운드 카드에 사용된다.

**답:** **True (참)**

---

### 22. (True/False): The 8259A is a controller that handles external interrupts from hardware devices.

(참/거짓) 8259A는 하드웨어 장치로부터 오는 외부 인터럽트를 처리하는 컨트롤러이다.

**답:** **True (참)** — PIC(Programmable Interrupt Controller)이다.

---

### 23. (True/False): The acronym PCI stands for programmable component interface.

(참/거짓) PCI는 programmable component interface의 약자이다.

**답:** **False (거짓)** — **Peripheral Component Interconnect**의 약자이다.

---

### 24. (True/False): VRAM stands for virtual random access memory.

(참/거짓) VRAM은 virtual random access memory의 약자이다.

**답:** **False (거짓)** — **Video RAM**의 약자이다.

---

### 25. At which level(s) can an assembly language program manipulate input/output?

어셈블리어 프로그램은 어느 수준(레벨)에서 입출력을 다룰 수 있는가?

**답:** **모든 수준에서 가능하다.**

| 수준 | 설명 |
|---|---|
| 하드웨어 (레벨 1) | 장치의 포트에 직접 입출력 |
| BIOS (레벨 2) | BIOS 서비스 루틴 호출 |
| 운영체제 (레벨 3) | OS가 제공하는 함수/API 호출 |

고급 언어는 보통 운영체제 수준으로 제한되지만, 어셈블리어는 세 수준을 모두 사용할 수 있다.

---

### 26. Why do game programs often send their sound output directly to the sound card's hardware ports?

게임 프로그램은 왜 사운드 출력을 사운드 카드의 하드웨어 포트로 직접 보내는 경우가 많은가?

**답:** **속도 때문이다.**

운영체제나 BIOS를 거치는 계층은 범용으로 만들어져 있어 처리 과정이 느리다. 게임은 실시간으로 소리를 출력해야 하므로, 중간 계층을 건너뛰고 하드웨어 포트에 직접 접근하여 지연을 줄이고 성능을 최대한 끌어올린다.
