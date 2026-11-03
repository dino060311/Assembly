# Programming Exercises 답안

---

## 1. Display ASCII Decimal

Write a procedure named WriteScaled that outputs a decimal ASCII number with an implied decimal point. Suppose the following number were defined as follows, where DECIMAL_OFFSET indicates that the decimal point must be inserted five positions from the right side of the number:

```asm
DECIMAL_OFFSET = 5
.data
decimal_one BYTE "100123456789765"
```

WriteScaled would display the number like this:

```text
1001234567.89765
```

When calling WriteScaled, pass the number’s offset in EDX, the number length in ECX, and the decimal offset in EBX. Write a test program that passes three numbers of different sizes to the WriteScaled procedure.

문자열로 저장된 숫자에 소수점이 생략되어 있을 때, `WriteScaled`라는 프로시저를 작성하여 소수점을 포함한 십진수 ASCII 문자열을 출력하시오. `DECIMAL_OFFSET`은 숫자의 오른쪽에서부터 소수점을 삽입할 위치를 나타냅니다. 예를 들어 `DECIMAL_OFFSET = 5`이고 문자열이 `"100123456789765"`라면 `1001234567.89765`로 출력합니다. 호출할 때 EDX에는 숫자 문자열의 주소, ECX에는 문자열의 길이, EBX에는 소수점 오른쪽 자릿수를 전달하시오. 길이가 서로 다른 숫자 3개를 전달하는 테스트 프로그램을 작성하시오.

**답:**

```asm
TITLE Display ASCII Decimal

INCLUDE Irvine32.inc

.data
decimal1 BYTE "100123456789765"
decimal2 BYTE "123456789"
decimal3 BYTE "987654321012"

.code
; EDX = 숫자 문자열 주소
; ECX = 문자열 길이
; EBX = 소수점 오른쪽 자릿수
WriteScaled PROC
    push eax
    push ecx
    push edx
    push esi
    push edi
    push ebx

    mov esi, edx                 ; ESI = 문자열 시작 주소
    mov edi, ecx                 ; EDI = 전체 문자열 길이
    sub edi, ebx                 ; EDI = 소수점 왼쪽에 출력할 자릿수

    ; 소수점 왼쪽 숫자 출력
    mov ecx, edi
LeftPart:
    cmp ecx, 0
    je  PrintPoint
    mov al, [esi]
    call WriteChar
    inc esi
    loop LeftPart

PrintPoint:
    mov al, '.'
    call WriteChar

    ; 소수점 오른쪽 숫자 출력
    mov ecx, ebx
RightPart:
    cmp ecx, 0
    je  WriteScaledDone
    mov al, [esi]
    call WriteChar
    inc esi
    loop RightPart

WriteScaledDone:
    call Crlf

    pop ebx
    pop edi
    pop esi
    pop edx
    pop ecx
    pop eax
    ret
WriteScaled ENDP

main PROC
    ; 첫 번째 숫자: 15자리, 소수점 오른쪽 5자리
    mov edx, OFFSET decimal1
    mov ecx, LENGTHOF decimal1
    mov ebx, 5
    call WriteScaled

    ; 두 번째 숫자: 9자리, 소수점 오른쪽 3자리
    mov edx, OFFSET decimal2
    mov ecx, LENGTHOF decimal2
    mov ebx, 3
    call WriteScaled

    ; 세 번째 숫자: 12자리, 소수점 오른쪽 4자리
    mov edx, OFFSET decimal3
    mov ecx, LENGTHOF decimal3
    mov ebx, 4
    call WriteScaled

    exit
main ENDP
END main
```

**풀이:**

1. `WriteScaled`는 숫자를 정수로 변환하지 않고, 문자열의 문자를 앞에서부터 출력합니다.
2. `EDX`에 전달된 주소를 `ESI`에 복사하여 현재 출력할 문자의 위치를 가리키게 합니다.
3. 전체 길이에서 `EBX`를 빼면 소수점 왼쪽에 출력할 문자 개수가 됩니다.
   - 예: 전체 길이 15, 소수점 오른쪽 자릿수 5 → 왼쪽 10자리
4. `LeftPart` 반복문에서 소수점 왼쪽 문자를 출력합니다.
5. 왼쪽 부분을 모두 출력하면 `.`을 출력합니다.
6. `RightPart` 반복문에서 소수점 오른쪽 문자를 출력합니다.
7. 프로시저가 사용하는 레지스터는 `PUSH`로 저장하고, 종료 전에 `POP`으로 복원합니다.

