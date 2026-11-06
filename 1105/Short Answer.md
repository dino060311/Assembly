# Short Answer 답안

---

## 1. Which statements belong in a procedure’s epilogue when the procedure has stack parameters and local variables?

스택 매개변수와 지역 변수를 사용하는 프로시저의 에필로그에는 어떤 명령문이 포함되어야 하는가?

**답:**

```asm
    mov esp, ebp
    pop ebp
    ret
```

STDCALL처럼 피호출자가 스택 매개변수까지 정리하는 호출 규약에서는 `RET` 대신 매개변수 바이트 수를 지정한 `RET n`을 사용할 수 있습니다.

**풀이:**

1. 프로시저의 프롤로그에서는 일반적으로 EBP를 스택 프레임의 기준으로 설정하고, 지역 변수를 위한 공간을 확보합니다.
2. `MOV ESP, EBP`는 ESP를 EBP가 가리키는 위치로 되돌려 지역 변수에 사용했던 스택 공간을 정리합니다.
3. `POP EBP`는 호출 전의 EBP 값을 복원합니다.
4. `RET`은 스택에 저장된 복귀 주소를 꺼내 호출한 위치로 돌아갑니다.
5. STDCALL처럼 피호출자가 매개변수 공간까지 정리하는 규약에서는 `RET n`을 사용하여 복귀와 함께 n바이트를 추가로 제거할 수 있습니다.

---

## 2. When a C function returns a 32-bit integer, where is the return value stored?

C 함수가 32비트 정수를 반환할 때, 반환값은 어디에 저장되는가?

**답:**

`EAX` 레지스터에 저장됩니다.

**풀이:**

- 32비트 정수 반환값은 일반적으로 EAX 레지스터를 통해 전달됩니다.
- 함수 호출이 끝난 뒤 반환값을 사용하려면 EAX의 값을 확인하면 됩니다.

```asm
call SomeFunction
; 함수의 32비트 반환값이 EAX에 들어 있음
mov result, eax
```

---

## 3. How does a program using the STDCALL calling convention clean up the stack after a procedure call?

STDCALL 호출 규약을 사용하는 프로그램은 프로시저 호출 후 스택을 어떻게 정리하는가?

**답:**

피호출자(called procedure)가 스택에 전달된 매개변수를 정리합니다. 보통 `RET n` 명령을 사용합니다.

**풀이:**

1. 호출자는 프로시저를 호출하기 전에 매개변수를 스택에 넣습니다.
2. 프로시저가 실행된 후 피호출자가 스택에 전달된 매개변수 공간을 정리합니다.
3. `RET n`은 복귀 주소를 꺼내 호출 위치로 돌아가면서, 추가로 n바이트만큼 ESP를 증가시켜 매개변수 공간을 제거합니다.

예를 들어 매개변수 두 개가 각각 4바이트라면 총 8바이트이므로 다음과 같이 쓸 수 있습니다.

```asm
ret 8
```

---

## 4. How is the LEA instruction more powerful than the OFFSET operator?

LEA 명령어는 OFFSET 연산자보다 어떤 점에서 더 강력한가?

**답:**

`LEA`는 베이스 레지스터, 인덱스 레지스터, 스케일 값, 변위 등을 조합한 유효 주소를 계산할 수 있습니다. 반면 `OFFSET`은 어셈블 시점에 결정되는 변수나 레이블의 오프셋 주소를 가져옵니다.

**풀이:**

`OFFSET`은 변수의 고정된 오프셋을 구할 때 사용합니다.

```asm
.data
array DWORD 10 DUP(?)

.code
mov esi, OFFSET array
```

`LEA`는 주소 계산식 전체를 처리할 수 있습니다.

```asm
mov ebx, 4
mov esi, 2
lea eax, array[ebx + esi*4]
```

위 명령은 `array`의 시작 주소에 EBX와 ESI\*4를 더한 유효 주소를 EAX에 저장합니다.

| 구분             | OFFSET                        | LEA                            |
| ---------------- | ----------------------------- | ------------------------------ |
| 기능             | 변수·레이블의 오프셋을 가져옴 | 유효 주소 계산                 |
| 주소 계산식      | 고정된 오프셋                 | 베이스·인덱스·스케일·변위 조합 |
| 레지스터 값 활용 | 직접 계산하지 않음            | 가능                           |

---

## 5. In the C++ example shown in Section 8.2.3, how much stack space is used by a variable of type int?

