cmake_minimum_required(VERSION 3.25)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_C_STANDARD 23)

project(
  reqt
  DESCRIPTION "Requirements Tracing"
  VERSION 0.0.1
  LANGUAGES C CXX
)

Include(FetchContent)

set(JSON_SystemInclude ON)
add_subdirectory(thirdparty/nlohmann_json EXCLUDE_FROM_ALL SYSTEM)
add_subdirectory(thirdparty/pboettch_json-schema-validator EXCLUDE_FROM_ALL SYSTEM)

FetchContent_Declare(
  Catch2
  GIT_REPOSITORY https://github.com/catchorg/Catch2.git
  GIT_TAG        v3.4.0
)

FetchContent_MakeAvailable(Catch2)

add_library(json_parser STATIC)

target_sources(json_parser PRIVATE ${CMAKE_CURRENT_LIST_DIR}/src/json_parser.cpp)

target_link_libraries(json_parser nlohmann_json::nlohmann_json)

target_include_directories(json_parser PRIVATE ${CMAKE_CURRENT_LIST_DIR}/src)

add_executable(unit_tests)

target_link_libraries(unit_tests PRIVATE Catch2::Catch2WithMain)

# Simplify build dependencies declarations for unit tests
function(obj_unit_test unit)
  set(varargs DEPENDENCIES INCLUDE_PATH)
  cmake_parse_arguments(
    OBJ_UNIT_TEST
    ""
    ""
    "${varargs}"
    ${ARGN}
  )

  add_library(
    obj_${unit}_test OBJECT ${CMAKE_CURRENT_LIST_DIR}/test/${unit}_test.cpp
  )

  target_include_directories(
    obj_${unit}_test PRIVATE ${CMAKE_SOURCE_DIR}/${OBJ_UNIT_TEST_INCLUDE_PATH}
  )

  target_link_libraries(obj_${unit}_test PRIVATE ${OBJ_UNIT_TEST_DEPENDENCIES} Catch2::Catch2WithMain)

  target_link_libraries(unit_tests PRIVATE obj_${unit}_test)
endfunction()


obj_unit_test(json_parser 
  INCLUDE_PATH src
  DEPENDENCIES json_parser
)

add_executable(demo src/main.cpp)

target_link_libraries(demo nlohmann_json_schema_validator::validator)