**실행 결과 예시:**

```text
1001234567.89765
123456.789
98765432.1012
```

---

## 2. Extended Subtraction Procedure

Create a procedure named Extended_Sub that subtracts two binary integers of arbitrary size. The storage size of the two integers must be the same, and their size must be a multiple of 32 bits. Write a test program that passes several pairs of integers, each at least 10 bytes long.

임의의 크기를 가진 두 이진 정수를 빼는 `Extended_Sub` 프로시저를 작성하시오. 두 정수의 저장 크기는 같아야 하며, 크기는 32비트의 배수여야 합니다. 각각 최소 10바이트 이상인 여러 정수 쌍을 전달하는 테스트 프로그램을 작성하시오.

**답:**

```asm
TITLE Extended Subtraction

INCLUDE Irvine32.inc

.data
; 각 정수는 12바이트(96비트)
; 가장 낮은 바이트가 배열의 첫 번째 요소에 저장되는 리틀 엔디안 형식
numA1 BYTE 12h, 34h, 56h, 78h, 9Ah, 0BCh, 0DEh, 0F0h, 11h, 22h, 33h, 44h
numB1 BYTE 01h, 02h, 03h, 04h, 05h, 06h, 07h, 08h, 09h, 0Ah, 0Bh, 0Ch
result1 BYTE 12 DUP(?)

numA2 BYTE 50h, 40h, 30h, 20h, 10h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
numB2 BYTE 10h, 20h, 30h, 40h, 50h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
result2 BYTE 12 DUP(?)

.code
; ESI = 첫 번째 정수 주소
; EDI = 두 번째 정수 주소
; EDX = 결과 저장 주소
; ECX = 바이트 수
Extended_Sub PROC
    push eax
    push esi
    push edi
    push edx
    push ecx

    clc                          ; 최초 빌림(borrow)을 0으로 설정

SubLoop:
    mov al, [esi]                ; 첫 번째 정수의 현재 바이트
    sbb al, [edi]                ; AL = AL - 두 번째 바이트 - CF
    mov [edx], al                ; 결과 바이트 저장

    ; LEA와 MOV는 Carry Flag를 변경하지 않음
    lea esi, [esi + 1]
    lea edi, [edi + 1]
    lea edx, [edx + 1]

    loop SubLoop                 ; LOOP는 플래그를 변경하지 않음

    pop ecx
    pop edx
    pop edi
    pop esi
    pop eax
    ret
Extended_Sub ENDP

main PROC
    ; 첫 번째 12바이트 정수 쌍
    mov esi, OFFSET numA1
    mov edi, OFFSET numB1
    mov edx, OFFSET result1
    mov ecx, LENGTHOF numA1
    call Extended_Sub

    mov edx, OFFSET result1
    mov ecx, LENGTHOF result1
    mov ebx, TYPE result1
    call DumpMem

    ; 두 번째 12바이트 정수 쌍
    mov esi, OFFSET numA2
    mov edi, OFFSET numB2
    mov edx, OFFSET result2
    mov ecx, LENGTHOF numA2
    call Extended_Sub

    mov edx, OFFSET result2
    mov ecx, LENGTHOF result2
    mov ebx, TYPE result2
    call DumpMem

    exit
main ENDP
END main
```

**풀이:**

1. 여러 바이트로 이루어진 정수는 리틀 엔디안 방식으로 저장되어 있다고 가정합니다. 가장 낮은 자리의 바이트가 가장 낮은 주소에 있습니다.
2. 뺄셈은 가장 낮은 바이트부터 시작해야 합니다.
3. `CLC`로 처음 빌림을 0으로 설정합니다.
4. `SBB`는 두 번째 피연산자와 Carry Flag를 함께 빼므로, 앞 바이트에서 발생한 빌림이 다음 바이트로 전달됩니다.
5. `MOV`와 `LEA`는 Carry Flag를 변경하지 않습니다. 따라서 바이트 주소를 다음 위치로 이동해도 빌림 정보가 유지됩니다.
6. `LOOP` 명령은 ECX를 감소시키지만 플래그를 변경하지 않으므로, 다음 `SBB`까지 Carry Flag가 보존됩니다.
7. 이 방식은 바이트 단위로 처리하므로 12바이트뿐 아니라 크기가 같은 다른 길이의 정수에도 사용할 수 있습니다. 문제에서 요구한 크기 조건에 맞게 전달하는 바이트 수는 4의 배수여야 합니다.

