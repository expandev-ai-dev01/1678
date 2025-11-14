import { Request } from 'express';
import { z } from 'zod';

/**
 * @summary CRUD operation types
 */
export type CrudOperation = 'CREATE' | 'READ' | 'UPDATE' | 'DELETE';

/**
 * @summary Security configuration for CRUD operations
 */
export interface SecurityConfig {
  securable: string;
  permission: CrudOperation;
}

/**
 * @summary Validated request data
 */
export interface ValidatedRequest {
  credential: {
    idAccount: number;
    idUser: number;
  };
  params: any;
}

/**
 * @summary CRUD Controller for handling common operations
 */
export class CrudController {
  private securityConfig: SecurityConfig[];

  constructor(securityConfig: SecurityConfig[]) {
    this.securityConfig = securityConfig;
  }

  /**
   * @summary Validate CREATE operation
   */
  async create(req: Request, schema: z.ZodSchema): Promise<[ValidatedRequest | null, any]> {
    return this.validateOperation(req, schema, 'CREATE');
  }

  /**
   * @summary Validate READ operation
   */
  async read(req: Request, schema: z.ZodSchema): Promise<[ValidatedRequest | null, any]> {
    return this.validateOperation(req, schema, 'READ');
  }

  /**
   * @summary Validate UPDATE operation
   */
  async update(req: Request, schema: z.ZodSchema): Promise<[ValidatedRequest | null, any]> {
    return this.validateOperation(req, schema, 'UPDATE');
  }

  /**
   * @summary Validate DELETE operation
   */
  async delete(req: Request, schema: z.ZodSchema): Promise<[ValidatedRequest | null, any]> {
    return this.validateOperation(req, schema, 'DELETE');
  }

  /**
   * @summary Internal validation logic
   */
  private async validateOperation(
    req: Request,
    schema: z.ZodSchema,
    operation: CrudOperation
  ): Promise<[ValidatedRequest | null, any]> {
    try {
      const params = await schema.parseAsync({ ...req.params, ...req.body, ...req.query });

      const validated: ValidatedRequest = {
        credential: {
          idAccount: 1,
          idUser: 1,
        },
        params,
      };

      return [validated, null];
    } catch (error) {
      return [null, error];
    }
  }
}

/**
 * @summary Success response helper
 */
export function successResponse<T>(data: T) {
  return {
    success: true,
    data,
    timestamp: new Date().toISOString(),
  };
}

/**
 * @summary Error response helper
 */
export function errorResponse(message: string, code?: string) {
  return {
    success: false,
    error: {
      code: code || 'VALIDATION_ERROR',
      message,
    },
    timestamp: new Date().toISOString(),
  };
}

/**
 * @summary General error constant
 */
export const StatusGeneralError = {
  statusCode: 500,
  code: 'INTERNAL_SERVER_ERROR',
  message: 'An unexpected error occurred',
};

export default CrudController;
