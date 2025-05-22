#!/bin/bash

# Source configuration
source "$(dirname "$0")/config.sh"

# Function to check if running as root
check_root() {
    if [ "$(id -u)" != "0" ]; then
        echo "Error: This script must be run as root"
        exit 1
    fi
}

# Function to install required packages
install_dependencies() {
    echo "Installing build dependencies..."
    
    # Update package lists
    apt-get update
    
    # Install essential build tools
    apt-get install -y \
        build-essential \
        bison \
        flex \
        libssl-dev \
        libelf-dev \
        bc \
        wget \
        git \
        cmake \
        python3 \
        python3-pip \
        parted \
        grub-efi \
        mtools \
        xorriso \
        debootstrap \
        squashfs-tools \
        dosfstools \
        qemu-system-x86 \
        qemu-utils
        
    # Install AI development tools
    apt-get install -y \
        nvidia-cuda-toolkit \
        nvidia-cuda-dev \
        python3-tensorflow \
        python3-torch
        
    # Install development libraries
    apt-get install -y \
        libncurses-dev \
        libglib2.0-dev \
        libpixman-1-dev \
        libfdt-dev \
        libgtk-3-dev \
        libaio-dev \
        libusb-1.0-0-dev
}

# Function to set up build directories
setup_directories() {
    echo "Setting up build directories..."
    
    # Create main build directory if it doesn't exist
    mkdir -p "$BUILD_ROOT"
    
    # Create required subdirectories
    mkdir -p "$SOURCES_DIR"
    mkdir -p "$TOOLS_DIR"
    mkdir -p "$BUILD_DIR"
    mkdir -p "$BUILD_DIR"/{boot,etc,usr,var,opt}
    
    # Set permissions
    chown -R $(whoami):$(whoami) "$BUILD_ROOT"
}

# Function to verify system requirements
verify_requirements() {
    echo "Verifying system requirements..."
    
    # Check RAM
    total_ram=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    if [ $total_ram -lt 16000000 ]; then  # 16GB in KB
        echo "Warning: Less than 16GB RAM available. Build might be slow."
    fi
    
    # Check disk space
    available_space=$(df -BG "$BUILD_ROOT" | awk 'NR==2 {print $4}' | tr -d 'G')
    if [ $available_space -lt 50 ]; then
        echo "Error: Insufficient disk space. At least 50GB required."
        exit 1
    fi
    
    # Check CPU cores
    cpu_cores=$(nproc)
    if [ $cpu_cores -lt 4 ]; then
        echo "Warning: Less than 4 CPU cores available. Build might be slow."
    fi
}

# Function to set up environment variables
setup_environment() {
    echo "Setting up build environment variables..."
    
    # Add tools directory to PATH
    export PATH="$TOOLS_DIR/bin:$PATH"
    
    # Set compiler flags
    export CFLAGS="-O2 -pipe"
    export CXXFLAGS="$CFLAGS"
    
    # Set make flags for parallel build
    export MAKEFLAGS="-j$(nproc)"
    
    # Save environment variables for future sessions
    cat > "$BUILD_ROOT/env.sh" << EOF
export PATH="$TOOLS_DIR/bin:\$PATH"
export CFLAGS="-O2 -pipe"
export CXXFLAGS="\$CFLAGS"
export MAKEFLAGS="-j\$(nproc)"
EOF
}

# Function to download source packages
download_sources() {
    echo "Downloading source packages..."
    cd "$SOURCES_DIR"
    
    # Download Linux kernel
    wget "https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-${LINUX_VERSION}.tar.xz"
    
    # Download GNU toolchain
    wget "https://ftp.gnu.org/gnu/gcc/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.xz"
    wget "https://ftp.gnu.org/gnu/glibc/glibc-${GLIBC_VERSION}.tar.xz"
    wget "https://ftp.gnu.org/gnu/binutils/binutils-${BINUTILS_VERSION}.tar.xz"
    
    # Download BusyBox
    wget "https://busybox.net/downloads/busybox-${BUSYBOX_VERSION}.tar.bz2"
    
    # Verify downloads
    echo "Verifying downloads..."
    for file in *.tar.*; do
        echo "Checking $file..."
        tar tf "$file" >/dev/null 2>&1 || {
            echo "Error: Failed to verify $file"
            exit 1
        }
    done
}

# Main function
main() {
    echo "Initializing build environment for AI OS..."
    
    # Check if running as root
    check_root
    
    # Run initialization steps
    verify_requirements
    install_dependencies
    setup_directories
    setup_environment
    download_sources
    
    echo "Build environment initialized successfully!"
    echo "To continue with the build process, run: ./build.sh"
}

# Execute main function
main "$@"
