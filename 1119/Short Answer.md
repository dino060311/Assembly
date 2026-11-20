# Short Answer 답안

---

## 1. What is the purpose of the STRUCT directive?

STRUCT 지시어의 목적은 무엇인가?

**답:**

관련된 여러 데이터를 하나의 사용자 정의 자료형으로 묶는 **구조체의 틀(템플릿)을 정의**하는 것입니다.

**풀이:**

1. `STRUCT`와 `ENDS` 사이에 구조체에 포함될 필드의 이름과 자료형을 선언합니다.
2. 각 필드는 BYTE, WORD, DWORD 등 서로 다른 자료형을 가질 수 있습니다.
3. 구조체 정의 자체는 실제 변수를 생성하는 것이 아니라 구조체의 형식을 정합니다. 실제 메모리 공간은 해당 구조체형의 변수를 선언할 때 마련됩니다.[^1]

```asm
Student STRUCT
    studentID DWORD ?
    score     WORD  ?
Student ENDS

student1 Student <>    ; Student 구조체형 변수 선언
```

---

## 2. Assume that the following structure has been defined:

```asm
RentalInvoice STRUCT
invoiceNum BYTE 5 DUP(' ')
dailyPrice WORD ?
daysRented WORD ?
RentalInvoice ENDS
```

State whether or not each of the following declarations is valid:

a. rentals RentalInvoice <>

b.
RentalInvoice rentals <>

c. march RentalInvoice <'12345',10,0>

d. RentalInvoice <,10,0>

e. current RentalInvoice <,15,0,0>

다음 구조체가 정의되어 있다고 가정하자.

```asm
RentalInvoice STRUCT
invoiceNum BYTE 5 DUP(' ')
dailyPrice WORD ?
daysRented WORD ?
RentalInvoice ENDS
```

다음 각 선언이 유효한지 여부를 말하시오.

**답:**

| 항목                                    | 유효 여부     | 이유                                                           |
| --------------------------------------- | ------------- | -------------------------------------------------------------- |
| a. `rentals RentalInvoice <>`           | 유효          | 변수 이름, 구조체형 이름, 초기화 목록의 순서가 올바릅니다.     |
| b. `RentalInvoice rentals <>`           | 유효하지 않음 | 변수 이름과 구조체형 이름의 순서가 바뀌었습니다.               |
| c. `march RentalInvoice <'12345',10,0>` | 유효          | 세 필드의 자료형과 초기화 값이 올바르게 대응합니다.            |
| d. `RentalInvoice <,10,0>`              | 유효하지 않음 | 구조체 변수를 선언하는 식별자(변수 이름)가 없습니다.           |
| e. `current RentalInvoice <,15,0,0>`    | 유효하지 않음 | 구조체 필드는 세 개이지만 초기화 값이 네 개 지정되어 있습니다. |

**풀이:**

1. 구조체 변수 선언의 기본 형식은 `변수이름 구조체형이름 <초기화 목록>`입니다.
2. 빈 꺾쇠괄호 `<>`는 구조체 정의에 지정된 기본 초기값을 사용한다는 뜻이므로 a는 유효합니다.
3. b는 구조체형 이름이 변수 이름보다 먼저 나와 선언 순서가 잘못되었습니다.
4. c는 `invoiceNum`에 5개의 문자 `'12345'`를 넣고, `dailyPrice`에 10, `daysRented`에 0을 넣으므로 유효합니다.
5. d는 변수 이름이 빠져 있어 유효한 구조체 변수 선언이 아닙니다.
6. e는 첫 번째 필드를 비워 두고 두 번째 필드에 15, 세 번째 필드에 0을 지정한 뒤 값 0을 하나 더 지정했습니다. 구조체에 대응하는 필드가 더 없으므로 유효하지 않습니다.[^1]

---

## 3. (True/False): A macro cannot contain data definitions.

(참/거짓): 매크로는 데이터 정의를 포함할 수 없다.

**답:**

**False (거짓)**입니다.

**풀이:**

1. 매크로에는 실행 명령어뿐만 아니라 데이터 정의문도 포함할 수 있습니다.
2. 예를 들어 매크로 안에서 `.data` 영역을 사용하고 `BYTE` 지시어로 문자열 변수를 정의할 수 있습니다.
3. 따라서 매크로는 코드와 데이터를 모두 포함할 수 있으므로 주어진 문장은 거짓입니다.[^2]

```asm
mWrite MACRO text
    LOCAL string
    .data
    string BYTE text,0
    .code
    mov edx, OFFSET string
    call WriteString
ENDM
```

---

## 4. What is the purpose of the LOCAL directive?

LOCAL 지시어의 목적은 무엇인가?

**답:**

매크로 안에서 사용하는 레이블을 **각 매크로 확장마다 고유한 이름으로 만들어 중복 선언을 방지**하는 것입니다.

**풀이:**

1. 같은 매크로를 여러 번 호출하면 매크로 내부의 일반 레이블 이름도 반복해서 생성됩니다.
2. 같은 이름의 레이블이 중복되면 어셈블 오류가 발생할 수 있습니다.
3. `LOCAL`로 레이블을 선언하면 전처리기가 매크로가 확장될 때마다 서로 다른 고유 이름을 부여합니다.[^2]

