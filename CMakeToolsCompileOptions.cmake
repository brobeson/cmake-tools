# Distributed under the MIT License.
# See https://github.com/brobeson/cmake-tools/blob/main/license for details.

#[=[.rst:
CMakeToolsCompileOptions
------------------------

This module provides a strict set of C++ compile options.  To use the options,
include this file:

.. code-block:: cmake

  include(CMakeToolsCompileOptions)

Result Variables
================

This module defines these variables:

.. variable:: CMAKE_TOOLS_COMPILE_OPTIONS

  A list of C++ compile options that set strict warnings and errors. To use the
  options, pass them to
  `target_compile_options() <https://cmake.org/cmake/help/v3.19/command/target_compile_options.html>`_:

  .. code-block:: cmake

    add_executable(app main.cpp)
    target_compile_options(app PRIVATE ${CMAKE_TOOLS_COMPILE_OPTIONS})
  
.. variable:: CMAKE_TOOLS_LINK_LIBRARIES

  A list of libraries to pass to the linker. To use the libraries, pass them to
  `target_link_libraries() <https://cmake.org/cmake/help/latest/command/target_link_libraries.html>`_:

  .. code-block:: cmake

    add_executable(app main.cpp)
    target_link_libraries(app PRIVATE ${CMAKE_TOOLS_LINK_LIBRARIES})

  .. warning::

    By default, you should place these first in the list of link dependencies.
    Some libraries, such as ``asan``, must be first on the link command.

    .. code-block:: cmake

      add_executable(app main.cpp)
      target_link_libraries(app PRIVATE ${CMAKE_TOOLS_LINK_LIBRARIES} Qt5::Core)

To see the exact options for your compiler, print the variable:

.. code-block:: cmake

  include(CMakePrintHelpers)
  cmake_print_variables(CMAKE_TOOLS_COMPILE_OPTIONS CMAKE_TOOLS_LINK_LIBRARIES)

If there are specific options that you don't want to use, just remove them from the list:

.. code-block:: cmake

  list(REMOVE_ITEM CMAKE_TOOLS_COMPILE_OPTIONS -Werror)

Hints
=====

You can control some of the options with these variables. Define them before
including this module.

.. variable:: CMAKE_TOOLS_ADDRESS_SANITIZER

  Add compile options to ``CMAKE_TOOLS_COMPILE_OPTIONS`` and `asan` to
  ``CMAKE_TOOLS_LINK_LIBRARIES`` to build with address sanitizer. The options
  and library only apply to debug builds.

  .. warning::

    You cannot set ``CMAKE_TOOLS_THREAD_SANITIZER`` and
    ``CMAKE_TOOLS_ADDRESS_SANITIZER`` together. The module will print an error,
    then continue the configuration step.

.. variable:: CMAKE_TOOLS_COVERAGE

  Add compile options to ``CMAKE_TOOLS_COMPILE_OPTIONS`` and `gcov` to
  ``CMAKE_TOOLS_LINK_LIBRARIES`` to enable test coverage.

.. variable:: CMAKE_TOOLS_THREAD_SANITIZER

  Add compile options to ``CMAKE_TOOLS_COMPILE_OPTIONS`` and `tsan` to
  ``CMAKE_TOOLS_LINK_LIBRARIES`` to build with thread sanitizer. The options
  and library only apply to debug builds.

  .. warning::

    You cannot set ``CMAKE_TOOLS_THREAD_SANITIZER`` and
    ``CMAKE_TOOLS_ADDRESS_SANITIZER`` together. The module will print an error,
    then continue the configuration step.

.. variable:: CMAKE_TOOLS_UB_SANITIZER

  Add compile options to ``CMAKE_TOOLS_COMPILE_OPTIONS`` and `ubsan` to
  ``CMAKE_TOOLS_LINK_LIBRARIES`` to build with undefined behavior sanitizer. The
  options and library only apply to debug builds.

Examples
========

Here are examples for some use cases.

.. code-block:: cmake

  # Get the default compile options, but don't treat warnings as errors.
  include(CMakeToolsCompileOptions)
  list(REMOVE_ITEM CMAKE_TOOLS_COMPILE_OPTIONS -Werror)
  add_executable(app app.cpp)
  target_compile_options(app PRIVATE ${CMAKE_TOOLS_COMPILE_OPTIONS})

.. code-block:: cmake

  # Add address and undefined behavior sanitizers to a unit test.
  set(CMAKE_TOOLS_ADDRESS_SANITIZER true)
  set(CMAKE_TOOLS_UB_SANITIZER true)
  include(CMakeToolsCompileOptions)
  add_executable(test test.cpp)
  target_compile_options(test PRIVATE ${CMAKE_TOOLS_COMPILE_OPTIONS})
  target_link_libraries(test PRIVATE ${CMAKE_TOOLS_LINK_LIBRARIES} Catch2::Catch2)

