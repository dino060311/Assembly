# Short Answer 답안

---

## 1. Name the MASM data type that matches each of the following standard MS-Windows

types:
a. BOOL
b. COLORREF
c. HANDLE
d. LPSTR
e. WPARAM

다음 표준 MS-Windows 자료형 각각에 대응하는 MASM 자료형의 이름을 쓰시오.

**답:**

| MS-Windows 자료형 | MASM 자료형 |
| ----------------- | ----------- |
| BOOL              | `DWORD`     |
| COLORREF          | `DWORD`     |
| HANDLE            | `DWORD`     |
| LPSTR             | `PTR BYTE`  |
| WPARAM            | `DWORD`     |

**풀이:**

1. `BOOL`은 Windows API에서 32비트 정수형으로 정의되므로, 이 문제의 MASM 대응 자료형은 `DWORD`이다.
2. `COLORREF`는 32비트 색상 값이므로 `DWORD`에 대응한다.
3. `HANDLE`과 `WPARAM`은 이 문제의 32비트 환경에서 32비트 크기이므로 `DWORD`로 표현한다.
4. `LPSTR`은 널 종료된 ANSI 문자열을 가리키는 포인터이므로 `PTR BYTE`이다.
5. 이 대응은 32비트 환경을 기준으로 한다. 64비트 환경에서는 핸들과 포인터 크기 자료형의 크기가 달라진다.

---

## 2. Which Win32 function returns a handle to standard input?

표준 입력에 대한 핸들을 반환하는 Win32 함수는 무엇인가?

**답:**

`GetStdHandle` 함수이다.

**풀이:**

1. `GetStdHandle`은 표준 입력, 표준 출력 또는 표준 오류에 대한 핸들을 반환한다.
2. 표준 입력 핸들을 얻으려면 `STD_INPUT_HANDLE`을 전달한다.
3. 32비트 코드에서 반환된 핸들은 `EAX`에 들어온다.

```asm
.data
inputHandle HANDLE ?

.code
INVOKE GetStdHandle, STD_INPUT_HANDLE
mov inputHandle, eax
```

---

## 3. Which Win32 function reads a string of text from the keyboard and places the string in a buffer?

키보드에서 문자열을 읽어 버퍼에 저장하는 Win32 함수는 무엇인가?

**답:**

`ReadConsole` 함수이다.

**풀이:**

1. 콘솔 입력 버퍼에서 문자 입력을 읽어 지정한 버퍼에 저장한다.
2. 두 번째 인수는 입력 버퍼의 주소이고, 네 번째 인수는 실제로 읽은 문자 수를 저장할 변수의 주소이다.
3. 아래 코드에서는 `stdInHandle`, `buffer`, `BufSize`, `charsRead`가 미리 준비되어 있다고 가정한다.
4. 반환되는 수는 바이트 수가 아니라 문자 수이다. 널 종료 문자도 자동으로 추가되지 않는다.

```asm
INVOKE ReadConsole, stdInHandle, ADDR buffer, \
    BufSize - 2, ADDR charsRead, NULL
```

---

## 4. Describe the COORD structure.

COORD 구조체를 설명하시오.

**답:**

`COORD`는 콘솔 화면 버퍼의 문자 셀 좌표 또는 크기를 나타내는 X, Y 필드로 구성된 구조체이다.

**풀이:**

1. 좌표를 나타낼 때 X는 열, Y는 행을 의미하며, 원점은 왼쪽 위의 `(0, 0)`이다.
2. Windows API의 실제 필드 형식은 둘 다 부호 있는 16비트 `SHORT`이다.
3. MASM의 일부 교재용 헤더는 같은 16비트 저장 공간을 `WORD`로 선언한다. 부호 의미까지 반영하면 `SWORD`에 해당한다.
4. 이미 포함 파일에 정의되어 있다면 구조체를 중복 정의하지 않는다.

```asm
; Definition illustrating the signed Windows fields
COORD STRUCT
    X SWORD ?
    Y SWORD ?
COORD ENDS
```

