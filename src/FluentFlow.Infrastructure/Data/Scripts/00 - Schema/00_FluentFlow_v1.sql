IF OBJECT_ID(N'[__EFMigrationsHistory]') IS NULL
BEGIN
    CREATE TABLE [__EFMigrationsHistory] (
        [MigrationId] nvarchar(150) NOT NULL,
        [ProductVersion] nvarchar(32) NOT NULL,
        CONSTRAINT [PK___EFMigrationsHistory] PRIMARY KEY ([MigrationId])
    );
END;
GO

BEGIN TRANSACTION;
IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260516080330_InitialCreate'
)
BEGIN
    IF SCHEMA_ID(N'Media') IS NULL EXEC(N'CREATE SCHEMA [Media];');
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260516080330_InitialCreate'
)
BEGIN
    IF SCHEMA_ID(N'App') IS NULL EXEC(N'CREATE SCHEMA [App];');
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260516080330_InitialCreate'
)
BEGIN
    IF SCHEMA_ID(N'Core') IS NULL EXEC(N'CREATE SCHEMA [Core];');
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260516080330_InitialCreate'
)
BEGIN
    CREATE TABLE [ReviewHistory] (
        [Id] uniqueidentifier NOT NULL,
        [UserId] uniqueidentifier NOT NULL,
        [DeckId] uniqueidentifier NOT NULL,
        [Date] datetime2 NOT NULL,
        [Mode] int NOT NULL,
        [CardsReviewed] int NOT NULL,
        [CardsNew] int NOT NULL,
        [AverageScore] float NOT NULL,
        [CreatedAt] datetime2 NOT NULL,
        [UpdatedAt] datetime2 NOT NULL,
        CONSTRAINT [PK_ReviewHistory] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260516080330_InitialCreate'
)
BEGIN
    CREATE TABLE [Core].[Roles] (
        [Id] uniqueidentifier NOT NULL,
        [Name] nvarchar(256) NULL,
        [NormalizedName] nvarchar(256) NULL,
        [ConcurrencyStamp] nvarchar(max) NULL,
        CONSTRAINT [PK_Roles] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260516080330_InitialCreate'
)
BEGIN
    CREATE TABLE [Core].[Users] (
        [Id] uniqueidentifier NOT NULL,
        [UserType] int NOT NULL,
        [Name] nvarchar(max) NOT NULL,
        [IsEnabled] bit NOT NULL,
        [ProfileImageUrl] nvarchar(max) NULL,
        [CreatedAt] datetime2 NOT NULL,
        [UserName] nvarchar(256) NULL,
        [NormalizedUserName] nvarchar(256) NULL,
        [Email] nvarchar(256) NULL,
        [NormalizedEmail] nvarchar(256) NULL,
        [EmailConfirmed] bit NOT NULL,
        [PasswordHash] nvarchar(max) NULL,
        [SecurityStamp] nvarchar(max) NULL,
        [ConcurrencyStamp] nvarchar(max) NULL,
        [PhoneNumber] nvarchar(max) NULL,
        [PhoneNumberConfirmed] bit NOT NULL,
        [TwoFactorEnabled] bit NOT NULL,
        [LockoutEnd] datetimeoffset NULL,
        [LockoutEnabled] bit NOT NULL,
        [AccessFailedCount] int NOT NULL,
        CONSTRAINT [PK_Users] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260516080330_InitialCreate'
)
BEGIN
    CREATE TABLE [Core].[RoleClaims] (
        [Id] int NOT NULL IDENTITY,
        [RoleId] uniqueidentifier NOT NULL,
        [ClaimType] nvarchar(max) NULL,
        [ClaimValue] nvarchar(max) NULL,
        CONSTRAINT [PK_RoleClaims] PRIMARY KEY ([Id]),
        CONSTRAINT [FK_RoleClaims_Roles_RoleId] FOREIGN KEY ([RoleId]) REFERENCES [Core].[Roles] ([Id]) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260516080330_InitialCreate'
)
BEGIN
    CREATE TABLE [App].[Decks] (
        [Id] uniqueidentifier NOT NULL,
        [UserId] uniqueidentifier NOT NULL,
        [Name] nvarchar(200) NOT NULL,
        [Description] nvarchar(500) NULL,
        [Language] nvarchar(10) NOT NULL,
        [NativeLanguage] nvarchar(10) NOT NULL,
        [MaxNewCardsPerDay] int NOT NULL,
        [MaxReviewsPerDay] int NOT NULL,
        [IsActive] bit NOT NULL,
        [CreatedAt] datetime2 NOT NULL,
        [UpdatedAt] datetime2 NOT NULL,
        CONSTRAINT [PK_Decks] PRIMARY KEY ([Id]),
        CONSTRAINT [FK_Decks_Users_UserId] FOREIGN KEY ([UserId]) REFERENCES [Core].[Users] ([Id]) ON DELETE NO ACTION
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260516080330_InitialCreate'
)
BEGIN
    CREATE TABLE [Core].[UserClaims] (
        [Id] int NOT NULL IDENTITY,
        [UserId] uniqueidentifier NOT NULL,
        [ClaimType] nvarchar(max) NULL,
        [ClaimValue] nvarchar(max) NULL,
        CONSTRAINT [PK_UserClaims] PRIMARY KEY ([Id]),
        CONSTRAINT [FK_UserClaims_Users_UserId] FOREIGN KEY ([UserId]) REFERENCES [Core].[Users] ([Id]) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260516080330_InitialCreate'
)
BEGIN
    CREATE TABLE [Core].[UserLogins] (
        [LoginProvider] nvarchar(450) NOT NULL,
        [ProviderKey] nvarchar(450) NOT NULL,
        [ProviderDisplayName] nvarchar(max) NULL,
        [UserId] uniqueidentifier NOT NULL,
        CONSTRAINT [PK_UserLogins] PRIMARY KEY ([LoginProvider], [ProviderKey]),
        CONSTRAINT [FK_UserLogins_Users_UserId] FOREIGN KEY ([UserId]) REFERENCES [Core].[Users] ([Id]) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260516080330_InitialCreate'
)
BEGIN
    CREATE TABLE [Core].[UserRoles] (
        [UserId] uniqueidentifier NOT NULL,
        [RoleId] uniqueidentifier NOT NULL,
        CONSTRAINT [PK_UserRoles] PRIMARY KEY ([UserId], [RoleId]),
        CONSTRAINT [FK_UserRoles_Roles_RoleId] FOREIGN KEY ([RoleId]) REFERENCES [Core].[Roles] ([Id]) ON DELETE CASCADE,
        CONSTRAINT [FK_UserRoles_Users_UserId] FOREIGN KEY ([UserId]) REFERENCES [Core].[Users] ([Id]) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260516080330_InitialCreate'
)
BEGIN
    CREATE TABLE [Core].[UserTokens] (
        [UserId] uniqueidentifier NOT NULL,
        [LoginProvider] nvarchar(450) NOT NULL,
        [Name] nvarchar(450) NOT NULL,
        [Value] nvarchar(max) NULL,
        CONSTRAINT [PK_UserTokens] PRIMARY KEY ([UserId], [LoginProvider], [Name]),
        CONSTRAINT [FK_UserTokens_Users_UserId] FOREIGN KEY ([UserId]) REFERENCES [Core].[Users] ([Id]) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260516080330_InitialCreate'
)
BEGIN
    CREATE TABLE [Media].[AudioBatchJobs] (
        [Id] uniqueidentifier NOT NULL,
        [DeckId] uniqueidentifier NOT NULL,
        [UserId] uniqueidentifier NOT NULL,
        [Status] nvarchar(30) NOT NULL,
        [TotalFiles] int NOT NULL,
        [ProcessedFiles] int NOT NULL,
        [FailedFiles] int NOT NULL,
        [StartedAt] datetime2 NULL,
        [CompletedAt] datetime2 NULL,
        [CreatedAt] datetime2 NOT NULL,
        [UpdatedAt] datetime2 NOT NULL,
        CONSTRAINT [PK_AudioBatchJobs] PRIMARY KEY ([Id]),
        CONSTRAINT [FK_AudioBatchJobs_Decks_DeckId] FOREIGN KEY ([DeckId]) REFERENCES [App].[Decks] ([Id]) ON DELETE NO ACTION
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260516080330_InitialCreate'
)
BEGIN
    CREATE TABLE [App].[Cards] (
        [Id] uniqueidentifier NOT NULL,
        [DeckId] uniqueidentifier NOT NULL,
        [Front] nvarchar(1000) NOT NULL,
        [Back] nvarchar(1000) NOT NULL,
        [Pronunciation] nvarchar(500) NULL,
        [AudioPath] nvarchar(500) NULL,
        [ListeningRepetitions] int NOT NULL,
        [ListeningEaseFactor] float NOT NULL,
        [ListeningInterval] int NOT NULL,
        [ListeningNextReview] datetime2 NULL,
        [SpeakingRepetitions] int NOT NULL,
        [SpeakingEaseFactor] float NOT NULL,
        [SpeakingInterval] int NOT NULL,
        [SpeakingNextReview] datetime2 NULL,
        [IsActive] bit NOT NULL,
        [CreatedAt] datetime2 NOT NULL,
        [UpdatedAt] datetime2 NOT NULL,
        CONSTRAINT [PK_Cards] PRIMARY KEY ([Id]),
        CONSTRAINT [FK_Cards_Decks_DeckId] FOREIGN KEY ([DeckId]) REFERENCES [App].[Decks] ([Id]) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260516080330_InitialCreate'
)
BEGIN
    CREATE TABLE [App].[StudySessions] (
        [Id] uniqueidentifier NOT NULL,
        [DeckId] uniqueidentifier NOT NULL,
        [UserId] uniqueidentifier NOT NULL,
        [Mode] nvarchar(20) NOT NULL,
        [StartedAt] datetime2 NOT NULL,
        [EndedAt] datetime2 NULL,
        [TotalCards] int NOT NULL,
        [ReviewedCards] int NOT NULL,
        [CreatedAt] datetime2 NOT NULL,
        [UpdatedAt] datetime2 NOT NULL,
        CONSTRAINT [PK_StudySessions] PRIMARY KEY ([Id]),
        CONSTRAINT [FK_StudySessions_Decks_DeckId] FOREIGN KEY ([DeckId]) REFERENCES [App].[Decks] ([Id]) ON DELETE NO ACTION
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260516080330_InitialCreate'
)
BEGIN
    CREATE TABLE [Media].[AudioBatchItems] (
        [Id] uniqueidentifier NOT NULL,
        [BatchJobId] uniqueidentifier NOT NULL,
        [FileName] nvarchar(260) NOT NULL,
        [FilePath] nvarchar(500) NOT NULL,
        [Status] nvarchar(30) NOT NULL,
        [TranscribedText] nvarchar(max) NULL,
        [TranslatedText] nvarchar(max) NULL,
        [ErrorMessage] nvarchar(1000) NULL,
        [RetryCount] int NOT NULL,
        [CreatedAt] datetime2 NOT NULL,
        [UpdatedAt] datetime2 NOT NULL,
        CONSTRAINT [PK_AudioBatchItems] PRIMARY KEY ([Id]),
        CONSTRAINT [FK_AudioBatchItems_AudioBatchJobs_BatchJobId] FOREIGN KEY ([BatchJobId]) REFERENCES [Media].[AudioBatchJobs] ([Id]) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260516080330_InitialCreate'
)
BEGIN
    CREATE TABLE [App].[StudyReviews] (
        [Id] uniqueidentifier NOT NULL,
        [SessionId] uniqueidentifier NOT NULL,
        [CardId] uniqueidentifier NOT NULL,
        [Mode] nvarchar(20) NOT NULL,
        [Score] int NOT NULL,
        [SimilarityScore] float NULL,
        [TranscribedText] nvarchar(1000) NULL,
        [PreviousInterval] int NOT NULL,
        [NewInterval] int NOT NULL,
        [ReviewedAt] datetime2 NOT NULL,
        [CreatedAt] datetime2 NOT NULL,
        [UpdatedAt] datetime2 NOT NULL,
        CONSTRAINT [PK_StudyReviews] PRIMARY KEY ([Id]),
        CONSTRAINT [FK_StudyReviews_Cards_CardId] FOREIGN KEY ([CardId]) REFERENCES [App].[Cards] ([Id]) ON DELETE NO ACTION,
        CONSTRAINT [FK_StudyReviews_StudySessions_SessionId] FOREIGN KEY ([SessionId]) REFERENCES [App].[StudySessions] ([Id]) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260516080330_InitialCreate'
)
BEGIN
    CREATE INDEX [IX_AudioBatchItems_BatchJobId] ON [Media].[AudioBatchItems] ([BatchJobId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260516080330_InitialCreate'
)
BEGIN
    CREATE INDEX [IX_AudioBatchJobs_DeckId] ON [Media].[AudioBatchJobs] ([DeckId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260516080330_InitialCreate'
)
BEGIN
    CREATE INDEX [IX_Cards_DeckId] ON [App].[Cards] ([DeckId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260516080330_InitialCreate'
)
BEGIN
    CREATE INDEX [IX_Decks_UserId] ON [App].[Decks] ([UserId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260516080330_InitialCreate'
)
BEGIN
    CREATE INDEX [IX_RoleClaims_RoleId] ON [Core].[RoleClaims] ([RoleId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260516080330_InitialCreate'
)
BEGIN
    EXEC(N'CREATE UNIQUE INDEX [RoleNameIndex] ON [Core].[Roles] ([NormalizedName]) WHERE [NormalizedName] IS NOT NULL');
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260516080330_InitialCreate'
)
BEGIN
    CREATE INDEX [IX_StudyReviews_CardId] ON [App].[StudyReviews] ([CardId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260516080330_InitialCreate'
)
BEGIN
    CREATE INDEX [IX_StudyReviews_SessionId] ON [App].[StudyReviews] ([SessionId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260516080330_InitialCreate'
)
BEGIN
    CREATE INDEX [IX_StudySessions_DeckId] ON [App].[StudySessions] ([DeckId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260516080330_InitialCreate'
)
BEGIN
    CREATE INDEX [IX_UserClaims_UserId] ON [Core].[UserClaims] ([UserId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260516080330_InitialCreate'
)
BEGIN
    CREATE INDEX [IX_UserLogins_UserId] ON [Core].[UserLogins] ([UserId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260516080330_InitialCreate'
)
BEGIN
    CREATE INDEX [IX_UserRoles_RoleId] ON [Core].[UserRoles] ([RoleId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260516080330_InitialCreate'
)
BEGIN
    CREATE INDEX [EmailIndex] ON [Core].[Users] ([NormalizedEmail]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260516080330_InitialCreate'
)
BEGIN
    EXEC(N'CREATE UNIQUE INDEX [UserNameIndex] ON [Core].[Users] ([NormalizedUserName]) WHERE [NormalizedUserName] IS NOT NULL');
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260516080330_InitialCreate'
)
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20260516080330_InitialCreate', N'10.0.8');
END;

COMMIT;
GO

BEGIN TRANSACTION;
IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260516081644_AddReviewHistoryMap'
)
BEGIN
    ALTER SCHEMA [App] TRANSFER [ReviewHistory];
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260516081644_AddReviewHistoryMap'
)
BEGIN
    ALTER TABLE [Media].[AudioBatchJobs] ADD [ApplicationUserId] uniqueidentifier NULL;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260516081644_AddReviewHistoryMap'
)
BEGIN
    DECLARE @var nvarchar(max);
    SELECT @var = QUOTENAME([d].[name])
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[App].[ReviewHistory]') AND [c].[name] = N'Mode');
    IF @var IS NOT NULL EXEC(N'ALTER TABLE [App].[ReviewHistory] DROP CONSTRAINT ' + @var + ';');
    ALTER TABLE [App].[ReviewHistory] ALTER COLUMN [Mode] nvarchar(20) NOT NULL;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260516081644_AddReviewHistoryMap'
)
BEGIN
    ALTER TABLE [App].[ReviewHistory] ADD [ApplicationUserId] uniqueidentifier NULL;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260516081644_AddReviewHistoryMap'
)
BEGIN
    CREATE INDEX [IX_StudySessions_UserId] ON [App].[StudySessions] ([UserId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260516081644_AddReviewHistoryMap'
)
BEGIN
    CREATE INDEX [IX_AudioBatchJobs_ApplicationUserId] ON [Media].[AudioBatchJobs] ([ApplicationUserId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260516081644_AddReviewHistoryMap'
)
BEGIN
    CREATE INDEX [IX_AudioBatchJobs_UserId] ON [Media].[AudioBatchJobs] ([UserId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260516081644_AddReviewHistoryMap'
)
BEGIN
    CREATE INDEX [IX_ReviewHistory_ApplicationUserId] ON [App].[ReviewHistory] ([ApplicationUserId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260516081644_AddReviewHistoryMap'
)
BEGIN
    CREATE INDEX [IX_ReviewHistory_DeckId] ON [App].[ReviewHistory] ([DeckId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260516081644_AddReviewHistoryMap'
)
BEGIN
    CREATE INDEX [IX_ReviewHistory_UserId_Date] ON [App].[ReviewHistory] ([UserId], [Date]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260516081644_AddReviewHistoryMap'
)
BEGIN
    ALTER TABLE [Media].[AudioBatchJobs] ADD CONSTRAINT [FK_AudioBatchJobs_Users_ApplicationUserId] FOREIGN KEY ([ApplicationUserId]) REFERENCES [Core].[Users] ([Id]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260516081644_AddReviewHistoryMap'
)
BEGIN
    ALTER TABLE [Media].[AudioBatchJobs] ADD CONSTRAINT [FK_AudioBatchJobs_Users_UserId] FOREIGN KEY ([UserId]) REFERENCES [Core].[Users] ([Id]) ON DELETE NO ACTION;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260516081644_AddReviewHistoryMap'
)
BEGIN
    ALTER TABLE [App].[ReviewHistory] ADD CONSTRAINT [FK_ReviewHistory_Decks_DeckId] FOREIGN KEY ([DeckId]) REFERENCES [App].[Decks] ([Id]) ON DELETE NO ACTION;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260516081644_AddReviewHistoryMap'
)
BEGIN
    ALTER TABLE [App].[ReviewHistory] ADD CONSTRAINT [FK_ReviewHistory_Users_ApplicationUserId] FOREIGN KEY ([ApplicationUserId]) REFERENCES [Core].[Users] ([Id]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260516081644_AddReviewHistoryMap'
)
BEGIN
    ALTER TABLE [App].[ReviewHistory] ADD CONSTRAINT [FK_ReviewHistory_Users_UserId] FOREIGN KEY ([UserId]) REFERENCES [Core].[Users] ([Id]) ON DELETE NO ACTION;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260516081644_AddReviewHistoryMap'
)
BEGIN
    ALTER TABLE [App].[StudySessions] ADD CONSTRAINT [FK_StudySessions_Users_UserId] FOREIGN KEY ([UserId]) REFERENCES [Core].[Users] ([Id]) ON DELETE NO ACTION;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260516081644_AddReviewHistoryMap'
)
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20260516081644_AddReviewHistoryMap', N'10.0.8');
END;

COMMIT;
GO

BEGIN TRANSACTION;
IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260516082216_FixUserIdFK'
)
BEGIN
    ALTER TABLE [Media].[AudioBatchJobs] DROP CONSTRAINT [FK_AudioBatchJobs_Users_ApplicationUserId];
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260516082216_FixUserIdFK'
)
BEGIN
    ALTER TABLE [App].[ReviewHistory] DROP CONSTRAINT [FK_ReviewHistory_Users_ApplicationUserId];
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260516082216_FixUserIdFK'
)
BEGIN
    DROP INDEX [IX_ReviewHistory_ApplicationUserId] ON [App].[ReviewHistory];
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260516082216_FixUserIdFK'
)
BEGIN
    DROP INDEX [IX_AudioBatchJobs_ApplicationUserId] ON [Media].[AudioBatchJobs];
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260516082216_FixUserIdFK'
)
BEGIN
    DECLARE @var1 nvarchar(max);
    SELECT @var1 = QUOTENAME([d].[name])
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[App].[ReviewHistory]') AND [c].[name] = N'ApplicationUserId');
    IF @var1 IS NOT NULL EXEC(N'ALTER TABLE [App].[ReviewHistory] DROP CONSTRAINT ' + @var1 + ';');
    ALTER TABLE [App].[ReviewHistory] DROP COLUMN [ApplicationUserId];
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260516082216_FixUserIdFK'
)
BEGIN
    DECLARE @var2 nvarchar(max);
    SELECT @var2 = QUOTENAME([d].[name])
    FROM [sys].[default_constraints] [d]
    INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
    WHERE ([d].[parent_object_id] = OBJECT_ID(N'[Media].[AudioBatchJobs]') AND [c].[name] = N'ApplicationUserId');
    IF @var2 IS NOT NULL EXEC(N'ALTER TABLE [Media].[AudioBatchJobs] DROP CONSTRAINT ' + @var2 + ';');
    ALTER TABLE [Media].[AudioBatchJobs] DROP COLUMN [ApplicationUserId];
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260516082216_FixUserIdFK'
)
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20260516082216_FixUserIdFK', N'10.0.8');
END;

