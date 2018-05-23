include(CMakeTestCompilerCommon)
unset(CMAKE_SYCL_COMPILER_WORKS CACHE)

if(NOT CMAKE_SYCL_COMPILER_WORKS)
  PrintTestCompilerStatus("SYCL" "")
  file(WRITE ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeTmp/main.cpp
      "#include <CL/sycl.hpp>\n"
      "#ifndef CL_SYCL_LANGUAGE_VERSION\n"
      "# error \"The CMAKE_SYCL_COMPILER is set to an invalid SYCL compiler\"\n"
      "#endif\n"
      "int main(){return 0;}\n")

  try_compile(CMAKE_SYCL_COMPILER_WORKS ${CMAKE_BINARY_DIR}
    ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeTmp/main.cpp
    OUTPUT_VARIABLE __CMAKE_SYCL_COMPILER_OUTPUT)

  # Move result from cache to normal variable.
  set(CMAKE_SYCL_COMPILER_WORKS ${CMAKE_SYCL_COMPILER_WORKS})
  unset(CMAKE_SYCL_COMPILER_WORKS CACHE)
  set(SYCL_TEST_WAS_RUN 1)
endif()

if(NOT CMAKE_SYCL_COMPILER_WORKS)
  PrintTestCompilerStatus("SYCL" " -- broken")
  file(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeError.log
    "Determining if the SYCL compiler works failed with "
    "the following output:\n${__CMAKE_SYCL_COMPILER_OUTPUT}\n\n")
  string(REPLACE "\n" "\n  " _output "${__CMAKE_SYCL_COMPILER_OUTPUT}")
  message(FATAL_ERROR "The SYCL compiler\n  \"${CMAKE_SYCL_COMPILER}\"\n"
    "is not able to compile a simple test program.\nIt fails "
    "with the following output:\n  ${_output}\n\n"
    "CMake will not be able to correctly generate this project.")
else()
  if(SYCL_TEST_WAS_RUN)
    PrintTestCompilerStatus("SYCL" " -- works")
    file(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeOutput.log
      "Determining if the SYCL compiler works passed with "
      "the following output:\n${__CMAKE_SYCL_COMPILER_OUTPUT}\n\n")
  endif()

  # Try to identify the ABI and configure it into CMakeSYCLCompiler.cmake
  include(${CMAKE_ROOT}/Modules/CMakeDetermineCompilerABI.cmake)
  cmake_determine_compiler_abi(SYCL ${CMAKE_CURRENT_LIST_DIR}/CMakeSYCLCompilerABI.cpp)

  # Re-configure to save learned information.
  configure_file(
    ${CMAKE_CURRENT_LIST_DIR}/CMakeSYCLCompiler.cmake.in
    ${CMAKE_PLATFORM_INFO_DIR}/CMakeSYCLCompiler.cmake
    @ONLY
    )
  include(${CMAKE_PLATFORM_INFO_DIR}/CMakeSYCLCompiler.cmake)
endif()

unset(__CMAKE_SYCL_COMPILER_OUTPUT)
