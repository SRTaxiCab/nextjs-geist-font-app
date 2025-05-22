# AI Operating System - Developer Guide

## Table of Contents
1. [Introduction](#introduction)
2. [Project Structure](#project-structure)
3. [Build System](#build-system)
4. [Component Architecture](#component-architecture)
5. [API Documentation](#api-documentation)
6. [Contributing Guidelines](#contributing-guidelines)
7. [Testing](#testing)
8. [Deployment](#deployment)
9. [Troubleshooting](#troubleshooting)

## Introduction
This guide provides developers with the necessary information to understand, contribute to, and maintain the AI Operating System project.

## Project Structure
- `src/`: Source code for UI components, services, and hooks
  - `components/ui/`: React components for the user interface
  - `services/`: Backend service modules for system features
  - `hooks/`: Custom React hooks
- `build-scripts/`: Scripts and configuration files for building and packaging
- `docs/`: Documentation files
- `public/`: Static assets
- `tests/`: Unit and integration tests

## Build System
- Uses shell scripts in `build-scripts/` for environment setup, building, and packaging
- Kernel configuration managed via `build-scripts/config/kernel.config`
- Build environment initialized with `init-build-env.sh`
- Build process started with `build.sh`
- System startup managed with `start.sh`

## Component Architecture
- UI built with React and Tailwind CSS
- Components organized by feature in `src/components/ui/`
- Shared components include buttons, cards, tabs, notifications, etc.
- State management primarily via React hooks (`useState`, `useEffect`, `useCallback`)
- Client components marked with `"use client";` directive
- Services provide backend logic and system interaction, accessed via React components

## API Documentation
- Services expose asynchronous methods for system operations
- Key services:
  - `securityService`: Disk encryption, firewall, secure boot status
  - `updateService`: System update checking, downloading, installation
  - `demoService`: Live demo mode management
  - `secureBootService`: Secure boot key management and signing
  - `imageSigningService`: Image signing and verification
  - `packageService`: Package management operations
- Services use Node.js child processes to execute system commands
- Notifications used for user feedback on service operations

## Contributing Guidelines
- Fork the repository and create feature branches
- Follow coding standards and best practices
- Write clear, concise commit messages
- Include tests for new features and bug fixes
- Submit pull requests with detailed descriptions
- Participate in code reviews and discussions

## Testing
- Unit tests for UI components and services
- Integration tests for system update and package management workflows
- System tests for boot process, performance, and hardware compatibility
- Tests located in the `tests/` directory
- Use testing frameworks such as Jest and React Testing Library

## Deployment
- Build the system using provided scripts
- Create bootable images with signed kernels and bootloaders
- Deploy to UEFI-capable hardware or virtual machines
- Configure Secure Boot and image signing as per documentation

## Troubleshooting
- Refer to system logs for errors
- Use recovery mode for boot issues
- Verify package signatures and update status
- Consult community forums and issue tracker

## Additional Resources
- [User Guide](./USER_GUIDE.md)
- [API Reference](./API_REFERENCE.md)
- [Community Forum](https://forum.example.com)
- [Issue Tracker](https://bugs.example.com)