COMMIT;
GO

BEGIN TRANSACTION;
IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260516085712_Phase02_Indexes'
)
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20260516085712_Phase02_Indexes', N'10.0.8');
END;

COMMIT;
GO

BEGIN TRANSACTION;
IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260516125601_Phase03_TranslationCache'
)
BEGIN
    CREATE TABLE [App].[TranslationCache] (
        [Id] uniqueidentifier NOT NULL,
        [SourceText] nvarchar(1000) NOT NULL,
        [TranslatedText] nvarchar(1000) NOT NULL,
        [FromLanguage] nvarchar(10) NOT NULL,
        [ToLanguage] nvarchar(10) NOT NULL,
        [CreatedAt] datetime2 NOT NULL,
        [UpdatedAt] datetime2 NOT NULL,
        CONSTRAINT [PK_TranslationCache] PRIMARY KEY ([Id])
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260516125601_Phase03_TranslationCache'
)
BEGIN
    CREATE UNIQUE INDEX [IX_TranslationCache_SourceText_FromLanguage_ToLanguage] ON [App].[TranslationCache] ([SourceText], [FromLanguage], [ToLanguage]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260516125601_Phase03_TranslationCache'
)
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20260516125601_Phase03_TranslationCache', N'10.0.8');
END;

COMMIT;
GO

