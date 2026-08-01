# cspell:ignore ARGN BUILDSYSTEMM endforeach endfunction endmacro

# cmake_language(DEFER CALL message "Verifying CMake targets against rules")

#[[
the_target(<target> MAY_NOT DEPEND_ON ANYTHING)
the_target(<target> MAY_NOT DEPEND_ON <target> [<target> [<target> ...] ])
#]]
function(the_target TARGET)
  if(NOT TARGET ${TARGET})
    message(SEND_ERROR "Target rules require a valid target; '${TARGET}' is not a target.")
    return()
  endif()
  cmake_parse_arguments(
    "arg"
    "MAY_NOT;DEPEND_ON;ANYTHING"
    ""
    ""
    ${ARGN}
  )
  if(NOT arg_MAY_NOT)
    message(SEND_ERROR "Target rules require the predicate 'MAY_NOT'.")
    return()
  endif()
  if(NOT arg_DEPEND_ON)
    message(SEND_ERROR "Target rules require the predicate 'DEPEND_ON'.")
    return()
  endif()
  if(NOT arg_ANYTHING AND NOT arg_UNPARSED_ARGUMENTS)
    message(SEND_ERROR "Target rule requires 'ANYTHING' or a list of target dependencies.")
    return()
  endif()
endfunction()

# function(_internal_does_target_depend_on)
# endfunction()

# the_target(supernovas.supernovas MAY_NOT DEPEND_ON ANYTHING)
# the_target(supernovas.supernovas MAY_NOT DEPEND_ON julian_date_test)
# no_target(EXCEPT julian_date_test MAY DEPEND_ON Boost::unit_test_framework)
# all_targets(EXCEPT ".+_test" MATCH "supernovas\.+")

include(CMakePrintHelpers)

#[=[
all_targets([EXCEPT <regex> [regex]] )
#]=]
function(all_targets)
  message(CHECK_START "Validating target names")
  cmake_parse_arguments(
    arg
    "MUST"
    ""
    "EXCEPT;EXCEPT_IN;MATCH"
    ${ARGN}
  )
  if(NOT arg_MATCH)
    message(SEND_ERROR "all_targets() rule must have 'MATCH <regex>' arguments.")
    message(CHECK_FAIL "failed")
    return()
  endif()
  list(TRANSFORM arg_EXCEPT_IN PREPEND "${CMAKE_SOURCE_DIR}/" REGEX "^[^/]")
  set(_ALL_TARGETS)
  _get_all_targets("${CMAKE_SOURCE_DIR}")
  foreach(_REGEX IN LISTS arg_EXCEPT)
    list(FILTER _ALL_TARGETS EXCLUDE REGEX "${_REGEX}")
  endforeach()
  foreach(_TARGET IN LISTS _ALL_TARGETS)
    set(_TARGET_MATCHES false)
    foreach(_REGEX IN LISTS arg_MATCH)
      if (NOT _TARGET_MATCHES AND _TARGET MATCHES "${_REGEX}")
        set(_TARGET_MATCHES true)
      endif()
    endforeach()
    if(NOT _TARGET_MATCHES)
      list(APPEND _FAILING_TARGETS ${_TARGET})
    endif()
  endforeach()
  if(_FAILING_TARGETS)
    message(CHECK_PASS "some targets failed")
    list(JOIN arg_MATCH " or " _REGEXES)
    foreach(_TARGET IN LISTS _FAILING_TARGETS)
      get_target_property(_SOURCE_DIR ${_TARGET} SOURCE_DIR)
      message(WARNING "Target '${_TARGET}' does not meet name requirements ${_REGEXES}. The target is defined in ${_SOURCE_DIR}")
    endforeach()
  else()
    message(CHECK_PASS "all targets passed")
  endif()
endfunction()

macro(_get_all_targets _DIRECTORY)
  # Get the targets defined in _DIRECTORY
  set(_SHOULD_SKIP false)
  foreach(EXCEPT IN LISTS arg_EXCEPT_IN)
    if("${_DIRECTORY}" MATCHES "^${EXCEPT}")
      set(_SHOULD_SKIP true)
    endif()
  endforeach()
  if(NOT _SHOULD_SKIP)
    get_directory_property(_TARGETS DIRECTORY "${_DIRECTORY}" BUILDSYSTEM_TARGETS)
    if(_TARGETS)
      list(APPEND _ALL_TARGETS ${_TARGETS})
    endif()

    # Recurse into subdirectories.
    get_directory_property(_SUBDIRECTORIES DIRECTORY "${_DIRECTORY}" SUBDIRECTORIES)
    foreach(_SUBDIRECTORY IN LISTS _SUBDIRECTORIES)
      _get_all_targets("${_SUBDIRECTORY}")
    endforeach()
  endif()
endmacro()
