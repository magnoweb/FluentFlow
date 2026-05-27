using FluentFlow.Core.Entities;
using FluentFlow.Core.Enums;
using FluentFlow.Infrastructure.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FluentFlow.Infrastructure.Data.Configurations;

public class ReviewHistoryMap : IEntityTypeConfiguration<ReviewHistory>
{
    public void Configure(EntityTypeBuilder<ReviewHistory> builder)
    {
        builder.HasKey(p => p.Id);

        builder.Property(p => p.Date).IsRequired();
        builder.Property(p => p.Mode) .IsRequired() .HasConversion<string>() .HasColumnType("nvarchar(20)");
        builder.Property(p => p.CardsReviewed).IsRequired();
        builder.Property(p => p.CardsNew).IsRequired();
        builder.Property(p => p.AverageScore).HasColumnType("float");
        builder.Property(p => p.CreatedAt).IsRequired();
        builder.Property(p => p.UpdatedAt).IsRequired();

        // FK para ApplicationUser — sem navigation no Core
        builder.HasOne<ApplicationUser>()
            .WithMany(u => u.ReviewHistories)
            .HasForeignKey(p => p.UserId)
            .OnDelete(DeleteBehavior.Restrict);

        // FK para Deck
        builder.HasOne<Deck>()
            .WithMany()
            .HasForeignKey(p => p.DeckId)
            .OnDelete(DeleteBehavior.Restrict);

        // Índice para queries de dashboard (filtro por utilizador + data)
        builder.HasIndex(p => new { p.UserId, p.Date });

        builder.ToTable(schema: "App", name: "ReviewHistory");
    }
}