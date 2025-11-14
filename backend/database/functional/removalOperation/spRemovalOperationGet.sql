/**
 * @summary
 * Retrieves removal operation details and statistics.
 * 
 * @procedure spRemovalOperationGet
 * @schema functional
 * @type stored-procedure
 * 
 * @endpoints
 * - GET /api/v1/internal/removal-operation/:id
 * 
 * @parameters
 * @param {INT} idAccount
 *   - Required: Yes
 *   - Description: Account identifier
 * 
 * @param {INT} idRemoval
 *   - Required: Yes
 *   - Description: Removal operation identifier
 * 
 * @testScenarios
 * - Valid operation retrieval
 * - Operation not found
 * - Security validation
 */
CREATE OR ALTER PROCEDURE [functional].[spRemovalOperationGet]
  @idAccount INTEGER,
  @idRemoval INTEGER
AS
BEGIN
  SET NOCOUNT ON;

  /**
   * @validation Removal operation existence validation
   * @throw {removalOperationDoesntExist}
   */
  IF NOT EXISTS (
    SELECT * FROM [functional].[removalOperation] rmvOpr
    WHERE rmvOpr.[idRemoval] = @idRemoval
      AND rmvOpr.[idAccount] = @idAccount
  )
  BEGIN
    ;THROW 51000, 'removalOperationDoesntExist', 1;
  END;

  /**
   * @output {RemovalData, 1, n}
   * @column {INT} idRemoval
   * @column {INT} idOperation
   * @column {INT} removalMode
   * @column {INT} status
   * @column {INT} progress
   * @column {INT} filesRemoved
   * @column {INT} filesWithError
   * @column {BIGINT} spaceFreed
   * @column {DATETIME2} dateStarted
   * @column {DATETIME2} dateCompleted
   */
  SELECT
    rmvOpr.[idRemoval],
    rmvOpr.[idOperation],
    rmvOpr.[removalMode],
    rmvOpr.[status],
    rmvOpr.[progress],
    rmvOpr.[filesRemoved],
    rmvOpr.[filesWithError],
    rmvOpr.[spaceFreed],
    rmvOpr.[dateStarted],
    rmvOpr.[dateCompleted]
  FROM [functional].[removalOperation] rmvOpr
  WHERE rmvOpr.[idRemoval] = @idRemoval
    AND rmvOpr.[idAccount] = @idAccount;
END;
GO
