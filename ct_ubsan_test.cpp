// Copyright LLVM
// Copied from
// https://clang.llvm.org/docs/UndefinedBehaviorSanitizer.html

int main(int argc, char **argv) {
  int k = 0x7fffffff;
  k += argc; // NOLINT
  return 0;
}
