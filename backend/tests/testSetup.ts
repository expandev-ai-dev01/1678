/**
 * @summary Global test setup configuration
 * @module testSetup
 */

import dotenv from 'dotenv';

/**
 * @summary Load test environment variables
 */
dotenv.config({ path: '.env.test' });

/**
 * @summary Global test timeout
 */
jest.setTimeout(30000);

/**
 * @summary Setup before all tests
 */
beforeAll(async () => {
  console.log('Test environment initialized');
});

/**
 * @summary Cleanup after all tests
 */
afterAll(async () => {
  console.log('Test environment cleanup completed');
});