---

## 3. Packed Decimal Conversion

Write a procedure named PackedToAsc that converts a 4-byte packed decimal integer to a string of ASCII decimal digits. Pass the packed integer and the address of a buffer holding the ASCII digits to the procedure. Write a short test program that passes at least 5 packed decimal integers to your procedure.

4바이트 패킹 십진 정수를 ASCII 십진 숫자 문자열로 변환하는 `PackedToAsc` 프로시저를 작성하시오. 패킹 정수와 ASCII 숫자를 저장할 버퍼의 주소를 프로시저에 전달하시오. 최소 5개의 패킹 십진 정수를 전달하는 간단한 테스트 프로그램을 작성하시오.

**답:**

```asm
TITLE Packed Decimal Conversion

INCLUDE Irvine32.inc

.data
; 4바이트 packed decimal: 숫자 7개 + 부호 니블
packed1 DWORD 1234567Ch
packed2 DWORD 7654321Ch
packed3 DWORD 0000123Ch
packed4 DWORD 9876543Ch
packed5 DWORD 2468101Ch

buffer BYTE 8 DUP(0)

.code
; EAX = 4바이트 packed decimal 값
; EDX = ASCII 문자열을 저장할 버퍼 주소
; 여기서는 양수 부호 니블 C를 사용하는 7자리 packed decimal을 처리
PackedToAsc PROC
    push eax
    push ebx
    push ecx
    push edx
    push edi

    mov ebx, eax                 ; EBX에 원본 packed decimal 저장
    mov edi, edx                 ; EDI = 출력 버퍼 주소
    mov ecx, 7                   ; 숫자 니블은 7개

ConvertLoop:
    ; 최상위 니블을 AL로 가져옴
    mov eax, ebx
    shr eax, 28
    and al, 0Fh
    add al, '0'                  ; 0~9를 ASCII '0'~'9'로 변환
    mov [edi], al

    inc edi
    shl ebx, 4                   ; 다음 숫자 니블을 최상위로 이동
    loop ConvertLoop

    mov byte ptr [edi], 0        ; 문자열 끝에 NULL 추가

    pop edi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
PackedToAsc ENDP

main PROC
    mov eax, packed1
    mov edx, OFFSET buffer
    call PackedToAsc
    mov edx, OFFSET buffer
    call WriteString
    call Crlf

    mov eax, packed2
    mov edx, OFFSET buffer
    call PackedToAsc
    mov edx, OFFSET buffer
    call WriteString
    call Crlf

    mov eax, packed3
    mov edx, OFFSET buffer
    call PackedToAsc
    mov edx, OFFSET buffer
    call WriteString
    call Crlf

    mov eax, packed4
    mov edx, OFFSET buffer
    call PackedToAsc
    mov edx, OFFSET buffer
    call WriteString
    call Crlf

    mov eax, packed5
    mov edx, OFFSET buffer
    call PackedToAsc
    mov edx, OFFSET buffer
    call WriteString
    call Crlf

    exit
main ENDP
END main
```

**풀이:**

1. Packed Decimal은 숫자 한 자리를 4비트(니블)로 저장합니다.
2. 4바이트는 총 8개의 니블로 구성됩니다. 이 예제에서는 앞의 7개 니블을 숫자로 사용하고 마지막 니블은 부호(C)로 사용합니다.
3. `SHR EAX, 28`은 최상위 4비트를 가장 오른쪽으로 이동시킵니다.
4. `AND AL, 0Fh`로 해당 니블만 남깁니다.
5. `ADD AL, '0'`을 실행하면 숫자 0~9가 ASCII 문자 `'0'`~`'9'`로 변환됩니다.
6. `SHL EBX, 4`를 실행하면 다음 니블이 최상위 위치로 이동합니다.
7. 7개의 숫자 니블을 모두 변환한 뒤 마지막에 NULL 문자를 넣어 문자열을 완성합니다.

**실행 결과 예시:**

```text
1234567
7654321
0000123
9876543
2468101
```

---

