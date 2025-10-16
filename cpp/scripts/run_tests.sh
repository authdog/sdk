#!/bin/bash

# Authdog C++ SDK Test Runner
# This script provides a comprehensive test suite for the C++ SDK

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
BUILD_TYPE="Release"
BUILD_DIR="build"
ENABLE_COVERAGE=false
ENABLE_SANITIZERS=false
ENABLE_VALGRIND=false
ENABLE_PROFILING=false
VERBOSE=false
PARALLEL_JOBS=$(nproc)

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -t, --type TYPE          Build type (Debug, Release, RelWithDebInfo) [default: Release]"
    echo "  -d, --dir DIR            Build directory [default: build]"
    echo "  -c, --coverage           Enable coverage reporting"
    echo "  -s, --sanitizers         Enable sanitizers (Address, Undefined, Leak)"
    echo "  -v, --valgrind           Enable Valgrind memory checking"
    echo "  -p, --profiling          Enable profiling"
    echo "  -j, --jobs JOBS          Number of parallel jobs [default: $(nproc)]"
    echo "  --verbose                Verbose output"
    echo "  -h, --help               Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                       # Basic test run"
    echo "  $0 -t Debug -c          # Debug build with coverage"
    echo "  $0 -s -v                # With sanitizers and Valgrind"
    echo "  $0 -p --verbose          # With profiling and verbose output"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--type)
            BUILD_TYPE="$2"
            shift 2
            ;;
        -d|--dir)
            BUILD_DIR="$2"
            shift 2
            ;;
        -c|--coverage)
            ENABLE_COVERAGE=true
            shift
            ;;
        -s|--sanitizers)
            ENABLE_SANITIZERS=true
            shift
            ;;
        -v|--valgrind)
            ENABLE_VALGRIND=true
            shift
            ;;
        -p|--profiling)
            ENABLE_PROFILING=true
            shift
            ;;
        -j|--jobs)
            PARALLEL_JOBS="$2"
            shift 2
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Validate build type
case $BUILD_TYPE in
    Debug|Release|RelWithDebInfo)
        ;;
    *)
        print_error "Invalid build type: $BUILD_TYPE"
        exit 1
        ;;
esac

# Check dependencies
check_dependencies() {
    print_status "Checking dependencies..."
    
    local missing_deps=()
    
    if ! command -v cmake &> /dev/null; then
        missing_deps+=("cmake")
    fi
    
    if ! command -v make &> /dev/null && ! command -v ninja &> /dev/null; then
        missing_deps+=("make or ninja")
    fi
    
    if ! command -v g++ &> /dev/null && ! command -v clang++ &> /dev/null; then
        missing_deps+=("g++ or clang++")
    fi
    
    if [ "$ENABLE_VALGRIND" = true ] && ! command -v valgrind &> /dev/null; then
        missing_deps+=("valgrind")
    fi
    
    if [ "$ENABLE_COVERAGE" = true ] && ! command -v gcov &> /dev/null; then
        missing_deps+=("gcov")
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_error "Missing dependencies: ${missing_deps[*]}"
        print_error "Please install the missing dependencies and try again."
        exit 1
    fi
    
    print_success "All dependencies found"
}

# Configure CMake
configure_cmake() {
    print_status "Configuring CMake..."
    
    local cmake_args=(
        "-B" "$BUILD_DIR"
        "-DCMAKE_BUILD_TYPE=$BUILD_TYPE"
        "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON"
        "-DAUTHDOG_BUILD_TESTS=ON"
        "-DAUTHDOG_BUILD_EXAMPLES=ON"
    )
    
    if [ "$ENABLE_COVERAGE" = true ]; then
        cmake_args+=("-DAUTHDOG_ENABLE_COVERAGE=ON")
    fi
    
    if [ "$ENABLE_SANITIZERS" = true ]; then
        cmake_args+=("-DAUTHDOG_ENABLE_SANITIZERS=ON")
    fi
    
    if [ "$ENABLE_VALGRIND" = true ]; then
        cmake_args+=("-DAUTHDOG_ENABLE_VALGRIND=ON")
    fi
    
    if [ "$ENABLE_PROFILING" = true ]; then
        cmake_args+=("-DAUTHDOG_ENABLE_PROFILING=ON")
    fi
    
    if [ "$VERBOSE" = true ]; then
        cmake_args+=("-DCMAKE_VERBOSE_MAKEFILE=ON")
    fi
    
    cmake "${cmake_args[@]}"
    
    print_success "CMake configuration complete"
}