```asm
myMacro MACRO
    LOCAL loopLabel
loopLabel:
    ; 반복해서 사용할 명령어
ENDM
```

---

## 5. Which directive displays a message on the console during the assembly step?

어셈블리 작업 중 콘솔에 메시지를 표시하는 지시어는 무엇인가?

**답:**

`ECHO` 지시어입니다.

**풀이:**

1. `ECHO`는 프로그램이 실행될 때가 아니라 어셈블되는 동안 콘솔에 메시지를 표시합니다.
2. 매크로의 인수가 빠졌거나 잘못된 값이 전달되었을 때 경고나 오류 안내 메시지를 출력하는 용도로 사용할 수 있습니다.[^2]

```asm
ECHO Assembling the program
```

---

## 6. Which directive marks the end of a conditional block of statements?

조건부 문장 블록의 끝을 표시하는 지시어는 무엇인가?

**답:**

`ENDIF` 지시어입니다.

**풀이:**

1. `IF` 지시어는 조건을 검사하고, 조건이 참일 때 해당 조건부 블록의 문장을 어셈블하도록 합니다.
2. `ELSE`가 있다면 조건이 거짓일 때 어셈블할 문장들을 지정할 수 있습니다.
3. `ENDIF`는 `IF`로 시작한 조건부 블록의 끝을 표시합니다.[^3]

```asm
IF value GT 0
    mov eax, 1
ELSE
    mov eax, 0
ENDIF
```

---

## 7. List all the relational operators that can be used in constant boolean expressions.

상수 불리언 표현식에서 사용할 수 있는 모든 관계 연산자를 나열하시오.

**답:**

`LT`, `GT`, `EQ`, `NE`, `LE`, `GE`입니다.

**풀이:**

| 연산자 | 의미                                |
| ------ | ----------------------------------- |
| `LT`   | 작다 (Less Than)                    |
| `GT`   | 크다 (Greater Than)                 |
| `EQ`   | 같다 (Equal)                        |
| `NE`   | 같지 않다 (Not Equal)               |
| `LE`   | 작거나 같다 (Less than or Equal)    |
| `GE`   | 크거나 같다 (Greater than or Equal) |

이 연산자들은 `IF` 등의 조건부 어셈블 지시어에서 상수 값을 비교할 때 사용합니다.[^3]

---

## 8. What is the purpose of the & operator in a macro definition?

매크로 정의에서 & 연산자의 목적은 무엇인가?

**답:**

매크로 매개변수의 값을 문자열 리터럴 내부에 삽입하도록 하는 **치환 연산자(Substitution operator)**입니다.

**풀이:**

1. 매크로 매개변수가 문자열 안에 들어 있으면 전처리기가 이를 일반 문자열의 일부로 인식하여 자동으로 치환하지 않을 수 있습니다.
2. 매개변수 앞에 `&`를 붙이면 전처리기가 해당 매개변수를 실제 전달된 인수로 치환합니다.
3. 따라서 문자열 안에 매크로 인수의 값을 포함하고 싶을 때 사용할 수 있습니다.[^4]

```asm
ShowRegister MACRO regName
    .data
    tempStr BYTE " &regName=",0
ENDM

; ShowRegister ECX로 호출하면 문자열 안의 regName이 ECX로 치환됨
```

---

## 9. What is the purpose of the ! operator in a macro definition?

매크로 정의에서 ! 연산자의 목적은 무엇인가?

**답:**

전처리기가 미리 정의된 연산자나 특수 문자를 연산자로 해석하지 않고 **일반 문자 그대로 처리하도록 하는 리터럴 문자 연산자(Literal-character operator)**입니다.

**풀이:**

1. 매크로 전처리기는 `>`와 같은 문자를 구분 기호나 특수 연산자로 해석할 수 있습니다.
2. 문자 앞에 `!`를 붙이면 해당 문자를 일반 문자로 처리하도록 지정할 수 있습니다.
3. 예를 들어 `!>`는 `>`를 리터럴 문자로 취급하게 하여, 꺾쇠괄호로 묶인 텍스트의 끝으로 잘못 해석되는 것을 방지합니다.[^4]

```asm
BadYValue TEXTEQU <Warning: Y-coordinate is !> 24>
```

---

## 10. What is the purpose of the % operator in a macro definition?

매크로 정의에서 % 연산자의 목적은 무엇인가?

**답:**

텍스트 매크로나 상수 표현식을 **확장하거나 계산하여 텍스트 형태로 변환**하는 확장 연산자(Expansion operator)입니다.

**풀이:**

1. `%`를 사용하면 상수 표현식을 계산한 뒤 그 결과를 텍스트로 전달할 수 있습니다.
2. 매크로에 상수 정수 인수가 필요할 때 계산식 자체가 아니라 계산된 정수 값을 전달할 수 있습니다.
3. 또한 `%`를 소스 코드 줄의 맨 앞에 쓰면 해당 줄에 있는 텍스트 매크로와 매크로 함수를 확장하도록 지시합니다.[^4]

```asm
count = 10
sumVal TEXTEQU %(5 + count)    ; 계산 결과인 15를 텍스트로 저장

; 상수 표현식을 계산하여 매크로에 전달
mGotoxyConst %(5 * 10), %(3 + 4)
```
