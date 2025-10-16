# Find GTest (already fetched in main CMakeLists.txt)
find_package(GTest REQUIRED)

add_executable(authdog_tests
    test_authdog_client.cpp
)

# Link with GTest targets
if(TARGET GTest::gtest)
    target_link_libraries(authdog_tests
        authdog_cpp_sdk
        GTest::gtest
        GTest::gtest_main
    )
else()
    # Fallback for FetchContent
    target_link_libraries(authdog_tests
        authdog_cpp_sdk
        gtest
        gtest_main
    )
endif()

# Coverage options for tests
if(AUTHDOG_ENABLE_COVERAGE)
    target_compile_options(authdog_tests PRIVATE --coverage)
    target_link_options(authdog_tests PRIVATE --coverage)
endif()

# Sanitizer options for tests
if(AUTHDOG_ENABLE_SANITIZERS)
    target_compile_options(authdog_tests PRIVATE
        -fsanitize=address
        -fsanitize=undefined
        -fsanitize=leak
        -fno-omit-frame-pointer
    )
    target_link_options(authdog_tests PRIVATE
        -fsanitize=address
        -fsanitize=undefined
        -fsanitize=leak
    )
endif()

# Profiling options for tests
if(AUTHDOG_ENABLE_PROFILING)
    target_compile_options(authdog_tests PRIVATE -pg)
    target_link_options(authdog_tests PRIVATE -pg)
endif()

include(GoogleTest)
gtest_discover_tests(authdog_tests)

# Add custom test properties
set_tests_properties(authdog_tests PROPERTIES
    TIMEOUT 300
    LABELS "unit;integration"
)

# Valgrind support
if(AUTHDOG_ENABLE_VALGRIND)
    find_program(VALGRIND_EXECUTABLE valgrind)
    if(VALGRIND_EXECUTABLE)
        add_custom_target(valgrind_tests
            COMMAND ${VALGRIND_EXECUTABLE}
                --leak-check=full
                --error-exitcode=1
                --track-origins=yes
                $<TARGET_FILE:authdog_tests>
            DEPENDS authdog_tests
            COMMENT "Running tests with Valgrind"
        )
    endif()
endif()

# Performance tests
add_custom_target(performance_tests
    COMMAND ${CMAKE_CURRENT_BINARY_DIR}/authdog_tests
        --gtest_filter="*Performance*"
        --gtest_repeat=10
    DEPENDS authdog_tests
    COMMENT "Running performance tests"
)

# Memory tests
add_custom_target(memory_tests
    COMMAND ${CMAKE_CURRENT_BINARY_DIR}/authdog_tests
        --gtest_filter="*Memory*"
    DEPENDS authdog_tests
    COMMENT "Running memory tests"
)
