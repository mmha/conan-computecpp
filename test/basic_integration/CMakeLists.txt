cmake_minimum_required(VERSION 3.11)
project(test_computecpp_package VERSION 1.0)

find_package(ComputeCpp REQUIRED)

add_executable(app main.cpp)