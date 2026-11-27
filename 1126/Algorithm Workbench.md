# Algorithm Workbench 답안

---

## 1. Show an example call to the ReadConsole function.

ReadConsole 함수를 호출하는 예를 보이시오.

**답:**

```asm
.data
inputHandle HANDLE ?
inputBuffer BYTE 80 DUP(?)
charsRead   DWORD ?

.code
INVOKE GetStdHandle, STD_INPUT_HANDLE
mov inputHandle, eax

INVOKE ReadConsole, inputHandle, ADDR inputBuffer, SIZEOF inputBuffer, ADDR charsRead, 0
```

**풀이:**

1. `GetStdHandle` 함수에 `STD_INPUT_HANDLE`을 전달하면 표준 입력 장치(키보드)의 핸들을 얻을 수 있다.
2. 반환된 핸들을 `inputHandle`에 저장한 뒤 `ReadConsole` 함수의 첫 번째 인수로 전달한다.
3. 두 번째 인수는 입력한 문자를 저장할 버퍼의 주소이고, 세 번째 인수는 읽을 최대 문자 수이다.
4. 네 번째 인수는 실제로 읽은 문자 수를 저장할 변수의 주소이며, 마지막 인수는 예약된 포인터이므로 0을 전달한다.

---

## 2. Show an example call to the WriteConsole function.

WriteConsole 함수를 호출하는 예를 보이시오.

**답:**

```asm
.data
outputHandle HANDLE ?
message      BYTE "Hello, console!",0
messageLength = ($ - message) - 1
charsWritten DWORD ?

.code
INVOKE GetStdHandle, STD_OUTPUT_HANDLE
mov outputHandle, eax

INVOKE WriteConsole, outputHandle, ADDR message, messageLength, ADDR charsWritten, 0
```

**풀이:**

1. `GetStdHandle` 함수에 `STD_OUTPUT_HANDLE`을 전달하면 표준 출력 장치(콘솔 화면)의 핸들을 얻을 수 있다.
2. `WriteConsole` 함수의 첫 번째 인수에는 출력 핸들을 전달한다.
3. 두 번째 인수는 화면에 출력할 문자열의 주소이고, 세 번째 인수는 출력할 문자 수이다.
4. 네 번째 인수에는 실제로 출력된 문자 수를 저장할 변수의 주소를 전달한다.
5. 마지막 인수는 예약된 포인터이므로 0을 전달한다. 문자열 끝의 널 문자는 출력하지 않도록 `messageLength`에서 제외하였다.

---

## 3. Show an example call to the CreateFile function that will open an existing file for reading.

읽기 위해 기존 파일을 여는 CreateFile 함수 호출의 예를 보이시오.

**답:**

```asm
.data
fileName BYTE "input.txt",0
hFile    HANDLE ?

.code
INVOKE CreateFile, ADDR fileName, GENERIC_READ, FILE_SHARE_READ, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0
mov hFile, eax

cmp eax, INVALID_HANDLE_VALUE
je  OpenError
```

**풀이:**

1. `CreateFile` 함수의 첫 번째 인수는 열 파일의 이름 또는 경로이다.
2. 두 번째 인수 `GENERIC_READ`는 파일을 읽기 전용으로 연다는 뜻이다.
3. 세 번째 인수 `FILE_SHARE_READ`는 다른 프로세스가 해당 파일을 읽기 위해 공유하여 여는 것을 허용한다.
4. 네 번째 인수와 마지막 인수는 보안 속성 및 템플릿 파일 핸들을 지정하는 값이며, 여기서는 사용하지 않으므로 0을 전달한다.
5. 다섯 번째 인수 `OPEN_EXISTING`은 이미 존재하는 파일만 열도록 지정한다. 여섯 번째 인수 `FILE_ATTRIBUTE_NORMAL`은 일반 파일 속성을 지정한다.
6. 함수가 성공하면 파일 핸들이 EAX에 반환된다. 실패하면 `INVALID_HANDLE_VALUE`가 반환되므로 이를 확인한다.

---

## 4. Show an example call to the CreateFile function that will create a new file with normal attributes, erasing any existing file by the same name.

일반 속성을 가진 새 파일을 생성하고, 같은 이름의 파일이 이미 있으면 기존 파일을 지우는 CreateFile 함수 호출의 예를 보이시오.

**답:**

