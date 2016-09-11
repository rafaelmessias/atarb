#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>

int asm_engine(unsigned char *code) {
  int result;
  __asm__ (
      "call *%1"
      : "=a" (result)
      : "r" (code)
  );
  return result;
}

int main() {
  unsigned char code[] = {
    0xB8, 0x2A, 0, 0, 0,
    0xC3
  };
  void* ptr = mmap(0, sizeof(code),
                   PROT_READ | PROT_WRITE | PROT_EXEC,
                   MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
  memcpy(ptr, code, sizeof(code));
  printf("%d\n", asm_engine(ptr));
  return 0;
}
