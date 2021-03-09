# Distributed under the MIT License.
# See https://github.com/brobeson/cmake-tools/blob/main/license for details.

#[=[.rst:
CMakeToolsDefaultCompileOptions
-------------------------------

This module provides a strict set of default C++ compile options.
To use the options, include this file:

.. code-block:: cmake

  include(CMakeToolsDefaultCompileOptions)

This module defines a list of compile options:

.. variable:: CMAKE_TOOLS_COMPILE_OPTIONS

  A list of C++ compile options that set strict warnings and errors.

To see the exact options for your compiler, print the variable:

.. code-block:: cmake

  include(CMakePrintHelpers)
  cmake_print_variables(CMAKE_TOOLS_COMPILE_OPTIONS)

If there are specific options that you don't want to use, just remove them from the list:

.. code-block:: cmake

  list(REMOVE_ITEM CMAKE_TOOLS_COMPILE_OPTIONS -Werror)

To use the options, pass them to `target_compile_options() <https://cmake.org/cmake/help/v3.19/command/target_compile_options.html>`_:

.. code-block:: cmake

  add_executable(app main.cpp)
  target_compile_options(app PRIVATE ${CMAKE_TOOLS_COMPILE_OPTIONS})
  
#]=]

if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  set(
    CMAKE_TOOLS_COMPILE_OPTIONS
    -pedantic-errors
    -Walloca
    -Wcast-qual
    -Wconversion
    -Wdate-time
    -Wduplicated-branches
    -Wduplicated-cond
    -Weffc++
    -Werror
    -Wfloat-equal
    -Wformat=2
    -Winvalid-pch
    -Wlogical-op
    -Wmissing-declarations
    -Wmissing-include-dirs
    -Wnoexcept
    -Wnon-virtual-dtor
    -Wold-style-cast
    -Woverloaded-virtual
    -Wpedantic
    -Wplacement-new=2
    -Wredundant-decls
    -Wregister
    -Wshadow
    -Wsign-conversion
    -Wsign-promo
    -Wsubobject-linkage
    -Wswitch-default
    -Wswitch-enum
    -Wtrampolines
    -Wundef
    -Wunused
    -Wunused-macros
    -Wuseless-cast
    -Wzero-as-null-pointer-constant
    -Wall
    -Wextra
    "$<$<CONFIG:Debug>:-fstack-protector-strong>"
    "$<$<CONFIG:Debug>:-Wstack-protector>"
    "$<$<CONFIG:Debug>:-ggdb>"
  )
  if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 8.0)
    list(
      APPEND
        CMAKE_TOOLS_COMPILE_OPTIONS
        -fdiagnostics-show-template-tree
        -Wcast-align=strict
        -Wextra-semi
    )
  endif()
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
  set(
    CMAKE_TOOLS_COMPILE_OPTIONS
    -fdiagnostics-show-template-tree
    -pedantic-errors
    -Weverything
    -Werror
    -Wno-c++98-c++11-c++14-compat
    -Wno-c++98-compat
    -Wno-c++11-compat
    -Wno-c++14-compat
    -Wno-documentation
    -Wno-documentation-unknown-command
    -Wno-padded
    -Wno-weak-vtables
    "$<$<CONFIG:Debug>:-fstack-protector-strong>"
    "$<$<CONFIG:Debug>:-Wstack-protector>"
    "$<$<CONFIG:Debug>:-ggdb>"
  )
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
  set(CMAKE_TOOLS_COMPILE_OPTIONS /analyze /Wall /WX)
else()
  message(
    WARNING
      " Default compiler options are not enabled for your compiler.\n"
      " Detected CMAKE_CXX_COMPILER_ID: ${CMAKE_CXX_COMPILER_ID}\n"
  )
endif()
