# Distributed under the MIT License. See
# https://github.com/brobeson/cmake-tools/blob/main/license for details.

# cspell:words endfunction endforeach plantuml

#[=[.rst:
CMakeToolsTargetDependencies
----------------------------

This module generates UML component diagrams of a project's targets and their
dependencies. To use this module, just include it and call the function:

.. code-block:: cmake

  include(CMakeToolsTargetDependencies)
  cmake_tools_make_target_dependency_graphs()

Commands
========

.. command:: cmake_tools_make_target_dependency_graphs

  .. code-block:: cmake

    cmake_tools_make_target_dependency_graphs(
      [NAMESPACE <namespace>]
      [TARGET_EXCLUDES regex [regex ...]]
      [DEPENDENCY_EXCLUDES regex [regex ...]]
      [VERBOSE]
      [SOURCE_DIRECTORY path]
      [OUTPUT_DIRECTORY path]
    )

  ``NAMESPACE``
    The namespace to use for grouping project targets into a UML frame. This
    should be the namespace used when you create alias targets or export your
    targets.

  ``TARGET_EXCLUDES``
    A list of regular expressions of project targets to exclude from the graphs.

  ``DEPENDENCY_EXCLUDES``
    A list of regular expressions of target dependencies to exclude from the
    graphs.

    .. warning::

      Remember CMake's rules for regular expressions and strings. For example,
      to exclude the ``stdc++fs`` library, the expression in CMake must be
      ``"stdc\\+\\+fs"``. The expression needs to treat the "+" characters
      literally, and to escape them for that purpose, the string needs "\\\\"
      instead of "\\".

  ``VERBOSE``
    Print extra status messages.

  ``SOURCE_DIRECTORY``
    The root path to recursively search for build targets. The default is
    ``${CMAKE_SOURCE_DIR}``.

  ``OUTPUT_DIRECTORY``
    The directory in which to write the PlantUML files and the diagrams. The
    default is ``${CMAKE_BINARY_DIR}/dependency_graphs``.

  ``NO_PLANTUML``
    By default, this function runs PlantUML after it writes the PlantUML files.
    Use this option to skip the PlantUML step.

  ``PLANTUML_ARGS``
      See ``PLANTUML_ARGS`` for :command:`run_plantuml`.
      See ``PLANTUML_ARGS`` for :command:cmake_tools_run_plantuml.

.. command:: cmake_tools_run_plantuml

  .. code-block:: cmake

    cmake_tools_run_plantuml([PLANTUML_ARGS arg [arg ...]])

  ``PLANTUML_ARGS``
    A list of command line arguments to pass to the PlantUML command. The list is
    empty by default. Do not specify PlantUML files to process; this function
    specifies the files for you.

Examples
========

Diagram everything except unit tests. All the unit test targets end with "_test".

.. code-block:: cmake

  cmake_tools_make_target_dependency_graphs(TARGET_EXCLUDES ".+_test")

Create SVG images.

.. code-block:: cmake

  cmake_tools_make_target_dependency_graphs(PLANTUML_ARGS -tsvg)

Post-process the PlantUML files before rendering the images.

.. code-block:: cmake

  cmake_tools_make_target_dependency_graphs(NO_PLANTUML)
  # Do your post processing.
  run_plantuml("${CMAKE_BINARY_DIR}/dependency_graphs")

#]=]

find_package(PlantUML)
include(CMakePrintHelpers)

