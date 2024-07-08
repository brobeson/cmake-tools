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

Confirmation Test
^^^^^^^^^^^^^^^^^

The module also configures a simple test, ``ct_sanitizer_test``, to confirm that
the sanitizer is configured correctly. The test contains a simple error that
should be caught by the appropriate sanitizer. If the test passes, the sanitizer
caught the error; if the test fails, the sanitizer did not catch the error. This
provides consuming projects with a sanity check that CTSanitizers correctly
configured the sanitizer. If the build type is not any of the sanitizers, the
test just exits with success.

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

if(CMAKE_CXX_COMPILER_ID STREQUAL GNU OR CMAKE_C_COMPILER_ID STREQUAL GNU)
	# if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS "13.0.0" OR CMAKE_C_COMPILER_VERSION VERSION_LESS "13.0.0")
	# message(WARNING "CT Sanitizers does not support GCC version ${CMAKE_CXX_COMPILER_VERSION}.")
	# return()
	# endif()
 string(REGEX MATCH "[0-9]+" _major_version "${CMAKE_CXX_COMPILER_VERSION}")
 set(_library_hints "/usr/lib/gcc/x86_64-linux-gnu/${_major_version}/")
#elseif(CMAKE_CXX_COMPILER_ID STREQUAL Clang)
#  if(NOT CMAKE_CXX_COMPILER_VERSION VERSION_EQUAL "14.0.6")
#    message(WARNING "CT Sanitizers does not support Clang version ${CMAKE_CXX_COMPILER_VERSION}.")
#    return()
#  endif()
#else()
#  message(WARNING "CT Sanitizers does not support ${CMAKE_CXX_COMPILER_ID}.")
#  return()
endif()

# Make sure the libraries are available on the system.
# set(_allowed_sanitizers ASan)
find_library(_asan_library NAMES asan DOC "The path to the address sanitizer library." HINTS "${_library_hints}")
if(_asan_library)
  list(APPEND _allowed_sanitizers ASan)
else()
  message(WARNING "Cannot find libasan. Skipping ASan build configuation.")
endif()

# Add the sanitizers to the lists of allowed build types and build
# configurations. I adapted sample code from Professional CMake, Chapter 14, into
# this.
get_property(isMultiConfig GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
if(isMultiConfig)
  list(APPEND CMAKE_CONFIGURATION_TYPES "${_allowed_sanitizers}")
  list(REMOVE_DUPLICATES CMAKE_CONFIGURATION_TYPES)
else()
  get_property(allowedBuildTypes CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS)
  list(APPEND allowedBuildTypes "${_allowed_sanitizers}")
  list(REMOVE_DUPLICATES allowedBuildTypes)
  # set(allowedBuildTypes Debug Release ${_allowed_sanitizers})
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "${allowedBuildTypes}")
  # if(NOT CMAKE_BUILD_TYPE)
  #   set(CMAKE_BUILD_TYPE Debug CACHE STRING "" FORCE)
  # elseif(NOT CMAKE_BUILD_TYPE IN_LIST allowedBuildTypes)
  #   message(FATAL_ERROR "Unknown build type: ${CMAKE_BUILD_TYPE}")
  # endif()
endif()

# Set the required compiler flags for each sanitizer build type. The compiler
# will handle linkg-time configuration.
set(CMAKE_C_FLAGS_ASAN "${CMAKE_CXX_FLAGS_DEBUG} -fsanitize=address -fno-omit-frame-pointer")
set(CMAKE_CXX_FLAGS_ASAN "${CMAKE_CXX_FLAGS_DEBUG} -fsanitize=address -fno-omit-frame-pointer")

# Add a test to ensure the sanitizer is configured properly. To correctly handle
# single- and multi-config generators, use generator expressions to build the
# correct C++ file and look for the correct sanitizer output.
#
# NOTE: The test is added to the consumer's build system. It's not a test for
# CMake Tools' software factory.
add_executable(ct_sanitizer_test)
target_sources(
  ct_sanitizer_test
  PRIVATE
    "$<$<CONFIG:asan>:${CMAKE_CURRENT_LIST_DIR}/ct_asan_test.cpp>"
)
add_test(NAME ct_sanitizer_test COMMAND ct_sanitizer_test)
set_tests_properties(
  ct_sanitizer_test
  PROPERTIES
    PASS_REGULAR_EXPRESSION
      "$<$<CONFIG:asan>:AddressSanitizer: heap-use-after-free>"
)

