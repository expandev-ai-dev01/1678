/**
 * @summary
 * Retrieves a specific scan configuration with its associated extensions and patterns.
 * 
 * @procedure spScanConfigurationGet
 * @schema functional
 * @type stored-procedure
 * 
 * @endpoints
 * - GET /api/v1/internal/scan-configuration/:id
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
 * @testScenarios
 * - Valid retrieval with existing configuration
 * - Configuration not found scenario
 * - Security validation failure
 */
CREATE OR ALTER PROCEDURE [functional].[spScanConfigurationGet]
  @idAccount INTEGER,
  @idConfiguration INTEGER
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
   * @output {ConfigurationData, 1, n}
   * @column {INT} idConfiguration
   * @column {NVARCHAR} name
   * @column {BIT} includeSubdirectories
   * @column {INT} minimumAge
   * @column {INT} minimumSize
   * @column {BIT} includeSystemFiles
   * @column {DATETIME2} dateCreated
   * @column {DATETIME2} dateModified
   */
  SELECT
    scnCfg.[idConfiguration],
    scnCfg.[name],
    scnCfg.[includeSubdirectories],
    scnCfg.[minimumAge],
    scnCfg.[minimumSize],
    scnCfg.[includeSystemFiles],
    scnCfg.[dateCreated],
    scnCfg.[dateModified]
  FROM [functional].[scanConfiguration] scnCfg
  WHERE scnCfg.[idConfiguration] = @idConfiguration
    AND scnCfg.[idAccount] = @idAccount
    AND scnCfg.[deleted] = 0;

  /**
   * @output {ExtensionData, n, n}
   * @column {INT} idExtension
   * @column {VARCHAR} extension
   * @column {NVARCHAR} description
   */
  SELECT
    tmpExt.[idExtension],
    tmpExt.[extension],
    tmpExt.[description]
  FROM [functional].[scanConfigurationExtension] scnCfgExt
    JOIN [config].[temporaryFileExtension] tmpExt ON (tmpExt.[idExtension] = scnCfgExt.[idExtension])
  WHERE scnCfgExt.[idAccount] = @idAccount
    AND scnCfgExt.[idConfiguration] = @idConfiguration;

  /**
   * @output {PatternData, n, n}
   * @column {INT} idPattern
   * @column {NVARCHAR} pattern
   * @column {NVARCHAR} description
   */
  SELECT
    tmpPat.[idPattern],
    tmpPat.[pattern],
    tmpPat.[description]
  FROM [functional].[scanConfigurationPattern] scnCfgPat
    JOIN [config].[temporaryFilePattern] tmpPat ON (tmpPat.[idPattern] = scnCfgPat.[idPattern])
  WHERE scnCfgPat.[idAccount] = @idAccount
    AND scnCfgPat.[idConfiguration] = @idConfiguration;
END;
GO