BEGIN TRANSACTION;
IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260516130836_Phase03_RefreshTokens'
)
BEGIN
    CREATE TABLE [Core].[RefreshTokens] (
        [Id] uniqueidentifier NOT NULL,
        [UserId] uniqueidentifier NOT NULL,
        [Token] nvarchar(500) NOT NULL,
        [ExpiresAt] datetime2 NOT NULL,
        [IsRevoked] bit NOT NULL,
        [ReplacedByToken] nvarchar(500) NULL,
        [CreatedByIp] nvarchar(50) NULL,
        [CreatedAt] datetime2 NOT NULL,
        [UpdatedAt] datetime2 NOT NULL,
        CONSTRAINT [PK_RefreshTokens] PRIMARY KEY ([Id]),
        CONSTRAINT [FK_RefreshTokens_Users_UserId] FOREIGN KEY ([UserId]) REFERENCES [Core].[Users] ([Id]) ON DELETE CASCADE
    );
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260516130836_Phase03_RefreshTokens'
)
BEGIN
    CREATE UNIQUE INDEX [IX_RefreshTokens_Token] ON [Core].[RefreshTokens] ([Token]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260516130836_Phase03_RefreshTokens'
)
BEGIN
    CREATE INDEX [IX_RefreshTokens_UserId] ON [Core].[RefreshTokens] ([UserId]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260516130836_Phase03_RefreshTokens'
)
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20260516130836_Phase03_RefreshTokens', N'10.0.8');
END;

COMMIT;
GO

BEGIN TRANSACTION;
IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260601135301_AddCefrLevelToCard'
)
BEGIN
    ALTER TABLE [App].[Cards] ADD [CefrLevel] nvarchar(2) NULL;
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260601135301_AddCefrLevelToCard'
)
BEGIN
    CREATE INDEX [IX_Cards_CefrLevel] ON [App].[Cards] ([CefrLevel]);
END;

IF NOT EXISTS (
    SELECT * FROM [__EFMigrationsHistory]
    WHERE [MigrationId] = N'20260601135301_AddCefrLevelToCard'
)
BEGIN
    INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
    VALUES (N'20260601135301_AddCefrLevelToCard', N'10.0.8');
END;

COMMIT;
GO