function(cmake_tools_make_target_dependency_graphs)
  cmake_parse_arguments(
    ct "NO_PLANTUML;VERBOSE" "NAMESPACE;OUTPUT_DIRECTORY;SOURCE_DIRECTORY"
    "DEPENDENCY_EXCLUDES;PLANTUML_ARGS;TARGET_EXCLUDES" ${ARGN})
  if(NOT ct_SOURCE_DIRECTORY)
    set(ct_SOURCE_DIRECTORY "${CMAKE_SOURCE_DIR}")
  endif()
  if(NOT ct_OUTPUT_DIRECTORY)
    set(ct_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/dependency_graphs")
  endif()
  message(CHECK_START "Building target dependency graphs")
  list(APPEND CMAKE_MESSAGE_INDENT "  ")
  set(ct_JSON "{}")
  _clean_output_directory()
  _get_filtered_targets()
  _get_filtered_dependencies()
  file(WRITE "${CMAKE_SOURCE_DIR}/targets.json" "${ct_JSON}")
  # _write_plantuml_file()
  # if(NOT ct_NO_PLANTUML)
  #   _log(CHECK_START "Generating dependency graph")
  #   run_plantuml("${ct_OUTPUT_DIRECTORY}")
  #   cmake_tools_run_plantuml("${ct_OUTPUT_DIRECTORY}")
  #   _log(CHECK_PASS "done")
  # endif()
  list(POP_BACK CMAKE_MESSAGE_INDENT)
  message(CHECK_PASS "done")
endfunction()

function(cmake_tools_run_plantuml directory)
  if(NOT PlantUML_FOUND)
    message(WARNING "Cannot run PlantUML; it is not installed")
    return()
  endif()
  cmake_parse_arguments(ct "" "" "PLANTUML_ARGS" ${ARGN})
  _log(CHECK_START "Generating dependency graph")
  execute_process(COMMAND ${PlantUML_COMMAND} "*.puml"
                  WORKING_DIRECTORY "${directory}")
  _log(CHECK_PASS "done")
endfunction()

# ===============================================================================
# Functions for gathering the list of allowed dependencies.

# Get the list of dependencies allowed in the dependency graph. Return the list
# of dependencies in ct_ALLOWED_DEPENDENCIES in the parent scope.
function(_get_filtered_dependencies)
  _log(CHECK_START "Filtering dependencies")
  foreach(target IN LISTS ct_TARGETS)
    get_target_property(dependencies ${target} LINK_LIBRARIES)
    list(APPEND all_dependencies ${dependencies})
  endforeach()
  list(REMOVE_DUPLICATES all_dependencies)
  list(FILTER all_dependencies EXCLUDE REGEX "\\$<.*")
  _filter_by_regex(all_dependencies EXCLUDE_PATTERNS ${ct_DEPENDENCY_EXCLUDES}
                   LIST ${all_dependencies})
  list(SORT all_dependencies)
  set(ct_ALLOWED_DEPENDENCIES
      ${all_dependencies}
      PARENT_SCOPE)
  list(LENGTH all_dependencies length)
  _log(CHECK_PASS "Found ${length} dependencies")
endfunction()

# ===============================================================================
# Functions for gathering the list of build targets.

# Get the list of project targets allowed in the dependency graph. Return the
# list of targets in ct_TARGETS in the parent scope.
function(_get_filtered_targets)
  _log(CHECK_START "Searching for targets in ${CMAKE_SOURCE_DIR}")
  _get_defined_targets(ct_TARGETS "${ct_SOURCE_DIRECTORY}")
  list(LENGTH ct_TARGETS length)
  _log(STATUS "Found ${length} targets before filtering")
  _filter_targets()
  list(SORT ct_TARGETS)
  foreach(target IN LISTS ct_TARGETS)
    string(JSON ct_JSON SET "${ct_JSON}" "${target}" "{}")
    get_target_property(target_type ${target} TYPE)
    string(JSON ct_JSON SET "${ct_JSON}" "${target}" "type" "\"${target_type}\"")
    get_target_property(link_libraries ${target} LINK_LIBRARIES)
    list(LENGTH link_libraries length)
    set(deps_json "[]")
    if(link_libraries)
      foreach(dep IN LISTS link_libraries())
        if(dep MATCHES "^\\$")
          string(REGEX MATCH ":[^:]+>+$" dep "${dep}")
          string(REPLACE ":" "" dep "${dep}")
          string(REPLACE ">" "" dep "${dep}")
        endif()
        if(TARGET ${dep})
          list(APPEND target_dependencies ${dep})
        endif()
        string(JSON deps_json SET "${deps_json}" ${length} "\"${dep}\"")
      endforeach()
    endif()
    string(JSON ct_JSON SET "${ct_JSON}" "${target}" "dependencies" ${deps_json})
  endforeach()
  list(REMOVE_DUPLICATES target_dependencies)
  foreach(dep IN LISTS target_dependencies)
    get_target_property(actual_target ${dep} ALIASED_TARGET)
    if(actual_target)
      string(REPLACE "::" ";" package "${dep}")
      list(GET package 0 package)
      string(JSON ct_JSON SET "${ct_JSON}" "${actual_target}" "package" "\"${package}\"")
      string(JSON ct_JSON SET "${ct_JSON}" "${actual_target}" "alias" "\"${dep}\"")
    else()
      message(STATUS "Still need to figure out dependency target ${dep}")
    endif()
  endforeach()
  # cmake_print_variables(target_dependencies)
  set(ct_JSON "${ct_JSON}" PARENT_SCOPE)
  set(ct_TARGETS ${ct_TARGETS} PARENT_SCOPE)
  list(LENGTH ct_TARGETS length)
  _log(CHECK_PASS "Found ${length} targets")
endfunction()

# Get all the targets defined in a directory and its descendent directories.
# Since this is a recursive function, it uses the typical pattern of IO
# parameters instead of manipulating the parent scope. Parameters: output: The
# variable to hold the list of found targets. root_directory: The directory to
# search for targets. The function searches descendent directories, too.
function(_get_defined_targets output root_directory)
  # Get targets defined in this directory, first.
  get_directory_property(targets DIRECTORY "${root_directory}"
                                           BUILDSYSTEM_TARGETS)
  list(LENGTH targets length)
  _log(STATUS "Found ${length} targets in ${root_directory}")

  # Search subdirectories.
  get_directory_property(subdirectories DIRECTORY "${root_directory}"
                                                  SUBDIRECTORIES)
  foreach(subdirectory IN LISTS subdirectories)
    if(subdirectory MATCHES "${CMAKE_BINARY_DIR}/_deps/.*")
      _log(STATUS "Skipping ${subdirectory}")
    else()
      _get_defined_targets(subdirectory_targets "${subdirectory}")
      list(LENGTH subdirectory_targets length)
      if(length GREATER 0)
        list(APPEND targets ${subdirectory_targets})
      endif()
    endif()
  endforeach()

  # Hand it all back up the call stack.
  set(${output}
      ${targets}
      PARENT_SCOPE)
endfunction()

# Remove unwanted targets from the list of all build targets. This removes
# targets built in by CMake, such as CTest targets, and it removes any targets
# that match a list of regular expressions.
function(_filter_targets)
  _filter_ctest_targets()
  _filter_utility_targets()
  list(LENGTH ct_TARGETS length)
  _log(STATUS "Found ${length} targets after filtering CMake targets")
  if(ct_TARGET_EXCLUDES)
    _log(STATUS "Filtering by regular expressions: ${ct_TARGET_EXCLUDES}")
    _filter_by_regex(ct_TARGETS EXCLUDE_PATTERNS ${ct_TARGET_EXCLUDES} LIST
                     ${ct_TARGETS})
    list(LENGTH ct_TARGETS length)
    _log(STATUS
         "Found ${length} targets after filtering by regular expressions")
  endif()
  set(ct_TARGETS
      ${ct_TARGETS}
      PARENT_SCOPE)
endfunction()

# Filter CTest targets out of the list of build targets.
function(_filter_ctest_targets)
  foreach(type IN ITEMS "Experimental" "Nightly" "Continuous")
    foreach(
      stage IN
      ITEMS ""
            "MemoryCheck"
            "Start"
            "Update"
            "Configure"
            "Build"
            "Test"
            "Coverage"
            "MemCheck"
            "Submit")
      list(REMOVE_ITEM ct_TARGETS ${type}${stage})
    endforeach()
  endforeach()
  set(ct_TARGETS
      ${ct_TARGETS}
      PARENT_SCOPE)
endfunction()

# Remove CMake utility targets from the list of targets created by the project.
# These are targets created by commands like add_custom_target().
function(_filter_utility_targets)
  foreach(target IN LISTS ct_TARGETS)
    get_target_property(target_type ${target} TYPE)
    if(target_type STREQUAL "UTILITY")
      list(REMOVE_ITEM ct_TARGETS ${target})
    endif()
  endforeach()
  set(ct_TARGETS
      ${ct_TARGETS}
      PARENT_SCOPE)
endfunction()

# ===============================================================================
# Functions for writing the PlantUML files.

# Write the PlantUML file.
function(_write_plantuml_file)
  _log(CHECK_START "Writing PlantUML files")
  set(whole_project_file "${ct_OUTPUT_DIRECTORY}/whole_project.puml")
  file(WRITE "${whole_project_file}" "@startuml\nskinparam linetype ortho\n")
  _write_targets_to_plantuml_file("${whole_project_file}" ${ct_TARGETS})
  _group_dependencies("${whole_project_file}" ${ct_ALLOWED_DEPENDENCIES})
  foreach(target IN LISTS ct_TARGETS)
    _write_dependencies_to_plantuml_file("${whole_project_file}" ${target})
    _write_target_specific_file(${target})
  endforeach()
  file(APPEND "${whole_project_file}" "@enduml\n")
  _log(CHECK_PASS "done")
endfunction()

# Write a PlantUML file for a specific target. This places the supplied target
# as the root of the graph and shows only that target's dependencies.
function(_write_target_specific_file target)
  set(project_file "${ct_OUTPUT_DIRECTORY}/${target}.puml")
  file(WRITE "${project_file}" "@startuml\nskinparam linetype ortho\n")
  _write_targets_to_plantuml_file("${project_file}" ${target})
  # _write_targets_to_plantuml_file("${whole_project_file}" ${target})
  get_target_property(libraries ${target} LINK_LIBRARIES)
  _group_dependencies("${project_file}" ${libraries})
  _write_dependencies_to_plantuml_file("${project_file}" ${target})
  file(APPEND "${project_file}" "@enduml\n")
endfunction()

# Define the project's build targets in a PlantUML file.
function(_write_targets_to_plantuml_file plantuml_file)
  if(DEFINED ct_NAMESPACE)
    file(APPEND "${plantuml_file}" "frame \"${ct_NAMESPACE}\" {\n")
  endif()
  foreach(target IN LISTS ARGN)
    get_target_property(target_type ${target} TYPE)
    string(TOLOWER ${target_type} target_type)
    string(REPLACE "_" " " target_type ${target_type})
    file(APPEND "${plantuml_file}" "[${target}] <<${target_type}>>\n")
  endforeach()
  if(DEFINED ct_NAMESPACE)
    file(APPEND "${plantuml_file}" "}\n")
  endif()
endfunction()

# Group namespaced dependencies into PlantUML frames.
function(_group_dependencies plantuml_file)
  list(FILTER ARGN INCLUDE REGEX ".+::.+")
  if(DEFINED ct_NAMESPACE)
    list(FILTER ARGN EXCLUDE REGEX "${ct_NAMESPACE}::.+")
  endif()
  foreach(dependency IN LISTS ARGN)
    string(REGEX MATCH "([^:]+)::([^:]+)" unused "${dependency}")
    file(APPEND "${plantuml_file}" "frame \"${CMAKE_MATCH_1}\" {\n")
    _get_actual_dependency(actual_dependency ${dependency})
    file(APPEND "${plantuml_file}"
         "[${CMAKE_MATCH_2}] as ${actual_dependency}\n")
    file(APPEND "${plantuml_file}" "}\n")
  endforeach()
endfunction()

# Write a target's dependencies and relationsships to a PlantUML file.
# Parameters: target: The build target for which to write dependency
# relationships.
function(_write_dependencies_to_plantuml_file plantuml_file target)
  get_target_property(libraries ${target} LINK_LIBRARIES)
  list(SORT libraries)
  foreach(dependency IN LISTS libraries)
    if(dependency IN_LIST ct_ALLOWED_DEPENDENCIES)
      _get_actual_dependency(actual_dependency ${dependency})
      file(APPEND "${plantuml_file}" "[${target}] --> [${actual_dependency}]\n")
    endif()
  endforeach()
endfunction()

# ===============================================================================
# Utility functions. These are general purpose functions that can have multiple
# callees. So, they follow a typical pattern of requiring the name of the output
# variable for returning data.

# Remove all files from the graph output directory.
function(_clean_output_directory)
  file(
    GLOB old_files
    LIST_DIRECTORIES false
    "${ct_OUTPUT_DIRECTORY}/*")
  if(old_files)
    file(REMOVE ${old_files})
  endif()
endfunction()

# Convert a dependency to a format suitable for PlantUML. Parameters: output:
# The variable to hold the new dependency name. dependency: The dependency, as
# reported by CMake. Returns: If `dependency` is an alias target defined by the
# project, return the target pointed to by the alias target. If `dependency` is
# a namespaced imported target, return the `dependency` : charaters changed to _
# characters: Qt5::Core -> Qt5__Core Else return the `dependency` as is.
function(_get_actual_dependency output dependency)
  if(TARGET ${dependency})
    get_target_property(aliased_target ${dependency} ALIASED_TARGET)
    if(aliased_target)
      set(${output}
          ${aliased_target}
          PARENT_SCOPE)
      return()
    endif()
    set(${output}
        ${dependency}
        PARENT_SCOPE)
  endif()
  string(REPLACE ":" "_" dependency ${dependency})
  set(${output}
      ${dependency}
      PARENT_SCOPE)
endfunction()

# Write a message to the console if the user enabled `VERBOSE`. Parameters:
# level: The level of the message. This must be a valid `mode` or `checkState`
# value for the `message()` command. ARGN: The values passed directly to the
# `message()` command for output.
function(_log level)
  if(NOT ct_VERBOSE)
    return()
  endif()
  if(level STREQUAL "CHECK_PASS" OR level STREQUAL "CHECK_FAIL")
    list(POP_BACK CMAKE_MESSAGE_INDENT)
  endif()
  message(${level} ${ARGN})
  if(level STREQUAL "CHECK_START")
    list(APPEND CMAKE_MESSAGE_INDENT "  ")
  endif()
  set(CMAKE_MESSAGE_INDENT
      ${CMAKE_MESSAGE_INDENT}
      PARENT_SCOPE)
endfunction()

# Remove elements from a list by regular expression. Parameters: output: The
# variable to hold the filtered list to return to the calling function.
# EXCLUDE_PATTERNS pattern [pattern ...] The list of regular expressions to use
# for filtering list elements. If an element matches any of these patterns, the
# function removes it from the list. LIST item [item ...] The list to filter.
function(_filter_by_regex output)
  cmake_parse_arguments(filter "" "" "EXCLUDE_PATTERNS;LIST" ${ARGN})
  foreach(regex IN LISTS filter_EXCLUDE_PATTERNS)
    list(FILTER filter_LIST EXCLUDE REGEX "${regex}")
  endforeach()
  set(${output}
      ${filter_LIST}
      PARENT_SCOPE)
endfunction()
