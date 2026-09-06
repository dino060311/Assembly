# 1.7.2 Algorithm Workbench

## 1. 16비트 이진 문자열 → 정수

왼쪽부터 읽으며 결과에 2를 곱하고 현재 비트를 더한다.

```java
public static int binary16ToInt(String binary) {
    int result = 0;
    for (int i = 0; i < binary.length(); i++) {
        result *= 2;
        if (binary.charAt(i) == '1') {
            result += 1;
        }
    }
    return result;
}
```

---

## 2. 32비트 16진수 문자열 → 정수

각 문자를 0~15로 바꾼 뒤 결과에 16을 곱하며 누적한다. 최대값이 int 범위를 넘으므로 long을 사용한다.

```java
public static long hex32ToInt(String hex) {
    long result = 0;
    for (int i = 0; i < hex.length(); i++) {
        char c = hex.charAt(i);
        int value;
        if (c >= '0' && c <= '9') {
            value = c - '0';
        } else if (c >= 'A' && c <= 'F') {
            value = c - 'A' + 10;
        } else {
            value = c - 'a' + 10;
        }
        result = result * 16 + value;
    }
    return result;
}
```

---

## 3. 정수 → 이진수 문자열

2로 나눈 나머지를 문자열 앞에 붙여 나간다.

```java
public static String intToBinary(int number) {
    if (number == 0) {
        return "0";
    }

    boolean negative = number < 0;
    if (negative) {
        number = -number;
    }

    String result = "";
    while (number > 0) {
        result = (number % 2) + result;
        number /= 2;
    }

    if (negative) {
        result = "-" + result;
    }
    return result;
}
```

---

## 4. 정수 → 16진수 문자열

16으로 나눈 나머지를 문자열 앞에 붙이고, 10~15는 A~F로 바꾼다.

```java
public static String intToHex(int number) {
    if (number == 0) {
        return "0";
    }

    boolean negative = number < 0;
    if (negative) {
        number = -number;
    }

    String result = "";
    while (number > 0) {
        int remainder = number % 16;
        char digit;
        if (remainder < 10) {
            digit = (char) ('0' + remainder);
        } else {
            digit = (char) ('A' + remainder - 10);
        }
        result = digit + result;
        number /= 16;
    }

    if (negative) {
        result = "-" + result;
    }
    return result;
}
```

---

## 5. 진법 b(2~10) 두 숫자 문자열 더하기

정수로 바꾸지 않고 오른쪽 자리부터 자리올림을 계산한다.

```java
public static String addInBase(String a, String b, int base) {
    String result = "";
    int i = a.length() - 1;
    int j = b.length() - 1;
    int carry = 0;

    while (i >= 0 || j >= 0 || carry != 0) {
        int digitA = 0;
        int digitB = 0;

        if (i >= 0) {
            digitA = a.charAt(i) - '0';
            i--;
        }
        if (j >= 0) {
            digitB = b.charAt(j) - '0';
            j--;
        }

        int sum = digitA + digitB + carry;
        result = (char) ('0' + sum % base) + result;
        carry = sum / base;
    }
    return result;
}
```

---

## 6. 긴 16진수 문자열 두 개 더하기

5번과 같은 방식이며 A~F 변환만 추가한다.

```java
public static int hexCharToValue(char c) {
    if (c >= '0' && c <= '9') {
        return c - '0';
    } else if (c >= 'A' && c <= 'F') {
        return c - 'A' + 10;
    } else {
        return c - 'a' + 10;
    }
}

public static char valueToHexChar(int value) {
    if (value < 10) {
        return (char) ('0' + value);
    }
    return (char) ('A' + value - 10);
}

public static String addHex(String a, String b) {
    String result = "";
    int i = a.length() - 1;
    int j = b.length() - 1;
    int carry = 0;

    while (i >= 0 || j >= 0 || carry != 0) {
        int digitA = 0;
        int digitB = 0;

        if (i >= 0) {
            digitA = hexCharToValue(a.charAt(i));
            i--;
        }
        if (j >= 0) {
            digitB = hexCharToValue(b.charAt(j));
            j--;
        }

        int sum = digitA + digitB + carry;
        result = valueToHexChar(sum % 16) + result;
        carry = sum / 16;
    }
    return result;
}
```

---

## 7. 한 자리 16진수 × 긴 16진수 문자열

오른쪽 자리부터 한 자리씩 곱하며 올림값을 넘긴다. 마지막에 앞자리 0을 제거한다.

```java
public static String multiplyHex(String hex, char singleDigit) {
    int multiplier = hexCharToValue(singleDigit);

    String result = "";
    int carry = 0;

    for (int i = hex.length() - 1; i >= 0; i--) {
        int product = hexCharToValue(hex.charAt(i)) * multiplier + carry;
        result = valueToHexChar(product % 16) + result;
        carry = product / 16;
    }

    while (carry > 0) {
        result = valueToHexChar(carry % 16) + result;
        carry /= 16;
    }

    while (result.length() > 1 && result.charAt(0) == '0') {
        result = result.substring(1);
    }
    return result;
}
```

---

## 8. Java 코드 디스어셈블

```java
public class Calculation {
    public static void main(String[] args) {
        int Y = 10;
        int X = (Y + 4) * 3;
    }
}
```

```bash
javac Calculation.java
javap -c Calculation
```

```text
0: bipush 10     // 10을 스택에 넣음
2: istore_1      // 스택의 값을 Y에 저장
3: iload_1       // Y를 스택에 넣음
4: iconst_4      // 4를 스택에 넣음
5: iadd          // 두 값을 더함 → Y + 4
6: iconst_3      // 3을 스택에 넣음
7: imul          // 두 값을 곱함 → (Y + 4) * 3
8: istore_2      // 결과를 X에 저장
```

---

## 9. 부호 없는 이진 정수 뺄셈

오른쪽 비트부터 세로셈으로 계산하고, 뺄 수 없으면 왼쪽 자리에서 1을 빌려온다.

```text
  10001000
- 00000101
----------
  10000011
```

0비트: 0-1 → 빌림, 10-1 = 1
1비트: 0(빌려줌)-0 = 0
2비트: 0-1 → 빌림, 10-1 = 1
3비트: 1(빌려줌)-0 = 0
4~7비트: 1000 그대로

```text
  00001111      00001111 - 00000101
- 00000101  →   0비트: 1-1 = 0
----------      1비트: 1-0 = 1
  00001010      2비트: 1-1 = 0
                3비트: 1-0 = 1
```

```text
  10100000      10100000 - 00010001
- 00010001  →   0비트: 0-1 → 빌림, 10-1 = 1
----------      1~3비트: 빌림 전파로 모두 1
  10001111      4비트: 0-1 → 빌림, 10-1 = 1
                5비트: 1(빌려줌)-0 = 0
                6~7비트: 10 그대로
```
