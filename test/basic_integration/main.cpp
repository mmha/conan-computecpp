#include <CL/sycl.hpp>

int main() {
	cl::sycl::queue queue;
	queue.submit([](cl::sycl::handler &cgh) {
		cl::sycl::stream os(1024, 80, cgh);
		cgh.single_task<class hello_world>([=] { os << "Hello, World!\n"; });
	});
}