---

## 5. Which Win32 function moves the file pointer to a specified offset relative to the beginning of a file?

파일의 시작 위치를 기준으로 지정된 오프셋으로 파일 포인터를 이동시키는 Win32 함수는 무엇인가?

**답:**

`SetFilePointer` 함수이다.

**풀이:**

1. 파일 핸들에 연결된 파일 포인터의 위치를 변경한다.
2. 파일의 시작을 기준으로 이동하려면 이동 기준 인수에 `FILE_BEGIN`을 지정한다.
3. 이후 읽기나 쓰기는 변경된 파일 포인터 위치에서 수행된다.

---

## 6. Which Win32 function changes the title of the console window?

콘솔 윈도우의 제목을 변경하는 Win32 함수는 무엇인가?

**답:**

`SetConsoleTitle` 함수이다.

**풀이:**

1. 콘솔 윈도우의 제목 문자열을 설정한다.
2. 새 제목을 담은 널 종료 문자열의 주소를 전달한다.

```asm
.data
consoleTitle BYTE "My Console Program", 0

.code
INVOKE SetConsoleTitle, ADDR consoleTitle
```

---

## 7. Which Win32 function lets you change the dimensions of the screen buffer?

화면 버퍼의 크기를 변경할 수 있게 해 주는 Win32 함수는 무엇인가?

**답:**

`SetConsoleScreenBufferSize` 함수이다.

**풀이:**

1. 콘솔 화면 버퍼의 열 수와 행 수를 변경한다.
2. 새 크기는 `COORD` 값으로 전달하며, 구조체의 주소가 아니라 값을 전달한다.
3. 버퍼 크기는 현재 콘솔 창의 크기보다 작을 수 없다.

```asm
.data
newSize COORD <100, 40>

.code
INVOKE SetConsoleScreenBufferSize, hConsoleOutput, newSize
```

---

## 8. Which Win32 function lets you change the size of the cursor?

커서의 크기를 변경할 수 있게 해 주는 Win32 함수는 무엇인가?

**답:**

`SetConsoleCursorInfo` 함수이다.

**풀이:**

1. 콘솔 커서의 크기와 표시 여부를 설정한다.
2. `dwSize`에는 문자 셀 높이에 대한 커서 높이의 백분율을 1부터 100까지 지정한다.
3. `bVisible`에는 커서의 표시 여부를 지정한다.
4. 함수에는 `CONSOLE_CURSOR_INFO` 구조체의 주소를 전달한다. 이미 정의된 구조체를 중복 선언하지 않는다.

```asm
CONSOLE_CURSOR_INFO STRUCT
    dwSize   DWORD ?
    bVisible DWORD ?
CONSOLE_CURSOR_INFO ENDS
```

---

## 9. Which Win32 function lets you change the color of subsequent text output?

이후 출력되는 텍스트의 색상을 변경할 수 있게 해 주는 Win32 함수는 무엇인가?

**답:**

`SetConsoleTextAttribute` 함수이다.

**풀이:**

1. 콘솔 화면 버퍼에 이후 기록되는 문자의 전경색과 배경색 속성을 설정한다.
2. 콘솔 출력 핸들과 색상 속성 값을 전달한다.
3. 이미 출력된 문자의 속성을 일괄 변경하는 함수는 아니다.

---

## 10. Which Win32 function lets you copy an array of attribute values to consecutive cells of the console screen buffer?

콘솔 화면 버퍼의 연속된 셀에 속성 값 배열을 복사할 수 있게 해 주는 Win32 함수는 무엇인가?

**답:**

`WriteConsoleOutputAttribute` 함수이다.

**풀이:**

1. `WORD` 속성 값 배열을 콘솔 화면 버퍼의 연속된 문자 셀에 기록한다.
2. 속성 배열의 주소, 기록할 셀 수, 시작 위치를 전달한다.
3. 시작 위치는 `COORD` 값으로 지정하며, 문자 자체는 변경하지 않는다.

