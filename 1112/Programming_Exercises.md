# Programming Exercises

---

## 1. Improved Str_copy Procedure

The Str_copy procedure shown in this chapter does not limit the number of characters to be copied. Create a new version (named Str_copyN) that receives an additional input parameter indicating the maximum number of characters to be copied.

**한글 해석:**

이 장의 Str_copy 프로시저는 복사할 문자 수를 제한하지 않는다. 복사할 최대 문자 수를 나타내는 입력 매개변수를 추가로 받는 새로운 버전인 Str_copyN을 작성하시오.

**답:**

```asm
INCLUDE Irvine32.inc

Str_copyN PROTO,
    pSource:PTR BYTE,
    pTarget:PTR BYTE,
    maxChars:DWORD

.data
sourceStr BYTE "Assembly Language",0
targetStr BYTE 9 DUP(0)
msg BYTE "Copied string: ",0

.code
main PROC
    ; 최대 8문자 + 널 문자 1바이트
    INVOKE Str_copyN, ADDR sourceStr, ADDR targetStr, 8

    mov edx, OFFSET msg
    call WriteString
    mov edx, OFFSET targetStr
    call WriteString
    call Crlf
    exit
main ENDP

Str_copyN PROC USES eax ecx esi edi,
    pSource:PTR BYTE,
    pTarget:PTR BYTE,
    maxChars:DWORD

    mov esi, pSource
    mov edi, pTarget
    mov ecx, maxChars

SCN_Loop:
    test ecx, ecx
    jz SCN_Terminate

    mov al, [esi]
    test al, al
    jz SCN_Terminate

    mov [edi], al
    inc esi
    inc edi
    dec ecx
    jmp SCN_Loop

SCN_Terminate:
    mov BYTE PTR [edi], 0
    ret
Str_copyN ENDP

END main
```

**풀이:**

1. `pSource`와 `pTarget`은 각각 원본 문자열과 대상 버퍼의 주소이고, `maxChars`는 복사할 최대 문자 수이다.
2. 원본의 널 문자 또는 지정한 최대 문자 수에 도달할 때까지 한 바이트씩 복사한다.
3. 복사가 끝나면 대상 문자열 끝에 널 문자를 추가한다.
4. 이 구현에서 `maxChars`는 널 문자를 제외한 문자 수이다. 대상 버퍼에는 최소 `maxChars + 1`바이트가 있어야 한다.
5. `maxChars`가 0이면 대상 버퍼의 첫 바이트에 널 문자만 기록한다.
6. 테스트에서는 처음 8문자인 `Assembly`가 복사된다. 원본과 대상 버퍼는 서로 겹치지 않는다고 가정한다.

---

## 2. Str_concat Procedure

Write a procedure named Str_concat that concatenates a source string to the end of a target string. Sufficient space must exist in the target string to accommodate the new characters. Pass pointers to the source and target strings. Here is a sample call:

```asm
.data
targetStr BYTE "ABCDE",10 DUP(0)
sourceStr BYTE "FGH",0
.code
INVOKE Str_concat, ADDR targetStr, ADDR sourceStr
```

**한글 해석:**

원본 문자열을 대상 문자열의 끝에 연결하는 Str_concat 프로시저를 작성하시오. 대상 버퍼에는 새 문자와 끝의 널 문자를 저장할 충분한 공간이 있어야 한다. 원본과 대상 문자열의 포인터를 전달한다. 제시된 호출 순서에 맞춰 대상 주소를 첫 번째 인수로, 원본 주소를 두 번째 인수로 받는다.

**답:**

```asm
INCLUDE Irvine32.inc

Str_concat PROTO, pTarget:PTR BYTE, pSource:PTR BYTE

.data
targetStr BYTE "ABCDE",10 DUP(0)
sourceStr BYTE "FGH",0

.code
main PROC
    INVOKE Str_concat, ADDR targetStr, ADDR sourceStr

    mov edx, OFFSET targetStr
    call WriteString
    call Crlf
    exit
main ENDP

Str_concat PROC USES eax esi edi,
    pTarget:PTR BYTE,
    pSource:PTR BYTE

    mov edi, pTarget

SCT_FindEnd:
    cmp BYTE PTR [edi], 0
    je SCT_CopyStart
    inc edi
    jmp SCT_FindEnd

SCT_CopyStart:
    mov esi, pSource

SCT_Copy:
    mov al, [esi]
    mov [edi], al
    inc esi
    inc edi
    test al, al
    jnz SCT_Copy
    ret
Str_concat ENDP

END main
```

**풀이:**

1. EDI를 대상 문자열의 시작 주소로 설정하고 널 문자가 있는 위치까지 이동한다.
2. 그 위치부터 원본 문자열을 복사한다. 대상의 기존 널 문자 자리에 원본의 첫 문자가 들어간다.
3. 원본의 끝을 나타내는 널 문자까지 함께 복사하여 새 문자열을 완성한다.
4. 테스트 결과는 `ABCDEFGH`이다.
5. 대상 버퍼의 용량은 호출자가 보장해야 하며, 두 문자열의 메모리 영역은 겹치지 않는다고 가정한다.

---

## 3. Str_remove Procedure

Write a procedure named Str_remove that removes n characters from a string. Pass a pointer to the position in the string where the characters are to be removed. Pass an integer specifying the number of characters to remove. The following code, for example, shows how to remove “xxxx” from target:

```asm
.data
target BYTE "abcxxxxdefghijklmop",0
.code
INVOKE Str_remove, ADDR [target+3], 4
```

**한글 해석:**

문자열에서 n개의 문자를 제거하는 Str_remove 프로시저를 작성하시오. 제거를 시작할 위치의 포인터와 제거할 문자 수를 전달한다. 예제에서는 문자열의 인덱스 3부터 4개의 문자 `xxxx`를 제거한다.

**답:**

```asm
INCLUDE Irvine32.inc

Str_remove PROTO, pPosition:PTR BYTE, removeCount:DWORD

.data
target BYTE "abcxxxxdefghijklmop",0

.code
main PROC
    INVOKE Str_remove, ADDR target[3], 4

    mov edx, OFFSET target
    call WriteString
    call Crlf
    exit
main ENDP

Str_remove PROC USES eax ecx esi edi,
    pPosition:PTR BYTE,
    removeCount:DWORD

    mov edi, pPosition
    mov esi, edi
    mov ecx, removeCount

SR_Skip:
    test ecx, ecx
    jz SR_Copy
    cmp BYTE PTR [esi], 0
    je SR_Copy
    inc esi
    dec ecx
    jmp SR_Skip

SR_Copy:
    mov al, [esi]
    mov [edi], al
    inc esi
    inc edi
    test al, al
    jnz SR_Copy
    ret
Str_remove ENDP

END main
```

