#include <ctype.h> // This should include _ctype.h
#include <stdio.h>

// Test user-defined static function
static int my_static_func() {
    return 10;
}

// Test user-defined inline function
// Using __inline as that's what _ctype.h uses internally mostly
__inline int my_inline_func() {
    return 20;
}

// Ensure __inline is still usable if the compiler supports it,
// or at least doesn't conflict.
// Some compilers might need 'static __inline' for non-exported inline functions.
static __inline int my_static_inline_func() {
    return 30;
}

int main() {
    int result = 0;
    result += my_static_func();
    result += my_inline_func(); // May need to be static __inline for some compilers if not optimized out
    result += my_static_inline_func();

    // Call a function from ctype.h to ensure it's still working
    if (isalpha('a')) {
        result += 1;
    } else {
        result -= 100; // Should not happen
    }

    if (isspace(' ')) {
        result += 1;
    } else {
        result -= 100; // Should not happen
    }

    // Expected: 10 (my_static_func) + 20 (my_inline_func) + 30 (my_static_inline_func) + 1 (isalpha) + 1 (isspace) = 62
    printf("Result: %d\n", result);
    if (result == 62) {
        printf("Verification Test Passed (normal build)!\n");
        return 0; // Success
    } else {
        printf("Verification Test Failed (normal build)! Expected 62, Got %d\n", result);
        return 1; // Failure
    }
}
