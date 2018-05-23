#.rst:
# FindSYCL
#---------------
#
#   Copyright 2018 Codeplay Software Ltd.
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use these files except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

find_program(COMPUTECPP_DEVICE_COMPILER compute++ PATH_SUFFIXES bin)
find_program(COMPUTECPP_INFO_TOOL computecpp_info PATH_SUFFIXES bin)
find_library(COMPUTECPP_RUNTIME_LIBRARY
  NAMES ComputeCpp ComputeCpp_vs2015
  PATHS ${ComputeCpp_DIR}
  PATH_SUFFIXES lib
  DOC "ComputeCpp Runtime Library" )
find_library(COMPUTECPP_RUNTIME_LIBRARY_DEBUG
  NAMES ComputeCpp ComputeCpp_vs2015_d
  PATHS ${ComputeCpp_DIR}
  PATH_SUFFIXES lib
  DOC "ComputeCpp Debug Runtime Library"
  )
find_library(COMPUTECPP_RUNTIME_LIBRARY_DEBUG
  NAMES ComputeCpp
  PATHS ${ComputeCpp_DIR}
  PATH_SUFFIXES lib
  DOC "ComputeCpp Runtime Library"
  )
find_path(COMPUTECPP_INCLUDE_DIRS CL/sycl.hpp
    PATHS ${ComputeCpp_DIR}
    PATH_SUFFIXES include
    )

if(COMPUTECPP_INFO_TOOL)
    execute_process(COMMAND ${COMPUTECPP_INFO_TOOL}
                            "--dump-version"
                    OUTPUT_VARIABLE COMPUTECPP_VERSION
                    OUTPUT_STRIP_TRAILING_WHITESPACE)
endif()

include(FindPackageHandleStandardArgs)

find_package_handle_standard_args(SYCL
    REQUIRED_VARS COMPUTECPP_DEVICE_COMPILER
                  COMPUTECPP_INFO_TOOL
                  COMPUTECPP_RUNTIME_LIBRARY
                  COMPUTECPP_INCLUDE_DIRS
    VERSION_VAR   COMPUTECPP_VERSION
)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR})
enable_language(SYCL)

find_package(OpenCL QUIET REQUIRED)