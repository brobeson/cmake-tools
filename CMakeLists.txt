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
if(WIN32)
  set(destination "cmake-tools")
else()
  set(destination "lib/cmake/cmake-tools")
endif()
install(
  FILES
    cmake-tools-config.cmake
    CMakeToolsDefaultCompileOptions.cmake
    CMakeToolsVersionFromGit.cmake
    FindLizard.cmake
    "${CMAKE_CURRENT_BINARY_DIR}/cmake-tools-config-version.cmake"
  DESTINATION "${destination}"
)

set(CPACK_DEBIAN_FILE_NAME "DEB-DEFAULT")
set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "all")
set(CPACK_PACKAGE_VENDOR brobeson)
set(CPACK_PACKAGE_CONTACT "brobeson@users.noreply.github.com")
set(CPACK_PACKAGE_CHECKSUM SHA256)
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/license.txt")
set(CPACK_WIX_UPGRADE_GUID "9f9428b2-9809-4d9b-85e8-3c4f8845da3b")
set(CPACK_WIX_CMAKE_PACKAGE_REGISTRY true)
set(CPACK_WIX_PROPERTY_ARPHELPLINK "https://cmake-tools.readthedocs.io/en/latest/")
include(CPack)