## 4. Encryption Using Rotate Operations

Write a procedure that performs simple encryption by rotating each plaintext byte a varying number of positions in different directions. For example, in the following array that represents the encryption key, a negative value indicates a rotation to the left and a positive value indicates a rotation to the right. The integer in each position indicates the magnitude of the rotation:

```asm
key BYTE -2, 4, 1, 0, -3, 5, 2, -4, -4, 6
```

Your procedure should loop through a plaintext message and align the key to the first 10 bytes of the message. Rotate each plaintext byte by the amount indicated by its matching key array value. Then, align the key to the next 10 bytes of the message and repeat the process. Write a program that tests your encryption procedure by calling it twice, with different data sets.

평문 바이트를 서로 다른 방향과 횟수로 회전시켜 간단하게 암호화하는 프로시저를 작성하시오. 암호화 키 배열에서 음수는 왼쪽 회전, 양수는 오른쪽 회전을 의미하며 정수의 절댓값은 회전 횟수를 나타냅니다. 프로시저는 평문 메시지의 처음 10바이트에 키 배열을 적용하고, 다음 10바이트에도 키 배열을 처음부터 다시 적용하는 과정을 반복해야 합니다. 서로 다른 데이터로 암호화 프로시저를 두 번 호출하는 테스트 프로그램을 작성하시오.

**답:**

```asm
TITLE Encryption Using Rotate Operations

INCLUDE Irvine32.inc

.data
key SBYTE -2, 4, 1, 0, -3, 5, 2, -4, -4, 6

message1 BYTE "Assembly language is fun!", 0
message2 BYTE "Rotate each byte to encrypt!", 0

.code
; ESI = 평문 문자열 주소
; 문자열은 NULL 문자(0)로 끝남
Encrypt PROC
    push eax
    push ebx
    push ecx
    push esi
    push edi

    mov edi, 0                   ; 키 배열 인덱스 = 0

EncryptLoop:
    mov al, [esi]
    cmp al, 0
    je  EncryptDone              ; NULL이면 문자열 끝

    movsx ecx, key[edi]          ; 현재 키 값을 부호 확장

    cmp ecx, 0
    jl  RotateLeft
    jg  RotateRight
    jmp NextByte                 ; 키가 0이면 회전하지 않음

RotateLeft:
    neg ecx                      ; 음수를 양수 회전 횟수로 변경
    rol byte ptr [esi], cl       ; 왼쪽 회전
    jmp NextByte

RotateRight:
    ror byte ptr [esi], cl       ; 오른쪽 회전

NextByte:
    inc esi                      ; 다음 평문 바이트
    inc edi                      ; 다음 키 위치

    cmp edi, 10
    jb  EncryptLoop
    mov edi, 0                   ; 키 10개를 사용했으면 처음으로

    jmp EncryptLoop

EncryptDone:
    pop edi
    pop esi
    pop ecx
    pop ebx
    pop eax
    ret
Encrypt ENDP

main PROC
    ; 첫 번째 메시지 암호화
    mov esi, OFFSET message1
    call Encrypt

    mov edx, OFFSET message1
    call WriteString
    call Crlf

    ; 두 번째 메시지 암호화
    mov esi, OFFSET message2
    call Encrypt

    mov edx, OFFSET message2
    call WriteString
    call Crlf

    exit
main ENDP
END main
```

**풀이:**

1. `key` 배열에는 총 10개의 회전 값이 저장되어 있습니다.
2. `ESI`는 현재 암호화할 평문 문자의 주소를 가리킵니다.
3. `EDI`는 키 배열의 인덱스이며 0부터 9까지 사용합니다.
4. `MOVSX`는 키 값이 음수일 수도 있으므로 부호를 유지하면서 ECX로 확장합니다.
5. 키 값이 음수이면 `NEG`로 회전 횟수를 양수로 바꾼 뒤 `ROL`을 사용합니다.
6. 키 값이 양수이면 `ROR`을 사용합니다.
7. 키 값이 0이면 해당 바이트는 회전하지 않습니다.
8. 키 배열의 10개 값을 모두 사용하면 `EDI`를 0으로 되돌려 다음 10바이트에 같은 키를 반복 적용합니다.
9. 메시지의 NULL 문자를 만나면 암호화를 종료합니다.
10. 이 프로시저는 원본 문자열을 직접 변경하는 방식입니다.

