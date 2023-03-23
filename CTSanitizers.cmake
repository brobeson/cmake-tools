# Distributed under the MIT License.
# See https://github.com/brobeson/cmake-tools/blob/main/license for details.

#[=[.rst:
CTSanitizers
------------

Set up build types and configurations for sanitizers.

.. warning::

  This is module is experimental. I don't know if this is the best way to
  abstract the sanitizer compile options, so the whole thing is subject to
  change while I experiment with it.

.. note::

  CMake makes a distinction between build type for single-config generators and
  build configuration for multi-config generators. For brevity, this
  documentation just refers to build types, but the documented behavior applies
  to build configurations, too. 

This module automatically adds ``ASan``, ``MSan``, ``TSan``, and ``UBSan`` to
your list of build types. If you select one of these build types, CMake sets up
the correct C and C++ compiler options to use the corresponding sanitizer. The
sanitizer build types extend CMake's built-in ``Debug`` build type.

.. warning::

  CTSanitizers does not ensure the sanitizer libraries are available. If you try
  to use a sanitizer build type and don't have the corresponding library
  installed, you will probably get a link error when you build your project.

Using This Module
^^^^^^^^^^^^^^^^^

Follow the instructions in :doc:`getting_started` to bring CMake Tools into your
project. Then include the module like you would any other module:

.. code-block:: cmake

  include(CTSanitizers)

Then set your build type or build configuration like normal:

.. code-block:: bash

  cmake -D BUILD_TYPE:STRING=ASan -S . -B build/
  cmake --build build/ --config ASan

Build Types and Configurations
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

CTSanitizers adds these build types to those already available:

.. variable:: ASan

  Create a debug build with `address sanitizer
  <https://github.com/google/sanitizers/wiki/AddressSanitizer>`_.

.. variable:: MSan

  Create a debug build with `memory sanitizer
  <https://github.com/google/sanitizers/wiki/MemorySanitizer>`_.

.. variable:: TSan

  Create a debug build with `thread sanitizer
  <https://github.com/google/sanitizers/wiki/ThreadSanitizerCppManual>`_.

.. variable:: UBSan

  Create a debug build with `undefined behavior sanitizer
  <https://clang.llvm.org/docs/UndefinedBehaviorSanitizer.html>`_.

Supported Compilers
^^^^^^^^^^^^^^^^^^^

CTSanitizers requires that you use a supported compiler. If CTSanitizers does
not support your compiler, the module will issue a warning and allow the CMake
process to finish.

+----------+---------+-------------+
| Compiler | Version | Status      |
+==========+=========+=============+
| Clang    | 14      | Tested      |
+----------+---------+-------------+
|          | 13      | Should Work |
+----------+---------+-------------+
| GCC      | 11      | Tested      |
+----------+---------+-------------+
|          | 10      | Should Work |
+----------+---------+-------------+

Confirmation Tests
^^^^^^^^^^^^^^^^^^

The module also configures a simple test for each sanitizer and adds the tests
to `CTest <https://cmake.org/cmake/help/latest/manual/ctest.1.html>`_. The tests
contain simple errors that should be caught by the appropriate sanitizer. If the
test passes, the sanitizer caught the error; if the test fails, the sanitizer
did not catch the error. This provides consuming projects with a sanity check
that CTSanitizers correctly configured the sanitizer.

The tests are disabled unless the build type matches the appropriate sanitizer.
For example, if you set your build type to ``ASan``, then ``ct_asan_test`` is
enabled and ``ct_msan_test``, ``ct_tsan_test``, and ``ct_ubsan_test`` are
disabled. If you set your build type to ``Debug``, then all four tests are
disabled.

.. variable:: ct_asan_test

  This test confirms that address sanitizer is working. It attempts to use heap
  memory after deallocating it (heap-use-after-free).

.. variable:: ct_msan_test

  This test confirms that memory sanitizer is working. It reads heap memory
  without initializing it (use-of-uninitialized-value).

.. variable:: ct_tsan_test

  This test confirms that thread sanitizer is working. It contains a data race.

.. variable:: ct_ubsan_test

  This test confirms that undefined behavior sanitizer is working. It overflows
  a signed integer.

IDE Integration
^^^^^^^^^^^^^^^

There are ways to integrate these build types into your IDE. If your IDE isn't
listed here, open an issue for me to document how to set up this integration.

Visual Studio Code
..................

If you use Microsoft's cmake-tools extension for VS Code, you can add to the
available variants with the ``cmake.defaultVariants`` setting. Here is a JSON
snippet you can copy into your *settings.json* file.

.. code-block:: json

  "cmake.defaultVariants": {
    "buildType": {
      "default": "debug",
      "description": "The build type.",
      "choices": {
        "asan": {
          "short": "Address Sanitizer",
          "long": "Debug build with address sanitizer.",
          "buildType": "ASan"
        },
        "msan": {
          "short": "Memory Sanitizer",
          "long": "Debug build with memory sanitizer.",
          "buildType": "MSan"
        },
        "tsan": {
          "short": "Thread Sanitizer",
          "long": "Debug build with thread sanitizer.",
          "buildType": "TSan"
        },
        "ubsan": {
          "short": "Undefined Behavior Sanitizer",
          "long": "Debug build with undefined behavior sanitizer.",
          "buildType": "UBSan"
        }
      }
    }
  }

#]=]

