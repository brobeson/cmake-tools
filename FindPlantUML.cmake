# Distributed under the MIT License.
# See https://github.com/brobeson/cmake-tools/blob/main/license for details.

#[=[.rst:
FindPlantUML
------------

PlantUML is a tool that transforms a text file into various model diagrams. See
https://plantuml.com for details about writing PlantUML files. This module looks
for PlantUML. It prefers an invocation script installed by some PlantUML system
packages, and falls back to running Java if a script is unavailable.

Result Variables
^^^^^^^^^^^^^^^^

This module defines the following variables:

.. variable:: PlantUML_FOUND

  True if PlantUML is found, false if it is not.

.. variable:: PlantUML_VERSION

  The version reported by ``plantuml -version``.

.. variable:: PlantUML_EXECUTABLE

  The path to the PlantUML program or script. Some systems install a wrapper
  script to run the PlantUML jar file. This is an advanced cache variable.

.. variable:: PlantUML_COMAND

  The command you can use in ``execute_process()``. This abstracts away the
  need to check PlantUML_EXECUTABLE or PlantUML_JAR.

Commands
^^^^^^^^

.. command:: run_plantuml

  Run PlantUML on *.puml* files to generate diagram images. If
  :variable:`PLANTUML_FOUND` is ``false``, the command prints a warning and
  skips running PlantUML.

  .. code-block:: cmake

    run_plantuml(directory [PLANTUML_ARGS arg [arg ...]])

  ``directory``
    Run PlantUML on *.puml* files in this directory.

  ``PLANTUML_ARGS``
    A list of command line arguments to pass to the PlantUML command. The list
    is empty by default. Do not specify PlantUML files to process; this function
    specifies the files for you.

Examples
^^^^^^^^

Render design diagrams as SVG images:

.. code-block:: cmake

  find_package(PlantUML)
  run_plantuml(
    "${CMAKE_SOURCE_DIR}/design_diagrams"
    PLANTUML_ARGS -tsvg
  )

#]=]

# By default, assume PlantUML is not installed.
set(PlantUML_COMAND "PlantUML_COMMAND-NOTFOUND")

# Check if the system has a wrapper script installed. Some systems, like
# Ubuntu install a script that runs the PlantUML JAR file.
find_program(
  PlantUML_EXECUTABLE
  NAMES plantuml
  DOC "PlantUML wrapper script to run the PlantUML jar."
)
mark_as_advanced(PlantUML_EXECUTABLE)

# Prefer the wrapper script if it's available. If not, try to fall back to
# manually running the JAR file.
if(PlantUML_EXECUTABLE)
  set(PlantUML_COMMAND "${PlantUML_EXECUTABLE}")
else()
  if(PlantUML_FIND_QUIETLY)
    set(find_java_quiet "QUIET")
  endif()
  find_package(Java ${find_java_quiet} COMPONENTS Runtime)
  if(Java_FOUND)
    execute_process(
      COMMAND ${Java_JAVA_EXECUTABLE} -jar plantuml.jar -version
      RESULT_VARIABLE command_failed
      OUTPUT_QUIET
      ERROR_QUIET
    )
    if(NOT command_failed)
      set(PlantUML_COMMAND "java -jar plantuml.jar")
    endif()
  endif()
endif()

# Figure out the PlantUML version. The -version output is a lot of text. Look
# for the version pattern in the first line.
execute_process(
  COMMAND "${PlantUML_COMMAND}" -version
  OUTPUT_VARIABLE PlantUML_VERSION
  OUTPUT_STRIP_TRAILING_WHITESPACE
  RESULT_VARIABLE plantuml_version_result
)
if(plantuml_version_result)
  set(PlantUML_VERSION "PlantUML_VERSION-NOTFOUND")
else()
  string(REPLACE "\n" ";" PlantUML_VERSION "${PlantUML_VERSION}")
  list(GET PlantUML_VERSION 0 PlantUML_VERSION)
  string(REGEX MATCH "[0-9]+.[0-9]+.[0-9]+" PlantUML_VERSION "${PlantUML_VERSION}")
  if(NOT PlantUML_VERSION)
    set(PlantUML_VERSION "PlantUML_VERSION-NOTFOUND")
  endif()
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(
  PlantUML
  REQUIRED_VARS PlantUML_COMMAND
  VERSION_VAR PlantUML_VERSION
  REASON_FAILURE_MESSAGE "Executable 'plantuml' not found and command 'java -jar plantuml.jar' failed"
)

function(run_plantuml directory)
  if(NOT PlantUML_FOUND)
    message(WARNING "Cannot run PlantUML; it is not installed")
    return()
  endif()
  cmake_parse_arguments(plantuml "" "" "PLANTUML_ARGS" ${ARGN})
  execute_process(
    COMMAND ${PlantUML_COMMAND} ${ct_PLANTUML_ARGS} "*.puml"
    WORKING_DIRECTORY "${directory}"
  )
endfunction()
