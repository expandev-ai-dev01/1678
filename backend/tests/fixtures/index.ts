/**
 * @summary Test data fixtures
 * @module fixtures
 */

/**
 * @summary Sample account fixture
 */
export const mockAccount = {
  idAccount: 1,
  name: 'Test Account',
  active: 1,
};

/**
 * @summary Sample user fixture
 */
export const mockUser = {
  idUser: 1,
  idAccount: 1,
  name: 'Test User',
  email: 'test@example.com',
};

export default {
  mockAccount,
  mockUser,
};
