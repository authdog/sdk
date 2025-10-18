# Create test executable
add_executable(authdog_tests
    test_authdog_client.cpp
)

# Link with GTest targets (using FetchContent from main CMakeLists.txt)
target_link_libraries(authdog_tests
    authdog_cpp_sdk
    gtest
    gtest_main
)

# Enable GoogleTest discovery
include(GoogleTest)
gtest_discover_tests(authdog_tests
    PROPERTIES
        TIMEOUT 300
)
