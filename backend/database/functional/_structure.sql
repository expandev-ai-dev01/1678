/**
 * @schema functional
 * Functional schema - business logic and operations
 */
CREATE SCHEMA [functional];
GO

/**
 * @table scanConfiguration Configuration for file scanning operations
 * @multitenancy true
 * @softDelete true
 * @alias scnCfg
 */
CREATE TABLE [functional].[scanConfiguration] (
  [idConfiguration] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [name] NVARCHAR(100) NOT NULL,
  [includeSubdirectories] BIT NOT NULL DEFAULT (1),
  [minimumAge] INTEGER NOT NULL DEFAULT (7),
  [minimumSize] INTEGER NOT NULL DEFAULT (0),
  [includeSystemFiles] BIT NOT NULL DEFAULT (0),
  [dateCreated] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [dateModified] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [deleted] BIT NOT NULL DEFAULT (0)
);
GO

/**
 * @primaryKey pkScanConfiguration
 * @keyType Object
 */
ALTER TABLE [functional].[scanConfiguration]
ADD CONSTRAINT [pkScanConfiguration] PRIMARY KEY CLUSTERED ([idConfiguration]);
GO

/**
 * @foreignKey fkScanConfiguration_Account
 * @target subscription.account
 */
ALTER TABLE [functional].[scanConfiguration]
ADD CONSTRAINT [fkScanConfiguration_Account] FOREIGN KEY ([idAccount])
REFERENCES [subscription].[account]([idAccount]);
GO

/**
 * @index ixScanConfiguration_Account
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixScanConfiguration_Account]
ON [functional].[scanConfiguration]([idAccount])
WHERE [deleted] = 0;
GO

/**
 * @table scanConfigurationExtension Extensions configured for a scan configuration
 * @multitenancy true
 * @softDelete false
 * @alias scnCfgExt
 */
CREATE TABLE [functional].[scanConfigurationExtension] (
  [idAccount] INTEGER NOT NULL,
  [idConfiguration] INTEGER NOT NULL,
  [idExtension] INTEGER NOT NULL
);
GO

/**
 * @primaryKey pkScanConfigurationExtension
 * @keyType Relationship
 */
ALTER TABLE [functional].[scanConfigurationExtension]
ADD CONSTRAINT [pkScanConfigurationExtension] PRIMARY KEY CLUSTERED ([idAccount], [idConfiguration], [idExtension]);
GO

/**
 * @foreignKey fkScanConfigurationExtension_Account
 * @target subscription.account
 */
ALTER TABLE [functional].[scanConfigurationExtension]
ADD CONSTRAINT [fkScanConfigurationExtension_Account] FOREIGN KEY ([idAccount])
REFERENCES [subscription].[account]([idAccount]);
GO

/**
 * @foreignKey fkScanConfigurationExtension_Configuration
 * @target functional.scanConfiguration
 */
ALTER TABLE [functional].[scanConfigurationExtension]
ADD CONSTRAINT [fkScanConfigurationExtension_Configuration] FOREIGN KEY ([idConfiguration])
REFERENCES [functional].[scanConfiguration]([idConfiguration]);
GO

/**
 * @foreignKey fkScanConfigurationExtension_Extension
 * @target config.temporaryFileExtension
 */
ALTER TABLE [functional].[scanConfigurationExtension]
ADD CONSTRAINT [fkScanConfigurationExtension_Extension] FOREIGN KEY ([idExtension])
REFERENCES [config].[temporaryFileExtension]([idExtension]);
GO

/**
 * @table scanConfigurationPattern Patterns configured for a scan configuration
 * @multitenancy true
 * @softDelete false
 * @alias scnCfgPat
 */
CREATE TABLE [functional].[scanConfigurationPattern] (
  [idAccount] INTEGER NOT NULL,
  [idConfiguration] INTEGER NOT NULL,
  [idPattern] INTEGER NOT NULL
);
GO

/**
 * @primaryKey pkScanConfigurationPattern
 * @keyType Relationship
 */
ALTER TABLE [functional].[scanConfigurationPattern]
ADD CONSTRAINT [pkScanConfigurationPattern] PRIMARY KEY CLUSTERED ([idAccount], [idConfiguration], [idPattern]);
GO

/**
 * @foreignKey fkScanConfigurationPattern_Account
 * @target subscription.account
 */
ALTER TABLE [functional].[scanConfigurationPattern]
ADD CONSTRAINT [fkScanConfigurationPattern_Account] FOREIGN KEY ([idAccount])
REFERENCES [subscription].[account]([idAccount]);
GO