# Build the project
build_project() {
    print_status "Building project..."
    
    local build_args=(
        "--build" "$BUILD_DIR"
        "--config" "$BUILD_TYPE"
        "--parallel" "$PARALLEL_JOBS"
    )
    
    if [ "$VERBOSE" = true ]; then
        build_args+=("--verbose")
    fi
    
    cmake "${build_args[@]}"
    
    print_success "Build complete"
}

# Run tests
run_tests() {
    print_status "Running tests..."
    
    local test_args=(
        "--test-dir" "$BUILD_DIR"
        "--output-on-failure"
        "--timeout" "300"
        "--parallel" "$PARALLEL_JOBS"
    )
    
    if [ "$VERBOSE" = true ]; then
        test_args+=("--verbose")
    fi
    
    ctest "${test_args[@]}"
    
    print_success "Tests completed"
}

# Run tests with Valgrind
run_valgrind_tests() {
    if [ "$ENABLE_VALGRIND" = true ]; then
        print_status "Running tests with Valgrind..."
        
        local valgrind_args=(
            "--test-dir" "$BUILD_DIR"
            "--output-on-failure"
            "--timeout" "600"
            "--test-command" "valgrind"
            "--test-args" "--leak-check=full --error-exitcode=1 --track-origins=yes"
        )
        
        if [ "$VERBOSE" = true ]; then
            valgrind_args+=("--verbose")
        fi
        
        ctest "${valgrind_args[@]}"
        
        print_success "Valgrind tests completed"
    fi
}

# Generate coverage report
generate_coverage() {
    if [ "$ENABLE_COVERAGE" = true ]; then
        print_status "Generating coverage report..."
        
        # Run tests to generate coverage data
        ctest --test-dir "$BUILD_DIR" --output-on-failure
        
        # Generate coverage report
        if command -v gcovr &> /dev/null; then
            gcovr --root . \
                --filter "src/.*" \
                --exclude "tests/.*" \
                --exclude "examples/.*" \
                --html \
                --html-details \
                --output "$BUILD_DIR/coverage.html" \
                --xml \
                --xml-pretty \
                --output "$BUILD_DIR/coverage.xml"
            
            print_success "Coverage report generated: $BUILD_DIR/coverage.html"
        else
            print_warning "gcovr not found, skipping coverage report generation"
        fi
    fi
}

# Run performance tests
run_performance_tests() {
    print_status "Running performance tests..."
    
    local perf_args=(
        "--test-dir" "$BUILD_DIR"
        "--output-on-failure"
        "--timeout" "600"
        "--parallel" "$PARALLEL_JOBS"
        "--test-command" "perf"
        "--test-args" "stat -e cycles,instructions,cache-misses,branch-misses"
    )
    
    if [ "$VERBOSE" = true ]; then
        perf_args+=("--verbose")
    fi
    
    ctest "${perf_args[@]}"
    
    print_success "Performance tests completed"
}

# Main execution
main() {
    print_status "Starting Authdog C++ SDK test suite"
    print_status "Build type: $BUILD_TYPE"
    print_status "Build directory: $BUILD_DIR"
    print_status "Parallel jobs: $PARALLEL_JOBS"
    print_status "Coverage: $ENABLE_COVERAGE"
    print_status "Sanitizers: $ENABLE_SANITIZERS"
    print_status "Valgrind: $ENABLE_VALGRIND"
    print_status "Profiling: $ENABLE_PROFILING"
    print_status "Verbose: $VERBOSE"
    echo ""
    
    check_dependencies
    configure_cmake
    build_project
    run_tests
    run_valgrind_tests
    generate_coverage
    
    if [ "$ENABLE_PROFILING" = true ]; then
        run_performance_tests
    fi
    
    print_success "All tests completed successfully!"
}

# Run main function
main "$@"
