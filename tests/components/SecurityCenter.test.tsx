import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { SecurityCenter } from '../../src/components/ui/SecurityCenter';
import { securityService } from '../../src/services/securityService';
import { act } from 'react';

// Mock the services
jest.mock('../../src/services/securityService');
jest.mock('../../src/services/secureBootService');
jest.mock('../../src/services/imageSigningService');

describe('SecurityCenter', () => {
  beforeEach(() => {
    jest.clearAllMocks();

    // Setup default mock implementations
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
  });

  it('renders without crashing', async () => {
    await act(async () => {
      render(<SecurityCenter />);
    });
    expect(screen.getByText('Security Center')).toBeInTheDocument();
  });

  it('displays disk encryption status', async () => {
    await act(async () => {
      render(<SecurityCenter />);
    });
    
    // Wait for the disk encryption section to appear
    const diskEncryptionText = await screen.findByText('Disk Encryption');
    expect(diskEncryptionText).toBeInTheDocument();

    // Wait for the device info to appear
    await waitFor(() => {
      const deviceText = screen.getByText((content) => content.includes('Device: /dev/sda2'));
      expect(deviceText).toBeInTheDocument();
    });

    // Check for algorithm info
    const algorithmText = await screen.findByText((content) => content.includes('Algorithm: aes-256-xts'));
    expect(algorithmText).toBeInTheDocument();
  });

  it('displays firewall status', async () => {
    await act(async () => {
      render(<SecurityCenter />);
    });
    
    // Wait for the firewall section to appear
    const firewallText = await screen.findByText('Firewall');
    expect(firewallText).toBeInTheDocument();

    // Wait for the rules info to appear
    await waitFor(() => {
      const rulesText = screen.getByText((content) => content.includes('ACCEPT TCP port 80'));
      expect(rulesText).toBeInTheDocument();
    });
  });

  it('handles disk encryption toggle', async () => {
    // Mock initial state as disabled
    (securityService.getDiskEncryptionStatus as jest.Mock).mockResolvedValue([
      { device: '/dev/sda2', status: 'decrypted', algorithm: 'none', mountPoint: '/' }
    ]);
    (securityService.enableDiskEncryption as jest.Mock).mockResolvedValue(undefined);
    
    await act(async () => {
      render(<SecurityCenter />);
    });

    // Wait for loading to complete and initial state to be set
    await waitFor(() => {
      const status = screen.getByText('Your disk is not encrypted');
      expect(status).toBeInTheDocument();
    });

    // Find and click the disk encryption switch
    const diskEncryptionSwitch = screen.getByRole('switch', { name: 'Disk encryption toggle' });
    expect(diskEncryptionSwitch).toBeInTheDocument();

    // Click the switch
    fireEvent.click(diskEncryptionSwitch);

    // Verify the service was called with correct parameters
    await waitFor(() => {
      expect(securityService.enableDiskEncryption).toHaveBeenCalledWith('/dev/sda2', 'temporary-password');
    });
  });

  it('handles firewall toggle', async () => {
    (securityService.disableFirewall as jest.Mock).mockResolvedValue(undefined);
    
    await act(async () => {
      render(<SecurityCenter />);
    });

    // Wait for loading to complete
    await waitFor(() => {
      expect(screen.queryByText('Loading...')).not.toBeInTheDocument();
    });

    // Find and click the firewall switch
    const firewallCard = screen.getByText('Firewall').closest('div');
    expect(firewallCard).toBeInTheDocument();

    const firewallSwitch = screen.getByRole('switch', { name: 'Firewall toggle' });
    expect(firewallSwitch).toBeInTheDocument();

    // Click the switch and wait for state updates
    await act(async () => {
      fireEvent.click(firewallSwitch);
      // Wait for the async operation to complete
      await Promise.resolve();
    });

    // Verify the service was called
    expect(securityService.disableFirewall).toHaveBeenCalled();
  });

  it('displays error notifications on failure', async () => {
    // Mock initial state as disabled
    (securityService.getDiskEncryptionStatus as jest.Mock).mockResolvedValue([
      { device: '/dev/sda2', status: 'decrypted', algorithm: 'none', mountPoint: '/' }
    ]);
    // Mock the service call to fail
    (securityService.enableDiskEncryption as jest.Mock).mockRejectedValue(new Error('Failed to enable encryption'));
    
    await act(async () => {
      render(<SecurityCenter />);
    });

    // Wait for initial load
    await waitFor(() => {
      const status = screen.getByText('Your disk is not encrypted');
      expect(status).toBeInTheDocument();
    });

    // Find and click the disk encryption switch
    const diskEncryptionSwitch = screen.getByRole('switch', { name: 'Disk encryption toggle' });
    fireEvent.click(diskEncryptionSwitch);

    // Wait for error notification to appear
    await waitFor(() => {
      // Check for both the error title and message
      expect(screen.getByRole('heading', { name: /disk encryption error/i })).toBeInTheDocument();
      expect(screen.getByText(/failed to modify disk encryption/i)).toBeInTheDocument();
    });
  });

  it('switches between tabs correctly', async () => {
    await act(async () => {
      render(<SecurityCenter />);
    });

    // Wait for loading to complete
    await waitFor(() => {
      expect(screen.queryByText('Loading...')).not.toBeInTheDocument();
    });

    // Get initial tab panel
    const initialPanel = screen.getByRole('tabpanel');
    expect(initialPanel).toHaveTextContent(/disk encryption/i);

    // Switch to Secure Boot tab
    const secureBootTab = screen.getByRole('tab', { name: /secure boot/i });
    fireEvent.click(secureBootTab);

    // Wait for Secure Boot panel to be visible with retry and delay
    await waitFor(async () => {
      const panel = screen.getByRole('tabpanel');
      expect(panel).toBeVisible();
      // Retry until 'secure boot' text appears or timeout
      if (!panel.textContent?.toLowerCase().includes('secure boot')) {
        // Wait a bit longer before retrying
        await new Promise(resolve => setTimeout(resolve, 500));
        throw new Error('Secure Boot content not loaded yet');
      }
    }, { timeout: 10000, interval: 200 });

    // Switch to Image Signing tab
    const imageSigningTab = screen.getByRole('tab', { name: /image signing/i });
    fireEvent.click(imageSigningTab);

    // Wait for Image Signing panel to be visible
    await waitFor(() => {
      const panel = screen.getByRole('tabpanel');
      expect(panel).toBeVisible();
      expect(panel.textContent?.toLowerCase()).not.toContain('disk encryption');
    });
  }, 20000);
});