**핵심 명령어:**

| 명령어  | 기능                   |
| ------- | ---------------------- |
| `ROL`   | 비트를 왼쪽으로 회전   |
| `ROR`   | 비트를 오른쪽으로 회전 |
| `MOVSX` | 부호를 유지하며 확장   |
| `NEG`   | 2의 보수로 부호 반전   |

---

## 5. Prime Numbers

Write a program that generates all prime numbers between 2 and 1000, using the Sieve of Eratosthenes method. You can find many articles that describe the method for finding primes in this manner on the Internet. Display all the prime values.

에라토스테네스의 체(Sieve of Eratosthenes)를 사용하여 2부터 1000 사이의 모든 소수를 생성하는 프로그램을 작성하시오. 이 방법으로 소수를 찾는 방법은 인터넷에서 확인할 수 있습니다. 생성한 모든 소수 값을 화면에 출력하시오.

**답:**

```asm
TITLE Prime Numbers - Sieve of Eratosthenes

INCLUDE Irvine32.inc

.data
isPrime BYTE 1001 DUP(1)          ; 처음에는 모든 수를 소수라고 가정

.code
main PROC
    ; 0과 1은 소수가 아님
    mov isPrime[0], 0
    mov isPrime[1], 0

    mov esi, 2                    ; 검사할 소수 후보 p = 2

OuterLoop:
    cmp esi, 31                   ; sqrt(1000)은 약 31.6
    ja  DisplayPrimes

    cmp isPrime[esi], 0
    je  NextPrime                  ; 이미 소수가 아니면 건너뜀

    ; p의 배수 제거는 p*p부터 시작
    mov eax, esi
    imul eax, esi                 ; EAX = p * p
    mov edi, eax                  ; EDI = 제거할 배수

MarkMultiples:
    cmp edi, 1000
    ja  NextPrime

    mov isPrime[edi], 0           ; p의 배수는 소수가 아님
    add edi, esi                  ; 다음 배수로 이동
    jmp MarkMultiples

NextPrime:
    inc esi
    jmp OuterLoop

DisplayPrimes:
    mov esi, 2

PrintLoop:
    cmp esi, 1000
    ja  ProgramDone

    cmp isPrime[esi], 1
    jne SkipNumber

    mov eax, esi
    call WriteDec
    mov al, ' '
    call WriteChar

SkipNumber:
    inc esi
    jmp PrintLoop

ProgramDone:
    call Crlf
    exit
main ENDP
END main
```

**풀이:**

1. `isPrime` 배열을 1001바이트로 만들고 모든 요소를 1로 초기화합니다. 인덱스가 숫자를 의미합니다.
   - `isPrime[2] = 1`이면 2는 소수입니다.
   - `isPrime[4] = 0`이면 4는 소수가 아닙니다.
2. 0과 1은 소수가 아니므로 0으로 설정합니다.
3. 2부터 31까지 소수 후보를 확인합니다. 1000 이하의 합성수는 반드시 제곱근 이하의 소인수를 가지므로 31까지만 확인하면 됩니다.
4. 현재 숫자가 이미 0이면 합성수이므로 다음 숫자로 이동합니다.
5. 현재 숫자 `p`가 소수라면 `p*p`부터 시작하여 `p`의 배수를 모두 0으로 표시합니다.
   - 예: `p = 2`이면 4, 6, 8, 10, ...을 제거합니다.
   - 예: `p = 3`이면 9, 12, 15, 18, ...을 제거합니다.
6. 모든 배수 제거가 끝나면 배열을 2부터 1000까지 확인합니다.
7. 값이 1인 인덱스만 소수이므로 `WriteDec`로 출력합니다.

**핵심 개념:**

- 소수: 1과 자기 자신만을 약수로 가지는 2 이상의 자연수
- 합성수: 1과 자기 자신 이외의 약수를 가지는 수
- 에라토스테네스의 체: 소수의 배수를 차례대로 제거하여 소수만 남기는 방법

---

## 6. Greatest Common Divisor (GCD)

The greatest common divisor (GCD) of two integers is the largest integer that will evenly divide both integers. The GCD algorithm involves integer division in a loop, described by the following pseudocode:

```cpp
int GCD(int x, int y)
{
    x = abs(x) // absolute value
    y = abs(y)
    do {
        int n = x % y
        x = y
        y = n
    } while (y > 0)
    return x
}
```

