# Algorithm Workbench 답안

---

## 1. Create a structure named SampleStruct containing two fields: field1, a single 16-bit WORD, and field2, an array of 20 32-bit DWORDs. The initial values of the fields may be left undefined.

SampleStruct라는 구조체를 생성하시오. 이 구조체는 두 개의 필드를 포함한다. field1은 16비트 WORD 하나이고, field2는 32비트 DWORD 20개로 이루어진 배열이다. 필드의 초기값은 정의하지 않아도 된다.

**답:**

```asm
SampleStruct STRUCT
    field1 WORD ?
    field2 DWORD 20 DUP(?)
SampleStruct ENDS
```

**풀이:**

1. `STRUCT`는 구조체의 정의를 시작하고, `ENDS`는 구조체 정의를 끝낸다.
2. `field1 WORD ?`는 초기값이 정해지지 않은 16비트 WORD 필드를 선언한다.
3. `field2 DWORD 20 DUP(?)`는 초기값이 정해지지 않은 DWORD를 20개 선언한다.
4. `?`는 초기값을 지정하지 않는다는 뜻이고, `DUP(?)`는 같은 형태의 공간을 반복해서 만든다.

---

## 2. Write a statement that retrieves the wHour field of a SYSTEMTIME structure.

SYSTEMTIME 구조체의 wHour 필드 값을 가져오는 명령문을 작성하시오.

**답:**

```asm
.data
time SYSTEMTIME <>

.code
mov ax, time.wHour
```

**풀이:**

1. `time SYSTEMTIME <>`는 SYSTEMTIME 형식의 구조체 변수를 선언한다.
2. `time.wHour`는 time 구조체 안에 있는 wHour 필드를 가리킨다.
3. `wHour`는 WORD 크기의 필드이므로 `AX` 레지스터로 값을 가져온다.

---

## 3. Using the following Triangle structure, declare a structure variable and initialize its vertices to (0,0), (5, 0), and (7,6):

다음 Triangle 구조체를 사용하여 구조체 변수를 선언하고 각 꼭짓점을 (0,0), (5, 0), (7,6)으로 초기화하시오.

```asm
Triangle STRUCT
    Vertex1 COORD <>
    Vertex2 COORD <>
    Vertex3 COORD <>
Triangle ENDS
```

**답:**

```asm
myShape Triangle <<0,0>, <5,0>, <7,6>>
```

**풀이:**

1. `myShape`는 Triangle 구조체 형식으로 선언한 구조체 변수이다.
2. Triangle 구조체에는 Vertex1, Vertex2, Vertex3 세 개의 COORD 필드가 있다.
3. 각 COORD 구조체는 X와 Y 좌표를 가지므로 `<0,0>`, `<5,0>`, `<7,6>` 순서로 초기화한다.
4. 바깥쪽 꺾쇠괄호는 Triangle 전체를 초기화하고, 각 안쪽 꺾쇠괄호는 각 COORD 필드의 X, Y 값을 초기화한다.

---

## 4. Declare an array of Triangle structures. Write a loop that initializes Vertex1 of each triangle to random coordinates in the range (0...10, 0...10).

Triangle 구조체 배열을 선언하시오. 각 삼각형의 Vertex1을 (0...10, 0...10) 범위의 임의 좌표로 초기화하는 반복문을 작성하시오.

**답:**

```asm
.data
ARRAY_SIZE = 5
triangles Triangle ARRAY_SIZE DUP(<>)

.code
mov ecx, ARRAY_SIZE
mov esi, 0

L1:
    mov eax, 11
    call RandomRange
    mov triangles[esi].Vertex1.X, ax

    mov eax, 11
    call RandomRange
    mov triangles[esi].Vertex1.Y, ax

    add esi, TYPE Triangle
    loop L1
```

**풀이:**

1. `ARRAY_SIZE = 5`는 배열에 저장할 Triangle 구조체의 개수를 5개로 지정한다.
2. `triangles Triangle ARRAY_SIZE DUP(<>)`는 초기값을 지정하지 않은 Triangle 구조체를 5개 선언한다.
3. Irvine32의 `RandomRange`는 EAX에 전달한 값 n을 기준으로 0부터 n-1까지의 난수를 EAX에 반환한다.
4. 좌표 범위가 0부터 10까지이므로 EAX에 11을 넣고 `RandomRange`를 호출한다.
5. X와 Y 좌표를 각각 난수로 생성한 다음 `Vertex1.X`, `Vertex1.Y`에 저장한다. 좌표 필드는 WORD이므로 AX를 사용한다.
6. `TYPE Triangle`은 Triangle 구조체 하나의 크기이므로, ESI에 이를 더하면 배열의 다음 구조체로 이동한다.
7. ECX가 0이 될 때까지 반복하여 모든 삼각형의 Vertex1 좌표를 초기화한다.

