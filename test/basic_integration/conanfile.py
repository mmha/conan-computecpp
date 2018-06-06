from conans import ConanFile, CMake, tools, RunEnvironment
import os


class TestComputeCppPackageConan(ConanFile):
    settings = "os", "compiler", "build_type", "arch"
    generators = "cmake_paths"

    def build(self):
        cmake = CMake(self)
        cmake.definitions["CMAKE_TOOLCHAIN_FILE"] = "conan_paths.cmake"
        cmake.configure()
        cmake.build()
        
    def test(self):
        with tools.environment_append(RunEnvironment(self).vars):
            self.run(os.path.join(self.build_folder,"app"))
