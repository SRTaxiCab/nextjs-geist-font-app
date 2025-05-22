#!/bin/bash

# Source configuration
source "$(dirname "$0")/config.sh"

# Log file
LOG_FILE="$BUILD_ROOT/build.log"

# Logging function
log() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $1" | tee -a "$LOG_FILE"
}

# Error handling
handle_error() {
    log "ERROR: Build failed at stage: $1"
    log "Check $LOG_FILE for details"
    exit 1
}

# Function to download and verify source packages
download_sources() {
    log "Downloading source packages..."
    
    cd "$SOURCES_DIR" || handle_error "Cannot access sources directory"
    
    # Download Linux kernel
    log "Downloading Linux kernel ${LINUX_VERSION}..."
    wget "https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-${LINUX_VERSION}.tar.xz" || handle_error "kernel download"
    
    # Download GNU toolchain
    log "Downloading GNU toolchain..."
    wget "https://ftp.gnu.org/gnu/gcc/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.xz" || handle_error "gcc download"
    wget "https://ftp.gnu.org/gnu/glibc/glibc-${GLIBC_VERSION}.tar.xz" || handle_error "glibc download"
    wget "https://ftp.gnu.org/gnu/binutils/binutils-${BINUTILS_VERSION}.tar.xz" || handle_error "binutils download"
    
    # Download BusyBox
    log "Downloading BusyBox ${BUSYBOX_VERSION}..."
    wget "https://busybox.net/downloads/busybox-${BUSYBOX_VERSION}.tar.bz2" || handle_error "busybox download"
    
    # Verify downloads
    log "Verifying downloads..."
    for file in *.tar.*; do
        if ! tar tf "$file" >/dev/null 2>&1; then
            handle_error "verification of $file"
        fi
    done
}

# Function to prepare toolchain
build_toolchain() {
    log "Building toolchain..."
    
    cd "$TOOLS_DIR" || handle_error "Cannot access tools directory"
    
    # Build binutils first
    log "Building binutils..."
    tar xf "$SOURCES_DIR/binutils-${BINUTILS_VERSION}.tar.xz"
    cd "binutils-${BINUTILS_VERSION}"
    ./configure --prefix="$TOOLS_DIR" --target=x86_64-aios-linux-gnu || handle_error "binutils configure"
    make -j$(nproc) || handle_error "binutils make"
    make install || handle_error "binutils install"
    cd ..
    
    # Build GCC
    log "Building GCC..."
    tar xf "$SOURCES_DIR/gcc-${GCC_VERSION}.tar.xz"
    cd "gcc-${GCC_VERSION}"
    ./configure --prefix="$TOOLS_DIR" --target=x86_64-aios-linux-gnu --enable-languages=c,c++ || handle_error "gcc configure"
    make -j$(nproc) || handle_error "gcc make"
    make install || handle_error "gcc install"
    cd ..
}

# Function to build the kernel
build_kernel() {
    log "Building Linux kernel..."
    
    cd "$SOURCES_DIR" || handle_error "Cannot access sources directory"
    tar xf "linux-${LINUX_VERSION}.tar.xz"
    cd "linux-${LINUX_VERSION}"
    
    # Apply custom kernel configuration if exists
    if [ -f "$CUSTOM_KERNEL_CONFIG" ]; then
        cp "$CUSTOM_KERNEL_CONFIG" .config
    else
        # Generate default config optimized for our needs
        make defconfig
        # Enable required features
        scripts/config --enable MODULES
        scripts/config --enable INTEL_IDLE
        scripts/config --enable CPU_FREQ
        scripts/config --enable NUMA
        scripts/config --enable HIGH_RES_TIMERS
        scripts/config --enable AI_ACCELERATOR
    fi
    
    # Build kernel
    make -j$(nproc) || handle_error "kernel build"
    make modules_install INSTALL_MOD_PATH="$BUILD_DIR" || handle_error "kernel modules install"
    make install INSTALL_PATH="$BUILD_DIR/boot" || handle_error "kernel install"
}

# Function to build base system
build_base_system() {
    log "Building base system..."
    
    # Build and install glibc
    cd "$SOURCES_DIR"
    tar xf "glibc-${GLIBC_VERSION}.tar.xz"
    cd "glibc-${GLIBC_VERSION}"
    mkdir build && cd build
    ../configure --prefix=/usr --host=x86_64-aios-linux-gnu || handle_error "glibc configure"
    make -j$(nproc) || handle_error "glibc make"
    make install DESTDIR="$BUILD_DIR" || handle_error "glibc install"
    
    # Build and install BusyBox
    cd "$SOURCES_DIR"
    tar xf "busybox-${BUSYBOX_VERSION}.tar.bz2"
    cd "busybox-${BUSYBOX_VERSION}"
    make defconfig
    # Configure BusyBox for static linking
    sed -i 's/# CONFIG_STATIC is not set/CONFIG_STATIC=y/' .config
    make -j$(nproc) || handle_error "busybox make"
    make install CONFIG_PREFIX="$BUILD_DIR" || handle_error "busybox install"
}