---

## 11. Which Win32 function lets you pause a program for a specified number of milliseconds?

지정된 밀리초 동안 프로그램을 일시 중지할 수 있게 해 주는 Win32 함수는 무엇인가?

**답:**

`Sleep` 함수이다.

**풀이:**

1. 정확히는 프로그램 전체가 아니라 호출한 스레드의 실행을 일시 중지한다.
2. 시간은 밀리초 단위로 전달한다.
3. 대기 후 실행 재개 시점은 타이머 해상도와 스케줄링에 영향을 받으므로 정확한 시간 지연을 보장하지는 않는다.

```asm
INVOKE Sleep, 1000    ; Request a delay of about one second
```

---

## 12. When CreateWindowEx is called, how is the window’s appearance information transmitted to the function?

CreateWindowEx를 호출할 때 윈도우의 외관 정보는 어떤 방식으로 함수에 전달되는가?

**답:**

윈도우 스타일 상수들을 조합하여 네 번째 인수인 `dwStyle`로 전달한다.

**풀이:**

1. `dwStyle`은 창의 테두리, 제목 표시줄 등 외관과 동작을 지정하는 스타일 비트들의 조합이다.
2. 첫 번째 인수 `dwExStyle`로는 확장 스타일을 별도로 지정한다.
3. 스타일은 비트 플래그이므로 덧셈보다 비트 OR 연산으로 조합하는 것이 적절하다.
4. `WS_OVERLAPPEDWINDOW`는 일반적인 주 윈도우에 필요한 스타일 조합이다.

```asm
MAIN_WINDOW_STYLE = WS_OVERLAPPEDWINDOW

INVOKE CreateWindowEx, 0, ADDR className, ADDR WindowName, \
    MAIN_WINDOW_STYLE, CW_USEDEFAULT, CW_USEDEFAULT, \
    CW_USEDEFAULT, CW_USEDEFAULT, NULL, NULL, hInstance, NULL
```

---

## 13. Name two button constants that can be used when calling the MessageBox function.

MessageBox 함수를 호출할 때 사용할 수 있는 버튼 상수 두 가지를 쓰시오.

**답:**

`MB_OK`와 `MB_YESNO`이다.

**풀이:**

1. `MB_OK`는 확인 버튼 하나를 표시한다.
2. `MB_YESNO`는 예와 아니요 버튼을 표시한다.
3. 버튼 종류는 `MessageBox`의 네 번째 인수에 지정한다.

```asm
INVOKE MessageBox, hWnd, ADDR message, ADDR title, MB_OK
INVOKE MessageBox, hWnd, ADDR message, ADDR title, MB_YESNO
```

---

## 14. Name two icon constants that can be used when calling the MessageBox function.

MessageBox 함수를 호출할 때 사용할 수 있는 아이콘 상수 두 가지를 쓰시오.

**답:**

`MB_ICONERROR`와 `MB_ICONINFORMATION`이다.

**풀이:**

1. `MB_ICONERROR`는 오류 아이콘을 표시한다.
2. `MB_ICONINFORMATION`은 정보 아이콘을 표시한다.
3. 아이콘과 버튼 플래그를 OR로 조합하여 네 번째 인수에 전달한다.

```asm
INVOKE MessageBox, hWnd, ADDR message, ADDR title, \
    MB_ICONERROR OR MB_OK
INVOKE MessageBox, hWnd, ADDR message, ADDR title, \
    MB_ICONINFORMATION OR MB_OK
```

---

## 15. Name at least three tasks performed by the WinMain (startup) procedure.

WinMain(시작) 프로시저가 수행하는 작업을 최소 세 가지 쓰시오.

**답:**

1. 주 윈도우 클래스를 준비하고 등록한다.
2. 주 윈도우를 생성한다.
3. 주 윈도우를 표시하고 갱신한다.
4. 메시지 루프를 실행하여 메시지를 윈도우 프로시저로 전달한다.

**풀이:**

