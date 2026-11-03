# Algorithm Workbench

## 1. Write a sequence of shift instructions that cause AX to be sign-extended into EAX. In other words, the sign bit of AX is copied into the upper 16 bits of EAX. Do not use the CWD instruction.

AX를 EAX로 부호 확장하는 시프트 명령어들을 작성하시오. 즉, AX의 부호 비트가 EAX의 상위 16비트로 복사되도록 하시오. CWD 명령어는 사용하지 마시오.

**답:**

```asm
shl eax,16
sar eax,16
```

**풀이:**

`SHL EAX,16`으로 원래 AX를 EAX의 상위 16비트로 이동시킨다. 이어서 `SAR EAX,16`을 실행하면 최상위 부호 비트를 유지하면서 오른쪽으로 16비트 이동하므로 AX의 부호가 EAX 전체에 확장된다.

---

## 2. Suppose the instruction set contained no rotate instructions. Show how you would use SHR and a conditional jump instruction to rotate the contents of the AL register 1 bit to the right.

명령어 집합에 회전 명령어가 없다고 가정하자. SHR과 조건부 점프 명령어를 사용하여 AL 레지스터의 내용을 오른쪽으로 1비트 회전시키는 방법을 작성하시오.

**답:**

```asm
shr al,1
jnc no_wrap
or al,80h
no_wrap:
```

**풀이:**

`SHR`은 AL을 오른쪽으로 이동시키고 원래 최하위 비트를 CF에 저장한다. `JNC`는 CF가 0이면 건너뛴다. CF가 1이면 `OR AL,80h`로 최상위 비트를 1로 설정한다. 따라서 원래 최하위 비트가 최상위 비트로 이동한 것과 같은 효과가 난다.

---

## 3. Write a logical shift instruction that multiplies the contents of EAX by 16.

EAX의 내용을 16배로 만드는 논리적 시프트 명령어를 작성하시오.

**답:**

```asm
shl eax,4
```

**풀이:**

왼쪽으로 1비트 시프트할 때마다 값은 2배가 된다. \(16=2^4\)이므로 4비트 왼쪽 시프트하면 16배가 된다.

---

## 4. Write a logical shift instruction that divides EBX by 4.

EBX를 4로 나누는 논리적 시프트 명령어를 작성하시오.

**답:**

```asm
shr ebx,2
```

**풀이:**

오른쪽으로 1비트 논리 시프트하면 2로 나누는 효과가 있다. \(4=2^2\)이므로 2비트 오른쪽 시프트한다. 부호 없는 정수 기준이며 나머지는 버려진다.

---

## 5. Write a single rotate instruction that exchanges the high and low halves of the DL register.

DL 레지스터의 상위 절반과 하위 절반을 서로 바꾸는 단일 회전 명령어를 작성하시오.

**답:**

```asm
ror dl,4
```

**풀이:**

DL은 8비트 레지스터이다. 4비트 오른쪽 회전하면 원래 상위 4비트가 하위 4비트로, 하위 4비트가 상위 4비트로 이동한다.

---

## 6. Write a single SHLD instruction that shifts the highest bit of the AX register into the lowest bit position of DX and shifts DX one bit to the left.

AX 레지스터의 최상위 비트를 DX의 최하위 비트 위치로 이동시키고, DX를 왼쪽으로 1비트 시프트하는 단일 SHLD 명령어를 작성하시오.

**답:**

```asm
shld dx,ax,1
```

**풀이:**

`SHLD destination,source,count`는 목적지를 왼쪽으로 시프트하고 원본 레지스터의 상위 비트를 목적지의 하위 빈자리에 채운다. 따라서 DX가 왼쪽으로 1비트 이동하고 AX의 최상위 비트가 DX의 최하위 비트로 들어간다.

---

## 7. Write a sequence of instructions that shift three memory bytes to the right by 1 bit position. Use the following test data: byteArray BYTE 81h,20h,33h

다음 테스트 데이터를 사용하여 메모리의 3바이트를 하나의 값처럼 취급하고 오른쪽으로 1비트 시프트하는 명령어들을 작성하시오.

```asm
byteArray BYTE 81h,20h,33h
```

**답:**

```asm
shr byteArray+2,1
rcr byteArray+1,1
rcr byteArray,1
```

**풀이:**

x86은 리틀 엔디안이므로 `byteArray`가 최하위 바이트이고 `byteArray+2`가 최상위 바이트이다. 오른쪽 시프트는 최상위 바이트부터 시작한다. `SHR`이 밀려 나온 비트를 CF에 넣고, 뒤의 `RCR` 명령어들이 CF를 다음 바이트로 전달한다.

---

## 8. Write a sequence of instructions that shift three memory words to the left by 1 bit position. Use the following test data: wordArray WORD 810Dh, 0C064h,93ABh

