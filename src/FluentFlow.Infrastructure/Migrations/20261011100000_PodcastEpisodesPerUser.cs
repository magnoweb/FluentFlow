using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace FluentFlow.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class PodcastEpisodesPerUser : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "PodcastEpisodes",
                schema: "App",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    UserId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    ExternalId = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    Title = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    Description = table.Column<string>(type: "nvarchar(1000)", maxLength: 1000, nullable: true),
                    Language = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: false),
                    Level = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: true),
                    Series = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: true),
                    Season = table.Column<int>(type: "int", nullable: true),
                    EpisodeNumber = table.Column<int>(type: "int", nullable: true),
                    DurationMs = table.Column<int>(type: "int", nullable: false),
                    AudioPath = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: false),
                    SlowAudioPath = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true),
                    SlowTempo = table.Column<double>(type: "float", nullable: true),
                    TranscriptJson = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    GeneratedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PodcastEpisodes", x => x.Id);
                    table.ForeignKey(
                        name: "FK_PodcastEpisodes_Users_UserId",
                        column: x => x.UserId,
                        principalSchema: "Core",
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_PodcastEpisodes_UserId_ExternalId",
                schema: "App",
                table: "PodcastEpisodes",
                columns: new[] { "UserId", "ExternalId" },
                unique: true);

            // O progresso antigo apontava para o catálogo em disco (ids de texto) — não há
            // episódios por utilizador a que o ligar, por isso é descartado.
            migrationBuilder.Sql("DELETE FROM [App].[PodcastProgress];");

            migrationBuilder.DropIndex(
                name: "IX_PodcastProgress_UserId_EpisodeId",
                schema: "App",
                table: "PodcastProgress");

            migrationBuilder.DropColumn(
                name: "EpisodeId",
                schema: "App",
                table: "PodcastProgress");

            migrationBuilder.AddColumn<Guid>(
                name: "PodcastEpisodeId",
                schema: "App",
                table: "PodcastProgress",
                type: "uniqueidentifier",
                nullable: false,
                defaultValue: new Guid("00000000-0000-0000-0000-000000000000"));

            migrationBuilder.CreateIndex(
                name: "IX_PodcastProgress_PodcastEpisodeId",
                schema: "App",
                table: "PodcastProgress",
                column: "PodcastEpisodeId");

            migrationBuilder.CreateIndex(
                name: "IX_PodcastProgress_UserId_PodcastEpisodeId",
                schema: "App",
                table: "PodcastProgress",
                columns: new[] { "UserId", "PodcastEpisodeId" },
                unique: true);

            migrationBuilder.AddForeignKey(
                name: "FK_PodcastProgress_PodcastEpisodes_PodcastEpisodeId",
                schema: "App",
                table: "PodcastProgress",
                column: "PodcastEpisodeId",
                principalSchema: "App",
                principalTable: "PodcastEpisodes",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_PodcastProgress_PodcastEpisodes_PodcastEpisodeId",
                schema: "App",
                table: "PodcastProgress");

            migrationBuilder.Sql("DELETE FROM [App].[PodcastProgress];");

            migrationBuilder.DropTable(
                name: "PodcastEpisodes",
                schema: "App");

            migrationBuilder.DropIndex(
                name: "IX_PodcastProgress_PodcastEpisodeId",
                schema: "App",
                table: "PodcastProgress");

            migrationBuilder.DropIndex(
                name: "IX_PodcastProgress_UserId_PodcastEpisodeId",
                schema: "App",
                table: "PodcastProgress");

            migrationBuilder.DropColumn(
                name: "PodcastEpisodeId",
                schema: "App",
                table: "PodcastProgress");

            migrationBuilder.AddColumn<string>(
                name: "EpisodeId",
                schema: "App",
                table: "PodcastProgress",
                type: "nvarchar(100)",
                maxLength: 100,
                nullable: false,
                defaultValue: "");

            migrationBuilder.CreateIndex(
                name: "IX_PodcastProgress_UserId_EpisodeId",
                schema: "App",
                table: "PodcastProgress",
                columns: new[] { "UserId", "EpisodeId" },
                unique: true);
        }
    }
}
