message(CHECK_START "Searching for CUDA-capable GPU")
list(APPEND CMAKE_MESSAGE_INDENT "  ")

find_package(CUDAToolkit)
if(NOT CUDAToolkit_FOUND)
  set(HAS_GPU false)
  list(POP_BACK CMAKE_MESSAGE_INDENT)
  message(CHECK_FAIL "not found")
  return()
endif()

#==============================================================================
# add_executable(HasGpu cmake/HasGpu.cpp)
# target_link_libraries(HasGpu PRIVATE CUDA::cudart)
#==============================================================================

try_run(
  _RUN_RESULT
  _COMPILE_RESULT
  SOURCES ${PROJECT_SOURCE_DIR}/cmake/HasGpu.cpp
  LINK_LIBRARIES CUDA::cudart
  RUN_OUTPUT_VARIABLE _RUN_OUTPUT
)
string(STRIP "${_RUN_OUTPUT}" _RUN_OUTPUT)

include(CMakePrintHelpers)
# cmake_print_variables(_COMPILE_RESULT _RUN_RESULT)

if(_COMPILE_RESULT OR _RUN_RESULT)
  set(HAS_GPU false)
  list(POP_BACK CMAKE_MESSAGE_INDENT)
  message(CHECK_FAIL "not found")
  return()
endif()

message(STATUS "${_RUN_OUTPUT}")
list(POP_BACK CMAKE_MESSAGE_INDENT)
message(CHECK_PASS "found")