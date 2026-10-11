-- Podcasts por utilizador: episódios enviados pela web + progresso ligado ao episódio
-- (equivalente à migração EF 20261011100000_PodcastEpisodesPerUser)
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[App].[PodcastEpisodes]') AND type in (N'U'))
BEGIN
    CREATE TABLE [App].[PodcastEpisodes](
        [Id] [uniqueidentifier] NOT NULL,
        [UserId] [uniqueidentifier] NOT NULL,
        [ExternalId] [nvarchar](100) NOT NULL,
        [Title] [nvarchar](200) NOT NULL,
        [Description] [nvarchar](1000) NULL,
        [Language] [nvarchar](20) NOT NULL,
        [Level] [nvarchar](20) NULL,
        [Series] [nvarchar](200) NULL,
        [Season] [int] NULL,
        [EpisodeNumber] [int] NULL,
        [DurationMs] [int] NOT NULL,
        [AudioPath] [nvarchar](500) NOT NULL,
        [SlowAudioPath] [nvarchar](500) NULL,
        [SlowTempo] [float] NULL,
        [TranscriptJson] [nvarchar](max) NOT NULL,
        [GeneratedAt] [datetime2](7) NOT NULL,
        [CreatedAt] [datetime2](7) NOT NULL,
        [UpdatedAt] [datetime2](7) NOT NULL,
        CONSTRAINT [PK_PodcastEpisodes] PRIMARY KEY CLUSTERED ([Id] ASC),
        CONSTRAINT [FK_PodcastEpisodes_Users_UserId] FOREIGN KEY ([UserId]) REFERENCES [Core].[Users] ([Id])
    )
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE Name = 'IX_PodcastEpisodes_UserId_ExternalId' AND object_id = object_id('[App].[PodcastEpisodes]'))
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX [IX_PodcastEpisodes_UserId_ExternalId] ON [App].[PodcastEpisodes] ([UserId], [ExternalId])
END
GO

-- PodcastProgress: EpisodeId (texto do catálogo em disco) → PodcastEpisodeId (FK)
IF COL_LENGTH('App.PodcastProgress', 'EpisodeId') IS NOT NULL
BEGIN
    DELETE FROM [App].[PodcastProgress];

    IF EXISTS (SELECT 1 FROM sys.indexes WHERE Name = 'IX_PodcastProgress_UserId_EpisodeId' AND object_id = object_id('[App].[PodcastProgress]'))
        DROP INDEX [IX_PodcastProgress_UserId_EpisodeId] ON [App].[PodcastProgress];

    -- EXEC: a coluna pode já não existir quando o batch é compilado
    EXEC(N'ALTER TABLE [App].[PodcastProgress] DROP COLUMN [EpisodeId]');
END
GO

IF COL_LENGTH('App.PodcastProgress', 'PodcastEpisodeId') IS NULL
BEGIN
    ALTER TABLE [App].[PodcastProgress] ADD [PodcastEpisodeId] [uniqueidentifier] NOT NULL
        CONSTRAINT [DF_PodcastProgress_PodcastEpisodeId] DEFAULT ('00000000-0000-0000-0000-000000000000');
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE Name = 'IX_PodcastProgress_PodcastEpisodeId' AND object_id = object_id('[App].[PodcastProgress]'))
    CREATE NONCLUSTERED INDEX [IX_PodcastProgress_PodcastEpisodeId] ON [App].[PodcastProgress] ([PodcastEpisodeId]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE Name = 'IX_PodcastProgress_UserId_PodcastEpisodeId' AND object_id = object_id('[App].[PodcastProgress]'))
    CREATE UNIQUE NONCLUSTERED INDEX [IX_PodcastProgress_UserId_PodcastEpisodeId] ON [App].[PodcastProgress] ([UserId], [PodcastEpisodeId]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_PodcastProgress_PodcastEpisodes_PodcastEpisodeId')
    ALTER TABLE [App].[PodcastProgress] ADD CONSTRAINT [FK_PodcastProgress_PodcastEpisodes_PodcastEpisodeId]
        FOREIGN KEY ([PodcastEpisodeId]) REFERENCES [App].[PodcastEpisodes] ([Id]) ON DELETE CASCADE;
GO