# If the consumer uses an unsupported compiler & version, give them a warning
# and bail out.
if(CMAKE_CXX_COMPILER_ID STREQUAL GNU)
  if(NOT CMAKE_CXX_COMPILER_VERSION VERSION_EQUAL "12.2.0")
    message(WARNING "CT Sanitizers does not support GCC version ${CMAKE_CXX_COMPILER_VERSION}.")
    return()
  endif()
  string(REGEX MATCH "[0-9]+" _major_version "${CMAKE_CXX_COMPILER_VERSION}")
  set(_library_hints "/usr/lib/gcc/x86_64-linux-gnu/${_major_version}/")
elseif(CMAKE_CXX_COMPILER_ID STREQUAL Clang)
  if(NOT CMAKE_CXX_COMPILER_VERSION VERSION_EQUAL "14.0.6")
    message(WARNING "CT Sanitizers does not support Clang version ${CMAKE_CXX_COMPILER_VERSION}.")
    return()
  endif()
else()
  message(WARNING "CT Sanitizers does not support ${CMAKE_CXX_COMPILER_ID}.")
  return()
endif()

# Make sure the libraries are available on the system.
set(_allowed_sanitizers ASan MSan TSan UBSan)
# find_library(_asan_library NAMES asan DOC "The path to the address sanitizer library." HINTS "${_library_hints}")
# if(_asan_library)
#   list(APPEND _allowed_sanitizers ASan)
# else()
#   message(WARNING "Cannot find libasan. Skipping ASan build configuation.")
# endif()
# find_library(_tsan_library NAMES tsan DOC "The path to the thread sanitizer library." HINTS "${_library_hints}")
# if(_tsan_library)
#   list(APPEND _allowed_sanitizers TSan)
# else()
#   message(WARNING "Cannot find libtsan. Skipping TSan build configuation.")
# endif()
# find_library(_ubsan_library NAMES ubsan DOC "The path to the undefined behavior sanitizer library." HINTS "${_library_hints}")
# if(_ubsan_library)
#   list(APPEND _allowed_sanitizers UBSan)
# else()
#   message(WARNING "Cannot find libubsan. Skipping UBSan build configuation.")
# endif()
# find_library(_msan_library NAMES m DOC "The path to the memory sanitizer library." HINTS "${_library_hints}")
# if(_msan_library)
#   list(APPEND _allowed_sanitizers MSan)
# else()
#   message(WARNING "Cannot find libm. Skipping MSan build configuration.")
# endif()

# Add the sanitizers to the lists of allowed build types and build
# configurations. I adapted sample code in Professional CMake, Chapter 14, into
# this.
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

# Set the required compiler flags for each sanitizer build type. The compiler
# will handle linkg-time configuration.
set(CMAKE_C_FLAGS_ASAN "${CMAKE_CXX_FLAGS_DEBUG} -fsanitize=address -fno-omit-frame-pointer")
set(CMAKE_CXX_FLAGS_ASAN "${CMAKE_CXX_FLAGS_DEBUG} -fsanitize=address -fno-omit-frame-pointer")
set(CMAKE_C_FLAGS_MSAN "${CMAKE_CXX_FLAGS_DEBUG} -fsanitize=memory -fno-omit-frame-pointer")
set(CMAKE_CXX_FLAGS_MSAN "${CMAKE_CXX_FLAGS_DEBUG} -fsanitize=memory -fno-omit-frame-pointer")
set(CMAKE_C_FLAGS_TSAN "${CMAKE_CXX_FLAGS_DEBUG} -fsanitize=thread -fPIE")# -pie")
set(CMAKE_CXX_FLAGS_TSAN "${CMAKE_CXX_FLAGS_DEBUG} -fsanitize=thread -fPIE")# -pie")
set(CMAKE_C_FLAGS_UBSAN "${CMAKE_CXX_FLAGS_DEBUG} -fsanitize=undefined")
set(CMAKE_CXX_FLAGS_UBSAN "${CMAKE_CXX_FLAGS_DEBUG} -fsanitize=undefined")

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
      DISABLED $<IF:$<CONFIG:ASan>,false,true>
      PASS_REGULAR_EXPRESSION "AddressSanitizer: heap-use-after-free"
  )

  add_executable(ct_tsan_test "${CMAKE_CURRENT_LIST_DIR}/ct_tsan_test.cpp")
  add_test(NAME ct_tsan_test COMMAND ct_tsan_test)
  set_tests_properties(
    ct_tsan_test
    PROPERTIES
      DISABLED $<IF:$<CONFIG:TSan>,false,true>
      PASS_REGULAR_EXPRESSION "ThreadSanitizer: data race"
  )

  add_executable(ct_ubsan_test "${CMAKE_CURRENT_LIST_DIR}/ct_ubsan_test.cpp")
  add_test(NAME ct_ubsan_test COMMAND ct_ubsan_test)
  set_tests_properties(
    ct_ubsan_test
    PROPERTIES
      DISABLED $<IF:$<CONFIG:UBSan>,false,true>
      PASS_REGULAR_EXPRESSION "runtime error: signed integer overflow"
  )

  add_executable(ct_msan_test "${CMAKE_CURRENT_LIST_DIR}/ct_msan_test.cpp")
  add_test(NAME ct_msan_test COMMAND ct_msan_test)
  set_tests_properties(
    ct_msan_test
    PROPERTIES
      DISABLED $<IF:$<CONFIG:msan>,false,true>
      PASS_REGULAR_EXPRESSION "MemorySanitizer: use-of-uninitialized-value"
  )
endif()
