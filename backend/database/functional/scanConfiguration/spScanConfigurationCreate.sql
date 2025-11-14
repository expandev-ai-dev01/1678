/**
 * @summary
 * Creates a new scan configuration with specified criteria for identifying temporary files.
 * 
 * @procedure spScanConfigurationCreate
 * @schema functional
 * @type stored-procedure
 * 
 * @endpoints
 * - POST /api/v1/internal/scan-configuration
 * 
 * @parameters
 * @param {INT} idAccount
 *   - Required: Yes
 *   - Description: Account identifier
 * 
 * @param {NVARCHAR(100)} name
 *   - Required: Yes
 *   - Description: Configuration name
 * 
 * @param {BIT} includeSubdirectories
 *   - Required: Yes
 *   - Description: Include subdirectories in scan
 * 
 * @param {INT} minimumAge
 *   - Required: Yes
 *   - Description: Minimum age in days
 * 
 * @param {INT} minimumSize
 *   - Required: Yes
 *   - Description: Minimum size in bytes
 * 
 * @param {BIT} includeSystemFiles
 *   - Required: Yes
 *   - Description: Include system files
 * 
 * @param {NVARCHAR(MAX)} extensionIds
 *   - Required: Yes
 *   - Description: Comma-separated extension IDs
 * 
 * @param {NVARCHAR(MAX)} patternIds
 *   - Required: Yes
 *   - Description: Comma-separated pattern IDs
 * 
 * @returns {INT} idConfiguration - Created configuration identifier
 * 
 * @testScenarios
 * - Valid creation with all parameters
 * - Security validation failure scenarios
 * - Business rule validation scenarios
 */
CREATE OR ALTER PROCEDURE [functional].[spScanConfigurationCreate]
  @idAccount INTEGER,
  @name NVARCHAR(100),
  @includeSubdirectories BIT,
  @minimumAge INTEGER,
  @minimumSize INTEGER,
  @includeSystemFiles BIT,
  @extensionIds NVARCHAR(MAX),
  @patternIds NVARCHAR(MAX)
AS
BEGIN
  SET NOCOUNT ON;

  /**
   * @validation Account existence validation
   * @throw {accountDoesntExist}
   */
  IF NOT EXISTS (SELECT * FROM [subscription].[account] acc WHERE acc.[idAccount] = @idAccount AND acc.[deleted] = 0)
  BEGIN
    ;THROW 51000, 'accountDoesntExist', 1;
  END;

  /**
   * @validation Name required validation
   * @throw {nameRequired}
   */
  IF @name IS NULL OR LEN(TRIM(@name)) = 0
  BEGIN
    ;THROW 51000, 'nameRequired', 1;
  END;

  /**
   * @validation Minimum age validation
   * @throw {minimumAgeMustBeEqualOrGreaterZero}
   */
  IF @minimumAge < 0
  BEGIN
    ;THROW 51000, 'minimumAgeMustBeEqualOrGreaterZero', 1;
  END;

  /**
   * @validation Minimum size validation
   * @throw {minimumSizeMustBeEqualOrGreaterZero}
   */
  IF @minimumSize < 0
  BEGIN
    ;THROW 51000, 'minimumSizeMustBeEqualOrGreaterZero', 1;
  END;

  DECLARE @idConfiguration INTEGER;

  BEGIN TRY
    BEGIN TRAN;

      /**
       * @rule {fn-scan-configuration-create} Create scan configuration record
       */
      INSERT INTO [functional].[scanConfiguration]
      ([idAccount], [name], [includeSubdirectories], [minimumAge], [minimumSize], [includeSystemFiles])
      VALUES
      (@idAccount, @name, @includeSubdirectories, @minimumAge, @minimumSize, @includeSystemFiles);

      SET @idConfiguration = SCOPE_IDENTITY();

      /**
       * @rule {fn-scan-configuration-extensions} Associate extensions with configuration
       */
      IF @extensionIds IS NOT NULL AND LEN(TRIM(@extensionIds)) > 0
      BEGIN
        INSERT INTO [functional].[scanConfigurationExtension]
        ([idAccount], [idConfiguration], [idExtension])
        SELECT @idAccount, @idConfiguration, CAST(value AS INTEGER)
        FROM STRING_SPLIT(@extensionIds, ',');
      END;

      /**
       * @rule {fn-scan-configuration-patterns} Associate patterns with configuration
       */
      IF @patternIds IS NOT NULL AND LEN(TRIM(@patternIds)) > 0
      BEGIN
        INSERT INTO [functional].[scanConfigurationPattern]
        ([idAccount], [idConfiguration], [idPattern])
        SELECT @idAccount, @idConfiguration, CAST(value AS INTEGER)
        FROM STRING_SPLIT(@patternIds, ',');
      END;

      /**
       * @output {ConfigurationResult, 1, 1}
       * @column {INT} idConfiguration
       *   - Description: Created configuration identifier
       */
      SELECT @idConfiguration AS [idConfiguration];

    COMMIT TRAN;
  END TRY
  BEGIN CATCH
    ROLLBACK TRAN;
    THROW;
  END CATCH;
END;
GO