1. 위 작업 중 세 가지 이상을 쓰면 된다.
2. 윈도우 클래스에는 메시지 처리 프로시저, 아이콘, 커서 등의 정보가 포함된다.
3. 교재의 어셈블리 예제에서는 시작 프로시저에서 인스턴스 핸들을 얻기도 한다. 일반적인 Win32 `WinMain`에서는 `hInstance`를 인수로 전달받는다.

---

## 16. Describe the role of the WinProc procedure in the example program.

예제 프로그램에서 WinProc 프로시저의 역할을 설명하시오.

**답:**

`WinProc`는 윈도우 메시지를 받아 프로그램에 필요한 처리를 수행하는 윈도우 프로시저이다.

**풀이:**

1. 메시지 식별자를 확인하여 어떤 이벤트가 발생했는지 판단한다.
2. 예제에서 별도로 처리하는 메시지에 대해서는 해당 동작을 수행한다.
3. 처리하지 않는 메시지는 `DefWindowProc`에 전달한다.

---

## 17. Which messages are processed by the WinProc procedure in the example program?

예제 프로그램에서 WinProc 프로시저가 처리하는 메시지는 무엇인가?

**답:**

`WM_LBUTTONDOWN`, `WM_CREATE`, `WM_CLOSE`이다.

**풀이:**

| 메시지           | 의미                                             |
| ---------------- | ------------------------------------------------ |
| `WM_LBUTTONDOWN` | 창의 클라이언트 영역에서 마우스 왼쪽 버튼을 누름 |
| `WM_CREATE`      | 윈도우 생성 과정에서 전달됨                      |
| `WM_CLOSE`       | 윈도우를 닫으려는 요청                           |

위 답은 교재의 `WinApp.asm` 예제를 기준으로 한다. 그 밖의 메시지는 `DefWindowProc`에 전달한다.

---

## 18. Describe the role of the ErrorHandler procedure in the example program.

예제 프로그램에서 ErrorHandler 프로시저의 역할을 설명하시오.

**답:**

`ErrorHandler`는 시스템 오류 정보를 얻어 메시지 상자로 표시하는 프로시저이다.

**풀이:**

1. `GetLastError`로 오류 코드를 얻는다.
2. `FormatMessage`로 오류 코드에 해당하는 메시지 문자열을 만든다.
3. `MessageBox`로 오류 내용을 표시한다.
4. `LocalFree`로 할당된 메시지 버퍼를 해제한다.

---

## 19. Does the message box activated immediately after calling CreateWindow appear before or after the application’s main window?

CreateWindow를 호출한 직후 활성화되는 메시지 박스는 응용 프로그램의 주 윈도우보다 먼저 나타나는가, 나중에 나타나는가?

**답:**

교재 예제의 실행 설명을 기준으로, 주 윈도우가 화면에 나타나기 **전에** 메시지 박스가 먼저 나타난다.

**풀이:**

1. 교재의 실행 설명에서는 메시지 박스들을 닫은 뒤 주 윈도우가 표시된다.
2. 따라서 이 예제를 묻는 문제의 답은 ‘먼저(before)’이다.
3. 다만 이를 모든 Windows 프로그램에 적용할 수 있는 일반 규칙으로 해석해서는 안 된다. 실제 표시 순서는 창 스타일과 `ShowWindow`, `UpdateWindow`, `MessageBox`의 호출 흐름에 따라 달라진다.

---

## 20. Does the message box activated by WM_CLOSE appear before or after the main window closes?

WM_CLOSE 메시지에 의해 활성화되는 메시지 박스는 주 윈도우가 닫히기 전에 나타나는가, 닫힌 후에 나타나는가?

**답:**

주 윈도우가 닫히기 **전에** 나타난다.

**풀이:**

1. 교재 예제의 `WM_CLOSE` 처리 코드는 먼저 `MessageBox`를 호출한다.
2. 메시지 박스를 닫은 뒤 `PostQuitMessage`를 호출하여 메시지 루프의 종료를 요청한다.
3. `PostQuitMessage` 자체가 창을 파괴하는 함수는 아니다. 창 파괴는 `DestroyWindow`와 구별해야 한다.

