#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <sys/mman.h>

typedef uint8_t byte;
typedef uint16_t word;
typedef uint32_t dword;

// Emulated context:
// x86    6507
// -----------
// AL     A
// AH     Flags
// BL     X
// BH     Y
// CL     SP
//
// Flag bits (0 to 7):
// C      C
// I      Z
// ~      I
// ~      D
// ~      B
// ~      ~
// Z      V
// N      N

void asm_engine(unsigned char *code) {
  word ax = 0, bx = 0, cx = 0;
  byte reg_A = 0, reg_X = 0, reg_SP = 0, flags = 0;
  __asm__ volatile (
      "call *%[code]\n\t"          // call code
      "lahf"                  // flags go to AH
      : "=a" (ax), "=b" (bx), "=c" (reg_SP)
      : [code] "r" (code)
  );
  reg_A = ax & 0xFF;
  reg_X = bx & 0xFF;
  flags = (ax & 0xFF00) >> 8;
  // Debug
  printf("reg_A: %d\n", reg_A);
  printf("reg_X: %d\n", reg_X);
  printf("reg_SP: %d\n", reg_SP);
  printf("flags: %d\n", flags);
  printf("  carry: %d\n", flags & 1);
  printf("  zero: %d\n", (flags >> 6) & 1);
  printf("  sign: %d\n", (flags >> 7) & 1);
}

int main() {
  unsigned char code[] = {
    0x90, 0x90,
    0xB3, 0xAB,         // mov $??, %bl
    0x80, 0xFB, 0x00,   // cmp $0, %bl   ; flags
    0x88, 0xD9,         // mov %bl, %cl
    0xC3                // ret
  };
  void* ptr = mmap(0, sizeof(code),
                   PROT_READ | PROT_WRITE | PROT_EXEC,
                   MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
  memcpy(ptr, code, sizeof(code));
  asm_engine(ptr);
  return 0;
}
