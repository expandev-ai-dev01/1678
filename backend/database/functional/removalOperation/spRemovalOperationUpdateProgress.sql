/**
 * @summary
 * Updates removal operation progress and statistics during file deletion.
 * 
 * @procedure spRemovalOperationUpdateProgress
 * @schema functional
 * @type stored-procedure
 * 
 * @endpoints
 * - PATCH /api/v1/internal/removal-operation/:id/progress
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
 * @param {INT} status
 *   - Required: Yes
 *   - Description: Operation status (0-3)
 * 
 * @param {INT} progress
 *   - Required: Yes
 *   - Description: Progress percentage (0-100)
 * 
 * @param {INT} filesRemoved
 *   - Required: Yes
 *   - Description: Number of files removed
 * 
 * @param {INT} filesWithError
 *   - Required: Yes
 *   - Description: Number of files with errors
 * 
 * @param {BIGINT} spaceFreed
 *   - Required: Yes
 *   - Description: Space freed in bytes
 * 
 * @testScenarios
 * - Valid progress update
 * - Operation completion
 * - Error handling
 */
CREATE OR ALTER PROCEDURE [functional].[spRemovalOperationUpdateProgress]
  @idAccount INTEGER,
  @idRemoval INTEGER,
  @status INTEGER,
  @progress INTEGER,
  @filesRemoved INTEGER,
  @filesWithError INTEGER,
  @spaceFreed BIGINT
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
   * @rule {fn-removal-operation-update} Update removal operation progress
   */
  UPDATE [functional].[removalOperation]
  SET
    [status] = @status,
    [progress] = @progress,
    [filesRemoved] = @filesRemoved,
    [filesWithError] = @filesWithError,
    [spaceFreed] = @spaceFreed,
    [dateCompleted] = CASE WHEN @status IN (2, 3) THEN GETUTCDATE() ELSE [dateCompleted] END
  WHERE [idRemoval] = @idRemoval
    AND [idAccount] = @idAccount;
END;
GO
