using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace FluentFlow.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddPodcastProgress : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "PodcastProgress",
                schema: "App",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    UserId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    EpisodeId = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    PositionMs = table.Column<int>(type: "int", nullable: false),
                    DurationMs = table.Column<int>(type: "int", nullable: false),
                    IsCompleted = table.Column<bool>(type: "bit", nullable: false),
                    CompletedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    PlayCount = table.Column<int>(type: "int", nullable: false),
                    IsFavorite = table.Column<bool>(type: "bit", nullable: false),
                    LastPlayedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PodcastProgress", x => x.Id);
                    table.ForeignKey(
                        name: "FK_PodcastProgress_Users_UserId",
                        column: x => x.UserId,
                        principalSchema: "Core",
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            // EXEC (em vez de CreateIndex): no script idempotente este batch é compilado mesmo
            // quando a migração já foi aplicada; como a 20261011100000_PodcastEpisodesPerUser
            // remove a coluna EpisodeId, um CREATE INDEX directo dava "Invalid column name 'EpisodeId'".
            migrationBuilder.Sql(
                "EXEC(N'CREATE UNIQUE INDEX [IX_PodcastProgress_UserId_EpisodeId] ON [App].[PodcastProgress] ([UserId], [EpisodeId])');");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "PodcastProgress",
                schema: "App");
        }
    }
}