다음 테스트 데이터를 사용하여 메모리의 3개 워드를 하나의 값처럼 취급하고 왼쪽으로 1비트 시프트하는 명령어들을 작성하시오.

```asm
wordArray WORD 810Dh, 0C064h,93ABh
```

**답:**

```asm
shl wordArray,1
rcl wordArray+2,1
rcl wordArray+4,1
```

**풀이:**

`wordArray`가 최하위 워드이고 `wordArray+4`가 최상위 워드이다. 왼쪽 시프트는 최하위 워드부터 시작한다. `SHL`로 나온 비트를 CF에 저장하고, `RCL`로 다음 워드의 최하위 비트에 전달한다.

---

## 9. Write instructions that multiply −5 by 3 and store the result in a 16-bit variable val1.

−5에 3을 곱하고 그 결과를 16비트 변수 val1에 저장하는 명령어를 작성하시오.

**답:**

```asm
mov ax,-5
imul ax,3
mov val1,ax
```

**풀이:**

`IMUL`은 부호 있는 곱셈 명령어이다. −5와 3을 곱하면 −15가 된다. 16비트 2의 보수 표현에서 −15는 `FFF1h`이므로 val1에 `FFF1h`가 저장된다.

---

## 10. Write instructions that divide −276 by 10 and store the result in a 16-bit variable val1.

−276을 10으로 나누고 그 결과를 16비트 변수 val1에 저장하는 명령어를 작성하시오.

**답:**

```asm
mov ax,-276
cwd
mov bx,10
idiv bx
mov val1,ax
```

**풀이:**

`IDIV`는 부호 있는 나눗셈 명령어이다. `CWD`는 AX의 부호를 DX로 확장하여 DX:AX를 만든다. `IDIV BX` 실행 후 몫은 AX, 나머지는 DX에 저장된다.

\[
-276 \div 10 = -27 \text{ (몫)},\quad -6 \text{ (나머지)}
\]

val1에는 몫 −27이 저장된다. 16비트 2의 보수 표현으로 `FFE5h`이다.

---

## 11. Implement the following C++ expression in assembly language, using 32-bit unsigned operands: val1 = (val2 \* val3) / (val4 - 3)

다음 C++ 식을 32비트 부호 없는 피연산자를 사용하여 어셈블리어로 구현하시오.

```cpp
val1 = (val2 * val3) / (val4 - 3)
```

**답:**

```asm
mov eax,val2
mul val3
mov ecx,val4
sub ecx,3
div ecx
mov val1,eax
```

**풀이:**

`MUL val3`은 EAX와 val3을 곱하고 64비트 결과를 EDX:EAX에 저장한다. `ECX`에서 3을 빼 분모 `val4-3`을 만든다. `DIV ECX`는 EDX:EAX를 ECX로 나누며 몫을 EAX에 저장한다. 마지막으로 그 몫을 val1에 저장한다.

**주의:** 분모가 0이거나 몫이 32비트 범위를 초과하면 나눗셈 오류가 발생한다.

---

## 12. Implement the following C++ expression in assembly language, using 32-bit signed operands: val1 = (val2 / val3) \* (val1 + val2)

다음 C++ 식을 32비트 부호 있는 피연산자를 사용하여 어셈블리어로 구현하시오.

```cpp
val1 = (val2 / val3) * (val1 + val2)
```

**답:**

```asm
mov eax,val2
cdq
idiv val3
mov ebx,eax

mov eax,val1
add eax,val2
imul eax,ebx
mov val1,eax
```

**풀이:**

`CDQ`는 EAX의 부호를 EDX로 확장한다. `IDIV val3`으로 val2를 val3으로 나누면 몫이 EAX에 저장된다. 몫을 EBX에 보관한 뒤 EAX에 val1을 넣고 val2를 더한다. `IMUL EAX,EBX`로 두 결과를 곱하고 val1에 저장한다.

---

## 13. Write a procedure that displays an unsigned 8-bit binary value in decimal format. Pass the binary value in AL. The input range is limited to 0 to 99, decimal. The only procedure you can call from the book’s link library is WriteChar. The procedure should contain approximately eight instructions. Here is a sample call:

```asm
mov al,65 ; range limit: 0 to 99
call showDecimal8
```

부호 없는 8비트 이진 값을 10진수 형식으로 출력하는 프로시저를 작성하시오. 값은 AL로 전달한다. 입력 범위는 10진수 0부터 99까지이다. 책의 링크 라이브러리에서 호출할 수 있는 프로시저는 WriteChar뿐이다. 프로시저는 약 8개의 명령어로 구성해야 한다. 다음은 호출 예시이다.

```asm
mov al,65 ; range limit: 0 to 99
call showDecimal8
```

**답:**