**풀이:**

1. EDI는 삭제가 시작되는 위치를 가리키며, ESI는 삭제 후 남길 부분을 찾는 포인터이다.
2. ESI를 최대 `removeCount`만큼 이동한다. 도중에 널 문자를 만나면 더 이동하지 않는다.
3. ESI부터 시작하는 나머지 문자열을 EDI 위치로 한 바이트씩 당겨 복사한다.
4. 널 문자까지 복사하므로 삭제된 부분을 제외한 문자열이 올바르게 종료된다.
5. 요청한 삭제 수가 남은 문자 수보다 크면 문자열 끝까지만 제거한다. 삭제 수가 0이면 문자열을 유지한다.
6. 테스트 결과는 `abcdefghijklmop`이다. 전달한 포인터는 문자열 내부의 유효한 위치 또는 끝의 널 문자를 가리킨다고 가정한다.

---

## 4. Str_find Procedure

Write a procedure named Str_find that searches for the first matching occurrence of a source string inside a target string and returns the matching position. The input parameters should be a pointer to the source string and a pointer to the target string. If a match is found, the procedure sets the Zero flag and EAX points to the matching position in the target string. Otherwise, the Zero flag is clear and EAX is undefined. The following code, for example, searches for “ABC” and returns with EAX pointing to the “A” in the target string:

```asm
.data
target BYTE "123ABC342432",0
source BYTE "ABC",0
pos DWORD ?
.code
INVOKE Str_find, ADDR source, ADDR target
jnz notFound
mov pos,eax
```

**한글 해석:**

대상 문자열 안에서 원본 문자열과 처음 일치하는 부분을 검색하는 Str_find 프로시저를 작성하시오. 원본 문자열과 대상 문자열의 포인터를 입력받는다.

찾으면 ZF를 1로 설정하고 EAX에 일치한 부분의 시작 주소를 반환한다. 찾지 못하면 ZF를 0으로 설정하고, 이때 EAX 값은 정의하지 않아도 된다. 예제에서는 `ABC`를 찾아 대상 문자열의 `A` 위치를 반환한다.

**답:**

```asm
INCLUDE Irvine32.inc

Str_find PROTO, pSource:PTR BYTE, pTarget:PTR BYTE

.data
target BYTE "123ABC342432",0
source BYTE "ABC",0
pos DWORD ?
foundMsg BYTE "Match begins at: ",0
missingMsg BYTE "Not found",0

.code
main PROC
    INVOKE Str_find, ADDR source, ADDR target
    jnz NotFound

    mov pos, eax
    mov edx, OFFSET foundMsg
    call WriteString
    mov edx, pos
    call WriteString
    call Crlf
    jmp ProgramDone

NotFound:
    mov edx, OFFSET missingMsg
    call WriteString
    call Crlf

ProgramDone:
    exit
main ENDP

Str_find PROC USES edx esi edi,
    pSource:PTR BYTE,
    pTarget:PTR BYTE

    mov edi, pTarget

SF_Try:
    mov esi, pSource
    mov edx, edi

SF_Compare:
    mov al, [esi]
    test al, al
    jz SF_Found                 ; 원본 전체가 일치함

    cmp BYTE PTR [edx], 0
    je SF_Missing               ; 대상의 끝까지 도달함

    cmp al, [edx]
    jne SF_Next

    inc esi
    inc edx
    jmp SF_Compare

SF_Next:
    inc edi
    jmp SF_Try

SF_Found:
    mov eax, edi
    cmp eax, eax                ; ZF = 1
    ret

SF_Missing:
    xor eax, eax
    cmp eax, 1                  ; ZF = 0
    ret
Str_find ENDP

END main
```

**풀이:**

1. EDI는 대상 문자열에서 현재 검사할 시작 위치를 가리킨다.
2. 각 시작 위치마다 ESI를 원본의 처음으로, EDX를 대상의 현재 위치로 설정한다.
3. 두 문자열을 한 문자씩 비교한다. 원본의 널 문자에 도달하면 원본 전체가 일치한 것이다.
4. 중간에 다르면 EDI를 1 증가시켜 다음 위치에서 다시 검색한다.
5. 성공하면 EAX에 시작 주소를 넣고 `CMP EAX, EAX`로 ZF를 1로 설정한다. 실패하면 `CMP EAX, 1`로 ZF를 0으로 설정한다.
6. 반환 직전의 `POP`, `MOV`, `RET`은 ZF를 변경하지 않는다. 호출자는 `INVOKE` 직후 다른 플래그 변경 명령 없이 `JNZ`로 성공 여부를 검사한다.
7. 빈 원본 문자열은 대상 문자열의 시작 위치에서 일치한 것으로 처리한다. 테스트에서 반환되는 주소는 `target + 3`이다.

---

## 5. Str_nextWord Procedure

Write a procedure called Str_nextWord that scans a string for the first occurrence of a certain delimiter character and replaces the delimiter with a null byte. There are two input parameters: a pointer to the string and the delimiter character. After the call, if the delimiter was found, the Zero flag is set and EAX contains the offset of the next character beyond the delimiter. Otherwise, the Zero flag is clear and EAX is undefined. The following example code passes the address of target and a comma as the delimiter:

```asm
.data
target BYTE "Johnson,Calvin",0
.code
INVOKE Str_nextWord, ADDR target, ','
jnz notFound
```

**한글 해석:**

문자열에서 지정한 구분 문자가 처음 나타나는 위치를 찾고, 해당 구분 문자를 널 바이트로 바꾸는 Str_nextWord 프로시저를 작성하시오. 문자열 포인터와 구분 문자를 입력받는다.

구분 문자를 찾으면 ZF를 1로 설정하고, EAX에 구분 문자 바로 다음 문자의 주소를 반환한다. 찾지 못하면 ZF를 0으로 설정하고 EAX는 정의하지 않아도 된다. 예제에서는 쉼표를 구분 문자로 사용한다.

**답:**