Implement this function in assembly language and write a test program that calls the function several times, passing it different values. Display all results on the screen.

두 정수의 최대공약수(GCD)는 두 정수를 모두 나누어떨어지게 하는 가장 큰 정수입니다. 제시된 의사 코드는 정수 나눗셈을 반복하여 최대공약수를 구하는 알고리즘입니다. 이 함수를 어셈블리 언어로 구현하고, 서로 다른 값을 전달하여 여러 번 호출하는 테스트 프로그램을 작성하시오. 모든 결과를 화면에 출력하시오.

**답:**

```asm
TITLE Greatest Common Divisor

INCLUDE Irvine32.inc

.data
msg1 BYTE "GCD(48, 18) = ", 0
msg2 BYTE "GCD(-84, 30) = ", 0
msg3 BYTE "GCD(100, 25) = ", 0
msg4 BYTE "GCD(17, 13) = ", 0

.code
; EAX = 첫 번째 정수 x
; EBX = 두 번째 정수 y
; 반환값 EAX = GCD
GCD PROC
    push ebx
    push edx

    ; x의 절댓값
    test eax, eax
    jns CheckY
    neg eax

CheckY:
    ; y의 절댓값
    test ebx, ebx
    jns GCDLoop
    neg ebx

GCDLoop:
    cmp ebx, 0
    je  GCDDone

    xor edx, edx
    div ebx                      ; EDX = x % y

    mov eax, ebx                 ; x = y
    mov ebx, edx                 ; y = 나머지
    jmp GCDLoop

GCDDone:
    pop edx
    pop ebx
    ret
GCD ENDP

main PROC
    ; GCD(48, 18)
    mov edx, OFFSET msg1
    call WriteString
    mov eax, 48
    mov ebx, 18
    call GCD
    call WriteDec
    call Crlf

    ; GCD(-84, 30)
    mov edx, OFFSET msg2
    call WriteString
    mov eax, -84
    mov ebx, 30
    call GCD
    call WriteDec
    call Crlf

    ; GCD(100, 25)
    mov edx, OFFSET msg3
    call WriteString
    mov eax, 100
    mov ebx, 25
    call GCD
    call WriteDec
    call Crlf

    ; GCD(17, 13)
    mov edx, OFFSET msg4
    call WriteString
    mov eax, 17
    mov ebx, 13
    call GCD
    call WriteDec
    call Crlf

    exit
main ENDP
END main
```

**풀이:**

1. `GCD` 프로시저는 EAX와 EBX로 두 정수를 전달받습니다.
2. 먼저 두 정수의 절댓값을 구합니다.
   - `TEST`로 부호를 확인합니다.
   - 음수이면 `NEG`로 부호를 반전합니다.
3. 유클리드 알고리즘을 반복합니다.
   - `DIV EBX`를 실행하면 EAX를 EBX로 나눈 몫은 EAX에, 나머지는 EDX에 저장됩니다.
   - `MOV EAX, EBX`로 x에 기존 y를 대입합니다.
   - `MOV EBX, EDX`로 y에 나머지를 대입합니다.
4. 나머지가 0이 되면 반복을 종료합니다.
5. 마지막 EAX에 남아 있는 값이 최대공약수입니다.

**실행 결과:**

```text
GCD(48, 18) = 6
GCD(-84, 30) = 6
GCD(100, 25) = 25
GCD(17, 13) = 1
```

---

## 7. Bitwise Multiplication

Write a procedure named BitwiseMultiply that multiplies any unsigned 32-bit integer by EAX, using only shifting and addition. Pass the integer to the procedure in the EBX register, and return the product in the EAX register. Write a short test program that calls the procedure and displays the product. (We will assume that the product is never larger than 32 bits.) This is a fairly challenging program to write. One possible approach is to use a loop to shift the multiplier to the right, keeping track of the number of shifts that occur before the Carry flag is set. The resulting shift count can then be applied to the SHL instruction, using the multiplicand as the destination operand. Then, the same process must be repeated until you find the last 1 bit in the multiplier.

