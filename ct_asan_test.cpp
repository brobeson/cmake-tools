// Copyright Google
// Copied from https://github.com/google/sanitizers/wiki/AddressSanitizerExampleUseAfterFree

int main(int argc, char** argv) {
  int* array = new int[100];
  delete [] array;
  return array[argc];  // NOLINT
}