```asm
INCLUDE Irvine32.inc

Str_nextWord PROTO, pString:PTR BYTE, delimiter:BYTE

.data
target BYTE "Johnson,Calvin",0
nextPtr DWORD ?
firstMsg BYTE "First word: ",0
nextMsg BYTE "Next word: ",0
missingMsg BYTE "Delimiter not found",0

.code
main PROC
    INVOKE Str_nextWord, ADDR target, ','
    jnz NoDelimiter

    mov nextPtr, eax

    mov edx, OFFSET firstMsg
    call WriteString
    mov edx, OFFSET target
    call WriteString
    call Crlf

    mov edx, OFFSET nextMsg
    call WriteString
    mov edx, nextPtr
    call WriteString
    call Crlf
    jmp ProgramDone

NoDelimiter:
    mov edx, OFFSET missingMsg
    call WriteString
    call Crlf

ProgramDone:
    exit
main ENDP

Str_nextWord PROC USES edx esi,
    pString:PTR BYTE,
    delimiter:BYTE

    mov esi, pString
    mov dl, delimiter

SNW_Loop:
    mov al, [esi]
    test al, al
    jz SNW_Missing

    cmp al, dl
    je SNW_Found

    inc esi
    jmp SNW_Loop

SNW_Found:
    mov BYTE PTR [esi], 0
    lea eax, [esi+1]
    cmp eax, eax                ; ZF = 1
    ret

SNW_Missing:
    xor eax, eax
    cmp eax, 1                  ; ZF = 0
    ret
Str_nextWord ENDP

END main
```

**풀이:**

1. 문자열을 앞에서부터 검색하며 각 문자를 구분 문자와 비교한다.
2. 구분 문자를 찾으면 해당 위치에 0을 기록하여 앞부분을 독립된 널 종료 문자열로 만든다.
3. 다음 단어의 주소는 구분 문자 위치보다 1바이트 뒤이므로 `LEA EAX, [ESI+1]`로 구한다.
4. 성공 시 ZF를 1, 실패 시 ZF를 0으로 설정하고 반환한다.
5. 테스트 후 `target`은 `Johnson`을, `nextPtr`은 `Calvin`의 시작을 가리킨다.
6. 문자열 끝의 널 문자 자체는 구분 문자로 처리하지 않는다. 구분 문자가 마지막 실제 문자라면 반환 주소는 끝의 널 문자를 가리킨다.

---

## 6. Constructing a Frequency Table

Write a procedure named Get_frequencies that constructs a character frequency table. Input to the procedure should be a pointer to a string and a pointer to an array of 256 doublewords initialized to all zeros. Each array position is indexed by its corresponding ASCII code. When the procedure returns, each entry in the array contains a count of how many times the corresponding character occurred in the string. For example:

```asm
.data
target BYTE "AAEBDCFBBC",0
freqTable DWORD 256 DUP(0)
.code
INVOKE Get_frequencies, ADDR target, ADDR freqTable
```

**한글 해석:**

문자 빈도표를 만드는 Get_frequencies 프로시저를 작성하시오. 문자열 포인터와 0으로 초기화된 256개 DWORD 배열의 포인터를 입력받는다.

각 배열 인덱스는 해당 문자의 ASCII 코드에 대응한다. 프로시저가 끝나면 각 항목에는 문자열에서 그 문자가 나타난 횟수가 저장되어야 한다.

**답:**

```asm
INCLUDE Irvine32.inc

Get_frequencies PROTO, pString:PTR BYTE, pTable:PTR DWORD

.data
target BYTE "AAEBDCFBBC",0
freqTable DWORD 256 DUP(0)
separator BYTE " : ",0

.code
main PROC
    INVOKE Get_frequencies, ADDR target, ADDR freqTable

    ; 등장한 문자만 코드 순서대로 출력한다.
    xor ebx, ebx

GF_Display:
    cmp DWORD PTR freqTable[ebx*4], 0
    je GF_Next

    mov eax, ebx
    call WriteChar
    mov edx, OFFSET separator
    call WriteString
    mov eax, freqTable[ebx*4]
    call WriteDec
    call Crlf

GF_Next:
    inc ebx
    cmp ebx, 256
    jb GF_Display
    exit
main ENDP

Get_frequencies PROC USES eax esi edi,
    pString:PTR BYTE,
    pTable:PTR DWORD

    mov esi, pString
    mov edi, pTable

GF_Loop:
    movzx eax, BYTE PTR [esi]
    test eax, eax
    jz GF_Done

    inc DWORD PTR [edi+eax*4]
    inc esi
    jmp GF_Loop

GF_Done:
    ret
Get_frequencies ENDP

END main
```

**풀이:**

1. ESI는 현재 문자, EDI는 빈도표의 시작 주소를 가리킨다.
2. `MOVZX`로 문자 코드를 0부터 255까지의 정수로 확장한다.
3. 빈도표 원소는 DWORD이므로 해당 항목의 주소는 `EDI + 문자 코드 × 4`이다.
4. 문자를 읽을 때마다 해당 항목을 1 증가시키고, 널 문자를 만나면 종료한다. 종료용 널 문자는 집계하지 않는다.
5. 테스트 문자열의 빈도는 A=2, B=3, C=2, D=1, E=1, F=1이다.
6. 테이블은 호출 전에 0으로 초기화해야 한다. 같은 테이블을 초기화하지 않고 다시 전달하면 기존 횟수에 누적된다.

---

## 7. Sieve of Eratosthenes

The Sieve of Eratosthenes, invented by the Greek mathematician of the same name, provides a quick way to find all prime numbers within a given range. The algorithm involves creating an array of bytes in which positions are “marked” by inserting 1s. Beginning with position 2 (which is a prime number), insert a 1 in each array position that is a multiple of 2. Then do the same thing for multiples of 3, the next prime number. Find the next prime number after 3, which is 5, and mark all positions that are multiples of 5. Proceed in this manner until all multiples of primes have been found. The remaining positions of the array that are unmarked indicate which numbers are prime. For this program, create a 65,000-element array and display all primes between 2 and 65,000. Declare the array in an uninitialized data segment (see Section 3.4.11) and use STOSB to fill it with zeros.

**한글 해석:**

에라토스테네스의 체를 사용하여 2부터 65,000까지의 모든 소수를 출력하시오. 바이트 배열에서 소수의 배수에 해당하는 위치를 1로 표시하고, 표시되지 않은 수를 소수로 판별한다.

65,000개 원소의 배열을 초기화되지 않은 데이터 세그먼트에 선언하고, STOSB를 사용하여 배열 전체를 0으로 초기화한다.

**답:**

