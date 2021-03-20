# Distributed under the MIT License.
# See https://github.com/brobeson/cmake-tools/blob/main/license for details.

#[=[.rst:
FindLizard
----------

Lizard is a cyclomatic complexity analysis tool.
See https://github.com/terryyin/lizard/.
This modules looks for Lizard and provides a function to add Lizard scans to the build system.

Result Variables
^^^^^^^^^^^^^^^^

This module defines the following variables:

.. variable:: Lizard_FOUND

  True if Lizard is found, false if it is not.

.. variable:: Lizard_VERSION

  The version reported by ``lizard --version``.

.. variable:: Lizard_EXECUTABLE

  The path to the Lizard program. This is an advanced cache variable.

Functions
^^^^^^^^^

.. command:: add_lizard_target

  This function adds a custom target to run Lizard.
  The target is run in `CMAKE_CURRENT_SOURCE_DIR <https://cmake.org/cmake/help/latest/variable/CMAKE_CURRENT_SOURCE_DIR.html>`_.

  ::

    add_lizard_target(
      name
      [ALL]
      [ARGUMENTS argument1 [argument2 ...]])

  The ``name`` must be a unique target name.
  ``ALL`` is passed on to the `add_custom_target() <https://cmake.org/cmake/help/latest/command/add_custom_target.html>`_ command.
  Use ``ARGUMENTS`` to specify command line arguments for Lizard.
  If ``ARGUMENTS`` is omitted, Lizard is run without any command line arguments.

  You can create multiple lizard targets.
  This supports the use case of scanning different parts of a project with different parameters.
  For example, you might be more lenient on the length of unit test cases than functions in your production code.

  Here is an example:

  .. code-block:: cmake

    find_package(Lizard)
    add_lizard_target(
      complexity_analysis
      ALL
      ARGUMENTS
        --CCN 10
        --lenght 50
        --warnings_only
    )

#]=]

find_program(
  Lizard_EXECUTABLE
  NAMES lizard
  DOC "Lizard cyclomatic complexity analyzer (https://github.com/terryyin/lizard/)"
)
mark_as_advanced(Lizard_EXECUTABLE)

if(Lizard_EXECUTABLE)
  execute_process(
    COMMAND "${Lizard_EXECUTABLE}" --version
    OUTPUT_VARIABLE Lizard_VERSION
    OUTPUT_STRIP_TRAILING_WHITESPACE
    RESULT_VARIABLE lizard_version_result
  )
  if(lizard_version_result)
    message(WARNING "Unable to determine lizard version.")
  endif()
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(
  Lizard
  REQUIRED_VARS Lizard_EXECUTABLE
  VERSION_VAR Lizard_VERSION
)
unset(Lizard_DIR CACHE)

function(add_lizard_target name)
  if(NOT Lizard_FOUND)
    message(
      WARNING
      "Lizard was not found. Please install Lizard before calling add_lizard_target()."
    )
  endif()
  cmake_parse_arguments(
    lizard
    "ALL"
    ""
    ARGUMENTS
    ${ARGN}
  )
  if(lizard_ALL)
    set(ALL "ALL")
  endif()
  add_custom_target(
    ${name}
    ${ALL}
    COMMAND ${Lizard_EXECUTABLE} ${lizard_ARGUMENTS}
    WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
    COMMENT "Running cyclomatic complexity analysis in ${CMAKE_CURRENT_SOURCE_DIR}."
  )
endfunction()
