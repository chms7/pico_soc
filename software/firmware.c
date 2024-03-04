#include "firmware.h"

int fibonacci(int n);
int sum(int a, int b);

void main() {
  int a = 0, b = 0, c = 0;
  // a = 3; b = 4;
  // c = sum(a, b);
  // print_str("hello\n");

  // // test
  // if (fibonacci(5) != 5) {
  //   asm( "call main");
  // }
  // if (fibonacci(10) != 55) {
  //   asm( "call main");
  // }
  // if (fibonacci(12) != 144) {
  //   asm( "call main");
  // }

  while (1) {
    a = a + 1;
    // b = a + 2;
    // c = b + 4;
  };
}

int fibonacci(int n) {
  if (n < 1) {
    return 0;
  } else if (n >= 1 && n <3) {
    return 1;
  } else {
    return (fibonacci(n-1) + fibonacci(n-2));
  }
}

int sum(int a, int b) {
  return a + b;
}