```asm
INCLUDE Irvine32.inc

LIMIT = 65000

.data
heading BYTE "Primes from 2 through 65000:",0

.data?
sieve BYTE LIMIT DUP(?)

.code
main PROC
    call BuildSieve

    mov edx, OFFSET heading
    call WriteString
    call Crlf

    call PrintPrimes
    exit
main ENDP

BuildSieve PROC USES eax ebx ecx edx edi
    cld
    mov edi, OFFSET sieve
    mov ecx, LIMIT
    xor eax, eax
    rep stosb

    ; 인덱스 n-1이 숫자 n을 나타낸다.
    mov BYTE PTR sieve[0], 1      ; 1은 소수가 아님
    mov ebx, 2                   ; 현재 후보 p

BS_Candidate:
    mov eax, ebx
    mul ebx                      ; EAX = p*p (이 범위에서는 EDX=0)
    cmp eax, LIMIT
    ja BS_Done

    cmp BYTE PTR sieve[ebx-1], 0
    jne BS_Next

    ; p*p보다 작은 배수는 이전 소수의 단계에서 처리됨
    mov edx, eax

BS_Mark:
    mov BYTE PTR sieve[edx-1], 1
    add edx, ebx
    cmp edx, LIMIT
    jbe BS_Mark

BS_Next:
    inc ebx
    jmp BS_Candidate

BS_Done:
    ret
BuildSieve ENDP

PrintPrimes PROC USES eax ebx edx
    LOCAL column:DWORD

    mov column, 0
    mov ebx, 2

PP_Loop:
    cmp BYTE PTR sieve[ebx-1], 0
    jne PP_Next

    mov eax, ebx
    call WriteDec
    mov al, ' '
    call WriteChar

    inc column
    cmp column, 10
    jb PP_Next

    call Crlf
    mov column, 0

PP_Next:
    inc ebx
    cmp ebx, LIMIT
    jbe PP_Loop

    cmp column, 0
    je PP_Done
    call Crlf

PP_Done:
    ret
PrintPrimes ENDP

END main
```

**풀이:**

1. `.data?`에 65,000바이트를 선언하고 `CLD`와 `REP STOSB`로 모두 0으로 채운다.
2. 배열 크기를 정확히 65,000으로 유지하면서 65,000까지 표현하기 위해, 숫자 n을 인덱스 `n - 1`에 대응시킨다. 숫자 0은 배열에 표현하지 않는다.
3. 1에 해당하는 첫 항목을 1로 표시하여 소수에서 제외한다.
4. p=2부터 시작하여 아직 표시되지 않은 p의 배수를 1로 표시한다.
5. 배수 표시는 $p^2$부터 시작한다. 그보다 작은 p의 배수는 이전 소수의 단계에서 이미 처리되었기 때문이다.
6. $p^2 > 65000$이 되면 체 구성을 종료할 수 있다.
7. 마지막으로 숫자 2부터 65,000까지 순회하여 값이 0인 항목을 출력한다. 출력은 한 줄에 소수 10개씩 배치한다.

---

## 8. Bubble Sort

Add a variable to the BubbleSort procedure in Section 9.5.1 that is set to 1 whenever a pair of values is exchanged within the inner loop. Use this variable to exit the sort before its normal completion if you discover that no exchanges took place during a complete pass through the array. (This variable is commonly known as an exchange flag.)

**한글 해석:**

9.5.1절의 BubbleSort 프로시저에 교환 여부를 나타내는 변수를 추가하시오. 내부 반복문에서 두 값을 교환하면 이 변수를 1로 설정한다.

배열 전체를 한 번 순회하는 동안 교환이 한 번도 없었다면 정렬이 완료된 것이므로, 예정된 반복 횟수를 모두 수행하기 전에 종료하도록 하시오. 이 변수는 일반적으로 교환 플래그(exchange flag)라고 한다.

**답:**

```asm
INCLUDE Irvine32.inc

BubbleSort PROTO, pArray:PTR SDWORD, itemCount:DWORD
DisplayArray PROTO, pArray:PTR SDWORD, itemCount:DWORD

.data
numbers SDWORD 9, -3, 7, 1, -8, 4
beforeMsg BYTE "Before: ",0
afterMsg BYTE "After:  ",0

.code
main PROC
    mov edx, OFFSET beforeMsg
    call WriteString
    INVOKE DisplayArray, ADDR numbers, LENGTHOF numbers

    INVOKE BubbleSort, ADDR numbers, LENGTHOF numbers

    mov edx, OFFSET afterMsg
    call WriteString
    INVOKE DisplayArray, ADDR numbers, LENGTHOF numbers
    exit
main ENDP

BubbleSort PROC USES eax ecx esi,
    pArray:PTR SDWORD,
    itemCount:DWORD

    LOCAL exchanged:DWORD

    mov ecx, itemCount
    cmp ecx, 2
    jb BUB_Done
    dec ecx

BUB_Outer:
    mov exchanged, 0
    mov esi, pArray
    push ecx                     ; 바깥 반복 횟수 보관

BUB_Inner:
    mov eax, [esi]
    cmp eax, [esi+4]
    jle BUB_NoSwap                ; 부호 있는 정수의 오름차순

    xchg eax, [esi+4]
    mov [esi], eax
    mov exchanged, 1

BUB_NoSwap:
    add esi, 4
    loop BUB_Inner

    pop ecx
    cmp exchanged, 0
    je BUB_Done                  ; 교환이 없으면 조기 종료
    loop BUB_Outer

BUB_Done:
    ret
BubbleSort ENDP

DisplayArray PROC USES eax ebx esi,
    pArray:PTR SDWORD,
    itemCount:DWORD

    mov esi, pArray
    mov ebx, itemCount

DA_Loop:
    test ebx, ebx
    jz DA_Done
    mov eax, [esi]
    call WriteInt
    mov al, ' '
    call WriteChar
    add esi, 4
    dec ebx
    jmp DA_Loop

DA_Done:
    call Crlf
    ret
DisplayArray ENDP

END main
```

**풀이:**

1. `exchanged`를 지역 DWORD 변수로 선언한다.
2. 바깥 반복을 시작할 때마다 0으로 초기화한다.
3. 인접한 두 원소를 교환하면 `exchanged`를 1로 설정한다.
4. 한 차례의 내부 반복이 끝난 뒤에도 0이면 모든 인접 쌍이 정렬 순서를 만족하므로 바로 종료한다.
5. 교환이 있었다면 다음 차례로 진행한다. 한 차례가 끝날 때마다 가장 큰 값이 뒤쪽에 확정되므로 다음 비교 횟수는 1 감소한다.
6. 원소가 0개 또는 1개이면 정렬할 필요 없이 반환한다.
7. 테스트 결과는 `-8, -3, 1, 4, 7, 9` 순서이다. `WriteInt`는 양수 앞에 `+` 기호를 출력할 수 있다.

