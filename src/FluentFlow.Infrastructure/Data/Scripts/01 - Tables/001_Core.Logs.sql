-- 1. Garante que o Schema existe
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Core')
BEGIN
    EXEC('CREATE SCHEMA [Core]')
END
GO

-- 2. Cria a tabela de Logs
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Core].[Logs]') AND type in (N'U'))
BEGIN
    CREATE TABLE [Core].[Logs](
        [Id] [int] IDENTITY(1,1) NOT NULL,
        [Message] [nvarchar](max) NULL,
        [MessageTemplate] [nvarchar](max) NULL,
        [Level] [nvarchar](128) NULL,
        [TimeStamp] [datetimeoffset](7) NOT NULL,
        [Exception] [nvarchar](max) NULL,
        [Properties] [xml] NULL,
        [LogEvent] [nvarchar](max) NULL,
        
        -- Colunas customizadas que adicionamos via ColumnOptions
        [UserId] [uniqueidentifier] NULL,
        [CardId] [uniqueidentifier] NULL,
        
        CONSTRAINT [PK_Logs] PRIMARY KEY CLUSTERED ([Id] ASC)
    )
END
GO

-- 3. Cria um índice para performance (Opcional, mas recomendado para o Dashboard)
CREATE NONCLUSTERED INDEX [IX_Logs_TimeStamp] ON [Core].[Logs] ([TimeStamp] DESC)
GO