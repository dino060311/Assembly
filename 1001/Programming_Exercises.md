# Programming Exercises 풀이

---

## 1. Converting from Big Endian to Little Endian

### 문제 설명

bigEndian에서 littleEndian으로 값을 복사하면서 바이트 순서를 역순으로 변환하는 프로그램을 작성하시오.
32비트 값은 12345678h입니다.

```asm
bigEndian BYTE 12h,34h,56h,78h
littleEndian DWORD ?
```

### 답 (풀이 코드)

```asm
TITLE BigEndian to LittleEndian Conversion

.386
.MODEL flat,stdcall

.data
bigEndian BYTE 12h,34h,56h,78h
littleEndian DWORD ?

.code
main PROC
    ; 바이트를 하나씩 읽어서 역순으로 조립
    mov al, bigEndian+3      ; AL = 78h
    mov ah, bigEndian+2      ; AH = 56h
    mov edx, eax             ; EDX = 56780000h

    mov al, bigEndian+1      ; AL = 34h
    mov ah, bigEndian        ; AH = 12h
    shl eax, 16              ; EAX = 12340000h

    or edx, eax              ; EDX = 78563412h (리틀엔디안)

    mov littleEndian, edx    ; littleEndian = 78563412h

    exit
main ENDP
END main
```

### 결과

- **littleEndian = 78563412h** (바이트 역순)
- 원본 빅엔디안: 12h, 34h, 56h, 78h
- 변환된 리틀엔디안: 78h, 56h, 34h, 12h (메모리 상 낮은 주소부터)

---

## 2. Exchanging Pairs of Array Values

### 문제 설명

짝수 개의 요소를 가진 배열에서 인덱싱된 주소와 루프를 이용해 연속된 쌍을 교환하시오.
예: {1,2,3,4,5,6} → {2,1,4,3,6,5}

### 답 (풀이 코드)

```asm
TITLE Exchange Pairs in Array

.386
.MODEL flat,stdcall

.data
myArray DWORD 1,2,3,4,5,6
arraySize = ($ - myArray) / TYPE myArray  ; 6

.code
main PROC
    mov esi, 0              ; 시작 인덱스
    mov ecx, arraySize / 2  ; 반복 횟수 = 3 (쌍의 개수)

L1:
    mov eax, myArray[esi]           ; EAX = myArray[i]
    mov edx, myArray[esi + 4]       ; EDX = myArray[i+1]

    xchg eax, edx                   ; 교환

    mov myArray[esi], eax           ; myArray[i] = EDX
    mov myArray[esi + 4], edx       ; myArray[i+1] = EAX

    add esi, 8                      ; 다음 쌍으로 이동 (8 = 2 * DWORD)
    loop L1

    exit
main ENDP
END main
```

### 결과

- 원본: {1, 2, 3, 4, 5, 6}
- 결과: {2, 1, 4, 3, 6, 5}

---

## 3. Summing the Gaps between Array Values

### 문제 설명

정렬된 배열에서 연속된 요소들의 차이(갭)를 모두 합산하시오.
예: {0, 2, 5, 9, 10} → 갭: 2, 3, 4, 1 → 합: 10

### 답 (풀이 코드)

```asm
TITLE Sum of Gaps Between Array Values

.386
.MODEL flat,stdcall

.data
myArray DWORD 0, 2, 5, 9, 10
arraySize = ($ - myArray) / TYPE myArray  ; 5

.code
main PROC
    mov esi, 0              ; 시작 인덱스
    mov eax, 0              ; EAX = 합계
    mov ecx, arraySize - 1  ; 반복 횟수 = 4 (갭은 n-1개)

L1:
    mov edx, myArray[esi + 4]       ; EDX = myArray[i+1]
    sub edx, myArray[esi]           ; EDX = 갭 = myArray[i+1] - myArray[i]

    add eax, edx                    ; 합계에 추가
    add esi, 4                      ; 다음 요소로 이동

    loop L1

    ; EAX = 10 (합계)
    exit
main ENDP
END main
```

### 결과

- 배열: {0, 2, 5, 9, 10}
- 갭: 2-0=2, 5-2=3, 9-5=4, 10-9=1
- **합계 (EAX) = 10**

---

## 4. Copying a Word Array to a DoubleWord Array

### 문제 설명

16비트 WORD 배열의 모든 요소를 32비트 DWORD 배열로 복사하시오.
(부호 없는 확장)

### 답 (풀이 코드)

```asm
TITLE Copy WORD Array to DWORD Array

.386
.MODEL flat,stdcall

.data
sourceArray WORD 100h, 200h, 300h, 400h
sourceSize = ($ - sourceArray) / TYPE sourceArray  ; 4

destArray DWORD sourceSize DUP(?)

.code
main PROC
    mov esi, 0              ; sourceArray 인덱스
    mov edi, 0              ; destArray 인덱스
    mov ecx, sourceSize     ; 반복 횟수

L1:
    movzx eax, sourceArray[esi]     ; EAX = sourceArray[i] (16비트 → 32비트 확장)
    mov destArray[edi], eax         ; destArray[i] = EAX

    add esi, 2              ; WORD 크기만큼 이동
    add edi, 4              ; DWORD 크기만큼 이동

    loop L1

    exit
main ENDP
END main
```

### 결과

- 원본 (WORD): {100h, 200h, 300h, 400h}
- 결과 (DWORD): {00000100h, 00000200h, 00000300h, 00000400h}

---

## 5. Fibonacci Numbers

### 문제 설명

루프를 사용해 피보나치 수열의 첫 7개 값을 계산하시오.
Fib(1)=1, Fib(2)=1, Fib(n)=Fib(n-1)+Fib(n-2)

### 답 (풀이 코드)

