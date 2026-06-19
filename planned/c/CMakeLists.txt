cmake_minimum_required(VERSION 3.10)
project(authdog_c_sdk VERSION 0.1.0 LANGUAGES C)

# Set C standard
set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)

# Find required packages
find_package(PkgConfig REQUIRED)
pkg_check_modules(CURL REQUIRED libcurl)

# Include directories
include_directories(include)

# Create the library
add_library(authdog_c_sdk STATIC
    src/authdog.c
)

# Link libraries
target_link_libraries(authdog_c_sdk ${CURL_LIBRARIES})
target_include_directories(authdog_c_sdk PUBLIC include)

# Add compiler flags
target_compile_options(authdog_c_sdk PRIVATE ${CURL_CFLAGS_OTHER})

# Create tests executable
add_executable(test_authdog
    tests/test_authdog.c
)

# Link test executable with library
target_link_libraries(test_authdog authdog_c_sdk)

# Enable testing
enable_testing()
add_test(NAME authdog_tests COMMAND test_authdog)

# Create example executable
add_executable(example
    examples/main.c
)

# Link example executable with library
target_link_libraries(example authdog_c_sdk)

# Installation
install(TARGETS authdog_c_sdk
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin
)

install(FILES include/authdog.h
    DESTINATION include
)

# Package configuration
set(CPACK_PACKAGE_NAME "authdog-c-sdk")
set(CPACK_PACKAGE_VERSION "0.1.0")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Authdog C SDK")
set(CPACK_PACKAGE_VENDOR "Authdog")

include(CPack)
