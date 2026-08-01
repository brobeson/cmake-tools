find_package(Python3 REQUIRED)

cmake_file_api(QUERY API_VERSION 1 CODEMODEL 2) # cspell:ignore CODEMODEL

add_custom_target(
  diagrams.component
  COMMAND Python3::Interpreter "${CMAKE_CURRENT_LIST_DIR}/cmake_graph.py"
  WORKING_DIRECTORY "${CMAKE_BINARY_DIR}"
  COMMENT "Creating component diagrams"
)