8.2.3절에 나온 C++ 예제에서 int형 변수 하나는 스택 공간을 얼마나 사용하는가?

**답:**

4바이트(32비트)입니다.

**풀이:**

- 32비트 환경에서 일반적인 C++ `int` 자료형의 크기는 4바이트입니다.
- 따라서 스택에 저장되는 지역 변수 하나가 `int`형이라면 4바이트의 공간을 사용합니다.

---

## 6. What advantages might the C calling convention have over the STDCALL calling convention?

C 호출 규약은 STDCALL 호출 규약보다 어떤 장점을 가질 수 있는가?

**답:**

C 호출 규약은 호출자가 스택 매개변수를 정리하므로, 가변 개수의 매개변수를 받는 함수(variable-argument function)를 구현하기에 유리합니다.

**풀이:**

1. C 호출 규약에서는 호출한 쪽(caller)이 프로시저 호출 후 스택에 전달한 매개변수를 정리합니다.
2. STDCALL에서는 호출된 쪽(callee)이 매개변수 공간을 정리합니다.
3. C 호출 규약에서는 호출자가 실제로 전달한 인수의 개수와 크기를 알고 있으므로, 다양한 개수의 인수를 받는 함수를 처리하기 쉽습니다.
4. 대표적인 예로 C의 `printf`처럼 인수 개수가 달라질 수 있는 함수가 있습니다.

| 구분               | C 호출 규약 | STDCALL           |
| ------------------ | ----------- | ----------------- |
| 스택 매개변수 정리 | 호출자      | 피호출자          |
| 가변 인수 처리     | 유리함      | 일반적으로 불편함 |

---

## 7. (True/False): When using the PROC directive, all parameters must be listed on the same line.

(True/False): PROC 지시어를 사용할 때 모든 매개변수는 반드시 한 줄에 나열해야 하는가?

**답:**

**False (거짓)**

**풀이:**

- MASM에서는 줄 연속 기호(`\`) 등을 사용하여 긴 PROC 선언을 여러 줄로 나누어 작성할 수 있습니다.
- 따라서 모든 매개변수를 반드시 한 줄에 작성해야 하는 것은 아닙니다.

예시:

```asm
MyProc PROC,
    param1:DWORD,
    param2:DWORD,
    param3:DWORD
```

---

## 8. (True/False): If you pass a variable containing the offset of an array of bytes to a procedure that expects a pointer to an array of words, the assembler will flag this as an error.

(True/False): 바이트 배열의 오프셋을 저장한 변수를 WORD 배열에 대한 포인터를 기대하는 프로시저에 전달하면, 어셈블러가 이를 오류로 표시하는가?

**답:**

**True (참)**

**풀이:**

- 프로시저의 매개변수가 특정 자료형의 포인터를 기대하도록 선언되어 있고 `INVOKE` 등을 통해 인수를 전달하면, MASM은 인수의 자료형과 매개변수의 자료형을 검사할 수 있습니다.
- BYTE 배열의 포인터와 WORD 배열의 포인터는 가리키는 자료형이 다릅니다.
- 따라서 BYTE 배열의 주소를 WORD 포인터 매개변수에 전달하면 자료형 불일치 오류가 발생할 수 있습니다.

핵심은 포인터가 단순히 주소만 전달하는 것이 아니라, 선언된 매개변수의 자료형 정보도 검사될 수 있다는 점입니다.

---

## 9. (True/False): If you pass an immediate value to a procedure that expects a reference parameter, you can generate a general-protection fault.

(True/False): 참조 매개변수를 기대하는 프로시저에 즉시값(immediate value)을 전달하면 일반 보호 오류(general-protection fault)가 발생할 수 있는가?

**답:**

**True (참)**

**풀이:**

1. 참조 매개변수는 값 자체가 아니라 해당 값이 저장된 메모리의 주소를 전달해야 합니다.
2. 즉시값은 메모리 주소가 아니라 숫자 그 자체입니다.
3. 이 값을 주소처럼 사용하여 메모리에 접근하면 잘못된 메모리 위치를 참조할 수 있습니다.
4. 그 결과 접근이 허용되지 않는 메모리 영역을 참조하여 일반 보호 오류(general-protection fault)가 발생할 수 있습니다.

예를 들어 숫자 `5`를 주소처럼 사용하여 `[5]`에 접근하면, 주소 5번지의 메모리를 읽거나 쓰려는 동작이 됩니다. 이는 유효한 데이터 주소가 아닐 수 있습니다.
