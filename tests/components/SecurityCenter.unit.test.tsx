import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { SecurityCenter } from '../../src/components/ui/SecurityCenter';
import { securityService } from '../../src/services/securityService';
import { act } from 'react';

// Mock the securityService methods
jest.mock('../../src/services/securityService');

describe('SecurityCenter Unit Tests', () => {
  beforeEach(() => {
    jest.clearAllMocks();

    (securityService.getDiskEncryptionStatus as jest.Mock).mockResolvedValue([
      {
        device: '/dev/sda2',
        status: 'encrypted',
        algorithm: 'aes-256-xts',
        mountPoint: '/'
      }
    ]);
    (securityService.getFirewallStatus as jest.Mock).mockResolvedValue(true);
    (securityService.getFirewallRules as jest.Mock).mockResolvedValue([
      {
        chain: 'INPUT',
        protocol: 'tcp',
        port: 80,
        action: 'ACCEPT'
      }
    ]);
    (securityService.getSecureBootStatus as jest.Mock).mockResolvedValue(true);
    (securityService.enableDiskEncryption as jest.Mock).mockResolvedValue(undefined);
    (securityService.disableDiskEncryption as jest.Mock).mockResolvedValue(undefined);
    (securityService.enableFirewall as jest.Mock).mockResolvedValue(undefined);
    (securityService.disableFirewall as jest.Mock).mockResolvedValue(undefined);
  });

  it('renders SecurityCenter component', async () => {
    await act(async () => {
      render(<SecurityCenter />);
    });
    expect(screen.getByText('Security Center')).toBeInTheDocument();
  });

  it('displays disk encryption status correctly', async () => {
    await act(async () => {
      render(<SecurityCenter />);
    });
    const diskEncryptionText = await screen.findByText('Disk Encryption');
    expect(diskEncryptionText).toBeInTheDocument();
    expect(screen.getByText(/Encrypted devices: 1/i)).toBeInTheDocument();
  });

  it('toggles disk encryption on switch click', async () => {
    await act(async () => {
      render(<SecurityCenter />);
    });
    const switchElement = screen.getByLabelText('Disk encryption toggle');
    expect(switchElement).toBeInTheDocument();

    fireEvent.click(switchElement);

    await waitFor(() => {
      expect(securityService.disableDiskEncryption).toHaveBeenCalledWith('/dev/sda2');
    });
  });

  it('displays firewall status correctly', async () => {
    await act(async () => {
      render(<SecurityCenter />);
    });
    const firewallText = await screen.findByText('Firewall');
    expect(firewallText).toBeInTheDocument();
    expect(screen.getByText(/Active rules: 1/i)).toBeInTheDocument();
  });

  it('toggles firewall on switch click', async () => {
    await act(async () => {
      render(<SecurityCenter />);
    });
    const switchElement = screen.getByLabelText('Firewall toggle');
    expect(switchElement).toBeInTheDocument();

    fireEvent.click(switchElement);

    await waitFor(() => {
      expect(securityService.disableFirewall).toHaveBeenCalled();
    });
  });
});
