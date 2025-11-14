/**
 * @summary
 * Creates multiple removed file records in batch for a removal operation.
 * 
 * @procedure spRemovedFileBatchCreate
 * @schema functional
 * @type stored-procedure
 * 
 * @endpoints
 * - POST /api/v1/internal/removed-file/batch
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
 * @param {NVARCHAR(MAX)} resultsJson
 *   - Required: Yes
 *   - Description: JSON array of removal result objects
 * 
 * @testScenarios
 * - Valid batch creation
 * - JSON parsing validation
 * - Removal operation validation
 */
CREATE OR ALTER PROCEDURE [functional].[spRemovedFileBatchCreate]
  @idAccount INTEGER,
  @idRemoval INTEGER,
  @resultsJson NVARCHAR(MAX)
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
   * @validation Results JSON required validation
   * @throw {resultsJsonRequired}
   */
  IF @resultsJson IS NULL OR LEN(TRIM(@resultsJson)) = 0
  BEGIN
    ;THROW 51000, 'resultsJsonRequired', 1;
  END;

  BEGIN TRY
    BEGIN TRAN;

      /**
       * @rule {fn-removed-file-batch-create} Insert removed file results from JSON
       */
      INSERT INTO [functional].[removedFile]
      ([idAccount], [idRemoval], [idFile], [success], [errorMessage])
      SELECT
        @idAccount,
        @idRemoval,
        CAST(JSON_VALUE(value, '$.idFile') AS INTEGER),
        CAST(JSON_VALUE(value, '$.success') AS BIT),
        JSON_VALUE(value, '$.errorMessage')
      FROM OPENJSON(@resultsJson);

    COMMIT TRAN;
  END TRY
  BEGIN CATCH
    ROLLBACK TRAN;
    THROW;
  END CATCH;
END;
GO
