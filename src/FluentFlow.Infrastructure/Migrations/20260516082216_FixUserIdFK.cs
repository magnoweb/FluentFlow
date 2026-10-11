using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace FluentFlow.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class FixUserIdFK : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_AudioBatchJobs_Users_ApplicationUserId",
                schema: "Media",
                table: "AudioBatchJobs");

            migrationBuilder.DropForeignKey(
                name: "FK_ReviewHistory_Users_ApplicationUserId",
                schema: "App",
                table: "ReviewHistory");

            migrationBuilder.DropIndex(
                name: "IX_ReviewHistory_ApplicationUserId",
                schema: "App",
                table: "ReviewHistory");

            migrationBuilder.DropIndex(
                name: "IX_AudioBatchJobs_ApplicationUserId",
                schema: "Media",
                table: "AudioBatchJobs");

            migrationBuilder.DropColumn(
                name: "ApplicationUserId",
                schema: "App",
                table: "ReviewHistory");

            migrationBuilder.DropColumn(
                name: "ApplicationUserId",
                schema: "Media",
                table: "AudioBatchJobs");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<Guid>(
                name: "ApplicationUserId",
                schema: "App",
                table: "ReviewHistory",
                type: "uniqueidentifier",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "ApplicationUserId",
                schema: "Media",
                table: "AudioBatchJobs",
                type: "uniqueidentifier",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_ReviewHistory_ApplicationUserId",
                schema: "App",
                table: "ReviewHistory",
                column: "ApplicationUserId");

            migrationBuilder.CreateIndex(
                name: "IX_AudioBatchJobs_ApplicationUserId",
                schema: "Media",
                table: "AudioBatchJobs",
                column: "ApplicationUserId");

            migrationBuilder.AddForeignKey(
                name: "FK_AudioBatchJobs_Users_ApplicationUserId",
                schema: "Media",
                table: "AudioBatchJobs",
                column: "ApplicationUserId",
                principalSchema: "Core",
                principalTable: "Users",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_ReviewHistory_Users_ApplicationUserId",
                schema: "App",
                table: "ReviewHistory",
                column: "ApplicationUserId",
                principalSchema: "Core",
                principalTable: "Users",
                principalColumn: "Id");
        }
    }
}