시프트와 덧셈만을 사용하여 EAX의 값에 임의의 부호 없는 32비트 정수를 곱하는 `BitwiseMultiply` 프로시저를 작성하시오. 곱할 정수는 EBX 레지스터로 전달하고, 곱셈 결과는 EAX 레지스터로 반환하시오. 프로시저를 호출하고 결과를 화면에 표시하는 간단한 테스트 프로그램을 작성하시오. 결과가 32비트를 초과하지 않는다고 가정합니다. 한 가지 방법은 곱셈기를 오른쪽으로 시프트하면서 Carry Flag가 설정될 때까지의 시프트 횟수를 세는 것입니다. 그 시프트 횟수를 곱셈수에 대한 `SHL` 명령에 적용할 수 있습니다. 곱셈기의 마지막 1비트를 찾을 때까지 이 과정을 반복합니다.

**답:**

```asm
TITLE Bitwise Multiplication

INCLUDE Irvine32.inc

.code
; EAX = 곱할 첫 번째 값(multiplicand)
; EBX = 곱할 두 번째 값(multiplier)
; 반환값 EAX = 곱
BitwiseMultiply PROC
    push ebx
    push ecx
    push edx

    mov ecx, eax                 ; ECX = multiplicand
    xor eax, eax                 ; EAX = 결과 누산기

MultiplyLoop:
    cmp ebx, 0
    je  MultiplyDone

    test ebx, 1                  ; multiplier의 최하위 비트 확인
    jz  SkipAdd

    add eax, ecx                 ; 현재 비트가 1이면 더함

SkipAdd:
    shl ecx, 1                   ; 다음 비트 위치에 맞게 multiplicand 이동
    shr ebx, 1                   ; multiplier를 오른쪽으로 1비트 이동
    jmp MultiplyLoop

MultiplyDone:
    pop edx
    pop ecx
    pop ebx
    ret
BitwiseMultiply ENDP

main PROC
    ; 25 * 12
    mov eax, 25
    mov ebx, 12
    call BitwiseMultiply

    call WriteDec
    call Crlf

    ; 123 * 7
    mov eax, 123
    mov ebx, 7
    call BitwiseMultiply

    call WriteDec
    call Crlf

    exit
main ENDP
END main
```

**풀이:**

1. 이진수 곱셈은 곱셈수의 각 비트를 확인하면서 필요한 값을 더하는 방식으로 구현할 수 있습니다.
2. `ECX`에는 처음 EAX에 있던 곱셈수를 저장합니다.
3. EAX는 결과를 누적하는 레지스터이므로 0으로 초기화합니다.
4. `TEST EBX, 1`은 EBX의 최하위 비트가 1인지 확인합니다.
   - 최하위 비트가 1이면 현재 곱셈수를 결과에 더합니다.
   - 0이면 더하지 않습니다.
5. `SHL ECX, 1`은 곱셈수를 왼쪽으로 한 비트 이동시킵니다. 이는 2를 곱하는 것과 같습니다.
6. `SHR EBX, 1`은 곱셈기를 오른쪽으로 한 비트 이동시킵니다. 다음 비트를 확인하기 위한 과정입니다.
7. EBX가 0이 되면 모든 비트를 확인한 것이므로 종료합니다.
8. 문제에서 결과가 32비트를 넘지 않는다고 가정했으므로 EAX에 결과를 반환합니다.

**실행 결과:**

```text
300
861
```

**예시: 25 × 12**

```text
25  = 11001
12  = 01100

12의 각 비트를 확인하여 필요한 값을 더하면
25 × 12 = 300
```

---

## 8. Add Packed Integers

Extend the AddPacked procedure from Section 7.6.1 so that it adds two packed decimal integers of arbitrary size (both lengths must be the same). Write a test program that passes AddPacked several pairs of integers: 4-byte, 8-byte, and 16-byte. We suggest that you use the following registers to pass information to the procedure:

```asm
ESI - pointer to the first number
EDI - pointer to the second number
EDX - pointer to the sum
ECX - number of bytes to add
```

7.6.1절의 `AddPacked` 프로시저를 확장하여 임의의 크기를 가진 두 패킹 십진 정수를 더하도록 하시오. 두 정수의 길이는 같아야 합니다. 4바이트, 8바이트, 16바이트 정수 쌍을 여러 개 전달하는 테스트 프로그램을 작성하시오. 프로시저에 정보를 전달할 때 다음 레지스터를 사용할 것을 권장합니다.

