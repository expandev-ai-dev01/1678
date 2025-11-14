/**
 * @summary Test helper functions
 * @module helpers
 */

/**
 * @summary Generate random string
 */
export function generateRandomString(length: number = 10): string {
  const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  let result = '';
  for (let i = 0; i < length; i++) {
    result += characters.charAt(Math.floor(Math.random() * characters.length));
  }
  return result;
}

/**
 * @summary Generate random number
 */
export function generateRandomNumber(min: number = 1, max: number = 1000): number {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

/**
 * @summary Wait for specified milliseconds
 */
export function wait(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

export default {
  generateRandomString,
  generateRandomNumber,
  wait,
};