# Function to set up the root filesystem
setup_rootfs() {
    log "Setting up root filesystem..."
    
    # Create essential directories
    mkdir -p "$BUILD_DIR"/{dev,proc,sys,run,tmp}
    chmod 1777 "$BUILD_DIR/tmp"
    
    # Create essential device nodes
    mknod -m 600 "$BUILD_DIR/dev/console" c 5 1
    mknod -m 666 "$BUILD_DIR/dev/null" c 1 3
    mknod -m 666 "$BUILD_DIR/dev/zero" c 1 5
    mknod -m 666 "$BUILD_DIR/dev/random" c 1 8
    mknod -m 666 "$BUILD_DIR/dev/urandom" c 1 9
    
    # Set up basic configuration
    mkdir -p "$BUILD_DIR/etc"
    echo "AI OS" > "$BUILD_DIR/etc/hostname"
    
    # Create basic fstab
    cat > "$BUILD_DIR/etc/fstab" << "EOF"
# <file system> <mount point>   <type>  <options>       <dump>  <pass>
/dev/root       /               ext4    defaults        1       1
proc            /proc           proc    defaults        0       0
sysfs           /sys            sysfs   defaults        0       0
devpts          /dev/pts        devpts  gid=5,mode=620  0       0
tmpfs           /run            tmpfs   defaults        0       0
EOF
}

# Function to install AI components
install_ai_components() {
    log "Installing AI components..."
    
    # Create AI components directory
    mkdir -p "$BUILD_DIR/opt/ai"
    
    # Install TensorFlow
    log "Installing TensorFlow ${TENSORFLOW_VERSION}..."
    # TODO: Add TensorFlow installation
    
    # Install PyTorch
    log "Installing PyTorch ${PYTORCH_VERSION}..."
    # TODO: Add PyTorch installation
    
    # Install CUDA drivers if needed
    if [ "$ENABLE_GPU" = true ]; then
        log "Installing CUDA ${CUDA_VERSION}..."
        # TODO: Add CUDA installation
    fi
}

# Function to create bootable image
create_bootable_image() {
    log "Creating bootable image..."
    
    local image_size="16G"  # 16GB image size
    local image_file="$BUILD_ROOT/aios.img"
    
    # Create empty image file
    dd if=/dev/zero of="$image_file" bs=1G count=16
    
    # Create partition table
    parted -s "$image_file" mklabel gpt
    parted -s "$image_file" mkpart primary fat32 1MiB 513MiB  # EFI partition
    parted -s "$image_file" mkpart primary ext4 513MiB 100%   # Root partition
    parted -s "$image_file" set 1 esp on
    
    # Set up loop device
    local loop_device=$(losetup -f --show "$image_file")
    
    # Format partitions
    mkfs.fat -F32 "${loop_device}p1"
    mkfs.ext4 "${loop_device}p2"
    
    # Mount and copy system
    mkdir -p "$BUILD_ROOT/mnt"
    mount "${loop_device}p2" "$BUILD_ROOT/mnt"
    cp -a "$BUILD_DIR"/* "$BUILD_ROOT/mnt"
    
    # Install bootloader
    mkdir -p "$BUILD_ROOT/mnt/boot/efi"
    mount "${loop_device}p1" "$BUILD_ROOT/mnt/boot/efi"
    grub-install --target=x86_64-efi --efi-directory="$BUILD_ROOT/mnt/boot/efi" --bootloader-id=AIOS --removable "$loop_device"
    
    # Clean up
    umount "$BUILD_ROOT/mnt/boot/efi"
    umount "$BUILD_ROOT/mnt"
    losetup -d "$loop_device"
    
    log "Bootable image created: $image_file"
}

# Main build process
main() {
    log "Starting AI OS build process..."
    
    # Initialize build environment
    init_build || handle_error "initialization"
    
    # Build steps
    download_sources || handle_error "downloading sources"
    build_toolchain || handle_error "building toolchain"
    build_kernel || handle_error "building kernel"
    build_base_system || handle_error "building base system"
    setup_rootfs || handle_error "setting up root filesystem"
    install_ai_components || handle_error "installing AI components"
    create_bootable_image || handle_error "creating bootable image"
    
    log "Build completed successfully!"
    log "Image available at: $BUILD_ROOT/aios.img"
}

# Execute main function
main "$@"
