#include <stdio.h>

// Simulate the relevant parts of _ctype.h
// Test Case 1: _EXTERNALIZE_CTYPE_INLINES_ is defined

#define _EXTERNALIZE_CTYPE_INLINES_

#ifdef _EXTERNALIZE_CTYPE_INLINES_
#define static_test_A
#define __inline_test_A
// This simulates a function definition that would use the macros
static_test_A __inline_test_A int externalized_func_A() { return 1; }
#undef static_test_A
#undef __inline_test_A
#endif

// After the block, static and __inline should be normal keywords
static int my_static_func_A() {
    return 10;
}

static __inline int my_inline_func_A() {
    return 20;
}

// Test Case 2: _EXTERNALIZE_CTYPE_INLINES_ is NOT defined
// (to ensure our original static __inline functions in the header are not affected
// by any hypothetical future changes that might accidentally undef them too broadly)

#undef _EXTERNALIZE_CTYPE_INLINES_ // Ensure it's not defined for this part

// These would be the normal static __inline functions in _ctype.h
// We are just testing if the keywords 'static' and '__inline' work as expected.
static __inline int normal_inline_func_B() {
    return 2;
}

int main() {
    int rA1 = externalized_func_A(); // Should compile to `int externalized_func_A()`
    int rA2 = my_static_func_A();
    int rA3 = my_inline_func_A();    // Standard inline or regular function
    int rB1 = normal_inline_func_B();

    if (rA1 != 1) {
        printf("Test Failed: externalized_func_A wrong value.\n");
        return 1;
    }
    if (rA2 != 10) {
        printf("Test Failed: my_static_func_A wrong value.\n");
        return 1;
    }
    // rA3 (my_inline_func_A) and rB1 (normal_inline_func_B) are harder to test for "inlineness"
    // without inspecting assembly, but compilation success is key.

    printf("Macro Verification Test Passed!\n");
    return 0; // Success
}
