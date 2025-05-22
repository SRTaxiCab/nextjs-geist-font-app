# AI Operating System - API Reference

## Table of Contents
1. [Security Service](#security-service)
2. [Update Service](#update-service)
3. [Demo Service](#demo-service)
4. [Secure Boot Service](#secure-boot-service)
5. [Image Signing Service](#image-signing-service)
6. [Package Service](#package-service)

## Security Service
`securityService` provides methods for managing system security features.

### Methods

#### getDiskEncryptionStatus
```typescript
async getDiskEncryptionStatus(): Promise<DiskEncryptionStatus[]>
```
Returns the encryption status of all storage devices.

#### enableDiskEncryption
```typescript
async enableDiskEncryption(device: string, password: string): Promise<void>
```
Enables encryption on the specified device.

#### disableDiskEncryption
```typescript
async disableDiskEncryption(device: string): Promise<void>
```
Disables encryption on the specified device.

#### getFirewallStatus
```typescript
async getFirewallStatus(): Promise<boolean>
```
Returns the current firewall status.

#### getFirewallRules
```typescript
async getFirewallRules(): Promise<FirewallRule[]>
```
Returns all configured firewall rules.

#### enableFirewall
```typescript
async enableFirewall(): Promise<void>
```
Enables the system firewall.

#### disableFirewall
```typescript
async disableFirewall(): Promise<void>
```
Disables the system firewall.

## Update Service
`updateService` handles system updates and version management.

### Methods

#### checkForUpdates
```typescript
async checkForUpdates(): Promise<UpdateInfo | null>
```
Checks for available system updates.

#### downloadUpdates
```typescript
async downloadUpdates(): Promise<void>
```
Downloads available updates.

#### installUpdates
```typescript
async installUpdates(): Promise<void>
```
Installs downloaded updates.

#### getAutoUpdateStatus
```typescript
async getAutoUpdateStatus(): Promise<boolean>
```
Returns the automatic update configuration status.

#### enableAutoUpdates
```typescript
async enableAutoUpdates(): Promise<void>
```
Enables automatic system updates.

#### disableAutoUpdates
```typescript
async disableAutoUpdates(): Promise<void>
```
Disables automatic system updates.

## Demo Service
`demoService` manages the live demo environment.

### Methods

#### startDemo
```typescript
async startDemo(options: DemoOptions): Promise<void>
```
Starts a new demo session with specified options.

#### stopDemo
```typescript
async stopDemo(): Promise<void>
```
Stops the current demo session.

#### getDemoStatus
```typescript
async getDemoStatus(): Promise<DemoStatus>
```
Returns the current demo session status.

#### resetEnvironment
```typescript
async resetEnvironment(): Promise<void>
```
Resets the demo environment to its initial state.

## Secure Boot Service
`secureBootService` manages system secure boot functionality.

### Methods

#### getStatus
```typescript
async getStatus(): Promise<SecureBootStatus>
```
Returns the current secure boot status.

#### generateKeys
```typescript
async generateKeys(): Promise<void>
```
Generates new secure boot keys.

#### enrollKeys
```typescript
async enrollKeys(): Promise<void>
```
Enrolls generated keys in the system.

#### signKernel
```typescript
async signKernel(): Promise<void>
```
Signs the system kernel with enrolled keys.

#### updateBootloader
```typescript
async updateBootloader(): Promise<void>
```
Updates and signs the bootloader.

#### verifySecureBoot
```typescript
async verifySecureBoot(): Promise<boolean>
```
Verifies secure boot configuration.

## Image Signing Service
`imageSigningService` handles system image signing and verification.

### Methods

#### generateSigningKeys
```typescript
async generateSigningKeys(): Promise<void>
```
Generates new image signing keys.

#### signImage
```typescript
async signImage(imagePath: string): Promise<SignatureInfo>
```
Signs a system image.

#### verifyImage
```typescript
async verifyImage(imagePath: string): Promise<boolean>
```
Verifies an image's signature.

#### listImages
```typescript
async listImages(): Promise<ImageInfo[]>
```
Lists all available system images.

#### backupKeys
```typescript
async backupKeys(backupPath: string): Promise<void>
```
Backs up signing keys.

#### importSigningKey
```typescript
async importSigningKey(keyPath: string, isPrivate: boolean): Promise<void>
```
Imports a signing key.

## Package Service
`packageService` manages system packages and software.

### Methods

#### searchPackages
```typescript
async searchPackages(query: string): Promise<PackageInfo[]>
```
Searches for packages matching the query.

#### getPackageInfo
```typescript
async getPackageInfo(packageName: string): Promise<PackageInfo>
```
Returns detailed information about a package.

#### installPackage
```typescript
async installPackage(packageName: string): Promise<void>
```
Installs a package.

#### removePackage
```typescript
async removePackage(packageName: string): Promise<void>
```
Removes an installed package.

#### updatePackage
```typescript
async updatePackage(packageName: string): Promise<void>
```
Updates a specific package.

#### getInstalledPackages
```typescript
async getInstalledPackages(): Promise<PackageInfo[]>
```
Lists all installed packages.

#### syncRepository
```typescript
async syncRepository(): Promise<void>
```
Synchronizes the package repository.

### Event Listeners

All services that support progress tracking provide a listener interface:

```typescript
addListener(listener: (progress: Progress) => void): () => void
```

Example usage:
```typescript
const removeListener = packageService.addListener((progress) => {
  console.log(`Progress: ${progress.status} - ${progress.progress}%`);
});

// Later, when done:
removeListener();
```

## Type Definitions

### Common Types

```typescript
interface Progress {
  status: 'idle' | 'downloading' | 'installing' | 'removing' | 'updating' | 'error';
  progress: number;
  currentPackage?: string;
  error?: string;
}

interface NotificationProps {
  id: string;
  type: 'info' | 'success' | 'warning' | 'error';
  title: string;
  message: string;
  duration?: number;
}
```

For detailed type definitions of other interfaces, refer to the respective service implementation files.
