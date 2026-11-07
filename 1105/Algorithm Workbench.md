# Algorithm Workbench

---

## 1. Here is a calling sequence for a procedure named AddThree that adds three doublewords (assume that the STDCALL calling convention is used): push 10h, push 20h, push 30h, call AddThree. Draw a picture of the procedure’s stack frame immediately after EBP has been pushed on the runtime stack.

다음은 세 개의 더블워드를 더하는 AddThree 프로시저의 호출 순서이다(STDCALL 호출 규약을 사용한다고 가정한다).

```asm
push 10h
push 20h
push 30h
call AddThree
```

EBP가 런타임 스택에 푸시된 직후 프로시저의 스택 프레임을 그림으로 나타내시오.

**답:**

```text
             높은 주소
        ┌──────────────────────┐
[EBP+16]│ 10h                  │ 첫 번째로 push한 인수
        ├──────────────────────┤
[EBP+12]│ 20h                  │ 두 번째로 push한 인수
        ├──────────────────────┤
 [EBP+8]│ 30h                  │ 세 번째로 push한 인수
        ├──────────────────────┤
 [EBP+4]│ 복귀 주소             │ CALL이 저장한 주소
        ├──────────────────────┤
   [EBP]│ 호출자의 이전 EBP     │ PUSH EBP로 저장
        └──────────────────────┘
             낮은 주소
```

**풀이:**

1. `push 10h`, `push 20h`, `push 30h` 순서로 인수를 스택에 넣는다. 스택은 낮은 주소 방향으로 자라므로 마지막에 넣은 `30h`가 가장 위쪽에 위치한다.
2. `call AddThree` 명령은 프로시저가 끝난 뒤 돌아갈 복귀 주소를 스택에 저장한다.
3. 프로시저의 프롤로그에서 `push ebp`를 실행하면 호출자의 EBP 값이 스택에 저장된다.
4. 이어서 일반적으로 `mov ebp,esp`를 실행하여 EBP를 현재 스택 프레임의 기준으로 설정한다. 그림의 `[EBP]` 표기는 이 기준 설정이 끝난 상태를 기준으로 한 것이다.
5. 따라서 `[EBP]`에는 이전 EBP, `[EBP+4]`에는 복귀 주소, `[EBP+8]`, `[EBP+12]`, `[EBP+16]`에는 각각 `30h`, `20h`, `10h`가 위치한다.

---

## 2. Create a procedure named AddThree that receives three integer parameters and calculates and returns their sum in the EAX register.

세 개의 정수 매개변수를 받아 합계를 계산하고 EAX 레지스터로 반환하는 AddThree 프로시저를 작성하시오.

**답:**

```asm
AddThree PROC STDCALL,
    num1:DWORD,
    num2:DWORD,
    num3:DWORD

    push ebp
    mov  ebp,esp

    mov  eax,num1
    add  eax,num2
    add  eax,num3

    pop  ebp
    ret  12
AddThree ENDP
```

**풀이:**

1. `num1`, `num2`, `num3`는 각각 4바이트 정수 매개변수이다.
2. 프로시저의 프롤로그에서 `push ebp`와 `mov ebp,esp`를 실행하여 스택 프레임을 설정한다.
3. 첫 번째 매개변수를 EAX에 넣고 두 번째와 세 번째 매개변수를 차례대로 더한다.
4. 계산된 합계는 EAX에 남으므로 반환값이 된다.
5. `pop ebp`로 호출자의 EBP를 복원한다.
6. STDCALL에서는 호출된 프로시저가 스택 매개변수를 정리하므로 `ret 12`를 사용한다. 세 매개변수는 각각 4바이트이므로 총 12바이트이다.

## 3. Declare a local variable named pArray that is a pointer to an array of doublewords.

더블워드 배열을 가리키는 pArray라는 이름의 지역 변수를 선언하시오.

**답:**

```asm
LOCAL pArray:PTR DWORD
```

**풀이:**

`LOCAL`은 프로시저의 지역 변수를 선언하는 지시어이다. `PTR DWORD`는 DWORD를 가리키는 포인터 형식을 의미한다. 따라서 `pArray`는 더블워드 배열의 시작 주소를 저장하는 포인터 지역 변수이다.

