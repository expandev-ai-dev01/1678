import { Request, Response, NextFunction } from 'express';

/**
 * @summary Error response interface
 */
export interface ErrorResponse {
  success: false;
  error: {
    code: string;
    message: string;
    details?: any;
  };
  timestamp: string;
}

/**
 * @summary Global error handling middleware
 * @description Catches and formats all errors in the application
 */
export function errorMiddleware(error: any, req: Request, res: Response, next: NextFunction): void {
  const statusCode = error.statusCode || 500;
  const errorCode = error.code || 'INTERNAL_SERVER_ERROR';
  const message = error.message || 'An unexpected error occurred';

  const errorResponse: ErrorResponse = {
    success: false,
    error: {
      code: errorCode,
      message: message,
      details: process.env.NODE_ENV === 'development' ? error.stack : undefined,
    },
    timestamp: new Date().toISOString(),
  };

  console.error('Error:', {
    code: errorCode,
    message: message,
    path: req.path,
    method: req.method,
    stack: error.stack,
  });

  res.status(statusCode).json(errorResponse);
}

export default errorMiddleware;
