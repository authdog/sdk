find_package(GTest REQUIRED)

add_executable(authdog_tests
    test_authdog_client.cpp
)

target_link_libraries(authdog_tests
    authdog_cpp_sdk
    GTest::gtest
    GTest::gtest_main
)

include(GoogleTest)
gtest_discover_tests(authdog_tests)