---

## 5. Write a macro named mPrintChar that displays a single character on the screen. It should have two parameters: this first specifies the character to be displayed and the second specifies how many times the character should be repeated. Here is a sample call:

화면에 하나의 문자를 출력하는 mPrintChar라는 매크로를 작성하시오. 매개변수는 두 개이며, 첫 번째 매개변수는 출력할 문자를 지정하고 두 번째 매개변수는 해당 문자를 몇 번 반복할지 지정한다. 다음은 호출 예시이다.

```asm
mPrintChar 'X',20
```

**답:**

```asm
mPrintChar MACRO char,count
    LOCAL temp
    .data
    temp BYTE count DUP(&char),0
    .code
    push edx
    mov edx, OFFSET temp
    call WriteString
    pop edx
ENDM
```

**풀이:**

1. `char`는 출력할 문자이고 `count`는 문자의 반복 횟수이다.
2. `count DUP(&char)`는 매개변수로 전달된 문자를 count번 반복하여 BYTE 배열을 만든다.
3. 마지막의 `0`은 문자열의 끝을 나타내는 널 문자이다.
4. `LOCAL temp`는 매크로를 여러 번 호출해도 temp 레이블이 서로 중복되지 않도록 고유한 레이블을 만든다.
5. `EDX`에 문자열의 시작 주소를 넣고 `WriteString`을 호출하면 반복된 문자가 화면에 출력된다.

---

## 6. Write a macro named mGenRandom that generates a random integer between 0 and n − 1. Let n be the only parameter.

0부터 n − 1 사이의 임의의 정수를 생성하는 mGenRandom이라는 매크로를 작성하시오. n을 유일한 매개변수로 사용한다.

**답:**

```asm
mGenRandom MACRO n
    mov eax, n
    call RandomRange
ENDM
```

**풀이:**

1. `RandomRange` 프로시저는 EAX에 전달된 값 n을 기준으로 0부터 n-1까지의 난수를 생성한다.
2. 따라서 매개변수 n을 EAX에 넣은 뒤 `RandomRange`를 호출한다.
3. 생성된 난수는 EAX에 반환된다.

호출 예시:

```asm
mGenRandom 100        ; EAX에 0부터 99까지의 난수 반환
```

---

## 7. Write a macro named mPromptInteger that displays a prompt and inputs an integer from the user. Pass it a string literal and the name of a doubleword variable. Sample call:

안내 문구를 표시하고 사용자로부터 정수를 입력받는 mPromptInteger라는 매크로를 작성하시오. 문자열 리터럴과 더블워드 변수의 이름을 매개변수로 전달한다. 호출 예시는 다음과 같다.

```asm
.data
minVal DWORD ?

.code
mPromptInteger "Enter the minimum value", minVal
```

**답:**

```asm
mPromptInteger MACRO prompt, returnVal
    mWrite prompt
    call ReadInt
    mov returnVal, eax
ENDM
```

**풀이:**

1. 첫 번째 매개변수 `prompt`는 화면에 표시할 문자열이다.
2. `mWrite prompt`는 Irvine 매크로 라이브러리의 mWrite 매크로를 호출하여 안내 문구를 출력한다.
3. `ReadInt`는 사용자로부터 정수를 입력받고 입력값을 EAX에 반환한다.
4. `mov returnVal, eax`는 입력받은 정수를 두 번째 매개변수로 전달된 DWORD 변수에 저장한다.

---

## 8. Write a macro named mWriteAt that locates the cursor and writes a string literal to the console window. Suggestion: Invoke the mGotoxy and mWrite macros from the book’s macro library.

커서의 위치를 지정하고 문자열 리터럴을 콘솔 창에 출력하는 mWriteAt이라는 매크로를 작성하시오. 교재의 매크로 라이브러리에 있는 mGotoxy와 mWrite 매크로를 호출하는 방법을 사용하시오.

**답:**

```asm
mWriteAt MACRO X,Y,literal
    mGotoxy X,Y
    mWrite literal
ENDM
```

호출 예시:

```asm
mWriteAt 10,5,"Hello, World!"
```

**풀이:**

1. `X`와 `Y`는 커서의 가로 및 세로 위치를 지정한다.
2. `mGotoxy X,Y`는 지정된 위치로 커서를 이동시킨다.
3. `mWrite literal`은 전달된 문자열 리터럴을 콘솔 창에 출력한다.
4. 기존에 제공되는 mGotoxy와 mWrite 매크로를 조합하여 새로운 매크로를 만든 것이다.

---

## 9. Show the expanded code produced by the following statement that invokes the mWriteString macro from Section 10.2.5:

