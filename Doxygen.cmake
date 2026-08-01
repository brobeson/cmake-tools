find_program(
  Doxygen_EXECUTABLE
  NAMES doxygen
  DOC "Doxygen documentation generator (https://www.doxygen.nl)"
)
if(Doxygen_EXECUTABLE)
  execute_process(
    COMMAND "${Doxygen_EXECUTABLE}" --version
    OUTPUT_VARIABLE Doxygen_VERSION
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(
  Doxygen
  REQUIRED_VARS Doxygen_EXECUTABLE
  VERSION_VAR Doxygen_VERSION
)

function(add_doxygen_target)
  cmake_parse_arguments(PARSE_ARGV 0 "" "" TARGET "" )
  if(NOT _TARGET)
    set(_TARGET ${PROJECT_NAME})
  endif()

  # List of header files as the input source files for the Doxygen target.
  get_target_property(HEADER_FILES ${_TARGET} HEADER_SET)
  if(NOT HEADER_FILES)
    message(
      AUTHOR_WARNING
      "Target ${_TARGET} does not have a header file set. Use target_sources() "
      "with a header file set. See "
      "https://cmake.org/cmake/help/latest/command/target_sources.html#file-sets "
      "for details. No documentation target generated.")
    return()
  endif()
  list(JOIN HEADER_FILES " " HEADER_FILE_STRING)

  # Header paths for the INPUT Doxygen configuration item.
  get_target_property(HEADER_DIRS ${_TARGET} HEADER_DIRS)
  if(NOT HEADER_DIRS)
    message(
      AUTHOR_WARNING
      "Target ${_TARGET} does not have a header search directory. "
      "Use target_sources() with a header file set and set the "
      "`BASE_DIRS` option. See "
      "https://cmake.org/cmake/help/latest/command/target_sources.html#file-sets "
      "for details. No documentation target generated.")
    return()
  endif()

  # Check if the input Doxyfile exists. If it doesn't, provide a better
  # error message than configure_file()'s error message.
  if(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/Doxyfile")
    message(
      AUTHOR_WARNING
      "The source Doxyfile does not exist. Add a Doxyfile in "
      "${CMAKE_CURRENT_SOURCE_DIR}. You can run `doxygen -g` to generate a "
      "default Doxyfile, then modify it to fit your project. No documentation "
      "target generated."
    )
    return()
  endif()

  # Configure files necessary for Doxygen to run.
  configure_file("${CMAKE_CURRENT_FUNCTION_LIST_DIR}/doxygen-awesome.css" doxygen-awesome.css COPYONLY)
  configure_file("${CMAKE_CURRENT_FUNCTION_LIST_DIR}/doxygen-awesome-sidebar-only.css" doxygen-awesome-sidebar-only.css COPYONLY)
  configure_file(Doxyfile Doxyfile)
  file(
    APPEND
    "${CMAKE_CURRENT_BINARY_DIR}/Doxyfile"
    "GENERATE_TREEVIEW = YES\n"
    "DISABLE_INDEX = NO\n"
    "HTML_EXTRA_STYLESHEET = doxygen-awesome.css doxygen-awesome-sidebar-only.css\n"
  )
  if(Doxygen_VERSION VERSION_GREATER_EQUAL 1.9.2)
    file(APPEND "${CMAKE_CURRENT_BINARY_DIR}/Doxyfile" "FULL_SIDEBAR = NO\n")
  endif()
  if(Doxygen_VERSION VERSION_GREATER_EQUAL 1.9.5)
    file(APPEND "${CMAKE_CURRENT_BINARY_DIR}/Doxyfile" "HTML_COLORSTYLE = LIGHT\n")
  endif()

  # Stamp file to avoid rebuilding the docs if input files have not changed.
  set(STAMP_FILE "${CMAKE_CURRENT_BINARY_DIR}/doxygen.stamp")

  add_custom_command(
    VERBATIM
    OUTPUT "${STAMP_FILE}"
    COMMAND "${Doxygen_EXECUTABLE}" Doxyfile
    COMMAND "${CMAKE_COMMAND}" -E touch "${STAMP_FILE}"
    COMMENT "Building ${_TARGET} documentation"
    DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/Doxyfile" ${HEADER_FILES}
  )
  add_custom_target(
    ${_TARGET}.docs
    ALL
    DEPENDS "${STAMP_FILE}"
    SOURCES ${HEADER_FILES}
  )
endfunction()


#[[
// Address sanitizer test
int main()
{
  char *x{new char[10]};
  delete[] x;
  return x[5];
}

// Undefined behavior test
int main()
{
  const int a[4]{0, 1, 2, 3};
  return a[5];
}



// Philip Nelson
I've accepted a new position at a small aerospace company called TenOne
Aerospace and I wanted to let you know how much I've enjoyed working with
you all. These last 5 years have been an incredible start to my career and
I'm glad I got to share it with you. Slingshot, DOTTIE, RECON, SENTINEL and
IR&Ds, y'all have taught me a lot (I even spent a semester studying computer
architecture from Seth!). I'll be leaving SDL on Feb 8th to start this new
adventure. I would be very happy if our paths crossed again.


// Jake Cook
For those that haven’t heard yet, today (Monday 13th Oct.) is my last day with SDL.
I wanted to share my appreciation for the quality engineers, peers, managers, and mentors each of you have been to me over my time with SDL. The trajectory of my career I owe to roots that were founded here, and I will always remember my time fondly. Perhaps even one day I’ll find my way back to Cache Valley :)
Those that would like to stay in touch long term, on a professional or personal basis, I’ve included my personal contact info below. Also welcome to find me on LinkedIn, but I read my messages infrequently.
Cell: 515-344-9124
Email: jake.w.cook@protonmail.com

#]]