```asm
TITLE Fibonacci Numbers

.386
.MODEL flat,stdcall

.data
fibonacci DWORD 7 DUP(?)

.code
main PROC
    mov fibArray, OFFSET fibonacci

    ; Fib(1) = 1
    mov dword ptr fibonacci[0], 1

    ; Fib(2) = 1
    mov dword ptr fibonacci[4], 1

    ; Fib(3) ~ Fib(7) 계산
    mov ecx, 5              ; 반복 횟수 = 5
    mov esi, 8              ; 시작 인덱스 = 2 (fibonacci[2])

L1:
    mov eax, fibonacci[esi - 4]     ; EAX = Fib(n-1)
    mov edx, fibonacci[esi - 8]     ; EDX = Fib(n-2)
    add eax, edx                    ; EAX = Fib(n-1) + Fib(n-2)

    mov fibonacci[esi], eax         ; Fib(n) = EAX
    add esi, 4                      ; 다음 요소로 이동

    loop L1

    exit
main ENDP
END main
```

### 결과

- Fib(1) = 1
- Fib(2) = 1
- Fib(3) = 2
- Fib(4) = 3
- Fib(5) = 5
- Fib(6) = 8
- Fib(7) = 13

---

## 6. Reverse an Array

### 문제 설명

다른 배열에 복사하지 않고 원본 배열의 요소들을 제자리에서 역순으로 정렬하시오.
SIZEOF, TYPE, LENGTHOF 연산자 사용으로 유연성 확보.

### 답 (풀이 코드)

```asm
TITLE Reverse an Array In Place

.386
.MODEL flat,stdcall

.data
myArray DWORD 10, 20, 30, 40, 50, 60

arrayType = TYPE myArray             ; 4 (DWORD)
arrayLength = LENGTHOF myArray       ; 6
arraySize = SIZEOF myArray           ; 24

.code
main PROC
    mov esi, OFFSET myArray          ; ESI = 시작 포인터
    mov edi, OFFSET myArray + arraySize - arrayType  ; EDI = 끝 포인터

    mov ecx, arrayLength / 2         ; 반복 횟수 = 3

L1:
    mov eax, [esi]                   ; EAX = 앞의 요소
    mov edx, [edi]                   ; EDX = 뒤의 요소

    xchg eax, edx                    ; 교환

    mov [esi], eax                   ; 앞 위치에 저장
    mov [edi], edx                   ; 뒤 위치에 저장

    add esi, arrayType               ; 앞 포인터 증가
    sub edi, arrayType               ; 뒤 포인터 감소

    loop L1

    exit
main ENDP
END main
```

### 결과

- 원본: {10, 20, 30, 40, 50, 60}
- **결과: {60, 50, 40, 30, 20, 10}**

---

## 7. Copy a String in Reverse Order

### 문제 설명

간접 주소와 루프를 이용해 문자열을 역순으로 복사하시오.

### 답 (풀이 코드)

```asm
TITLE Copy String in Reverse Order

.386
.MODEL flat,stdcall

.data
source BYTE "This is the source string",0
target BYTE SIZEOF source DUP('#')

sourceLength = $ - source - 1       ; null 문자 제외

.code
main PROC
    mov esi, OFFSET source + sourceLength - 1  ; ESI = 소스 끝 (null 제외)
    mov edi, OFFSET target                      ; EDI = 타겟 시작

    mov ecx, sourceLength           ; 반복 횟수

L1:
    mov al, [esi]                   ; AL = 소스의 문자 (끝에서부터)
    mov [edi], al                   ; 타겟에 저장

    dec esi                         ; 소스 포인터 감소 (역순)
    inc edi                         ; 타겟 포인터 증가

    loop L1

    ; null 문자 추가
    mov byte ptr [edi], 0

    exit
main ENDP
END main
```

### 결과

- 원본: "This is the source string"
- **결과: "gnirts ecruos eht si sihT"**

---

## 8. Shifting the Elements in an Array

### 문제 설명

루프와 인덱싱된 주소를 사용해 32비트 정수 배열의 요소들을 앞으로 한 칸 회전하시오.
배열 끝의 값이 처음 위치로 감싸서 이동합니다.
예: {10, 20, 30, 40} → {40, 10, 20, 30}

### 답 (풀이 코드)

```asm
TITLE Rotate Array Elements Forward

.386
.MODEL flat,stdcall

.data
myArray DWORD 10, 20, 30, 40
arraySize = LENGTHOF myArray        ; 4

.code
main PROC
    ; 마지막 요소 저장
    mov eax, myArray[arraySize * 4 - 4]  ; EAX = myArray[3] = 40
    mov ebx, eax                         ; EBX에 임시 저장

    ; 모든 요소를 한 칸씩 뒤로 이동
    mov ecx, arraySize - 1          ; 반복 횟수 = 3
    mov esi, (arraySize - 1) * 4    ; 마지막에서 시작

L1:
    mov edx, myArray[esi - 4]       ; EDX = myArray[i-1]
    mov myArray[esi], edx           ; myArray[i] = myArray[i-1]

    sub esi, 4                      ; 이전 인덱스로 이동

    loop L1

    ; 첫 번째 위치에 마지막 요소 삽입
    mov myArray[0], ebx             ; myArray[0] = 40

    exit
main ENDP
END main
```

### 결과

- 원본: {10, 20, 30, 40}
- **결과: {40, 10, 20, 30}**

|       단계        | 배열 상태        |
| :---------------: | ---------------- |
|       원본        | {10, 20, 30, 40} |
|   EBX에 40 저장   | {10, 20, 30, 40} |
| 한 칸씩 뒤로 이동 | {10, 10, 20, 30} |
| 첫 번째에 40 삽입 | {40, 10, 20, 30} |
