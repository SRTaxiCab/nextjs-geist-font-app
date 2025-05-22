import '@testing-library/jest-dom';

// Mock the next/navigation hooks
jest.mock('next/navigation', () => ({
  useRouter() {
    return {
      push: jest.fn(),
      replace: jest.fn(),
      prefetch: jest.fn()
    };
  },
  usePathname() {
    return '';
  }
}));
