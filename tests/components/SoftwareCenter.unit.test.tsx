import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { SoftwareCenter } from '../../src/components/ui/SoftwareCenter';
import { packageService } from '../../src/services/packageService';
import { act } from 'react';

// Mock the packageService methods
jest.mock('../../src/services/packageService');

describe('SoftwareCenter Unit Tests', () => {
  beforeEach(() => {
    jest.clearAllMocks();

    (packageService.syncRepository as jest.Mock).mockResolvedValue(undefined);
    (packageService.searchPackages as jest.Mock).mockResolvedValue([
      {
        name: 'test-package',
        version: '1.0.0',
        description: 'Test package description',
        size: '1MB',
        installed: false,
        updateAvailable: false,
        dependencies: [],
        category: 'Utilities',
        maintainer: 'Test Maintainer',
      }
    ]);
    (packageService.getInstalledPackages as jest.Mock).mockResolvedValue([]);
    (packageService.installPackage as jest.Mock).mockResolvedValue(undefined);
    (packageService.removePackage as jest.Mock).mockResolvedValue(undefined);
    (packageService.updatePackage as jest.Mock).mockResolvedValue(undefined);
    (packageService.addListener as jest.Mock).mockImplementation(() => () => {});
  });

  it('renders SoftwareCenter component', async () => {
    await act(async () => {
      render(<SoftwareCenter />);
    });
    expect(screen.getByText('Software Center')).toBeInTheDocument();
  });

  it('displays package list', async () => {
    await act(async () => {
      render(<SoftwareCenter />);
    });
    expect(await screen.findByText('test-package')).toBeInTheDocument();
  });

  it('installs a package', async () => {
    await act(async () => {
      render(<SoftwareCenter />);
    });
    const installButton = screen.getByText('Install');
    fireEvent.click(installButton);

    await waitFor(() => {
      expect(packageService.installPackage).toHaveBeenCalledWith('test-package');
    });
  });

  it('removes a package', async () => {
    (packageService.getInstalledPackages as jest.Mock).mockResolvedValue([
      {
        name: 'test-package',
        version: '1.0.0',
        description: 'Test package description',
        size: '1MB',
        installed: true,
        updateAvailable: false,
        dependencies: [],
        category: 'Utilities',
        maintainer: 'Test Maintainer',
      }
    ]);
    await act(async () => {
      render(<SoftwareCenter />);
    });
    const removeButton = screen.getByText('Remove');
    fireEvent.click(removeButton);

    await waitFor(() => {
      expect(packageService.removePackage).toHaveBeenCalledWith('test-package');
    });
  });

  it('updates a package', async () => {
    (packageService.searchPackages as jest.Mock).mockResolvedValue([
      {
        name: 'test-package',
        version: '1.1.0',
        description: 'Test package description',
        size: '1MB',
        installed: true,
        updateAvailable: true,
        dependencies: [],
        category: 'Utilities',
        maintainer: 'Test Maintainer',
      }
    ]);
    await act(async () => {
      render(<SoftwareCenter />);
    });
    const updateButton = screen.getByText('Update');
    fireEvent.click(updateButton);

    await waitFor(() => {
      expect(packageService.updatePackage).toHaveBeenCalledWith('test-package');
    });
  });
});
