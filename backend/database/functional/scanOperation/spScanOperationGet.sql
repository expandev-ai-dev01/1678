/**
 * @summary
 * Retrieves scan operation details and statistics.
 * 
 * @procedure spScanOperationGet
 * @schema functional
 * @type stored-procedure
 * 
 * @endpoints
 * - GET /api/v1/internal/scan-operation/:id
 * 
 * @parameters
 * @param {INT} idAccount
 *   - Required: Yes
 *   - Description: Account identifier
 * 
 * @param {INT} idOperation
 *   - Required: Yes
 *   - Description: Operation identifier
 * 
 * @testScenarios
 * - Valid operation retrieval
 * - Operation not found
 * - Security validation
 */
CREATE OR ALTER PROCEDURE [functional].[spScanOperationGet]
  @idAccount INTEGER,
  @idOperation INTEGER
AS
BEGIN
  SET NOCOUNT ON;

  /**
   * @validation Operation existence validation
   * @throw {operationDoesntExist}
   */
  IF NOT EXISTS (
    SELECT * FROM [functional].[scanOperation] scnOpr
    WHERE scnOpr.[idOperation] = @idOperation
      AND scnOpr.[idAccount] = @idAccount
  )
  BEGIN
    ;THROW 51000, 'operationDoesntExist', 1;
  END;

  /**
   * @output {OperationData, 1, n}
   * @column {INT} idOperation
   * @column {INT} idConfiguration
   * @column {NVARCHAR} directoryPath
   * @column {INT} status
   * @column {INT} totalFiles
   * @column {INT} identifiedFiles
   * @column {BIGINT} potentialSpace
   * @column {INT} progress
   * @column {DATETIME2} dateStarted
   * @column {DATETIME2} dateCompleted
   */
  SELECT
    scnOpr.[idOperation],
    scnOpr.[idConfiguration],
    scnOpr.[directoryPath],
    scnOpr.[status],
    scnOpr.[totalFiles],
    scnOpr.[identifiedFiles],
    scnOpr.[potentialSpace],
    scnOpr.[progress],
    scnOpr.[dateStarted],
    scnOpr.[dateCompleted]
  FROM [functional].[scanOperation] scnOpr
  WHERE scnOpr.[idOperation] = @idOperation
    AND scnOpr.[idAccount] = @idAccount;
END;
GO
