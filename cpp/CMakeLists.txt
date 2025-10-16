cmake_minimum_required(VERSION 3.16)
project(AuthdogCppSdk VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Find required packages
find_package(nlohmann_json REQUIRED)
find_package(cpr REQUIRED)
find_package(Threads REQUIRED)

# Include directories
include_directories(include)

# Source files
set(SOURCES
    src/authdog_client.cpp
    src/exceptions.cpp
)

# Header files
set(HEADERS
    include/authdog/authdog_client.h
    include/authdog/exceptions.h
    include/authdog/types.h
)

# Create library
add_library(authdog_cpp_sdk STATIC ${SOURCES} ${HEADERS})

# Link libraries
target_link_libraries(authdog_cpp_sdk 
    nlohmann_json::nlohmann_json
    cpr::cpr
    Threads::Threads
)

# Set include directories for the target
target_include_directories(authdog_cpp_sdk PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
)

# Compiler-specific options
target_compile_options(authdog_cpp_sdk PRIVATE
    $<$<CXX_COMPILER_ID:GNU>:-Wall -Wextra -Wpedantic>
    $<$<CXX_COMPILER_ID:Clang>:-Wall -Wextra -Wpedantic>
    $<$<CXX_COMPILER_ID:MSVC>:/W4>
)

# Install targets
install(TARGETS authdog_cpp_sdk
    EXPORT AuthdogCppSdkTargets
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
    INCLUDES DESTINATION include
)

install(FILES ${HEADERS}
    DESTINATION include/authdog
)

# Create example executable
add_executable(authdog_example examples/main.cpp)
target_link_libraries(authdog_example authdog_cpp_sdk)

# Tests
enable_testing()
add_subdirectory(tests)

# Package configuration
include(CMakePackageConfigHelpers)
write_basic_package_version_file(
    AuthdogCppSdkConfigVersion.cmake
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY AnyNewerVersion
)

configure_package_config_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/AuthdogCppSdkConfig.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/AuthdogCppSdkConfig.cmake
    INSTALL_DESTINATION lib/cmake/AuthdogCppSdk
)

install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/AuthdogCppSdkConfig.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/AuthdogCppSdkConfigVersion.cmake
    DESTINATION lib/cmake/AuthdogCppSdk
)

install(EXPORT AuthdogCppSdkTargets
    FILE AuthdogCppSdkTargets.cmake
    NAMESPACE Authdog::
    DESTINATION lib/cmake/AuthdogCppSdk
)
