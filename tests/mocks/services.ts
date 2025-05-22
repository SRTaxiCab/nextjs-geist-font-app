export const securityService = {
  getDiskEncryptionStatus: jest.fn(),
  getFirewallStatus: jest.fn(),
  getFirewallRules: jest.fn(),
  enableDiskEncryption: jest.fn(),
  disableDiskEncryption: jest.fn(),
  enableFirewall: jest.fn(),
  disableFirewall: jest.fn(),
  getSecureBootStatus: jest.fn()
};

export const secureBootService = {
  getStatus: jest.fn(),
  generateKeys: jest.fn()
};

export const imageSigningService = {
  listImages: jest.fn(),
  signImage: jest.fn()
};
