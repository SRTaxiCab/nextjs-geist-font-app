#!/bin/bash

# AI OS Build Configuration

# System Information
export AIOS_VERSION="1.0.0"
export AIOS_NAME="AI Operating System"
export AIOS_CODENAME="Genesis"

# Build Environment
export BUILD_ROOT="/mnt/aios"
export SOURCES_DIR="$BUILD_ROOT/sources"
export TOOLS_DIR="$BUILD_ROOT/tools"
export BUILD_DIR="$BUILD_ROOT/build"

# System Requirements
export MIN_RAM="8192" # 8GB in MB
export MIN_CPU="Intel i5"
export MIN_DISK="16384" # 16GB in MB

# Core Packages Versions
export LINUX_VERSION="6.1.0"    # Latest stable kernel
export GLIBC_VERSION="2.37"     # GNU C Library
export GCC_VERSION="13.2.0"     # GNU Compiler Collection
export BINUTILS_VERSION="2.41"  # Binary Utilities
export BUSYBOX_VERSION="1.36.1" # Basic Unix utilities

# AI Components
export TENSORFLOW_VERSION="2.14.0"
export PYTORCH_VERSION="2.1.0"
export CUDA_VERSION="12.2"

# Build Options
export ENABLE_GUI=true
export ENABLE_NETWORKING=true
export ENABLE_BLUETOOTH=true
export ENABLE_WIFI=true

# Bootloader Configuration
export BOOTLOADER="grub"
export BOOT_TIMEOUT=5
export ENABLE_LIVE_USB=true

# Custom Kernel Configuration
export CUSTOM_KERNEL_CONFIG="config/kernel.config"

# Function to verify system requirements
check_requirements() {
    echo "Checking build system requirements..."
    
    # Check RAM
    local total_ram=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    if [ $total_ram -lt $MIN_RAM ]; then
        echo "Error: Insufficient RAM. Required: ${MIN_RAM}MB, Available: ${total_ram}KB"
        return 1
    fi
    
    # Check CPU
    if ! grep -q "$MIN_CPU" /proc/cpuinfo; then
        echo "Warning: CPU requirements not met. Required: $MIN_CPU"
    fi
    
    # Check disk space
    local available_space=$(df -BM "$BUILD_ROOT" | awk 'NR==2 {print $4}' | tr -d 'M')
    if [ $available_space -lt $MIN_DISK ]; then
        echo "Error: Insufficient disk space. Required: ${MIN_DISK}MB, Available: ${available_space}MB"
        return 1
    fi
    
    return 0
}

# Function to setup build directory structure
setup_build_env() {
    echo "Setting up build environment..."
    
    mkdir -p "$SOURCES_DIR"
    mkdir -p "$TOOLS_DIR"
    mkdir -p "$BUILD_DIR"
    mkdir -p "$BUILD_DIR/boot"
    mkdir -p "$BUILD_DIR/etc"
    mkdir -p "$BUILD_DIR/usr"
    mkdir -p "$BUILD_DIR/var"
    mkdir -p "$BUILD_DIR/opt"
    
    # Create version file
    echo "$AIOS_NAME $AIOS_VERSION ($AIOS_CODENAME)" > "$BUILD_DIR/etc/aios-release"
    
    return 0
}

# Main build initialization
init_build() {
    echo "Initializing $AIOS_NAME build system..."
    
    if ! check_requirements; then
        echo "Failed to meet system requirements"
        exit 1
    fi
    
    if ! setup_build_env; then
        echo "Failed to setup build environment"
        exit 1
    fi
    
    echo "Build system initialized successfully"
    return 0
}

# Execute initialization if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    init_build
fi
