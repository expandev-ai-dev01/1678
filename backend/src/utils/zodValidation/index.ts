import { z } from 'zod';

/**
 * @summary Common Zod validation schemas
 * @module zodValidation
 */

/**
 * @summary String validation with max length
 */
export const zString = z.string().min(1);

/**
 * @summary Nullable string validation
 */
export const zNullableString = (maxLength?: number) => {
  let schema = z.string();
  if (maxLength) {
    schema = schema.max(maxLength);
  }
  return schema.nullable();
};

/**
 * @summary Name validation (1-200 characters)
 */
export const zName = z.string().min(1).max(200);

/**
 * @summary Description validation (max 500 characters)
 */
export const zNullableDescription = z.string().max(500).nullable();

/**
 * @summary Foreign key validation
 */
export const zFK = z.number().int().positive();

/**
 * @summary Nullable foreign key validation
 */
export const zNullableFK = z.number().int().positive().nullable();

/**
 * @summary Bit/Boolean validation
 */
export const zBit = z.union([z.literal(0), z.literal(1)]);

/**
 * @summary Date string validation
 */
export const zDateString = z.string().datetime();

/**
 * @summary Email validation
 */
export const zEmail = z.string().email();

/**
 * @summary Nullable email validation
 */
export const zNullableEmail = z.string().email().nullable();

export default {
  zString,
  zNullableString,
  zName,
  zNullableDescription,
  zFK,
  zNullableFK,
  zBit,
  zDateString,
  zEmail,
  zNullableEmail,
};