.. code-block:: cmake

  # Set up to gather unit test coverage data.
  set(CMAKE_TOOLS_COVERAGE true)
  include(CMakeToolsCompileOptions)
  add_executable(test test.cpp)
  target_compile_options(test PRIVATE ${CMAKE_TOOLS_COMPILE_OPTIONS})
  target_link_libraries(test PRIVATE ${CMAKE_TOOLS_LINK_LIBRARIES} Catch2::Catch2)

#]=]

if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  list(
    APPEND CMAKE_TOOLS_COMPILE_OPTIONS
    -pedantic-errors
    -Walloca
    -Wcast-qual
    -Wconversion
    -Wdate-time
    -Wduplicated-branches
    -Wduplicated-cond
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
  # CMake added VERSION_GREATER_EQUAL in CMake 7. To allow consumers to use
  # earlier versions of CMake, I don't use it here.
  if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER 8.0 OR CMAKE_CXX_COMPILER_VERSION VERSION_EQUAL 8.0)
    list(
      APPEND
        CMAKE_TOOLS_COMPILE_OPTIONS
        -fdiagnostics-show-template-tree
        -Wcast-align=strict
        -Wextra-semi
    )
  # elseif(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER 9.0 OR CMAKE_CXX_COMPILER_VERSION VERSION_EQUAL 9.0)
  #   set(_issue_dev_warning_about_version true)
  endif()
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
  list(
    APPEND CMAKE_TOOLS_COMPILE_OPTIONS
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
  list(APPEND CMAKE_TOOLS_COMPILE_OPTIONS /analyze /Wall /WX)
else()
  message(
    WARNING
      " Default compiler options are not enabled for your compiler.\n"
      " Detected CMAKE_CXX_COMPILER_ID: ${CMAKE_CXX_COMPILER_ID}\n"
  )
endif()

# Handle the sanitizer option.
if(CMAKE_TOOLS_UB_SANITIZER)
  list(
    APPEND CMAKE_TOOLS_COMPILE_OPTIONS
    $<$<CONFIG:Debug>:-fsanitize=undefined>
    $<$<CONFIG:Debug>:-fsanitize=float-divide-by-zero>
    $<$<CONFIG:Debug>:-fsanitize=float-cast-overflow>
    $<$<CONFIG:Debug>:-fno-sanitize-recover=all>
  )
  list(APPEND CMAKE_TOOLS_LINK_LIBRARIES ubsan)
endif()

if(CMAKE_TOOLS_ADDRESS_SANITIZER)
  if(CMAKE_TOOLS_THREAD_SANITIZER)
    message(SEND_ERROR "Address sanitizer and thread sanitizer are mutually exclusive. Please disable one.")
  endif()
  list(
    APPEND CMAKE_TOOLS_COMPILE_OPTIONS
    $<$<CONFIG:Debug>:-fsanitize=address>
    $<$<CONFIG:Debug>:-fsanitize=pointer-compare>
    $<$<CONFIG:Debug>:-fsanitize=pointer-subtract>
  )
  list(PREPEND CMAKE_TOOLS_LINK_LIBRARIES asan)
endif()

if(CMAKE_TOOLS_THREAD_SANITIZER)
  list(
    APPEND CMAKE_TOOLS_COMPILE_OPTIONS
    $<$<CONFIG:Debug>:-fsanitize=thread>
  )
  list(PREPEND CMAKE_TOOLS_LINK_LIBRARIES tsan)
endif()

# if(_issue_dev_warning_about_version)
#   message(
#     AUTHOR_WARNING
#     "New options introduced in ${CMAKE_CXX_COMPILER_ID} version "
#     "${CMAKE_CXX_COMPILER_VERSION} are not supported, yet. Check for a new "
#     "version of cmake-tools at "
#     "https://github.com/brobeson/cmake-tools/releases. If the latest version of "
#     "cmake-tools does not support this compiler version, please open an issue "
#     "at https://github.com/brobeson/cmake-tools/issues to add support."
#   )
# endif()

if(CMAKE_TOOLS_COVERAGE)
  list(
    APPEND CMAKE_TOOLS_COMPILE_OPTIONS
    $<$<CONFIG:Debug>:--coverage>
    $<$<CONFIG:Debug>:-fno-inline>
  )
  list(APPEND CMAKE_TOOLS_LINK_LIBRARIES $<$<CONFIG:Debug>:gcov>)
endif()
