-- Repetições do áudio no modo Listening (equivalente à migração EF 20261010130000_AddDeckListeningRepeatCount)
IF COL_LENGTH('App.Decks', 'ListeningRepeatCount') IS NULL
BEGIN
    ALTER TABLE [App].[Decks] ADD [ListeningRepeatCount] [int] NOT NULL CONSTRAINT [DF_Decks_ListeningRepeatCount] DEFAULT (1)
END
GO