- ESI: 첫 번째 숫자의 포인터
- EDI: 두 번째 숫자의 포인터
- EDX: 합계를 저장할 포인터
- ECX: 더할 바이트 수

**답:**

```asm
TITLE Add Packed Integers

INCLUDE Irvine32.inc

.data
; Packed BCD는 한 바이트에 십진 숫자 두 자리를 저장
; 아래 배열은 낮은 자리 바이트부터 저장하는 리틀 엔디안 순서

; 4바이트 packed decimal
numA4 BYTE 34h, 12h, 00h, 00h
numB4 BYTE 66h, 87h, 00h, 00h
sum4  BYTE 4 DUP(0)

; 8바이트 packed decimal
numA8 BYTE 00h, 00h, 00h, 00h, 00h, 00h, 12h, 34h
numB8 BYTE 00h, 00h, 00h, 00h, 00h, 00h, 56h, 78h
sum8  BYTE 8 DUP(0)

; 16바이트 packed decimal
numA16 BYTE 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 12h, 34h
numB16 BYTE 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 56h, 78h
sum16 BYTE 16 DUP(0)

.code
; ESI = 첫 번째 packed decimal 주소
; EDI = 두 번째 packed decimal 주소
; EDX = 합계를 저장할 주소
; ECX = 더할 바이트 수
AddPacked PROC
    push eax
    push esi
    push edi
    push edx
    push ecx

    clc                          ; 처음 Carry를 0으로 설정

AddLoop:
    mov al, [esi]                ; 첫 번째 숫자의 현재 바이트
    adc al, [edi]                ; 두 번째 바이트와 이전 Carry를 더함
    daa                          ; AL을 packed BCD 형식으로 보정
    mov [edx], al                ; 결과 바이트 저장

    ; INC는 Carry Flag를 변경하지 않으므로 다음 바이트에 Carry 전달 가능
    inc esi
    inc edi
    inc edx

    loop AddLoop

    pop ecx
    pop edx
    pop edi
    pop esi
    pop eax
    ret
AddPacked ENDP

main PROC
    ; 4바이트 덧셈
    mov esi, OFFSET numA4
    mov edi, OFFSET numB4
    mov edx, OFFSET sum4
    mov ecx, LENGTHOF numA4
    call AddPacked

    mov esi, OFFSET sum4
    mov ecx, LENGTHOF sum4
    mov ebx, TYPE sum4
    call DumpMem

    ; 8바이트 덧셈
    mov esi, OFFSET numA8
    mov edi, OFFSET numB8
    mov edx, OFFSET sum8
    mov ecx, LENGTHOF numA8
    call AddPacked

    mov esi, OFFSET sum8
    mov ecx, LENGTHOF sum8
    mov ebx, TYPE sum8
    call DumpMem

    ; 16바이트 덧셈
    mov esi, OFFSET numA16
    mov edi, OFFSET numB16
    mov edx, OFFSET sum16
    mov ecx, LENGTHOF numA16
    call AddPacked

    mov esi, OFFSET sum16
    mov ecx, LENGTHOF sum16
    mov ebx, TYPE sum16
    call DumpMem

    exit
main ENDP
END main
```

**풀이:**

1. Packed BCD는 한 바이트에 십진수 두 자리를 저장합니다. 예를 들어 `34h`는 십진수 34를 의미합니다.
2. 가장 낮은 자리 바이트부터 더해야 하므로 배열을 낮은 주소에서 높은 주소 방향으로 처리합니다.
3. `CLC`로 첫 번째 바이트를 더하기 전에 Carry Flag를 0으로 초기화합니다.
4. `ADC AL, [EDI]`는 AL과 두 번째 숫자의 바이트, 이전 바이트에서 전달된 Carry를 더합니다.
5. `DAA`는 덧셈 결과를 packed BCD 형식에 맞게 십진 보정합니다.
6. 보정된 AL을 결과 배열에 저장합니다.
7. 다음 바이트로 이동한 뒤 `LOOP`로 반복합니다.
8. `INC`와 `MOV`는 Carry Flag를 변경하지 않으므로 `DAA`에서 발생한 십진 Carry가 다음 바이트의 `ADC`로 전달됩니다.
9. 같은 길이의 두 배열을 처리하므로 ECX에 4, 8, 16을 전달하면 각각의 크기에 맞게 계산할 수 있습니다.
