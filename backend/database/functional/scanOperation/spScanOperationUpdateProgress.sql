/**
 * @summary
 * Updates scan operation progress and statistics during file analysis.
 * 
 * @procedure spScanOperationUpdateProgress
 * @schema functional
 * @type stored-procedure
 * 
 * @endpoints
 * - PATCH /api/v1/internal/scan-operation/:id/progress
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
 * @param {INT} status
 *   - Required: Yes
 *   - Description: Operation status (0-3)
 * 
 * @param {INT} totalFiles
 *   - Required: Yes
 *   - Description: Total files analyzed
 * 
 * @param {INT} identifiedFiles
 *   - Required: Yes
 *   - Description: Files identified as temporary
 * 
 * @param {BIGINT} potentialSpace
 *   - Required: Yes
 *   - Description: Potential space to free in bytes
 * 
 * @param {INT} progress
 *   - Required: Yes
 *   - Description: Progress percentage (0-100)
 * 
 * @testScenarios
 * - Valid progress update
 * - Operation completion
 * - Error status handling
 */
CREATE OR ALTER PROCEDURE [functional].[spScanOperationUpdateProgress]
  @idAccount INTEGER,
  @idOperation INTEGER,
  @status INTEGER,
  @totalFiles INTEGER,
  @identifiedFiles INTEGER,
  @potentialSpace BIGINT,
  @progress INTEGER
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
   * @rule {fn-scan-operation-update} Update operation progress
   */
  UPDATE [functional].[scanOperation]
  SET
    [status] = @status,
    [totalFiles] = @totalFiles,
    [identifiedFiles] = @identifiedFiles,
    [potentialSpace] = @potentialSpace,
    [progress] = @progress,
    [dateCompleted] = CASE WHEN @status IN (2, 3) THEN GETUTCDATE() ELSE [dateCompleted] END
  WHERE [idOperation] = @idOperation
    AND [idAccount] = @idAccount;
END;
GO
