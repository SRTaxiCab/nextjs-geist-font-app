#!/bin/bash

# Make scripts executable
chmod +x init-build-env.sh build.sh

# Check if running as root
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root"
    echo "Please run: sudo $0"
    exit 1
fi

echo "=== AI Operating System Build System ==="
echo "Starting build process..."

# Initialize build environment
./init-build-env.sh || {
    echo "Failed to initialize build environment"
    exit 1
}

# Start the build process
./build.sh || {
    echo "Failed to build AI OS"
    exit 1
}

echo "Build process completed!"
echo "Your bootable AI OS image is available at: /mnt/aios/aios.img"
echo
echo "To create a bootable USB drive, use:"
echo "sudo dd if=/mnt/aios/aios.img of=/dev/sdX bs=4M status=progress"
echo "(Replace /dev/sdX with your USB device path)"
