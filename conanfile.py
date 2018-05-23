from conans import ConanFile, tools
import os

class ComputeCppConan(ConanFile):
    name = "computecpp"
    version = "0.8.0"
    generators = "virtualenv"
    no_copy_source = True
    exports_sources = "ComputeCpp-CE-*-Ubuntu.16.04-64bit.tar.gz", "cmake/*"

    def package(self):
        archive = os.path.join(self.source_folder, "ComputeCpp-CE-%s-Ubuntu.16.04-64bit.tar.gz" % self.version)
        cmake = os.path.join(self.source_folder, "cmake")
        tools.untargz(archive)
        self.copy("*", src="ComputeCpp-CE-%s-Ubuntu-16.04-x86_64" % self.version)
        self.copy("*", src=cmake, dst="share/cmake/ComputeCpp")

    def package_info(self):
        self.cpp_info.libs = ["libComputeCpp.so"]
        self.env_info.PATH.append(os.path.join(self.package_folder, "bin"))
        self.user_info.ComputeCpp_DIR = self.package_folder