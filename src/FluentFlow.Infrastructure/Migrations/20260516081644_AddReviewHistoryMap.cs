using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace FluentFlow.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddReviewHistoryMap : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameTable(
                name: "ReviewHistory",
                newName: "ReviewHistory",
                newSchema: "App");

            migrationBuilder.AddColumn<Guid>(
                name: "ApplicationUserId",
                schema: "Media",
                table: "AudioBatchJobs",
                type: "uniqueidentifier",
                nullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "Mode",
                schema: "App",
                table: "ReviewHistory",
                type: "nvarchar(20)",
                nullable: false,
                oldClrType: typeof(int),
                oldType: "int");

            migrationBuilder.AddColumn<Guid>(
                name: "ApplicationUserId",
                schema: "App",
                table: "ReviewHistory",
                type: "uniqueidentifier",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_StudySessions_UserId",
                schema: "App",
                table: "StudySessions",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_AudioBatchJobs_ApplicationUserId",
                schema: "Media",
                table: "AudioBatchJobs",
                column: "ApplicationUserId");

            migrationBuilder.CreateIndex(
                name: "IX_AudioBatchJobs_UserId",
                schema: "Media",
                table: "AudioBatchJobs",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_ReviewHistory_ApplicationUserId",
                schema: "App",
                table: "ReviewHistory",
                column: "ApplicationUserId");

            migrationBuilder.CreateIndex(
                name: "IX_ReviewHistory_DeckId",
                schema: "App",
                table: "ReviewHistory",
                column: "DeckId");

            migrationBuilder.CreateIndex(
                name: "IX_ReviewHistory_UserId_Date",
                schema: "App",
                table: "ReviewHistory",
                columns: new[] { "UserId", "Date" });

            migrationBuilder.AddForeignKey(
                name: "FK_AudioBatchJobs_Users_ApplicationUserId",
                schema: "Media",
                table: "AudioBatchJobs",
                column: "ApplicationUserId",
                principalSchema: "Core",
                principalTable: "Users",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_AudioBatchJobs_Users_UserId",
                schema: "Media",
                table: "AudioBatchJobs",
                column: "UserId",
                principalSchema: "Core",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_ReviewHistory_Decks_DeckId",
                schema: "App",
                table: "ReviewHistory",
                column: "DeckId",
                principalSchema: "App",
                principalTable: "Decks",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_ReviewHistory_Users_ApplicationUserId",
                schema: "App",
                table: "ReviewHistory",
                column: "ApplicationUserId",
                principalSchema: "Core",
                principalTable: "Users",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_ReviewHistory_Users_UserId",
                schema: "App",
                table: "ReviewHistory",
                column: "UserId",
                principalSchema: "Core",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_StudySessions_Users_UserId",
                schema: "App",
                table: "StudySessions",
                column: "UserId",
                principalSchema: "Core",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_AudioBatchJobs_Users_ApplicationUserId",
                schema: "Media",
                table: "AudioBatchJobs");

            migrationBuilder.DropForeignKey(
                name: "FK_AudioBatchJobs_Users_UserId",
                schema: "Media",
                table: "AudioBatchJobs");

            migrationBuilder.DropForeignKey(
                name: "FK_ReviewHistory_Decks_DeckId",
                schema: "App",
                table: "ReviewHistory");

            migrationBuilder.DropForeignKey(
                name: "FK_ReviewHistory_Users_ApplicationUserId",
                schema: "App",
                table: "ReviewHistory");

            migrationBuilder.DropForeignKey(
                name: "FK_ReviewHistory_Users_UserId",
                schema: "App",
                table: "ReviewHistory");

            migrationBuilder.DropForeignKey(
                name: "FK_StudySessions_Users_UserId",
                schema: "App",
                table: "StudySessions");

            migrationBuilder.DropIndex(
                name: "IX_StudySessions_UserId",
                schema: "App",
                table: "StudySessions");

            migrationBuilder.DropIndex(
                name: "IX_AudioBatchJobs_ApplicationUserId",
                schema: "Media",
                table: "AudioBatchJobs");

            migrationBuilder.DropIndex(
                name: "IX_AudioBatchJobs_UserId",
                schema: "Media",
                table: "AudioBatchJobs");

            migrationBuilder.DropIndex(
                name: "IX_ReviewHistory_ApplicationUserId",
                schema: "App",
                table: "ReviewHistory");

            migrationBuilder.DropIndex(
                name: "IX_ReviewHistory_DeckId",
                schema: "App",
                table: "ReviewHistory");

            migrationBuilder.DropIndex(
                name: "IX_ReviewHistory_UserId_Date",
                schema: "App",
                table: "ReviewHistory");

            migrationBuilder.DropColumn(
                name: "ApplicationUserId",
                schema: "Media",
                table: "AudioBatchJobs");

            migrationBuilder.DropColumn(
                name: "ApplicationUserId",
                schema: "App",
                table: "ReviewHistory");

            migrationBuilder.RenameTable(
                name: "ReviewHistory",
                schema: "App",
                newName: "ReviewHistory");

            migrationBuilder.AlterColumn<int>(
                name: "Mode",
                table: "ReviewHistory",
                type: "int",
                nullable: false,
                oldClrType: typeof(string),
                oldType: "nvarchar(20)");
        }
    }
}