/**
 * @foreignKey fkScanConfigurationPattern_Configuration
 * @target functional.scanConfiguration
 */
ALTER TABLE [functional].[scanConfigurationPattern]
ADD CONSTRAINT [fkScanConfigurationPattern_Configuration] FOREIGN KEY ([idConfiguration])
REFERENCES [functional].[scanConfiguration]([idConfiguration]);
GO

/**
 * @foreignKey fkScanConfigurationPattern_Pattern
 * @target config.temporaryFilePattern
 */
ALTER TABLE [functional].[scanConfigurationPattern]
ADD CONSTRAINT [fkScanConfigurationPattern_Pattern] FOREIGN KEY ([idPattern])
REFERENCES [config].[temporaryFilePattern]([idPattern]);
GO

/**
 * @table scanOperation File scanning operations history
 * @multitenancy true
 * @softDelete false
 * @alias scnOpr
 */
CREATE TABLE [functional].[scanOperation] (
  [idOperation] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [idConfiguration] INTEGER NOT NULL,
  [directoryPath] NVARCHAR(500) NOT NULL,
  [status] INTEGER NOT NULL DEFAULT (0),
  [totalFiles] INTEGER NOT NULL DEFAULT (0),
  [identifiedFiles] INTEGER NOT NULL DEFAULT (0),
  [potentialSpace] BIGINT NOT NULL DEFAULT (0),
  [progress] INTEGER NOT NULL DEFAULT (0),
  [dateStarted] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [dateCompleted] DATETIME2 NULL
);
GO

/**
 * @primaryKey pkScanOperation
 * @keyType Object
 */
ALTER TABLE [functional].[scanOperation]
ADD CONSTRAINT [pkScanOperation] PRIMARY KEY CLUSTERED ([idOperation]);
GO

/**
 * @foreignKey fkScanOperation_Account
 * @target subscription.account
 */
ALTER TABLE [functional].[scanOperation]
ADD CONSTRAINT [fkScanOperation_Account] FOREIGN KEY ([idAccount])
REFERENCES [subscription].[account]([idAccount]);
GO

/**
 * @foreignKey fkScanOperation_Configuration
 * @target functional.scanConfiguration
 */
ALTER TABLE [functional].[scanOperation]
ADD CONSTRAINT [fkScanOperation_Configuration] FOREIGN KEY ([idConfiguration])
REFERENCES [functional].[scanConfiguration]([idConfiguration]);
GO

/**
 * @check chkScanOperation_Status
 * @enum {0} Not Started
 * @enum {1} In Progress
 * @enum {2} Completed
 * @enum {3} Error
 */
ALTER TABLE [functional].[scanOperation]
ADD CONSTRAINT [chkScanOperation_Status] CHECK ([status] BETWEEN 0 AND 3);
GO

/**
 * @index ixScanOperation_Account
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixScanOperation_Account]
ON [functional].[scanOperation]([idAccount]);
GO

/**
 * @index ixScanOperation_Account_Status
 * @type Search
 */
CREATE NONCLUSTERED INDEX [ixScanOperation_Account_Status]
ON [functional].[scanOperation]([idAccount], [status]);
GO

/**
 * @table identifiedFile Files identified during scan operations
 * @multitenancy true
 * @softDelete false
 * @alias idnFil
 */
CREATE TABLE [functional].[identifiedFile] (
  [idFile] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [idOperation] INTEGER NOT NULL,
  [filePath] NVARCHAR(500) NOT NULL,
  [fileName] NVARCHAR(255) NOT NULL,
  [extension] VARCHAR(50) NOT NULL,
  [size] BIGINT NOT NULL,
  [dateModified] DATETIME2 NOT NULL,
  [identificationCriteria] NVARCHAR(100) NOT NULL
);
GO

/**
 * @primaryKey pkIdentifiedFile
 * @keyType Object
 */
ALTER TABLE [functional].[identifiedFile]
ADD CONSTRAINT [pkIdentifiedFile] PRIMARY KEY CLUSTERED ([idFile]);
GO

/**
 * @foreignKey fkIdentifiedFile_Account
 * @target subscription.account
 */
ALTER TABLE [functional].[identifiedFile]
ADD CONSTRAINT [fkIdentifiedFile_Account] FOREIGN KEY ([idAccount])
REFERENCES [subscription].[account]([idAccount]);
GO

/**
 * @foreignKey fkIdentifiedFile_Operation
 * @target functional.scanOperation
 */
ALTER TABLE [functional].[identifiedFile]
ADD CONSTRAINT [fkIdentifiedFile_Operation] FOREIGN KEY ([idOperation])
REFERENCES [functional].[scanOperation]([idOperation]);
GO

