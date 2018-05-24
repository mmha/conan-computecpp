from conans import ConanFile, tools
import os
import errno

class ComputeCppConan(ConanFile):
    name = "computecpp"
    version = "0.8.0"
    url = "https://codeplay.com/"
    description = "A heterogeneous parallel programming platform that provides a beta pre-conformant implementantion of SYCL 1.2.1 Khronos specification"
    license="proprietary"
    generators = "virtualenv"
    no_copy_source = True
    exports_sources = "cmake/*", "ComputeCpp-CE-*.tar.gz"
    settings = {
        "os": ["Linux", "Windows"],
        "arch": ["x86_64", "armv7hf", "armv8"]
    }
    source_name = ""
    source_tarball = ""
    source_unpacked_name = ""

    def configure(self):
        if self.settings.os == "Windows":
            distribution = "Windows.7"
        elif self.settings.os == "Linux":
            if tools.os_info.linux_distro == "ubuntu":
                name = "Ubuntu"
                version = tools.os_info.os_version if tools.os_info.os_version in [
                    "14.04", "16.04"
                ] else "16.04"
                distribution = "%s.%s" % (name, version)
                unpacked_distribution = distribution = "%s-%s" % (name,
                                                                  version)
            elif tools.os_info.linux_distro == "centos":
                name = "CentOS"
                distribution = name
            else:
                self.output.warn("You are using an unsupported distribution. Reverting to the Ubuntu 16.04 package...")
                distribution = "Ubuntu.16.04"
                unpacked_distribution = "Ubuntu-16.04"

        if self.settings.arch == "x86_64":
            arch = "64bit"
            unpacked_architecture = "x86_64"
        elif self.settings.arch.startswith("armv8"):
            arch = "arm64"
            unpacked_architecture = "ARM_64"
        elif self.settings.arch.startswith("arm"):
            arch = "arm32"
            unpacked_architecture = "ARM_32"

        self.source_name = "ComputeCpp-CE-%s-%s-%s" % (self.version,
                                                       distribution, arch)
        self.source_tarball = self.source_name + ".tar.gz"
        self.source_unpacked_name = "ComputeCpp-CE-%s-%s-%s" % (
            self.version, unpacked_distribution, unpacked_architecture)

        self.output.info("Distribution: " + distribution)
        self.output.info("Target architecture: " + arch)
        self.output.info("Expected tarball name: " + self.source_tarball)
        if not os.path.isfile(self.source_tarball):
            error_msg = self.source_tarball + " not found. Please ensure you downloaded the appropriate package for your operating system from https://developer.codeplay.com"
            self.output.error(error_msg)
            raise OSError(error_msg)

    def package(self):
        archive = os.path.join(self.source_folder, self.source_tarball)
        cmake = os.path.join(self.source_folder, "cmake")
        tools.untargz(archive)
        self.copy("*", src=self.source_unpacked_name)
        self.copy("*", src=cmake, dst="share/cmake/ComputeCpp")

    def package_info(self):
        if self.settings.os == "Linux":
            self.cpp_info.libs = ["libComputeCpp.so"]
        elif self.settings.os == "Windows":
            self.cpp_info.libs = ["ComputeCpp-vs2015.lib"]

        self.env_info.PATH.append(os.path.join(self.package_folder, "bin"))
        self.user_info.ComputeCpp_DIR = self.package_folder

    def package_id(self):
        self.info.settings.source = self.source_tarball