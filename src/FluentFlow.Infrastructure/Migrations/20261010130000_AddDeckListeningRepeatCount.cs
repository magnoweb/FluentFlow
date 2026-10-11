using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace FluentFlow.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddDeckListeningRepeatCount : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // Decks existentes ficam com 1 (sem repetição)
            migrationBuilder.AddColumn<int>(
                name: "ListeningRepeatCount",
                schema: "App",
                table: "Decks",
                type: "int",
                nullable: false,
                defaultValue: 1);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "ListeningRepeatCount",
                schema: "App",
                table: "Decks");
        }
    }
}
