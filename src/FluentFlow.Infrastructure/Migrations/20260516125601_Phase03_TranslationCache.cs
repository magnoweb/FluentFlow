using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace FluentFlow.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class Phase03_TranslationCache : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "TranslationCache",
                schema: "App",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    SourceText = table.Column<string>(type: "nvarchar(1000)", nullable: false),
                    TranslatedText = table.Column<string>(type: "nvarchar(1000)", nullable: false),
                    FromLanguage = table.Column<string>(type: "nvarchar(10)", nullable: false),
                    ToLanguage = table.Column<string>(type: "nvarchar(10)", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_TranslationCache", x => x.Id);
                });

            migrationBuilder.CreateIndex(
                name: "IX_TranslationCache_SourceText_FromLanguage_ToLanguage",
                schema: "App",
                table: "TranslationCache",
                columns: new[] { "SourceText", "FromLanguage", "ToLanguage" },
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "TranslationCache",
                schema: "App");
        }
    }
}