---

## 9. Binary Search

Rewrite the binary search procedure shown in this chapter by using registers for mid, first, and last. Add comments to clarify the registers’ usage.

**한글 해석:**

이 장의 이진 검색 프로시저를 수정하여 mid, first, last를 지역 변수 대신 레지스터에 저장하도록 하시오. 각 레지스터의 용도를 명확히 설명하는 주석을 추가하시오.

**답:**

```asm
INCLUDE Irvine32.inc

.data
numbers SDWORD -20, -5, 0, 7, 12, 30, 44
foundMsg BYTE "Index of 12: ",0
missingMsg BYTE "Index of 99: ",0

.code
main PROC
    push 12
    push LENGTHOF numbers
    push OFFSET numbers
    call BinarySearch
    push eax
    mov edx, OFFSET foundMsg
    call WriteString
    pop eax
    call WriteInt
    call Crlf

    push 99
    push LENGTHOF numbers
    push OFFSET numbers
    call BinarySearch
    push eax
    mov edx, OFFSET missingMsg
    call WriteString
    pop eax
    call WriteInt
    call Crlf
    exit
main ENDP

; 아래 프로시저는 스택 프레임을 직접 구성한다.
OPTION PROLOGUE:NONE
OPTION EPILOGUE:NONE

BinarySearch PROC
    push ebp
    mov ebp, esp
    push ebx
    push ecx
    push edx
    push esi
    push edi

    ; [EBP+8]  = 배열 주소
    ; [EBP+12] = 원소 개수
    ; [EBP+16] = 검색값
    ; ESI = first, EDI = last, EBX = mid
    ; ECX = 배열 주소, EDX = 검색값, EAX = 임시값/반환값

    mov ecx, [ebp+8]
    mov edi, [ebp+12]
    test edi, edi
    jz BIN_Missing
    dec edi
    xor esi, esi
    mov edx, [ebp+16]

BIN_Loop:
    cmp esi, edi
    jg BIN_Missing

    ; mid = first + (last-first)/2
    mov eax, edi
    sub eax, esi
    shr eax, 1
    add eax, esi
    mov ebx, eax

    mov eax, [ecx+ebx*4]
    cmp eax, edx
    je BIN_Found
    jl BIN_Right

    ; 현재 값이 더 크면 last = mid-1
    lea edi, [ebx-1]
    jmp BIN_Loop

BIN_Right:
    ; 현재 값이 더 작으면 first = mid+1
    lea esi, [ebx+1]
    jmp BIN_Loop

BIN_Found:
    mov eax, ebx
    jmp BIN_Done

BIN_Missing:
    mov eax, -1

BIN_Done:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    mov esp, ebp
    pop ebp
    ret 12
BinarySearch ENDP

OPTION PROLOGUE:PrologueDef
OPTION EPILOGUE:EpilogueDef

END main
```

**풀이:**

1. ESI에 `first`, EDI에 `last`, EBX에 `mid`를 저장하여 반복 중 메모리 접근을 줄인다.
2. 배열은 부호 있는 DWORD의 오름차순으로 정렬되어 있어야 한다.
3. 중간 위치는 다음 식으로 계산한다.

$$mid = first + \left\lfloor \frac{last-first}{2} \right\rfloor$$

4. 중간 원소가 검색값보다 작으면 `first = mid + 1`, 크면 `last = mid - 1`로 범위를 줄인다.
5. 일치하면 0부터 시작하는 원소 인덱스를 EAX로 반환하고, 없으면 -1을 반환한다.
6. 테스트에서 12는 인덱스 4에 있으므로 4를 반환하고, 99는 없으므로 -1을 반환한다.
7. 이 예제는 명시적인 `PUSH`와 `CALL`로 인수를 전달한다. 프로시저에서 `RET 12`로 세 DWORD 인수를 정리한다.
8. `OPTION PROLOGUE:NONE`과 `OPTION EPILOGUE:NONE`으로 자동 프레임 생성을 끈 뒤 직접 구성한다. 따라서 자동 프롤로그와 수동 프롤로그가 중복되지 않는다.
9. 인덱스를 부호 있는 값으로 비교하므로 원소 개수는 $2^{31}-1$ 이하라고 가정한다.

---

## 10. Letter Matrix

Create a procedure that generates a four-by-four matrix of randomly chosen capital letters. When choosing letters, there must be a 50% probability that the chosen letter is a vowel. Write a test program with a loop that calls your procedure five times and displays each matrix in the console window.

**한글 해석:**

무작위 대문자로 이루어진 4×4 행렬을 생성하는 프로시저를 작성하시오. 각 문자가 모음으로 선택될 확률은 50%여야 한다.

반복문에서 이 프로시저를 다섯 번 호출하고, 생성한 행렬을 매번 콘솔 창에 출력하는 테스트 프로그램을 작성하시오.

**답:**

```asm
INCLUDE Irvine32.inc


GenerateMatrix PROTO, pMatrix:PTR BYTE
DisplayMatrix PROTO, pMatrix:PTR BYTE

.data

vowels BYTE "AEIOU"
consonants BYTE "BCDFGHJKLMNPQRSTVWXYZ"
matrix BYTE 16 DUP(?)

.code
main PROC
    call Randomize
    mov ebx, 5

LM_Loop:
    INVOKE GenerateMatrix, ADDR matrix
    INVOKE DisplayMatrix, ADDR matrix
    call Crlf
    dec ebx
    jnz LM_Loop

    exit
main ENDP

GenerateMatrix PROC USES eax ebx esi,
    pMatrix:PTR BYTE

    mov esi, pMatrix
    xor ebx, ebx

GM_Loop:
    mov eax, 2
    call RandomRange             ; 0 또는 1
    test eax, eax
    jz GM_Vowel

    mov eax, LENGTHOF consonants
    call RandomRange
    mov al, consonants[eax]
    jmp GM_Store

GM_Vowel:
    mov eax, LENGTHOF vowels
    call RandomRange
    mov al, vowels[eax]

GM_Store:
    mov [esi+ebx], al
    inc ebx
    cmp ebx, 16
    jb GM_Loop
    ret
GenerateMatrix ENDP

DisplayMatrix PROC USES eax ebx esi,
    pMatrix:PTR BYTE

    mov esi, pMatrix
    xor ebx, ebx

DM_Loop:
    mov al, [esi+ebx]
    call WriteChar
    mov al, ' '
    call WriteChar

    inc ebx
    test ebx, 3
    jnz DM_Next
    call Crlf

DM_Next:
    cmp ebx, 16
    jb DM_Loop
    ret
DisplayMatrix ENDP

END main
```

