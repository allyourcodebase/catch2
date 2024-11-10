#include <demo/header.hpp>

#include <catch2/catch_test_macros.hpp>

TEST_CASE("Fibonacci")
{
	CHECK(fibonacci(7) == 13);
	CHECK(fibonacci(6, 1, 1) == 13);
	CHECK(fibonacci(5, 1, 2) == 13);

	CHECK(fibonacci(4, 5, 10) == 40);
}
