/**
 * @summary
 * Creates a new scan operation record to track file analysis progress.
 * 
 * @procedure spScanOperationCreate
 * @schema functional
 * @type stored-procedure
 * 
 * @endpoints
 * - POST /api/v1/internal/scan-operation
 * 
 * @parameters
 * @param {INT} idAccount
 *   - Required: Yes
 *   - Description: Account identifier
 * 
 * @param {INT} idConfiguration
 *   - Required: Yes
 *   - Description: Configuration identifier
 * 
 * @param {NVARCHAR(500)} directoryPath
 *   - Required: Yes
 *   - Description: Directory path to scan
 * 
 * @returns {INT} idOperation - Created operation identifier
 * 
 * @testScenarios
 * - Valid operation creation
 * - Configuration validation
 * - Directory path validation
 */
CREATE OR ALTER PROCEDURE [functional].[spScanOperationCreate]
  @idAccount INTEGER,
  @idConfiguration INTEGER,
  @directoryPath NVARCHAR(500)
AS
BEGIN
  SET NOCOUNT ON;

  /**
   * @validation Configuration existence validation
   * @throw {configurationDoesntExist}
   */
  IF NOT EXISTS (
    SELECT * FROM [functional].[scanConfiguration] scnCfg
    WHERE scnCfg.[idConfiguration] = @idConfiguration
      AND scnCfg.[idAccount] = @idAccount
      AND scnCfg.[deleted] = 0
  )
  BEGIN
    ;THROW 51000, 'configurationDoesntExist', 1;
  END;

  /**
   * @validation Directory path required validation
   * @throw {directoryPathRequired}
   */
  IF @directoryPath IS NULL OR LEN(TRIM(@directoryPath)) = 0
  BEGIN
    ;THROW 51000, 'directoryPathRequired', 1;
  END;

  DECLARE @idOperation INTEGER;

  /**
   * @rule {fn-scan-operation-create} Create scan operation record
   */
  INSERT INTO [functional].[scanOperation]
  ([idAccount], [idConfiguration], [directoryPath], [status])
  VALUES
  (@idAccount, @idConfiguration, @directoryPath, 0);

  SET @idOperation = SCOPE_IDENTITY();

  /**
   * @output {OperationResult, 1, 1}
   * @column {INT} idOperation
   *   - Description: Created operation identifier
   */
  SELECT @idOperation AS [idOperation];
END;
GO