**풀이:**

1. 모음 집합은 `AEIOU`, 자음 집합은 나머지 21개의 영문 대문자로 구성한다.
2. `RandomRange`에 2를 전달하여 0 또는 1을 선택한다. 0이면 모음, 1이면 자음 집합에서 문자를 고른다.
3. 모음은 5개 중 하나를, 자음은 21개 중 하나를 다시 무작위로 선택한다.
4. 따라서 각 문자가 모음일 확률은 50%이다. 행렬마다 반드시 모음이 8개 나온다는 뜻은 아니다.
5. `GenerateMatrix`는 16바이트를 채우고, `DisplayMatrix`는 4문자마다 줄을 바꾸어 4×4로 출력한다.
6. 프로그램 시작 시 `Randomize`를 한 번 호출하고, 행렬 생성과 출력을 다섯 번 반복한다.
7. 이 문제에서 모음은 A, E, I, O, U로 한정하며 Y는 자음으로 처리한다.

---

## 11. Letter Matrix/Sets with Vowels

Use the letter matrix generated in the previous programming exercise as a starting point for this program. Generate a single random four-by-four letter matrix in which each letter has a 50% probability of being a vowel. Traverse each matrix row, column, and diagonal, generating sets of letters. Display only four-letter sets containing exactly two vowels. Suppose, for example, the following matrix was generated:

```text
P O A Z
A E A U
G K A E
I A G D
```

Then the four-letter sets displayed by the program would be POAZ, GKAE, IAGD, PAGI, ZUED, PEAD, and ZAKI. The order of letters within each set is unimportant.

**한글 해석:**

앞 문제의 문자 행렬을 바탕으로 프로그램을 작성하시오. 각 문자가 모음일 확률이 50%인 4×4 무작위 행렬을 하나 생성한다.

각 행, 열, 대각선을 순회하여 네 글자 집합을 만들고, 그중 모음이 정확히 두 개인 집합만 출력한다. 각 집합 안에서 문자의 순서는 중요하지 않다.

**답:**

```asm
INCLUDE Irvine32.inc


GenerateMatrix PROTO, pMatrix:PTR BYTE
DisplayMatrix PROTO, pMatrix:PTR BYTE

DisplaySetIfTwo PROTO, pStart:PTR BYTE, stepSize:DWORD

.data

vowels BYTE "AEIOU"
consonants BYTE "BCDFGHJKLMNPQRSTVWXYZ"
matrix BYTE 16 DUP(?)

heading BYTE "Four-letter sets with exactly two vowels:",0

.code
main PROC
    call Randomize
    INVOKE GenerateMatrix, ADDR matrix
    INVOKE DisplayMatrix, ADDR matrix
    call Crlf

    mov edx, OFFSET heading
    call WriteString
    call Crlf

    ; 네 행: 시작 위치 0,4,8,12 / 이동 간격 1
    mov esi, OFFSET matrix
    mov ebx, 4

LMS_Rows:
    INVOKE DisplaySetIfTwo, esi, 1
    add esi, 4
    dec ebx
    jnz LMS_Rows

    ; 네 열: 시작 위치 0,1,2,3 / 이동 간격 4
    mov esi, OFFSET matrix
    mov ebx, 4

LMS_Columns:
    INVOKE DisplaySetIfTwo, esi, 4
    inc esi
    dec ebx
    jnz LMS_Columns

    ; 왼쪽 위 -> 오른쪽 아래: 0,5,10,15
    INVOKE DisplaySetIfTwo, ADDR matrix, 5

    ; 오른쪽 위 -> 왼쪽 아래: 3,6,9,12
    INVOKE DisplaySetIfTwo, ADDR matrix[3], 3

    exit
main ENDP

GenerateMatrix PROC USES eax ebx esi,
    pMatrix:PTR BYTE

    mov esi, pMatrix
    xor ebx, ebx

GM_Loop:
    mov eax, 2
    call RandomRange             ; 0 또는 1
    test eax, eax
    jz GM_Vowel

    mov eax, LENGTHOF consonants
    call RandomRange
    mov al, consonants[eax]
    jmp GM_Store

GM_Vowel:
    mov eax, LENGTHOF vowels
    call RandomRange
    mov al, vowels[eax]

GM_Store:
    mov [esi+ebx], al
    inc ebx
    cmp ebx, 16
    jb GM_Loop
    ret
GenerateMatrix ENDP

DisplayMatrix PROC USES eax ebx esi,
    pMatrix:PTR BYTE

    mov esi, pMatrix
    xor ebx, ebx

DM_Loop:
    mov al, [esi+ebx]
    call WriteChar
    mov al, ' '
    call WriteChar

    inc ebx
    test ebx, 3
    jnz DM_Next
    call Crlf

DM_Next:
    cmp ebx, 16
    jb DM_Loop
    ret
DisplayMatrix ENDP

DisplaySetIfTwo PROC USES eax ebx ecx esi edi,
    pStart:PTR BYTE,
    stepSize:DWORD

    mov esi, pStart
    mov edi, stepSize
    xor ebx, ebx                 ; 모음 개수
    mov ecx, 4

DST_Count:
    mov al, [esi]
    cmp al, 'A'
    je DST_Vowel
    cmp al, 'E'
    je DST_Vowel
    cmp al, 'I'
    je DST_Vowel
    cmp al, 'O'
    je DST_Vowel
    cmp al, 'U'
    jne DST_Next

DST_Vowel:
    inc ebx

DST_Next:
    add esi, edi
    loop DST_Count

    cmp ebx, 2
    jne DST_Done

    mov esi, pStart
    mov ebx, 4

DST_Print:
    mov al, [esi]
    call WriteChar
    add esi, edi
    dec ebx
    jnz DST_Print
    call Crlf

DST_Done:
    ret
DisplaySetIfTwo ENDP

END main
```

**풀이:**