```asm
showDecimal8 PROC
    mov ah,0
    mov bl,10
    div bl
    mov dl,ah
    test al,al
    jz one_digit
    add al,'0'
    call WriteChar
one_digit:
    mov al,dl
    add al,'0'
    call WriteChar
    ret
showDecimal8 ENDP
```

**풀이:**

`DIV BL`은 AX를 10으로 나눈다. 몫은 AL(십의 자리), 나머지는 AH(일의 자리)에 저장된다. 나머지를 DL에 임시 보관한다. 십의 자리가 0이 아니면 ASCII 문자로 바꾸어 먼저 출력하고, 일의 자리도 ASCII 문자로 바꾸어 출력한다. 따라서 65는 `65`로, 7은 `7`로 출력된다.

---

## 14. Challenge: Suppose AX contains 0072h and the Auxiliary Carry flag is set as a result of adding two unknown ASCII decimal digits. Use the Intel 64 and IA-32 Instruction Set Reference to determine what output the AAA instruction would produce. Explain your answer.

도전 문제: 두 개의 알 수 없는 ASCII 십진 숫자를 더한 결과로 Auxiliary Carry Flag(AF)가 설정되어 있고 AX에 `0072h`가 들어 있다고 가정하자. Intel 64 및 IA-32 명령어 참조 문서를 사용하여 AAA 명령어가 어떤 결과를 출력하는지 구하고 설명하시오.

**답:**

- **AX = `0108h`**
- **AH = `01h`, AL = `08h`**
- **AF = 1, CF = 1**

**풀이:**

`AAA`는 ASCII 덧셈 결과를 조정한다. AF가 1이므로 조정 조건이 참이다.

1. AL에 6을 더한다: `72h + 06h = 78h`
2. AH에 1을 더한다: `00h + 01h = 01h`
3. AL의 상위 4비트를 지운다: `78h AND 0Fh = 08h`
4. 최종 AX는 `0108h`이다.
5. 조정이 수행되었으므로 AF와 CF는 1로 설정된다.

---

## 15. Challenge: Using only SUB, MOV, and AND instructions, show how to calculate x = n mod y, assuming that you are given the values of n and y. You can assume that n is any 32-bit unsigned integer, and y is a power of 2.

도전 문제: SUB, MOV, AND 명령어만 사용하여 x = n mod y를 계산하는 방법을 작성하시오. n과 y의 값은 이미 주어져 있다고 가정한다. n은 임의의 32비트 부호 없는 정수이며 y는 2의 거듭제곱이라고 가정한다.

**답:**

```asm
mov eax,n
mov ecx,y
sub ecx,1
and eax,ecx
mov x,eax
```

**풀이:**

y가 2의 거듭제곱이면 다음 관계를 이용할 수 있다.

\[
n \bmod y = n \ \text{AND}\ (y-1)
\]

ECX에 y를 넣고 1을 빼 y−1을 만든다. EAX에 있는 n과 ECX를 AND 연산하면 나머지가 나온다. 그 결과를 x에 저장한다. 예를 들어 y가 8이면 `y−1 = 7 = 00000111b`이므로 하위 3비트만 남는다.

---

## 16. Challenge: Using only SAR, ADD, and XOR instructions (but no conditional jumps), write code that calculates the absolute value of the signed integer in the EAX register. Hints: A number can be negated by adding −1 to it and then forming its one’s complement. Also, if you XOR an integer with all 1s, its 1s are reversed. On the other hand, if you XOR an integer with all zeros, the integer is unchanged.

도전 문제: 조건부 점프 명령어를 사용하지 않고 SAR, ADD, XOR 명령어만 사용하여 EAX 레지스터에 있는 부호 있는 정수의 절댓값을 계산하는 코드를 작성하시오. 힌트: 어떤 수에 −1을 더한 다음 1의 보수를 취하면 그 수의 부호를 반전시킬 수 있다. 정수를 모든 비트가 1인 값과 XOR하면 비트가 반전된다. 반대로 모든 비트가 0인 값과 XOR하면 정수는 변하지 않는다.

**답:**

```asm
mov edx,eax
sar edx,31
xor eax,edx
xor edx,0FFFFFFFFh
add edx,1
add eax,edx
```

**풀이:**

`MOV EDX,EAX`로 원래 값을 복사하고 `SAR EDX,31`로 부호 마스크를 만든다.

- 양수 또는 0이면 EDX = `00000000h`
- 음수이면 EDX = `FFFFFFFFh`

`XOR EAX,EDX`는 양수일 때 원래 값을 유지하고, 음수일 때 비트를 반전시킨다. 다음 두 명령어 `XOR EDX,0FFFFFFFFh`와 `ADD EDX,1`은 음수일 때 1, 양수일 때 0인 보정값을 만든다. 마지막 `ADD EAX,EDX`로 보정값을 더하면 절댓값이 된다.
