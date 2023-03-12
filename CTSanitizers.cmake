# If the consumer uses an unsupported compiler & version, give them a warning
# and bail out.
if(CMAKE_CXX_COMPILER_ID STREQUAL GNU)
  if(NOT CMAKE_CXX_COMPILER_VERSION VERSION_EQUAL "12.2.0")
    message(WARNING "CT Sanitizers does not support GCC version ${CMAKE_CXX_COMPILER_VERSION}.")
    return()
  endif()
  string(REGEX MATCH "[0-9]+" _major_version "${CMAKE_CXX_COMPILER_VERSION}")
  set(_library_hints "/usr/lib/gcc/x86_64-linux-gnu/${_major_version}/")
else()
  message(WARNING "CT Sanitizers does not support ${CMAKE_CXX_COMPILER_ID}.")
  return()
endif()

# Make sure the libraries are available on the system.
find_library(_asan_library NAMES asan DOC "The path to the address sanitizer library." HINTS "${_library_hints}")
if(NOT _asan_library)
  message(WARNING "Cannot find libasan. Skipping ASan build configuation.")
endif()

# Add the sanitizers to the lists of allowed build types and build
# configurations. I adapted sample code in Professional CMake, Chapter 14, into
# this.
set(_allowed_sanitizers ASan) # msan tsan ubsan)
get_property(isMultiConfig GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
if(isMultiConfig)
  foreach(sanitizer IN LISTS _allowed_sanitizers)
    if(NOT "${sanitizer}" IN_LIST CMAKE_CONFIGURATION_TYPES)
      list(APPEND CMAKE_CONFIGURATION_TYPES "${sanitizer}")
    endif()
  endforeach()
else()
  set(allowedBuildTypes Debug Release ${_allowed_sanitizers})
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "${allowedBuildTypes}")
  if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Debug CACHE STRING "" FORCE)
  elseif(NOT CMAKE_BUILD_TYPE IN_LIST allowedBuildTypes)
    message(FATAL_ERROR "Unknown build type: ${CMAKE_BUILD_TYPE}")
  endif()
endif()

# Set the required compiler and linker flags for each sanitizer build type.
set(CMAKE_C_FLAGS_ASAN "${CMAKE_CXX_FLAGS_DEBUG} -fsanitize=address -fno-omit-frame-pointer")
set(CMAKE_CXX_FLAGS_ASAN "${CMAKE_CXX_FLAGS_DEBUG} -fsanitize=address -fno-omit-frame-pointer")
set(CMAKE_EXE_LINKER_FLAGS_ASAN "-lasan")

# Add tests to ensure the sanitizer is configured properly. To correctly handle
# single- and multi-config generators, we build all the sanitizer tests, and
# conditionally enable the correct test using a generator expression. Also, the
# tests pass if the sanitizer caught the issue and output it to the console;
# hence the PASS_REGULAR_EXPRESSION.
#
# NOTE: These are tests added to the consumer's build system. They aren't tests
# for CMake Tools' software factory.
include(CTest)
if(BUILD_TESTING)
  add_executable(ct_asan_test "${CMAKE_CURRENT_LIST_DIR}/ct_asan_test.cpp")
  add_test(NAME ct_asan_test COMMAND ct_asan_test)
  set_tests_properties(
    ct_asan_test
    PROPERTIES
      DISABLED $<IF:$<CONFIG:asan>,false,true>
      PASS_REGULAR_EXPRESSION "AddressSanitizer: heap-use-after-free"
  )
endif()