## 4. Declare a local variable named buffer that is an array of 20 bytes.

20바이트 배열인 buffer라는 이름의 지역 변수를 선언하시오.

**답:**

```asm
LOCAL buffer[20]:BYTE
```

**풀이:**

`buffer[20]`은 BYTE 원소가 20개인 배열을 의미한다. BYTE 하나는 1바이트이므로 전체 크기는 20바이트이다.

## 5. Declare a local variable named pwArray that points to a 16-bit unsigned integer.

16비트 부호 없는 정수를 가리키는 pwArray라는 이름의 지역 변수를 선언하시오.

**답:**

```asm
LOCAL pwArray:PTR WORD
```

**풀이:**

WORD는 16비트 자료형이다. `PTR WORD`는 WORD형 데이터를 가리키는 포인터 형식이므로 `pwArray`는 16비트 부호 없는 정수의 주소를 저장한다.

## 6. Declare a local variable named myByte that holds an 8-bit signed integer.

8비트 부호 있는 정수를 저장하는 myByte라는 이름의 지역 변수를 선언하시오.

**답:**

```asm
LOCAL myByte:SBYTE
```

**풀이:**

`SBYTE`는 8비트 부호 있는 정수 자료형이다. 따라서 `myByte`는 1바이트 크기의 부호 있는 정수를 저장한다.

## 7. Declare a local variable named myArray that is an array of 20 doublewords.

20개의 더블워드로 이루어진 myArray라는 이름의 지역 배열을 선언하시오.

**답:**

```asm
LOCAL myArray[20]:DWORD
```

**풀이:**

`myArray[20]`은 DWORD 원소가 20개인 배열이다. DWORD 하나는 4바이트이므로 전체 크기는 \(20 \times 4 = 80\)바이트이다.

## 8. Create a procedure named SetColor that receives two stack parameters: forecolor and backcolor, and calls the SetTextColor procedure from the Irvine32 library.

forecolor와 backcolor라는 두 개의 스택 매개변수를 받아 Irvine32 라이브러리의 SetTextColor 프로시저를 호출하는 SetColor 프로시저를 작성하시오.

**답:**

```asm
SetColor PROC STDCALL,
    forecolor:DWORD,
    backcolor:DWORD

    mov  eax,backcolor
    shl  eax,4
    or   eax,forecolor
    call SetTextColor

    ret  8
SetColor ENDP
```

**풀이:**

1. `forecolor`와 `backcolor`를 각각 DWORD 스택 매개변수로 받는다.
2. Irvine32의 `SetTextColor`는 EAX에 지정된 색상 속성값을 전달받는다.
3. 색상 속성값에서 배경색은 상위 4비트에, 전경색은 하위 4비트에 배치한다.
4. `mov eax,backcolor`로 배경색을 EAX에 넣고 `shl eax,4`로 4비트 왼쪽으로 이동한다.
5. `or eax,forecolor`로 전경색을 하위 비트에 결합한다.
6. `call SetTextColor`로 문자 색상을 설정한다.
7. STDCALL이므로 `ret 8`로 두 DWORD 매개변수에 해당하는 8바이트를 정리한다.

## 9. Create a procedure named WriteColorChar that receives three stack parameters: char, forecolor, and backcolor. It displays a single character, using the color attributes specified in forecolor and backcolor.

char, forecolor, backcolor라는 세 개의 스택 매개변수를 받는 WriteColorChar 프로시저를 작성하시오. forecolor와 backcolor에 지정된 색상 속성을 사용하여 문자 하나를 출력하시오.

**답:**

```asm
WriteColorChar PROC STDCALL USES eax,
    char:DWORD,
    forecolor:DWORD,
    backcolor:DWORD

    mov  eax,backcolor
    shl  eax,4
    or   eax,forecolor
    call SetTextColor

    mov  al,BYTE PTR char
    call WriteChar

    ret  12
WriteColorChar ENDP
```

**풀이:**

