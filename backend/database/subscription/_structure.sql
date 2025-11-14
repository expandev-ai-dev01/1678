/**
 * @schema subscription
 * Subscription schema - account management and tenant operations
 */
CREATE SCHEMA [subscription];
GO

/**
 * @table account Account management for multi-tenancy
 * @multitenancy false
 * @softDelete true
 * @alias acc
 */
CREATE TABLE [subscription].[account] (
  [idAccount] INTEGER IDENTITY(1, 1) NOT NULL,
  [name] NVARCHAR(100) NOT NULL,
  [active] BIT NOT NULL DEFAULT (1),
  [dateCreated] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [dateModified] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [deleted] BIT NOT NULL DEFAULT (0)
);
GO

/**
 * @primaryKey pkAccount
 * @keyType Object
 */
ALTER TABLE [subscription].[account]
ADD CONSTRAINT [pkAccount] PRIMARY KEY CLUSTERED ([idAccount]);
GO

/**
 * @index ixAccount_Active
 * @type SoftDelete
 */
CREATE NONCLUSTERED INDEX [ixAccount_Active]
ON [subscription].[account]([active])
WHERE [deleted] = 0;
GO
