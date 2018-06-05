# This file is based on CMake's CMakeDetermine*Compiler.cmake
# Distributed under the OSI-approved BSD 3-Clause License.
# See https://cmake.org/licensing for details.

set(CMAKE_SYCL_SDK_INCLUDE_DIRECTORIES ${COMPUTECPP_INCLUDE_DIRS})
set(CMAKE_SYCL_SDK_LINK_LIBRARIES ${COMPUTECPP_RUNTIME_LIBRARY})

include(${CMAKE_ROOT}/Modules/CMakeDetermineCompiler.cmake)
include(${CMAKE_ROOT}/Modules/CMakeParseImplicitLinkInfo.cmake)

if(NOT CMAKE_SYCL_COMPILER)
  set(CMAKE_SYCL_COMPILER_INIT NOTFOUND)
    if(NOT $ENV{SYCLCXX} STREQUAL "")
      get_filename_component(CMAKE_SYCL_COMPILER_INIT $ENV{SYCLCXX} PROGRAM PROGRAM_ARGS CMAKE_SYCL_FLAGS_ENV_INIT)
      if(CMAKE_SYCL_FLAGS_ENV_INIT)
        set(CMAKE_SYCL_COMPILER_ARG1 "${CMAKE_SYCL_FLAGS_ENV_INIT}" CACHE STRING "First argument to CXX compiler")
      endif()
      if(NOT EXISTS ${CMAKE_SYCL_COMPILER_INIT})
        message(FATAL_ERROR "Could not find compiler set in environment variable SYCLCXX:\n$ENV{SYCLCXX}.\n${CMAKE_SYCL_COMPILER_INIT}")
      endif()
    endif()

  if(NOT CMAKE_SYCL_COMPILER_INIT)
    set(CMAKE_SYCL_COMPILER_LIST compute++)
  endif()

  _cmake_find_compiler(SYCL)
else()
  _cmake_find_compiler_path(SYCL)
endif()

mark_as_advanced(CMAKE_SYCL_COMPILER)

list(APPEND CMAKE_SYCL_COMPILER_ID_MATCH_VENDORS ComputeCpp)

# Build a small source file to identify the compiler.
if(NOT CMAKE_SYCL_COMPILER_ID_RUN)
  set(CMAKE_SYCL_COMPILER_ID_RUN 1)

  # Try to identify the compiler.
  set(CMAKE_SYCL_COMPILER_ID)
  set(CMAKE_SYCL_PLATFORM_ID)
  file(READ ${CMAKE_ROOT}/Modules/CMakePlatformId.h.in
    CMAKE_SYCL_COMPILER_ID_PLATFORM_CONTENT)

  set(CMAKE_SYCL_COMPILER_ID_VENDOR_FLAGS_ComputeCpp)
  set(CMAKE_SYCL_COMPILER_ID_VENDOR_REGEX_ComputeCpp "Codeplay ComputeCpp .+ Device Compiler")

  set(CMAKE_CXX_COMPILER_ID_TOOL_MATCH_REGEX "\nLd[^\n]*(\n[ \t]+[^\n]*)*\n[ \t]+([^ \t\r\n]+)[^\r\n]*-o[^\r\n]*CompilerIdSYCL/(\\./)?(CompilerIdSYCL.xctest/)?CompilerIdSYCL[ \t\n\\\"]")
  set(CMAKE_CXX_COMPILER_ID_TOOL_MATCH_INDEX 2)
  set(CMAKE_SYCL_COMPILER_ID_FLAGS_ALWAYS -v)

  include(${CMAKE_ROOT}/Modules/CMakeDetermineCompilerId.cmake)
  set(CMAKE_SYCL_COMPILER_VERSION ${COMPUTECPP_VERSION})
  set(CMAKE_SYCL_COMPILER_VERSION_INTERNAL ${COMPUTECPP_VERSION})
  set(CMAKE_CXX_STANDARD_COMPUTED_DEFAULT 98)
  cmake_determine_compiler_id(SYCL SYCLFLAGS CMakeSYCLCompilerId.cpp)
endif()

set(_CMAKE_PROCESSING_LANGUAGE "SYCL")
include(CMakeFindBinUtils)
unset(_CMAKE_PROCESSING_LANGUAGE)

if(MSVC_SYCL_ARCHITECTURE_ID)
  set(SET_MSVC_SYCL_ARCHITECTURE_ID
    "set(MSVC_SYCL_ARCHITECTURE_ID ${MSVC_SYCL_ARCHITECTURE_ID})")
endif()

# configure all variables set in this file
configure_file(${CMAKE_CURRENT_LIST_DIR}/CMakeSYCLCompiler.cmake.in
  ${CMAKE_PLATFORM_INFO_DIR}/CMakeSYCLCompiler.cmake
  @ONLY
  )

set(CMAKE_SYCL_COMPILER_ENV_VAR "SYCLCXX")