1. 앞 문제와 같은 방식으로 무작위 행렬을 한 번 생성한다.
2. 검사 대상은 행 4개, 열 4개, 길이가 4인 대각선 2개로 총 10개이다.
3. 각 행은 이동 간격 1, 각 열은 이동 간격 4로 접근한다.
4. 주대각선의 인덱스는 0, 5, 10, 15이므로 간격 5를 사용한다. 반대 대각선은 3, 6, 9, 12이므로 간격 3을 사용한다.
5. `DisplaySetIfTwo`는 시작 주소와 간격을 전달받아 네 문자의 모음 개수를 센다.
6. 모음 개수가 정확히 2일 때만 네 문자를 출력한다.
7. 조건을 만족하는 집합이 없으면 제목 아래에 아무 집합도 출력되지 않을 수 있다.
8. 제시된 예시 행렬로 검사하려면 무작위 생성 호출 대신 해당 16개 문자를 행 우선 순서로 저장하면 된다. 중복된 글자가 있더라도 각 위치의 글자를 각각 하나로 센다.

---

## 12. Calculating the Sum of an Array Row

Write a procedure named calc_row_sum that calculates the sum of a single row in a two-dimensional array of bytes, words, or doublewords. The procedure should have the following stack parameters: array offset, row size, array type, row index. It must return the sum in EAX. Use explicit stack parameters, not INVOKE or extended PROC. Write a program that tests your procedure with arrays of byte, word, and doubleword. Prompt the user for the row index, and display the sum of the selected row.

**한글 해석:**

BYTE, WORD 또는 DWORD로 이루어진 2차원 배열의 한 행의 합을 계산하는 calc_row_sum 프로시저를 작성하시오.

배열 주소, 행 크기, 배열 원소의 자료형 크기, 행 인덱스를 스택 매개변수로 받으며 합계를 EAX로 반환해야 한다. 이 프로시저의 호출과 구현에는 INVOKE나 매개변수 목록이 있는 확장 PROC를 사용하지 말고 스택 매개변수를 명시적으로 처리한다.

BYTE, WORD, DWORD 배열로 테스트하는 프로그램을 작성하시오. 사용자에게 행 인덱스를 입력받고 해당 행의 합을 출력한다.

**답:**

```asm
INCLUDE Irvine32.inc

.data
byteArray BYTE 1,2,3,4
          BYTE 5,6,7,8
          BYTE 9,10,11,12

wordArray WORD 100,200,300,400
          WORD 500,600,700,800
          WORD 900,1000,1100,1200

dwordArray DWORD 1000,2000,3000,4000
           DWORD 5000,6000,7000,8000
           DWORD 9000,10000,11000,12000

ROW_COUNT = 3
COL_COUNT = 4
BYTE_ROW_SIZE  = COL_COUNT * TYPE byteArray
WORD_ROW_SIZE  = COL_COUNT * TYPE wordArray
DWORD_ROW_SIZE = COL_COUNT * TYPE dwordArray

prompt BYTE "Enter row index (0-2): ",0
invalidMsg BYTE "Invalid row index.",0
byteMsg BYTE "BYTE row sum: ",0
wordMsg BYTE "WORD row sum: ",0
dwordMsg BYTE "DWORD row sum: ",0

.code
main PROC
    LOCAL rowIndex:DWORD

    mov edx, OFFSET prompt
    call WriteString
    call ReadInt

    cmp eax, 0
    jl InvalidInput
    cmp eax, ROW_COUNT
    jae InvalidInput
    mov rowIndex, eax

    ; 우측 인수부터 PUSH:
    ; 행 인덱스, 원소 크기, 행 바이트 수, 배열 주소
    push rowIndex
    push TYPE byteArray
    push BYTE_ROW_SIZE
    push OFFSET byteArray
    call calc_row_sum

    push eax
    mov edx, OFFSET byteMsg
    call WriteString
    pop eax
    call WriteDec
    call Crlf

    push rowIndex
    push TYPE wordArray
    push WORD_ROW_SIZE
    push OFFSET wordArray
    call calc_row_sum

    push eax
    mov edx, OFFSET wordMsg
    call WriteString
    pop eax
    call WriteDec
    call Crlf

    push rowIndex
    push TYPE dwordArray
    push DWORD_ROW_SIZE
    push OFFSET dwordArray
    call calc_row_sum

    push eax
    mov edx, OFFSET dwordMsg
    call WriteString
    pop eax
    call WriteDec
    call Crlf
    jmp ProgramDone

InvalidInput:
    mov edx, OFFSET invalidMsg
    call WriteString
    call Crlf

ProgramDone:
    exit
main ENDP

OPTION PROLOGUE:NONE
OPTION EPILOGUE:NONE

calc_row_sum PROC
    push ebp
    mov ebp, esp
    push ebx
    push ecx
    push edx
    push esi

    ; [EBP+8]  = 배열 시작 주소
    ; [EBP+12] = 한 행의 바이트 수
    ; [EBP+16] = 원소 크기: 1, 2, 4
    ; [EBP+20] = 행 인덱스: 0부터 시작

    ; 선택한 행의 시작 주소
    mov eax, [ebp+12]
    mul DWORD PTR [ebp+20]
    mov esi, [ebp+8]
    add esi, eax

    ; 행의 원소 개수 = 행 바이트 수 / 원소 크기
    mov ebx, [ebp+16]
    mov eax, [ebp+12]
    xor edx, edx
    div ebx
    mov ecx, eax
    xor eax, eax                 ; 합계
    jecxz CRS_Done

CRS_Loop:
    cmp ebx, 1
    je CRS_Byte
    cmp ebx, 2
    je CRS_Word

    mov edx, [esi]               ; DWORD
    jmp CRS_Add

CRS_Byte:
    movzx edx, BYTE PTR [esi]
    jmp CRS_Add

CRS_Word:
    movzx edx, WORD PTR [esi]

CRS_Add:
    add eax, edx
    add esi, ebx
    loop CRS_Loop

CRS_Done:
    pop esi
    pop edx
    pop ecx
    pop ebx
    mov esp, ebp
    pop ebp
    ret 16
calc_row_sum ENDP

OPTION PROLOGUE:PrologueDef
OPTION EPILOGUE:EpilogueDef

END main
```

**풀이:**

1. 세 배열은 모두 3행 4열이며, 행 인덱스는 0부터 시작한다.
2. 이 구현에서 `row size`는 한 행의 **바이트 수**이다. BYTE 배열은 4, WORD 배열은 8, DWORD 배열은 16이다.
3. 인수는 오른쪽부터 `PUSH`하며, 프로시저는 EBP를 기준으로 명시적으로 접근한다.
4. 선택한 행의 시작 주소는 다음 식으로 계산한다.

$$\text{행 시작 주소} = \text{배열 주소} + \text{행 인덱스} \times \text{한 행의 바이트 수}$$

