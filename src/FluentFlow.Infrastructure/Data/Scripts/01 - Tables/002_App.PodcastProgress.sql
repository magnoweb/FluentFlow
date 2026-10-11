-- Progresso dos utilizadores nos episódios de podcast
-- (equivalente à migração EF 20261010120000_AddPodcastProgress)
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'App')
BEGIN
    EXEC('CREATE SCHEMA [App]')
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[App].[PodcastProgress]') AND type in (N'U'))
BEGIN
    CREATE TABLE [App].[PodcastProgress](
        [Id] [uniqueidentifier] NOT NULL,
        [UserId] [uniqueidentifier] NOT NULL,
        [EpisodeId] [nvarchar](100) NOT NULL,
        [PositionMs] [int] NOT NULL,
        [DurationMs] [int] NOT NULL,
        [IsCompleted] [bit] NOT NULL,
        [CompletedAt] [datetime2](7) NULL,
        [PlayCount] [int] NOT NULL,
        [IsFavorite] [bit] NOT NULL,
        [LastPlayedAt] [datetime2](7) NOT NULL,
        [CreatedAt] [datetime2](7) NOT NULL,
        [UpdatedAt] [datetime2](7) NOT NULL,
        CONSTRAINT [PK_PodcastProgress] PRIMARY KEY CLUSTERED ([Id] ASC),
        CONSTRAINT [FK_PodcastProgress_Users_UserId] FOREIGN KEY ([UserId]) REFERENCES [Core].[Users] ([Id]) ON DELETE CASCADE
    )
END
GO

-- O índice só se aplica enquanto a coluna EpisodeId existir: a migração
-- 20261011100000_PodcastEpisodesPerUser (script 004) substitui-a por PodcastEpisodeId.
-- EXEC evita o erro de compilação "Invalid column name 'EpisodeId'" quando a coluna já não existe.
IF COL_LENGTH('App.PodcastProgress', 'EpisodeId') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.indexes WHERE Name = 'IX_PodcastProgress_UserId_EpisodeId' AND object_id = object_id('[App].[PodcastProgress]'))
BEGIN
    EXEC(N'CREATE UNIQUE NONCLUSTERED INDEX [IX_PodcastProgress_UserId_EpisodeId] ON [App].[PodcastProgress] ([UserId], [EpisodeId])');
END
GO