10.2.5절의 mWriteString 매크로를 호출하는 다음 문장이 확장되었을 때 생성되는 코드를 보이시오.

```asm
mWriteStr namePrompt
```

**답:**

```asm
push edx
mov edx, OFFSET namePrompt
call WriteString
pop edx
```

**풀이:**

1. `mWriteStr` 매크로의 매개변수 `buffer` 자리에 `namePrompt`가 전달된다.
2. `push edx`로 기존 EDX 값을 스택에 저장한다.
3. `mov edx, OFFSET namePrompt`로 문자열의 시작 주소를 EDX에 넣는다.
4. `WriteString`을 호출하여 문자열을 출력한다.
5. `pop edx`로 기존 EDX 값을 복원한다.

---

## 10. Show the expanded code produced by the following statement that invokes the mReadString macro from Section 10.2.5:

10.2.5절의 mReadString 매크로를 호출하는 다음 문장이 확장되었을 때 생성되는 코드를 보이시오.

```asm
mReadStr customerName
```

**답:**

```asm
push ecx
push edx
mov edx, OFFSET customerName
mov ecx, (SIZEOF customerName) - 1
call ReadString
pop edx
pop ecx
```

**풀이:**

1. `push ecx`와 `push edx`로 기존 레지스터 값을 스택에 저장한다.
2. `mov edx, OFFSET customerName`으로 입력 문자열을 저장할 버퍼의 시작 주소를 EDX에 넣는다.
3. `mov ecx, (SIZEOF customerName) - 1`은 널 문자를 저장할 공간 1바이트를 제외한 입력 가능 크기를 ECX에 설정한다.
4. `ReadString`을 호출하여 사용자 입력을 customerName 버퍼에 저장한다.
5. `pop edx`와 `pop ecx`로 기존 레지스터 값을 복원한다.

---

## 11. Write a macro named mDumpMemx that receives a single parameter, the name of a variable. Your macro must call the mDumpMem macro from the book’s library, passing it the variable’s offset, number of units, and unit size. Demonstrate a call to the mDumpMemx macro.

변수의 이름 하나를 매개변수로 받는 mDumpMemx라는 매크로를 작성하시오. 이 매크로는 교재의 매크로 라이브러리에 있는 mDumpMem 매크로를 호출해야 하며, 변수의 오프셋, 단위 개수, 단위 크기를 전달해야 한다. mDumpMemx 매크로의 호출 예시도 보이시오.

**답:**

```asm
mDumpMemx MACRO varName
    mDumpMem OFFSET varName, LENGTHOF varName, TYPE varName
ENDM
```

호출 예시:

```asm
.data
myArray DWORD 10h,20h,30h,40h

.code
mDumpMemx myArray
```

**풀이:**

1. `varName`은 메모리 내용을 출력할 변수의 이름이다.
2. `OFFSET varName`은 변수의 시작 주소를 전달한다.
3. `LENGTHOF varName`은 변수에 포함된 원소의 개수를 전달한다.
4. `TYPE varName`은 원소 하나의 크기(바이트 수)를 전달한다.
5. 전달된 세 인수를 사용하여 교재의 `mDumpMem` 매크로를 호출한다.

---

## 12. Show an example of a macro parameter having a default argument initializer.

기본 인수 초기화 값을 가진 매크로 매개변수의 예를 보이시오.

**답:**

```asm
mWriteLn MACRO text:=<" ">
    mWrite text
    call Crlf
ENDM
```

호출 예시:

```asm
mWriteLn
```

**풀이:**

1. `text:=<" ">`는 매크로가 호출될 때 인수가 전달되지 않으면 기본값으로 공백 문자열을 사용한다는 뜻이다.
2. `mWrite text`는 전달된 문자열 또는 기본 공백 문자열을 출력한다.
3. `call Crlf`는 줄바꿈을 수행한다.
4. 따라서 인수 없이 `mWriteLn`을 호출하면 공백 하나를 출력한 뒤 줄을 바꾼다.

---

## 13. Write a short example that uses the IF, ELSE, and ENDIF directives.

IF, ELSE, ENDIF 지시어를 사용하는 간단한 예제를 작성하시오.

**답:**

```asm
mCopyWord MACRO intVal
    IF (TYPE intVal) EQ 2
        mov ax, intVal
    ELSE
        ECHO Invalid operand size
    ENDIF
ENDM
```

호출 예시:

```asm
.data
wordVal WORD 1234h
dwordVal DWORD 12345678h

.code
mCopyWord wordVal
mCopyWord dwordVal
```

**풀이:**