5. 행 원소 개수는 행 바이트 수를 원소 크기로 나눈 값이다.
6. 원소 크기에 따라 BYTE와 WORD는 `MOVZX`로 확장하고, DWORD는 그대로 읽어 EAX에 더한다.
7. 사용한 레지스터를 복원한 뒤 `RET 16`으로 네 DWORD 스택 인수를 정리한다.
8. 사용자 입력은 0부터 2까지인지 검사한다. 행 1을 선택하면 합계는 BYTE=26, WORD=2,600, DWORD=26,000이다.
9. 원소는 부호 없는 정수로 처리하며 합계는 32비트이다. 합계가 32비트 범위를 넘으면 하위 32비트만 남는다.
10. 호출자가 유효한 행 번호, 원소 크기 1·2·4, 원소 크기의 배수인 행 바이트 수를 전달한다고 가정한다. 이 프로그램의 입력과 상수는 해당 조건을 만족한다.

---

## 13. Trimming Leading Characters

Create a variant of the Str_trim procedure that lets the caller remove all instances of a leading character from a string. For example, if you were to call it with a pointer to the string “###ABC” and pass it the # character, the resulting string would be “ABC”.

**한글 해석:**

문자열 앞부분에 연속해서 나타나는 지정 문자를 모두 제거하는 Str_trim의 변형을 작성하시오.

예를 들어 `###ABC` 문자열의 포인터와 문자 `#`을 전달하면 결과 문자열은 `ABC`가 되어야 한다.

**답:**

```asm
INCLUDE Irvine32.inc

Str_trimLeading PROTO, pString:PTR BYTE, trimChar:BYTE

.data
target BYTE "###ABC",0
alsoTest BYTE "######",0

.code
main PROC
    INVOKE Str_trimLeading, ADDR target, '#'
    mov edx, OFFSET target
    call WriteString
    call Crlf

    INVOKE Str_trimLeading, ADDR alsoTest, '#'
    mov edx, OFFSET alsoTest
    call WriteString             ; 빈 문자열
    call Crlf
    exit
main ENDP

Str_trimLeading PROC USES eax edx esi edi,
    pString:PTR BYTE,
    trimChar:BYTE

    mov esi, pString
    mov edi, esi
    mov dl, trimChar

STL_Skip:
    mov al, [esi]
    test al, al
    jz STL_Copy
    cmp al, dl
    jne STL_Copy
    inc esi
    jmp STL_Skip

STL_Copy:
    mov al, [esi]
    mov [edi], al
    inc esi
    inc edi
    test al, al
    jnz STL_Copy
    ret
Str_trimLeading ENDP

END main
```

**풀이:**

1. ESI와 EDI를 모두 문자열 시작 주소로 설정한다.
2. ESI만 이동시키면서 문자열 앞부분의 제거 대상 문자를 건너뛴다.
3. 다른 문자 또는 널 문자를 만나면 그 위치부터 문자열을 원래 시작 주소로 당겨 복사한다.
4. 널 문자까지 함께 복사하므로 문자열이 올바르게 종료된다.
5. 앞부분에만 적용하므로 중간이나 끝의 동일 문자는 제거하지 않는다.
6. 모든 문자가 제거 대상이면 첫 바이트에 널 문자를 기록하여 빈 문자열을 만든다.
7. 복사 목적지가 원본보다 앞쪽 또는 같은 위치이므로 앞에서 뒤로 복사해도 아직 읽지 않은 문자를 덮어쓰지 않는다.

---

## 14. Trimming a Set of Characters

Create a variant of the Str_trim procedure that lets the caller remove all instances of a set of characters from the end of a string. For example, if you were to call it with a pointer to the string “ABC#$&” and pass it a pointer to an array of filter characters containing “%#!;$&\*”, the resulting string would be “ABC”.

**한글 해석:**

문자열 끝에서 지정한 문자 집합에 포함되는 문자들을 모두 제거하는 Str_trim의 변형을 작성하시오.

예를 들어 `ABC#$&` 문자열과 필터 문자 집합 `%#!;$&*`의 포인터를 전달하면 결과 문자열은 `ABC`가 되어야 한다.

**답:**

```asm
INCLUDE Irvine32.inc

Str_trimSet PROTO, pString:PTR BYTE, pFilter:PTR BYTE

.data
target BYTE "ABC#$&",0
filterChars BYTE "%#!;$&*",0

.code
main PROC
    INVOKE Str_trimSet, ADDR target, ADDR filterChars

    mov edx, OFFSET target
    call WriteString
    call Crlf
    exit
main ENDP

Str_trimSet PROC USES eax ebx edx esi edi,
    pString:PTR BYTE,
    pFilter:PTR BYTE

    mov ebx, pString
    mov edi, ebx

STS_FindEnd:
    cmp BYTE PTR [edi], 0
    je STS_CheckLast
    inc edi
    jmp STS_FindEnd

STS_CheckLast:
    cmp edi, ebx
    je STS_Finish               ; 빈 문자열 또는 모두 제거됨

    mov al, [edi-1]             ; 현재 마지막 실제 문자
    mov esi, pFilter

STS_FilterLoop:
    mov dl, [esi]
    test dl, dl
    jz STS_Finish               ; 필터에 없으면 여기서 종료

    cmp al, dl
    je STS_Remove

    inc esi
    jmp STS_FilterLoop

STS_Remove:
    dec edi
    jmp STS_CheckLast

STS_Finish:
    mov BYTE PTR [edi], 0
    ret
Str_trimSet ENDP

END main
```

**풀이:**

1. EDI를 문자열 끝의 널 문자 위치로 이동한다.
2. `[EDI-1]`에 있는 마지막 실제 문자가 필터 집합에 포함되는지 확인한다.
3. 필터에 포함되어 있으면 EDI를 1 감소시켜 그 문자를 제거 대상에 포함하고, 이전 문자를 다시 검사한다.
4. 필터에 없는 문자를 만나거나 문자열 시작까지 도달하면 멈춘다.
5. 마지막으로 EDI 위치에 널 문자를 기록하여 제거한 뒷부분을 문자열에서 제외한다.
6. 필터 배열도 널 종료 문자열로 전달한다. 필터가 비어 있으면 원본을 유지하며, 원본이 비어 있으면 아무 문자도 읽지 않고 종료한다.
7. 문자열 중간의 필터 문자는 제거하지 않는다. 예를 들어 `A#B$`는 `A#B`가 된다.
8. 테스트에서는 끝의 `&`, `$`, `#`이 모두 필터에 있으므로 결과는 `ABC`이다. 문자 배열은 쓰기 가능하고, 필터 배열은 대상 문자열과 겹치지 않는다고 가정한다.