/**
 * @index ixIdentifiedFile_Account_Operation
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixIdentifiedFile_Account_Operation]
ON [functional].[identifiedFile]([idAccount], [idOperation]);
GO

/**
 * @table removalOperation File removal operations history
 * @multitenancy true
 * @softDelete false
 * @alias rmvOpr
 */
CREATE TABLE [functional].[removalOperation] (
  [idRemoval] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [idOperation] INTEGER NOT NULL,
  [removalMode] INTEGER NOT NULL DEFAULT (0),
  [status] INTEGER NOT NULL DEFAULT (0),
  [progress] INTEGER NOT NULL DEFAULT (0),
  [filesRemoved] INTEGER NOT NULL DEFAULT (0),
  [filesWithError] INTEGER NOT NULL DEFAULT (0),
  [spaceFreed] BIGINT NOT NULL DEFAULT (0),
  [dateStarted] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [dateCompleted] DATETIME2 NULL
);
GO

/**
 * @primaryKey pkRemovalOperation
 * @keyType Object
 */
ALTER TABLE [functional].[removalOperation]
ADD CONSTRAINT [pkRemovalOperation] PRIMARY KEY CLUSTERED ([idRemoval]);
GO

/**
 * @foreignKey fkRemovalOperation_Account
 * @target subscription.account
 */
ALTER TABLE [functional].[removalOperation]
ADD CONSTRAINT [fkRemovalOperation_Account] FOREIGN KEY ([idAccount])
REFERENCES [subscription].[account]([idAccount]);
GO

/**
 * @foreignKey fkRemovalOperation_Operation
 * @target functional.scanOperation
 */
ALTER TABLE [functional].[removalOperation]
ADD CONSTRAINT [fkRemovalOperation_Operation] FOREIGN KEY ([idOperation])
REFERENCES [functional].[scanOperation]([idOperation]);
GO

/**
 * @check chkRemovalOperation_RemovalMode
 * @enum {0} Recycle Bin
 * @enum {1} Permanent
 */
ALTER TABLE [functional].[removalOperation]
ADD CONSTRAINT [chkRemovalOperation_RemovalMode] CHECK ([removalMode] BETWEEN 0 AND 1);
GO

/**
 * @check chkRemovalOperation_Status
 * @enum {0} Not Started
 * @enum {1} In Progress
 * @enum {2} Completed
 * @enum {3} Error
 */
ALTER TABLE [functional].[removalOperation]
ADD CONSTRAINT [chkRemovalOperation_Status] CHECK ([status] BETWEEN 0 AND 3);
GO

/**
 * @index ixRemovalOperation_Account
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixRemovalOperation_Account]
ON [functional].[removalOperation]([idAccount]);
GO

/**
 * @table removedFile Files removed during removal operations
 * @multitenancy true
 * @softDelete false
 * @alias rmvFil
 */
CREATE TABLE [functional].[removedFile] (
  [idRemovedFile] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [idRemoval] INTEGER NOT NULL,
  [idFile] INTEGER NOT NULL,
  [success] BIT NOT NULL,
  [errorMessage] NVARCHAR(500) NULL
);
GO

/**
 * @primaryKey pkRemovedFile
 * @keyType Object
 */
ALTER TABLE [functional].[removedFile]
ADD CONSTRAINT [pkRemovedFile] PRIMARY KEY CLUSTERED ([idRemovedFile]);
GO

/**
 * @foreignKey fkRemovedFile_Account
 * @target subscription.account
 */
ALTER TABLE [functional].[removedFile]
ADD CONSTRAINT [fkRemovedFile_Account] FOREIGN KEY ([idAccount])
REFERENCES [subscription].[account]([idAccount]);
GO

/**
 * @foreignKey fkRemovedFile_Removal
 * @target functional.removalOperation
 */
ALTER TABLE [functional].[removedFile]
ADD CONSTRAINT [fkRemovedFile_Removal] FOREIGN KEY ([idRemoval])
REFERENCES [functional].[removalOperation]([idRemoval]);
GO

/**
 * @foreignKey fkRemovedFile_File
 * @target functional.identifiedFile
 */
ALTER TABLE [functional].[removedFile]
ADD CONSTRAINT [fkRemovedFile_File] FOREIGN KEY ([idFile])
REFERENCES [functional].[identifiedFile]([idFile]);
GO

/**
 * @index ixRemovedFile_Account_Removal
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixRemovedFile_Account_Removal]
ON [functional].[removedFile]([idAccount], [idRemoval]);
GO
