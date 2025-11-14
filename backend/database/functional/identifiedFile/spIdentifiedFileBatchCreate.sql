/**
 * @summary
 * Creates multiple identified file records in batch for a scan operation.
 * 
 * @procedure spIdentifiedFileBatchCreate
 * @schema functional
 * @type stored-procedure
 * 
 * @endpoints
 * - POST /api/v1/internal/identified-file/batch
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
 * @param {NVARCHAR(MAX)} filesJson
 *   - Required: Yes
 *   - Description: JSON array of file objects
 * 
 * @testScenarios
 * - Valid batch creation
 * - JSON parsing validation
 * - Operation validation
 */
CREATE OR ALTER PROCEDURE [functional].[spIdentifiedFileBatchCreate]
  @idAccount INTEGER,
  @idOperation INTEGER,
  @filesJson NVARCHAR(MAX)
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
   * @validation Files JSON required validation
   * @throw {filesJsonRequired}
   */
  IF @filesJson IS NULL OR LEN(TRIM(@filesJson)) = 0
  BEGIN
    ;THROW 51000, 'filesJsonRequired', 1;
  END;

  BEGIN TRY
    BEGIN TRAN;

      /**
       * @rule {fn-identified-file-batch-create} Insert identified files from JSON
       */
      INSERT INTO [functional].[identifiedFile]
      ([idAccount], [idOperation], [filePath], [fileName], [extension], [size], [dateModified], [identificationCriteria])
      SELECT
        @idAccount,
        @idOperation,
        JSON_VALUE(value, '$.filePath'),
        JSON_VALUE(value, '$.fileName'),
        JSON_VALUE(value, '$.extension'),
        CAST(JSON_VALUE(value, '$.size') AS BIGINT),
        CAST(JSON_VALUE(value, '$.dateModified') AS DATETIME2),
        JSON_VALUE(value, '$.identificationCriteria')
      FROM OPENJSON(@filesJson);

    COMMIT TRAN;
  END TRY
  BEGIN CATCH
    ROLLBACK TRAN;
    THROW;
  END CATCH;
END;
GO
