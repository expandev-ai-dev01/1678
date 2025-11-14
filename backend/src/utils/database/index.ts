import sql from 'mssql';
import { config } from '@/config';

/**
 * @summary Database connection pool
 */
let pool: sql.ConnectionPool | null = null;

/**
 * @summary Expected return types for database operations
 */
export enum ExpectedReturn {
  Single = 'single',
  Multi = 'multi',
  None = 'none',
}

/**
 * @summary Record set interface
 */
export interface IRecordSet<T = any> {
  recordset: T[];
  rowsAffected: number[];
}

/**
 * @summary Get database connection pool
 */
export async function getPool(): Promise<sql.ConnectionPool> {
  if (!pool) {
    pool = await sql.connect(config.database);
  }
  return pool;
}

/**
 * @summary Execute database request
 * @param routine Stored procedure name
 * @param parameters Input parameters
 * @param expectedReturn Expected return type
 * @param transaction Optional transaction
 * @param resultSetNames Optional result set names for multi-result queries
 */
export async function dbRequest(
  routine: string,
  parameters: any,
  expectedReturn: ExpectedReturn,
  transaction?: sql.Transaction,
  resultSetNames?: string[]
): Promise<any> {
  const currentPool = await getPool();
  const request = transaction ? new sql.Request(transaction) : currentPool.request();

  for (const [key, value] of Object.entries(parameters)) {
    request.input(key, value);
  }

  const result = await request.execute(routine);

  switch (expectedReturn) {
    case ExpectedReturn.Single:
      return result.recordset[0];
    case ExpectedReturn.Multi:
      if (resultSetNames && resultSetNames.length > 0) {
        const namedResults: { [key: string]: any } = {};
        resultSetNames.forEach((name, index) => {
          namedResults[name] = result.recordsets[index];
        });
        return namedResults;
      }
      return result.recordsets;
    case ExpectedReturn.None:
      return result.rowsAffected;
    default:
      return result;
  }
}

/**
 * @summary Begin database transaction
 */
export async function beginTransaction(): Promise<sql.Transaction> {
  const currentPool = await getPool();
  const transaction = new sql.Transaction(currentPool);
  await transaction.begin();
  return transaction;
}

/**
 * @summary Commit database transaction
 */
export async function commitTransaction(transaction: sql.Transaction): Promise<void> {
  await transaction.commit();
}

/**
 * @summary Rollback database transaction
 */
export async function rollbackTransaction(transaction: sql.Transaction): Promise<void> {
  await transaction.rollback();
}

/**
 * @summary Close database connection pool
 */
export async function closePool(): Promise<void> {
  if (pool) {
    await pool.close();
    pool = null;
  }
}

export default {
  getPool,
  dbRequest,
  beginTransaction,
  commitTransaction,
  rollbackTransaction,
  closePool,
  ExpectedReturn,
};
