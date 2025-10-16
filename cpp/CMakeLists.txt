cmake_minimum_required(VERSION 3.16)
project(AuthdogCppSdk VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Build options
option(AUTHDOG_BUILD_TESTS "Build tests" ON)
option(AUTHDOG_BUILD_EXAMPLES "Build examples" ON)
option(AUTHDOG_BUILD_DOCS "Build documentation" OFF)
option(AUTHDOG_ENABLE_COVERAGE "Enable coverage reporting" OFF)
option(AUTHDOG_ENABLE_SANITIZERS "Enable sanitizers" OFF)
option(AUTHDOG_ENABLE_PROFILING "Enable profiling" OFF)
option(AUTHDOG_ENABLE_VALGRIND "Enable Valgrind support" OFF)

# Find required packages
find_package(Threads REQUIRED)

# Fetch nlohmann_json if not found
find_package(nlohmann_json QUIET)
if(NOT nlohmann_json_FOUND)
    include(FetchContent)
    FetchContent_Declare(
        nlohmann_json
        GIT_REPOSITORY https://github.com/nlohmann/json.git
        GIT_TAG v3.11.2
    )
    FetchContent_MakeAvailable(nlohmann_json)
endif()

# Fetch CPR if not found
find_package(cpr QUIET)
if(NOT cpr_FOUND)
    include(FetchContent)
    FetchContent_Declare(
        cpr
        GIT_REPOSITORY https://github.com/libcpr/cpr.git
        GIT_TAG 1.10.4
    )
    FetchContent_MakeAvailable(cpr)
endif()

# Find optional packages
if(AUTHDOG_BUILD_TESTS)
    find_package(GTest QUIET)
    if(NOT GTest_FOUND)
        include(FetchContent)
        FetchContent_Declare(
            googletest
            GIT_REPOSITORY https://github.com/google/googletest.git
            GIT_TAG v1.14.0
        )
        FetchContent_MakeAvailable(googletest)
    endif()
endif()

if(AUTHDOG_BUILD_DOCS)
    find_package(Doxygen REQUIRED)
endif()

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

# Coverage options
if(AUTHDOG_ENABLE_COVERAGE)
    target_compile_options(authdog_cpp_sdk PRIVATE --coverage)
    target_link_options(authdog_cpp_sdk PRIVATE --coverage)
endif()

# Sanitizer options
if(AUTHDOG_ENABLE_SANITIZERS)
    target_compile_options(authdog_cpp_sdk PRIVATE
        -fsanitize=address
        -fsanitize=undefined
        -fsanitize=leak
        -fno-omit-frame-pointer
    )
    target_link_options(authdog_cpp_sdk PRIVATE
        -fsanitize=address
        -fsanitize=undefined
        -fsanitize=leak
    )
endif()

# Profiling options
if(AUTHDOG_ENABLE_PROFILING)
    target_compile_options(authdog_cpp_sdk PRIVATE -pg)
    target_link_options(authdog_cpp_sdk PRIVATE -pg)
endif()

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
if(AUTHDOG_BUILD_EXAMPLES)
    add_executable(authdog_example examples/main.cpp)
    target_link_libraries(authdog_example authdog_cpp_sdk)
endif()

# Tests
if(AUTHDOG_BUILD_TESTS)
    enable_testing()
    add_subdirectory(tests)
endif()

# Documentation
if(AUTHDOG_BUILD_DOCS)
    set(DOXYGEN_IN ${CMAKE_CURRENT_SOURCE_DIR}/Doxyfile.in)
    set(DOXYGEN_OUT ${CMAKE_CURRENT_BINARY_DIR}/Doxyfile)
    
    configure_file(${DOXYGEN_IN} ${DOXYGEN_OUT} @ONLY)
    
    add_custom_target(docs
        COMMAND ${DOXYGEN_EXECUTABLE} ${DOXYGEN_OUT}
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        COMMENT "Generating API documentation with Doxygen"
        VERBATIM
    )
    
    install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/docs/
        DESTINATION docs
    )
endif()

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