1. `IF (TYPE intVal) EQ 2`는 매개변수로 전달된 변수의 크기가 2바이트인지 확인한다.
2. 조건이 참이면 `mov ax, intVal`을 생성하여 WORD 값을 AX에 저장한다.
3. 조건이 거짓이면 `ELSE` 아래의 `ECHO Invalid operand size`를 실행하여 어셈블리 과정에서 메시지를 표시한다.
4. `ENDIF`는 조건부 어셈블리 블록의 끝을 나타낸다.

---

## 14. Write a statement using the IF directive that checks the value of the constant macro parameter Z; if Z is less than zero, display a message during assembly indicating that Z is invalid.

IF 지시어를 사용하여 상수 매크로 매개변수 Z의 값을 검사하는 문장을 작성하시오. Z가 0보다 작으면 Z가 유효하지 않다는 메시지를 어셈블리 과정에서 표시해야 한다.

**답:**

```asm
mCheck MACRO Z
    IF Z LT 0
        ECHO **** Operand Z is invalid ****
    ENDIF
ENDM
```

호출 예시:

```asm
mCheck -1
```

**풀이:**

1. `IF Z LT 0`은 매개변수 Z가 0보다 작은지 검사한다.
2. 조건이 참이면 `ECHO` 지시어가 어셈블리 과정에서 `Operand Z is invalid` 메시지를 표시한다.
3. 조건이 거짓이면 메시지를 표시하지 않는다.
4. `LT`는 less than을 의미하는 관계 연산자이다.

---

## 15. Write a short macro that demonstrates the use of the & operator when the macro parameter is embedded in a literal string.

매크로 매개변수가 문자열 리터럴 안에 포함되어 있을 때 & 연산자를 사용하는 방법을 보여주는 간단한 매크로를 작성하시오.

**답:**

```asm
CreateString MACRO strVal
    LOCAL temp
    .data
    temp BYTE "Var&strVal",0
    .code
ENDM
```

호출 예시:

```asm
CreateString 1
```

확장되는 문자열:

```asm
"Var1",0
```

**풀이:**

1. 매크로 매개변수 `strVal`을 문자열 리터럴 안에 직접 포함하면 매개변수 이름이 일반 문자처럼 처리될 수 있다.
2. `&` 연산자를 사용하면 문자열 안에서도 매개변수의 값이 치환된다.
3. `CreateString 1`로 호출하면 `"Var&strVal"`이 `"Var1"`로 확장된다.
4. `LOCAL temp`는 매크로가 여러 번 호출될 때 데이터 레이블이 중복되지 않도록 한다.

---

## 16. Assume the following mLocate macro definition:

다음 mLocate 매크로 정의를 가정하시오.

```asm
mLocate MACRO xval,yval
    IF xval LT 0                 ;; xval < 0?
        EXITM                    ;; if so, exit
    ENDIF

    IF yval LT 0                 ;; yval < 0?
        EXITM                    ;; if so, exit
    ENDIF

    mov bx,0                     ;; video page 0
    mov ah,2                     ;; locate cursor
    mov dh,yval
    mov dl,xval
    int 10h                      ;; call the BIOS
ENDM
```

Show the source code generated by the preprocessor when the macro is expanded by each of the following statements:

다음 각 문장으로 매크로를 확장할 때 전처리기가 생성하는 소스 코드를 보이시오.

```asm
.data
row BYTE 15
col BYTE 60

.code
mLocate -2,20
mLocate 10,20
mLocate col,row
```

**답:**

**(1) `mLocate -2,20`**

```asm
; 생성되는 코드 없음
```

**(2) `mLocate 10,20`**

```asm
mov bx,0
mov ah,2
mov dh,20
mov dl,10
int 10h
```

**(3) `mLocate col,row`**

```asm
mov bx,0
mov ah,2
mov dh,row
mov dl,col
int 10h
```

**풀이:**

1. 첫 번째 호출인 `mLocate -2,20`에서는 `xval`에 -2가 전달된다. `IF xval LT 0` 조건이 참이므로 `EXITM`이 실행되어 매크로 확장이 즉시 종료되고 코드가 생성되지 않는다.
2. 두 번째 호출인 `mLocate 10,20`에서는 두 인수가 모두 0보다 작지 않다. 따라서 조건부 블록을 통과하고 BX, AH, DH, DL을 설정한 뒤 BIOS 인터럽트 `int 10h`를 호출하는 코드가 생성된다.
3. 세 번째 호출인 `mLocate col,row`에서는 매개변수 자리에 숫자 대신 변수 이름이 전달된다. 생성되는 명령문에는 해당 인수 이름이 치환되어 `mov dh,row`, `mov dl,col`이 들어간다.
4. `EXITM`은 매크로 확장을 즉시 끝내며, 그 뒤에 있는 명령문은 확장 결과에 포함되지 않는다.