---

## 21. Describe a linear address.

선형 주소(linear address)를 설명하시오.

**답:**

32비트 보호 모드에서 선형 주소는 세그먼트 변환을 거친 32비트 주소이며, 범위는 `00000000h`부터 `FFFFFFFFh`까지이다.

**풀이:**

1. 세그먼트 선택자로 해당 세그먼트 디스크립터를 참조한다.
2. 세그먼트 베이스 주소와 오프셋으로 선형 주소를 계산한다.
3. 페이징을 사용하면 이 주소가 다시 물리 주소로 변환된다.

$$\text{선형 주소} = \text{세그먼트 베이스 주소} + \text{오프셋}$$

---

## 22. How does paging relate to linear memory?

페이징은 선형 메모리와 어떤 관계가 있는가?

**답:**

페이징은 선형 주소 공간을 페이지 단위로 나누고, 각 페이지를 물리 메모리의 페이지 프레임에 매핑하는 기능이다.

**풀이:**

1. 이 문제에서는 4KB 페이지를 사용하는 전통적인 32비트 비-PAE 페이징을 기준으로 한다.
2. 선형 주소는 디렉터리 인덱스 10비트, 테이블 인덱스 10비트, 페이지 내부 오프셋 12비트로 나뉜다.
3. 프로세서는 페이지 디렉터리와 페이지 테이블을 통해 물리 주소를 얻는다.
4. 다른 페이징 모드에서는 주소 비트 수와 변환 구조가 달라질 수 있다.

---

## 23. If paging is disabled, how does the processor translate a linear address to a physical address?

페이징이 비활성화되어 있다면 프로세서는 선형 주소를 물리 주소로 어떻게 변환하는가?

**답:**

교재의 32비트 보호 모드 모델에서는 선형 주소를 그대로 물리 주소로 사용한다.

**풀이:**

1. 세그먼트 변환을 통해 선형 주소를 만드는 과정은 수행한다.
2. 페이지 테이블을 통한 추가 주소 변환은 수행하지 않는다.
3. 따라서 선형 주소와 물리 주소가 동일하다.

---

## 24. What advantage does paging offer?

페이징이 제공하는 장점은 무엇인가?

**답:**

필요한 페이지만 물리 메모리에 적재할 수 있어 제한된 물리 메모리를 효율적으로 사용하고 가상 메모리를 지원한다.

**풀이:**

1. 프로그램의 모든 페이지를 동시에 물리 메모리에 둘 필요가 없다.
2. 운영체제는 필요한 경우 디스크에 보관한 페이지를 다시 메모리로 가져올 수 있다.
3. 따라서 실행 중인 프로그램들이 사용하는 가상 메모리의 합이 물리 메모리보다 큰 경우도 지원할 수 있다.
4. 페이징 하드웨어만으로 디스크 입출력이 수행되는 것은 아니며, 페이지 폴트 처리는 운영체제가 담당한다.

---

## 25. Which register contains the base location of a local descriptor table?

로컬 디스크립터 테이블의 시작 주소를 포함하는 레지스터는 무엇인가?

**답:**

`LDTR`(Local Descriptor Table Register)이다.

**풀이:**

1. LDTR의 보이는 부분에는 LDT 디스크립터를 가리키는 세그먼트 선택자가 들어 있다.
2. 숨겨진 부분에는 해당 LDT의 베이스 주소, 한계값, 속성이 캐시된다.
3. 따라서 답은 LDTR이지만, 선택자 자체가 베이스 주소인 것은 아니다.

---

## 26. Which register contains the base location of a global descriptor table?

글로벌 디스크립터 테이블의 시작 주소를 포함하는 레지스터는 무엇인가?

**답:**

`GDTR`(Global Descriptor Table Register)이다.

**풀이:**

