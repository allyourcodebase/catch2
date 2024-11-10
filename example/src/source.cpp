#include "header.hpp"

auto fibonacci(uint8_t n, uintmax_t f0, uintmax_t f1) -> uintmax_t
{
	switch (n) {
	case 0: return f0;
	case 1: return f1;
	}
	return fibonacci(n-1, f1, f0 + f1);
}