1. `char`, `forecolor`, `backcolor`를 세 개의 DWORD 스택 매개변수로 받는다.
2. `USES eax`는 프로시저에서 변경하는 EAX의 원래 값을 보존하고 프로시저가 끝날 때 복원하도록 한다.
3. `backcolor`를 EAX에 넣고 4비트 왼쪽으로 이동한 뒤 `forecolor`를 OR 연산으로 결합한다.
4. `SetTextColor`를 호출하여 지정된 전경색과 배경색을 설정한다.
5. `mov al,BYTE PTR char`로 출력할 문자의 하위 1바이트를 AL에 넣는다.
6. Irvine32의 `WriteChar`는 AL에 있는 문자를 출력한다.
7. STDCALL이므로 `ret 12`로 세 DWORD 매개변수에 해당하는 12바이트를 정리한다.

## 10. Write a procedure named DumpMemory that encapsulates the DumpMem procedure in the Irvine32 library. Use declared parameters and the USES directive. The following is an example of how it should be called: INVOKE DumpMemory, OFFSET array, LENGTHOF array, TYPE array.

Irvine32 라이브러리의 DumpMem 프로시저를 감싸는 DumpMemory라는 프로시저를 작성하시오. 선언된 매개변수와 USES 지시어를 사용하시오. 호출 예시는 다음과 같다.

```asm
INVOKE DumpMemory, OFFSET array, LENGTHOF array, TYPE array
```

**답:**

```asm
DumpMemory PROC STDCALL USES esi ecx ebx,
    pArray:PTR BYTE,
    itemCount:DWORD,
    itemSize:DWORD

    mov  esi,pArray
    mov  ecx,itemCount
    mov  ebx,itemSize
    call DumpMem

    ret  12
DumpMemory ENDP
```

**풀이:**

1. `DumpMemory`는 배열의 시작 주소, 원소 개수, 원소 크기를 매개변수로 받는다.
2. Irvine32의 `DumpMem`은 배열의 시작 주소를 ESI, 원소 개수를 ECX, 원소 크기를 EBX에 전달받는다.
3. `mov esi,pArray`로 배열의 시작 주소를 ESI에 넣는다.
4. `mov ecx,itemCount`로 출력할 원소 개수를 ECX에 넣는다.
5. `mov ebx,itemSize`로 각 원소의 크기를 EBX에 넣는다.
6. `USES esi ecx ebx`는 프로시저가 사용하는 레지스터의 기존 값을 보존한다.
7. `call DumpMem`으로 Irvine32의 메모리 덤프 기능을 실행한다.
8. 예시의 `OFFSET array`, `LENGTHOF array`, `TYPE array`는 각각 배열의 시작 주소, 원소 개수, 원소 하나의 크기를 전달한다.
9. STDCALL이므로 `ret 12`로 세 DWORD 매개변수에 해당하는 12바이트를 정리한다.

## 11. Declare a procedure named MultArray that receives two pointers to arrays of doublewords, and a third parameter indicating the number of array elements. Also, create a PROTO declaration for this procedure.

더블워드 배열을 가리키는 포인터 두 개와 배열 원소의 개수를 나타내는 세 번째 매개변수를 받는 MultArray 프로시저를 선언하시오. 또한 이 프로시저의 PROTO 선언도 작성하시오.

**답:**

```asm
MultArray PROTO STDCALL,
    pArray1:PTR DWORD,
    pArray2:PTR DWORD,
    elementCount:DWORD

MultArray PROC STDCALL,
    pArray1:PTR DWORD,
    pArray2:PTR DWORD,
    elementCount:DWORD

    ; 프로시저 본문
    ret  12
MultArray ENDP
```

**풀이:**

1. `PROTO`는 프로시저의 이름과 매개변수 형식을 미리 선언한다.
2. `pArray1`과 `pArray2`는 각각 DWORD 배열을 가리키는 포인터이므로 `PTR DWORD`로 선언한다.
3. `elementCount`는 배열 원소의 개수를 전달받으므로 DWORD로 선언한다.
4. `PROC`는 실제 프로시저의 시작을 나타내며, PROTO 선언과 같은 매개변수 목록을 사용한다.
5. 이 문제는 프로시저의 매개변수와 PROTO 선언을 요구하므로 배열을 실제로 처리하는 코드는 문제의 요구 범위에 포함되지 않는다.
6. STDCALL을 사용하므로 세 DWORD 매개변수는 `ret 12`로 정리한다.