1. GDTR은 GDT의 베이스 주소와 테이블 한계값을 보관한다.
2. 프로세서는 이 정보를 사용하여 GDT의 디스크립터를 찾는다.

---

## 27. How many global descriptor tables can exist?

글로벌 디스크립터 테이블은 몇 개 존재할 수 있는가?

**답:**

교재의 단일 프로세서 설명에서는 **하나(1개)**이다.

**풀이:**

1. 정확히는 각 논리 프로세서가 한 시점에 GDTR로 참조하는 활성 GDT는 하나이다.
2. 메모리에 서로 다른 GDT를 여러 개 만들어 둘 수는 있다.
3. 따라서 ‘시스템 전체에 GDT를 단 하나만 만들 수 있다’는 뜻은 아니다.

---

## 28. How many local descriptor tables can exist?

로컬 디스크립터 테이블은 몇 개 존재할 수 있는가?

**답:**

**여러 개** 존재할 수 있다.

**풀이:**

1. 작업이나 프로그램별로 서로 다른 LDT를 둘 수 있다.
2. 다만 각 논리 프로세서에서 LDTR이 현재 선택하는 LDT는 한 번에 하나이다.

---

## 29. Name at least four fields in a segment descriptor.

세그먼트 디스크립터에 포함되는 필드를 최소 네 가지 쓰시오.

**답:**

| 필드                             | 의미                        |
| -------------------------------- | --------------------------- |
| Base address                     | 세그먼트 베이스 주소        |
| Descriptor privilege level (DPL) | 디스크립터 권한 수준        |
| Type                             | 세그먼트 유형과 접근 속성   |
| Present (P)                      | 세그먼트 존재 여부          |
| Granularity (G)                  | 한계값의 해석 단위          |
| Segment limit                    | 허용되는 오프셋 범위의 경계 |

**풀이:**

1. 위 항목 중 네 가지 이상을 쓰면 된다.
2. G가 0이면 바이트 단위, 1이면 4KB 단위로 한계값을 해석한다.
3. 한계값은 단순히 바이트 수로 표현한 크기와 같지는 않다. 일반적인 확장 방향의 세그먼트에서는 유효 한계값이 마지막으로 허용되는 오프셋을 나타낸다.

---

## 30. Which structures are involved in the paging process?

페이징 과정에 관여하는 구조체(구조)는 무엇인가?

**답:**

페이지 디렉터리(Page Directory), 페이지 테이블(Page Table), 페이지/페이지 프레임(Page/Page Frame)이다.

**풀이:**

1. 전통적인 32비트 비-PAE, 4KB 페이지 모델을 기준으로 한다.
2. 페이지 디렉터리의 항목은 페이지 테이블을 가리킨다.
3. 페이지 테이블의 항목은 물리 페이지 프레임을 가리킨다.
4. 페이지는 선형 주소 공간의 단위이고, 페이지 프레임은 물리 메모리의 대응 단위이다.

---

## 31. Which structure contains the base address of a page table?

페이지 테이블의 베이스 주소를 포함하는 구조는 무엇인가?

**답:**

페이지 디렉터리 항목(Page Directory Entry, PDE)이다.

**풀이:**

1. 선형 주소의 디렉터리 인덱스로 PDE를 선택한다.
2. 4KB 페이지를 사용하는 이 모델에서 PDE의 주소 필드는 페이지 테이블의 물리 베이스 주소를 지정한다.

---

## 32. Which structure contains the base address of a page frame?

페이지 프레임의 베이스 주소를 포함하는 구조는 무엇인가?

**답:**

페이지 테이블 항목(Page Table Entry, PTE)이다.

**풀이:**

1. 선형 주소의 테이블 인덱스로 PTE를 선택한다.
2. PTE의 주소 필드는 물리 페이지 프레임의 베이스 주소를 지정한다.
3. 여기에 페이지 내부 오프셋을 더하여 최종 물리 주소를 얻는다.

$$\text{물리 주소} = \text{페이지 프레임 베이스 주소} + \text{페이지 내부 오프셋}$$
