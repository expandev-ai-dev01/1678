/**
 * @summary
 * Creates a new removal operation record to track file deletion progress.
 * 
 * @procedure spRemovalOperationCreate
 * @schema functional
 * @type stored-procedure
 * 
 * @endpoints
 * - POST /api/v1/internal/removal-operation
 * 
 * @parameters
 * @param {INT} idAccount
 *   - Required: Yes
 *   - Description: Account identifier
 * 
 * @param {INT} idOperation
 *   - Required: Yes
 *   - Description: Scan operation identifier
 * 
 * @param {INT} removalMode
 *   - Required: Yes
 *   - Description: Removal mode (0=Recycle Bin, 1=Permanent)
 * 
 * @returns {INT} idRemoval - Created removal operation identifier
 * 
 * @testScenarios
 * - Valid removal operation creation
 * - Operation validation
 * - Removal mode validation
 */
CREATE OR ALTER PROCEDURE [functional].[spRemovalOperationCreate]
  @idAccount INTEGER,
  @idOperation INTEGER,
  @removalMode INTEGER
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
   * @validation Removal mode validation
   * @throw {invalidRemovalMode}
   */
  IF @removalMode NOT BETWEEN 0 AND 1
  BEGIN
    ;THROW 51000, 'invalidRemovalMode', 1;
  END;

  DECLARE @idRemoval INTEGER;

  /**
   * @rule {fn-removal-operation-create} Create removal operation record
   */
  INSERT INTO [functional].[removalOperation]
  ([idAccount], [idOperation], [removalMode], [status])
  VALUES
  (@idAccount, @idOperation, @removalMode, 0);

  SET @idRemoval = SCOPE_IDENTITY();

  /**
   * @output {RemovalResult, 1, 1}
   * @column {INT} idRemoval
   *   - Description: Created removal operation identifier
   */
  SELECT @idRemoval AS [idRemoval];
END;
GO
