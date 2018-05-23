# Conan Recipe and SYCL as a CMake Language for ComputeCpp
This repository contains a recipe for repackaging ComputeCpp as a conan package together with a set of CMake modules that allow the use SYCL without any usage of macros.

---------------
#### WARNING: Both the Conan recipe and the CMake modules are highly experimental. They are likely to break as development of both ComputeCpp and the scripts themselves progress.

---------------

## Creating a Conan package
The conan recipe won't download ComputeCpp by itself. You need to download it from the [Codeplay website](https://developer.codeplay.com) and place the tarball into the same directory as `conanfile.py`. After that, you can create your package as usual:

```bash
cd conan-computecpp
conan create . codeplay/testing
```

## Using ComputeCpp with CMake
The recipe also installs an experimental set of CMake modules that integrate SYCL tightly into CMake such that enabling SYCL is as simple as `find_package(ComputeCpp)`:


**CMakeLists.txt**

```cmake
cmake_minimum_required(VERSION 3.4)
project(hello_sycl)

# The usual conan boilerplate
if(EXISTS "${CMAKE_BINARY_DIR}/conanbuildinfo.cmake")
    include("${CMAKE_BINARY_DIR}/conanbuildinfo.cmake")
    conan_basic_setup(TARGETS NO_OUTPUT_DIRS)
endif()

# This will enable SYCL as a CMake language and set compute++ to be its compiler
find_package(ComputeCpp REQUIRED)

# The device compiler will be automatically invoked on each .cpp file.
# Every target containing SYCL code will implicitly link against ComputeCpp
add_executable(app my_parallel_code.cpp)
```

**conanfile.txt**

```ini
[requires]
computecpp/0.8.0@codeplay/testing

[generators]
cmake
```

**Build process:**

```bash
mkdir build
cd build
conan install ..
cmake .. [-GNinja]
ninja
```

When invoking CMake, the configuration log should print out something similar to this:

```
-- The C compiler identification is GNU 8.1.0
-- The CXX compiler identification is GNU 8.1.0
-- Check for working C compiler: /usr/bin/cc
-- Check for working C compiler: /usr/bin/cc -- works
-- Detecting C compiler ABI info
-- Detecting C compiler ABI info - done
-- Detecting C compile features
-- Detecting C compile features - done
-- Check for working CXX compiler: /usr/bin/c++
-- Check for working CXX compiler: /usr/bin/c++ -- works
-- Detecting CXX compiler ABI info
-- Detecting CXX compiler ABI info - done
-- Detecting CXX compile features
-- Detecting CXX compile features - done
-- Current conanbuildinfo.cmake directory: /home/morris/Projects/hello_sycl/build
-- Conan: Compiler GCC>=5, checking major version 8.1
-- Conan: Checking correct version: 8.1
-- Conan: Using cmake global configuration
-- Conan: Adjusting language standard
-- Found SYCL: /home/morris/.conan/data/computecpp/0.8.0/codeplay/testing/package/5ab84d6acfe1f23c4fae0ab88f26e3a396351ac9/bin/compute++ (found version "CE 0.8.0")
-- The SYCL compiler identification is ComputeCpp CE 0.8.0
-- Check for working SYCL compiler: /home/morris/.conan/data/computecpp/0.8.0/codeplay/testing/package/5ab84d6acfe1f23c4fae0ab88f26e3a396351ac9/bin/compute++
-- Check for working SYCL compiler: /home/morris/.conan/data/computecpp/0.8.0/codeplay/testing/package/5ab84d6acfe1f23c4fae0ab88f26e3a396351ac9/bin/compute++ -- works
-- Detecting SYCL compiler ABI info
-- Detecting SYCL compiler ABI info - done
-- Configuring done
-- Generating done
-- Build files have been written to: /home/morris/Projects/hello_sycl/build
```

## Opting out of SYCL

To exclude just a couple of files, use `set_source_files_properties`:

```cmake
add_executable(app my_parallel_code.cpp cpu_only.cpp more_cpu_only_code.cpp)
set_source_files_properties(cpu_only.cpp more_cpu_only_code.cpp PROPERTIES LANGUAGE CXX)
```

To make SYCL opt-in, you have to enable the `CXX` language after the `find_package(ComputeCpp)` call:

```cmake
cmake_minimum_required(VERSION 3.4)
project(hello_sycl LANGUAGES C)

if(EXISTS "${CMAKE_BINARY_DIR}/conanbuildinfo.cmake")
    include("${CMAKE_BINARY_DIR}/conanbuildinfo.cmake")
    conan_basic_setup(TARGETS NO_OUTPUT_DIRS)
endif()

find_package(ComputeCpp REQUIRED)
enable_language(CXX)

# The host compiler will be invoked for each .cpp file unless overridden by set_source_files_properties
add_executable(app my_parallel_code.cpp cpu_only.cpp more_cpu_only_code.cpp)
set_source_files_properties(my_parallel_code.cpp PROPERTIES LANGUAGE SYCL)
```

## Current Limitations
- This is completely untested on Windows
- Currently only the SYCL driver mode is supported. Using a separate compiler for the host code might be feasible
- The rpath won't be set correctly unless the `LINKER_LANGUAGE` of the target is forced to `CXX`
- `CMAKE_CXX_STANDARD`, `CMAKE_SYCL_STANDARD` and compile features are not supported. This will probably require an upstream change to CMake.
- TriSYCL is not supported yet