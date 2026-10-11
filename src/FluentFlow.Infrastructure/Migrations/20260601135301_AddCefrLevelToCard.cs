using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace FluentFlow.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddCefrLevelToCard : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "CefrLevel",
                schema: "App",
                table: "Cards",
                type: "nvarchar(2)",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_Cards_CefrLevel",
                schema: "App",
                table: "Cards",
                column: "CefrLevel");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_Cards_CefrLevel",
                schema: "App",
                table: "Cards");

            migrationBuilder.DropColumn(
                name: "CefrLevel",
                schema: "App",
                table: "Cards");
        }
    }
}
