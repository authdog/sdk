#!/bin/bash

# Authdog C++ SDK Dependencies Installer
# This script installs the required dependencies for building and testing the C++ SDK

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Function to detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt-get &> /dev/null; then
            echo "ubuntu"
        elif command -v yum &> /dev/null; then
            echo "rhel"
        elif command -v pacman &> /dev/null; then
            echo "arch"
        else
            echo "linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        echo "windows"
    else
        echo "unknown"
    fi
}

# Function to install dependencies on Ubuntu/Debian
install_ubuntu() {
    print_status "Installing dependencies on Ubuntu/Debian..."
    
    sudo apt-get update
    sudo apt-get install -y \
        build-essential \
        cmake \
        ninja-build \
        pkg-config \
        libcurl4-openssl-dev \
        libssl-dev \
        git \
        wget \
        curl
    
    # Install optional dependencies
    if [ "$1" = "--full" ]; then
        sudo apt-get install -y \
            libgtest-dev \
            valgrind \
            gcovr \
            lcov \
            clang-format \
            clang-tidy \
            cppcheck \
            doxygen \
            graphviz \
            libgoogle-perftools-dev
    fi
    
    print_success "Dependencies installed successfully"
}

# Function to install dependencies on RHEL/CentOS/Fedora
install_rhel() {
    print_status "Installing dependencies on RHEL/CentOS/Fedora..."
    
    if command -v dnf &> /dev/null; then
        PKG_MGR="dnf"
    else
        PKG_MGR="yum"
    fi
    
    sudo $PKG_MGR update -y
    sudo $PKG_MGR install -y \
        gcc-c++ \
        cmake \
        ninja-build \
        pkgconfig \
        libcurl-devel \
        openssl-devel \
        git \
        wget \
        curl
    
    # Install optional dependencies
    if [ "$1" = "--full" ]; then
        sudo $PKG_MGR install -y \
            gtest-devel \
            valgrind \
            gcovr \
            lcov \
            clang-tools-extra \
            cppcheck \
            doxygen \
            graphviz \
            gperftools-devel
    fi
    
    print_success "Dependencies installed successfully"
}

# Function to install dependencies on Arch Linux
install_arch() {
    print_status "Installing dependencies on Arch Linux..."
    
    sudo pacman -S --needed \
        base-devel \
        cmake \
        ninja \
        pkg-config \
        curl \
        openssl \
        git \
        wget
    
    # Install optional dependencies
    if [ "$1" = "--full" ]; then
        sudo pacman -S --needed \
            gtest \
            valgrind \
            gcovr \
            lcov \
            clang \
            clang-tools-extra \
            cppcheck \
            doxygen \
            graphviz \
            gperftools
    fi
    
    print_success "Dependencies installed successfully"
}

# Function to install dependencies on macOS
install_macos() {
    print_status "Installing dependencies on macOS..."
    
    # Check if Homebrew is installed
    if ! command -v brew &> /dev/null; then
        print_error "Homebrew is not installed. Please install Homebrew first:"
        print_error "https://brew.sh/"
        exit 1
    fi
    
    brew update
    brew install \
        cmake \
        ninja \
        pkg-config \
        curl \
        openssl \
        git
    
    # Install optional dependencies
    if [ "$1" = "--full" ]; then
        brew install \
            googletest \
            valgrind \
            gcovr \
            lcov \
            clang-format \
            clang-tidy \
            cppcheck \
            doxygen \
            graphviz \
            gperftools
    fi
    
    print_success "Dependencies installed successfully"
}

# Function to install dependencies on Windows
install_windows() {
    print_status "Installing dependencies on Windows..."
    
    # Check if Chocolatey is installed
    if ! command -v choco &> /dev/null; then
        print_error "Chocolatey is not installed. Please install Chocolatey first:"
        print_error "https://chocolatey.org/install"
        exit 1
    fi
    
    choco install -y \
        cmake \
        ninja \
        pkgconfiglite \
        curl \
        openssl \
        git
    
    # Install optional dependencies
    if [ "$1" = "--full" ]; then
        choco install -y \
            vcpkg \
            visualstudio2022-workload-nativedesktop \
            visualstudio2022-workload-nativedesktop \
            doxygen.install \
            graphviz
    fi
    
    print_success "Dependencies installed successfully"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --full              Install all dependencies including optional ones"
    echo "  --help              Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                 # Install basic dependencies"
    echo "  $0 --full          # Install all dependencies"
}

# Main function
main() {
    local install_full=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --full)
                install_full=true
                shift
                ;;
            --help)
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
    
    print_status "Detecting operating system..."
    local os=$(detect_os)
    print_status "Detected OS: $os"
    
    case $os in
        ubuntu)
            if [ "$install_full" = true ]; then
                install_ubuntu --full
            else
                install_ubuntu
            fi
            ;;
        rhel)
            if [ "$install_full" = true ]; then
                install_rhel --full
            else
                install_rhel
            fi
            ;;
        arch)
            if [ "$install_full" = true ]; then
                install_arch --full
            else
                install_arch
            fi
            ;;
        macos)
            if [ "$install_full" = true ]; then
                install_macos --full
            else
                install_macos
            fi
            ;;
        windows)
            if [ "$install_full" = true ]; then
                install_windows --full
            else
                install_windows
            fi
            ;;
        *)
            print_error "Unsupported operating system: $os"
            print_error "Please install dependencies manually:"
            print_error "  - CMake 3.16+"
            print_error "  - C++17 compiler (GCC, Clang, or MSVC)"
            print_error "  - Git"
            print_error "  - pkg-config"
            exit 1
            ;;
    esac
    
    print_success "All dependencies installed successfully!"
    print_status "You can now build the C++ SDK with:"
    print_status "  cd cpp && cmake -B build && cmake --build build"
}

# Run main function
main "$@"
