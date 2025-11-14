/**
 * @summary
 * Lists all scan configurations for an account.
 * 
 * @procedure spScanConfigurationList
 * @schema functional
 * @type stored-procedure
 * 
 * @endpoints
 * - GET /api/v1/internal/scan-configuration
 * 
 * @parameters
 * @param {INT} idAccount
 *   - Required: Yes
 *   - Description: Account identifier
 * 
 * @testScenarios
 * - Valid list retrieval
 * - Empty list scenario
 * - Security validation
 */
CREATE OR ALTER PROCEDURE [functional].[spScanConfigurationList]
  @idAccount INTEGER
AS
BEGIN
  SET NOCOUNT ON;

  /**
   * @output {ConfigurationList, n, n}
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
  WHERE scnCfg.[idAccount] = @idAccount
    AND scnCfg.[deleted] = 0
  ORDER BY scnCfg.[dateCreated] DESC;
END;
GO
