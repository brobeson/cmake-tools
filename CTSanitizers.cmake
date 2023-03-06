set(_allowed_sanitizers asan msan tsan ubsan)

# Adapted from Professional CMake, Chapter 14.
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

include(CMakePrintHelpers)
cmake_print_variables(CMAKE_CXX_FLAGS_DEBUG CMAKE_CXX_FLAGS_RELEASE CMAKE_CXX_FLAGS_MINSIZEREL CMAKE_CXX_FLAGS_RELWITHDEBINFO)

set(CMAKE_C_FLAGS_ASAN "${CMAKE_CXX_FLAGS_DEBUG} -fsanitize=address -fno-omit-frame-pointer")
set(CMAKE_CXX_FLAGS_ASAN "${CMAKE_CXX_FLAGS_DEBUG} -fsanitize=address -fno-omit-frame-pointer")
set(CMAKE_EXE_LINKER_FLAGS_ASAN "-lasan")

#[[
set(
  CMAKE_TOOLS_SANITIZERS
  ""
  CACHE
  STRING
  "Add sanitizers to the build. Acceptable values are: ${_allowed_sanitizers}. You request multiple sanitizers by separating them with semicolons."
)
set_property(CACHE CMAKE_TOOLS_SANITIZERS PROPERTY STRINGS ${_allowed_sanitizers})
if(NOT CMAKE_TOOLS_SANITIZERS OR CMAKE_TOOLS_SANITIZERS STREQUAL "none")
  return()
endif()

# Do all this case-insensitive.
string(TOLOWER CMAKE_TOOLS_SANITIZERS "${CMAKE_TOOLS_SANITIZERS}")
if(CMAKE_TOOLS_SANITIZERS STREQUAL "none")
  return()
endif()

# Only support a subset of compilers.
if(NOT CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  message(WARNING "CMakeToolsSanitizers does not support your compiler, ${CMAKE_CXX_COMPILER_ID}. You can go to https://github.com/brobeson/cmake-tools/issues to request support for your compiler.")
  return()
endif()

# Ensure all requested sanitizers are valid.
foreach(sanitizer IN LISTS CMAKE_TOOLS_SANITIZERS)
  if(NOT sanitizer IN_LIST _allowed_sanitizers)
    string(REPLACE ";" ", " _allowed_sanitizers "${_allowed_sanitizers}")
    message(FATAL_ERROR "${sanitizer} is not a valid sanitizer. Valid sanitizers are ${_allowed_sanitizers}.")
  endif()
endforeach()

# Ensure the user did not request mutually exclusive sanitizers.
if(tsan IN_LIST CMAKE_TOOLS_SANITIZERS AND asan IN_LIST CMAKE_TOOLS_SANITIZERS)
  message(FATAL_ERROR "You requested asan and tsan. These sanitizers are mutually exclusive. Please select just one.")
endif()
if(tsan IN_LIST CMAKE_TOOLS_SANITIZERS AND msan IN_LIST CMAKE_TOOLS_SANITIZERS)
  message(FATAL_ERROR "You requested msan and tsan. These sanitizers are mutually exclusive. Please select just one.")
endif()

message(STATUS "Building with ${CMAKE_TOOLS_SANITIZERS}.")

# Everything is OK. Set the compile and link options for the requested
# sanitizers.
if("asan" IN_LIST CMAKE_TOOLS_SANITIZERS)
  add_compile_options()
  add_link_options()
endif()

if("msan" IN_LIST CMAKE_TOOLS_SANITIZERS)
  add_compile_options()
  add_link_options()
endif()

if("tsan" IN_LIST CMAKE_TOOLS_SANITIZERS)
  add_compile_options()
  add_link_options()
endif()

if("ubsan" IN_LIST CMAKE_TOOLS_SANITIZERS)
  add_compile_options()
  add_link_options()
endif()
]]
