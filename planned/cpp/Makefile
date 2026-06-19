# Authdog C++ SDK Makefile
# Provides convenient targets for building, testing, and development

.PHONY: all build test clean install docs coverage sanitizers valgrind help

# Default target
all: build test

# Build configuration
BUILD_TYPE ?= Release
BUILD_DIR ?= build
PARALLEL_JOBS ?= $(shell nproc)

# Build options
ENABLE_COVERAGE ?= OFF
ENABLE_SANITIZERS ?= OFF
ENABLE_VALGRIND ?= OFF
ENABLE_PROFILING ?= OFF
ENABLE_DOCS ?= OFF

# CMake configuration
CMAKE_ARGS = -B $(BUILD_DIR) \
	-DCMAKE_BUILD_TYPE=$(BUILD_TYPE) \
	-DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
	-DAUTHDOG_BUILD_TESTS=ON \
	-DAUTHDOG_BUILD_EXAMPLES=ON \
	-DAUTHDOG_ENABLE_COVERAGE=$(ENABLE_COVERAGE) \
	-DAUTHDOG_ENABLE_SANITIZERS=$(ENABLE_SANITIZERS) \
	-DAUTHDOG_ENABLE_VALGRIND=$(ENABLE_VALGRIND) \
	-DAUTHDOG_ENABLE_PROFILING=$(ENABLE_PROFILING) \
	-DAUTHDOG_BUILD_DOCS=$(ENABLE_DOCS)

# Build targets
configure:
	@echo "Configuring CMake..."
	cmake $(CMAKE_ARGS)

build: configure
	@echo "Building project..."
	cmake --build $(BUILD_DIR) --config $(BUILD_TYPE) --parallel $(PARALLEL_JOBS)

# Test targets
test: build
	@echo "Running tests..."
	ctest --test-dir $(BUILD_DIR) --output-on-failure --timeout 300 --parallel $(PARALLEL_JOBS)

test-verbose: build
	@echo "Running tests with verbose output..."
	ctest --test-dir $(BUILD_DIR) --output-on-failure --timeout 300 --parallel $(PARALLEL_JOBS) --verbose

test-valgrind: build
	@echo "Running tests with Valgrind..."
	ctest --test-dir $(BUILD_DIR) --output-on-failure --timeout 600 --test-command valgrind --test-args "--leak-check=full --error-exitcode=1 --track-origins=yes"

test-performance: build
	@echo "Running performance tests..."
	ctest --test-dir $(BUILD_DIR) --output-on-failure --timeout 600 --parallel $(PARALLEL_JOBS) --test-command perf --test-args "stat -e cycles,instructions,cache-misses,branch-misses"

# Coverage targets
coverage: ENABLE_COVERAGE=ON
coverage: build
	@echo "Generating coverage report..."
	ctest --test-dir $(BUILD_DIR) --output-on-failure
	@if command -v gcovr >/dev/null 2>&1; then \
		gcovr --root . \
			--filter "src/.*" \
			--exclude "tests/.*" \
			--exclude "examples/.*" \
			--html \
			--html-details \
			--output $(BUILD_DIR)/coverage.html \
			--xml \
			--xml-pretty \
			--output $(BUILD_DIR)/coverage.xml; \
		echo "Coverage report generated: $(BUILD_DIR)/coverage.html"; \
	else \
		echo "gcovr not found, skipping coverage report generation"; \
	fi

# Sanitizer targets
sanitizers: ENABLE_SANITIZERS=ON
sanitizers: build test

# Valgrind targets
valgrind: ENABLE_VALGRIND=ON
valgrind: build test-valgrind

# Profiling targets
profiling: ENABLE_PROFILING=ON
profiling: build test-performance

# Documentation targets
docs: ENABLE_DOCS=ON
docs: build
	@echo "Generating documentation..."
	cmake --build $(BUILD_DIR) --target docs

# Debug build
debug: BUILD_TYPE=Debug
debug: build test