```asm
.data
fileName BYTE "output.txt",0
hFile    HANDLE ?

.code
INVOKE CreateFile, ADDR fileName, GENERIC_WRITE, 0, 0, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0
mov hFile, eax

cmp eax, INVALID_HANDLE_VALUE
je  CreateError
```

**풀이:**

1. 첫 번째 인수는 생성할 파일의 이름 또는 경로이다.
2. 두 번째 인수 `GENERIC_WRITE`는 파일에 데이터를 쓸 수 있도록 지정한다.
3. 세 번째 인수에 0을 전달하여 다른 프로세스와 파일을 공유하지 않도록 한다.
4. 네 번째 인수와 마지막 인수는 이 예제에서 사용하지 않으므로 0을 전달한다.
5. 다섯 번째 인수 `CREATE_ALWAYS`는 파일이 없으면 새로 만들고, 같은 이름의 파일이 이미 있으면 기존 내용을 지우고 새 파일을 생성하도록 지정한다.
6. 여섯 번째 인수 `FILE_ATTRIBUTE_NORMAL`은 파일에 일반 속성을 지정한다. 성공하면 새 파일의 핸들이 EAX에 반환된다.

---

## 5. Show an example call to the ReadFile function.

ReadFile 함수를 호출하는 예를 보이시오.

**답:**

```asm
.data
hFile      HANDLE ?        ; 이미 열려 있는 파일의 핸들
fileBuffer BYTE 128 DUP(?)
bytesRead  DWORD ?

.code
INVOKE ReadFile, hFile, ADDR fileBuffer, SIZEOF fileBuffer, ADDR bytesRead, 0
```

**풀이:**

1. `ReadFile` 함수의 첫 번째 인수는 읽을 파일의 핸들이다.
2. 두 번째 인수는 읽은 데이터를 저장할 버퍼의 주소이다.
3. 세 번째 인수는 읽으려는 최대 바이트 수이며, 여기서는 버퍼의 크기인 `SIZEOF fileBuffer`를 전달한다.
4. 네 번째 인수는 실제로 읽은 바이트 수를 저장할 변수의 주소이다.
5. 마지막 인수는 비동기 입출력에 사용하는 OVERLAPPED 구조체의 주소이다. 동기 방식으로 읽는 이 예제에서는 0을 전달한다.

---

## 6. Show an example call to the WriteFile function.

WriteFile 함수를 호출하는 예를 보이시오.

**답:**

```asm
.data
hFile        HANDLE ?
fileData     BYTE "This is a test.",0
bytesToWrite = ($ - fileData) - 1
bytesWritten DWORD ?

.code
INVOKE WriteFile, hFile, ADDR fileData, bytesToWrite, ADDR bytesWritten, 0
```

**풀이:**

1. `WriteFile` 함수의 첫 번째 인수는 데이터를 기록할 파일의 핸들이다.
2. 두 번째 인수는 파일에 쓸 데이터가 저장된 버퍼의 주소이다.
3. 세 번째 인수는 파일에 기록할 바이트 수이다. 여기서는 문자열의 끝에 있는 널 문자를 제외한 길이를 전달한다.
4. 네 번째 인수는 실제로 기록한 바이트 수를 저장할 변수의 주소이다.
5. 마지막 인수는 OVERLAPPED 구조체의 주소이다. 동기 방식의 파일 쓰기에서는 0을 전달한다.

---

## 7. Show an example of calling the MessageBox function.

MessageBox 함수를 호출하는 예를 보이시오.

**답:**

```asm
.data
messageText BYTE "The operation is complete.",0
captionText BYTE "Notice",0

.code
INVOKE MessageBox, 0, ADDR messageText, ADDR captionText, MB_OK OR MB_ICONINFORMATION
```

**풀이:**

1. `MessageBox` 함수의 첫 번째 인수는 메시지 상자의 소유자 윈도우 핸들이다. 0을 전달하면 소유자 윈도우를 지정하지 않는다.
2. 두 번째 인수는 메시지 상자에 표시할 문자열의 주소이다.
3. 세 번째 인수는 메시지 상자의 제목 표시줄에 나타낼 문자열의 주소이다.
4. 네 번째 인수는 버튼과 아이콘 모양을 지정한다. `MB_OK`는 확인 버튼을 표시하고, `MB_ICONINFORMATION`은 정보 아이콘을 표시한다.
5. 메시지 상자를 표시하려면 문자열이 널 문자로 끝나도록 선언해야 한다.
