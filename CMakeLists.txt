cmake_minimum_required(VERSION 3.14)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}")
include(CMakeToolsVersionFromGit)

project(
  cmake-tools
  VERSION ${CMAKE_TOOLS_GIT_TAG}
  DESCRIPTION "A collection of scripts for CMake."
  HOMEPAGE_URL "https://github.com/brobeson/cmake-tools"
  LANGUAGES NONE
)

include(CMakePackageConfigHelpers)
write_basic_package_version_file(
  cmake-tools-config-version.cmake
  COMPATIBILITY SameMajorVersion
  ARCH_INDEPENDENT
)
install(
  FILES
    cmake-tools-config.cmake
    CMakeToolsDefaultCompileOptions.cmake
    CMakeToolsVersionFromGit.cmake
    FindLizard.cmake
    "${CMAKE_CURRENT_BINARY_DIR}/cmake-tools-config-version.cmake"
  DESTINATION "/usr/lib/cmake/cmake-tools"
)

set(CPACK_PACKAGE_VENDOR brobeson)
set(CPACK_PACKAGE_CONTACT "brobeson@users.noreply.github.com")
set(CPACK_PACKAGE_CHECKSUM SHA256)
set(CPACK_DEBIAN_FILE_NAME "DEB-DEFAULT")
set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "all")
include(CPack)
