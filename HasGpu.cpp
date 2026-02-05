// Source - https://stackoverflow.com/a/2297877
// Posted by Christopher Bruns, modified by community. See post 'Timeline' for
// change history Retrieved 2026-01-13, License - CC BY-SA 2.5

#include <cuda_runtime.h>
#include <stdio.h>
#include <iostream>

int main()
{
  int deviceCount, device;
  int gpuDeviceCount = 0;
  struct cudaDeviceProp properties;
  cudaError_t cudaResultCode = cudaGetDeviceCount(&deviceCount);
  std::cout << "cudaResultCode: " << cudaResultCode << '\n';
  if (cudaResultCode != cudaSuccess)
  {
    deviceCount = 0;
  }
  /* machines with no GPUs can still report one emulation device */
  for (device = 0; device < deviceCount; ++device)
  {
    cudaGetDeviceProperties(&properties, device);
    if (properties.major != 9999)
    { /* 9999 means emulation only */
      ++gpuDeviceCount;
    }
  }
  printf("%d GPU CUDA device(s) found\n", gpuDeviceCount);

  /* don't just return the number of gpus, because other runtime cuda
     errors can also yield non-zero return values */
  if (gpuDeviceCount > 0)
  {
    return 0; /* success */
  }
  else
  {
    return 1; /* failure */
  }
}
