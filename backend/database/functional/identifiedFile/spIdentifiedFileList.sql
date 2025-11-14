/**
 * @summary
 * Lists all identified files for a specific scan operation.
 * 
 * @procedure spIdentifiedFileList
 * @schema functional
 * @type stored-procedure
 * 
 * @endpoints
 * - GET /api/v1/internal/scan-operation/:id/files
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
 * - Valid file list retrieval
 * - Empty list scenario
 * - Operation validation
 */
CREATE OR ALTER PROCEDURE [functional].[spIdentifiedFileList]
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
   * @output {FileList, n, n}
   * @column {INT} idFile
   * @column {NVARCHAR} filePath
   * @column {NVARCHAR} fileName
   * @column {VARCHAR} extension
   * @column {BIGINT} size
   * @column {DATETIME2} dateModified
   * @column {NVARCHAR} identificationCriteria
   */
  SELECT
    idnFil.[idFile],
    idnFil.[filePath],
    idnFil.[fileName],
    idnFil.[extension],
    idnFil.[size],
    idnFil.[dateModified],
    idnFil.[identificationCriteria]
  FROM [functional].[identifiedFile] idnFil
  WHERE idnFil.[idAccount] = @idAccount
    AND idnFil.[idOperation] = @idOperation
  ORDER BY idnFil.[size] DESC;
END;
GO