# Release build
release: BUILD_TYPE=Release
release: build test

# Development build with all features
dev: ENABLE_COVERAGE=ON
dev: ENABLE_SANITIZERS=ON
dev: ENABLE_VALGRIND=ON
dev: ENABLE_PROFILING=ON
dev: ENABLE_DOCS=ON
dev: BUILD_TYPE=Debug
dev: build test

# CI build
ci: ENABLE_COVERAGE=ON
ci: ENABLE_SANITIZERS=ON
ci: ENABLE_VALGRIND=ON
ci: BUILD_TYPE=Release
ci: build test

# Install target
install: build
	@echo "Installing SDK..."
	cmake --install $(BUILD_DIR)

# Clean targets
clean:
	@echo "Cleaning build directory..."
	rm -rf $(BUILD_DIR)

clean-all: clean
	@echo "Cleaning all generated files..."
	rm -rf $(BUILD_DIR)
	rm -f compile_commands.json
	rm -rf docs/

# Linting targets
lint:
	@echo "Running clang-format check..."
	@find src include examples tests -name "*.cpp" -o -name "*.h" | xargs clang-format --dry-run --Werror

format:
	@echo "Formatting code with clang-format..."
	@find src include examples tests -name "*.cpp" -o -name "*.h" | xargs clang-format -i

# Static analysis targets
analyze:
	@echo "Running static analysis..."
	@if command -v cppcheck >/dev/null 2>&1; then \
		cppcheck --enable=all --inconclusive --std=c++17 \
			--suppress=missingIncludeSystem \
			--suppress=unusedFunction \
			--suppress=unmatchedSuppression \
			src/ include/ examples/ tests/; \
	else \
		echo "cppcheck not found, skipping static analysis"; \
	fi

# Dependencies target
deps:
	@echo "Installing dependencies..."
	@./scripts/install_deps.sh

deps-full:
	@echo "Installing all dependencies..."
	@./scripts/install_deps.sh --full

# Help target
help:
	@echo "Authdog C++ SDK Makefile"
	@echo ""
	@echo "Available targets:"
	@echo "  all              - Build and test (default)"
	@echo "  build            - Build the project"
	@echo "  test             - Run tests"
	@echo "  test-verbose     - Run tests with verbose output"
	@echo "  test-valgrind    - Run tests with Valgrind"
	@echo "  test-performance - Run performance tests"
	@echo "  coverage         - Generate coverage report"
	@echo "  sanitizers       - Build and test with sanitizers"
	@echo "  valgrind         - Build and test with Valgrind"
	@echo "  profiling        - Build and test with profiling"
	@echo "  docs             - Generate documentation"
	@echo "  debug            - Debug build and test"
	@echo "  release          - Release build and test"
	@echo "  dev              - Development build with all features"
	@echo "  ci               - CI build with coverage and sanitizers"
	@echo "  install          - Install the SDK"
	@echo "  clean            - Clean build directory"
	@echo "  clean-all        - Clean all generated files"
	@echo "  lint             - Run clang-format check"
	@echo "  format           - Format code with clang-format"
	@echo "  analyze          - Run static analysis"
	@echo "  deps             - Install basic dependencies"
	@echo "  deps-full        - Install all dependencies"
	@echo "  help             - Show this help message"
	@echo ""
	@echo "Environment variables:"
	@echo "  BUILD_TYPE       - Build type (Debug, Release) [default: Release]"
	@echo "  BUILD_DIR        - Build directory [default: build]"
	@echo "  PARALLEL_JOBS    - Number of parallel jobs [default: \$(nproc)]"
	@echo ""
	@echo "Examples:"
	@echo "  make                    # Basic build and test"
	@echo "  make debug             # Debug build"
	@echo "  make coverage          # Build with coverage"
	@echo "  make sanitizers        # Build with sanitizers"
	@echo "  make dev               # Development build"
	@echo "  make ci                # CI build"
	@echo "  BUILD_TYPE=Debug make  # Custom build type"
