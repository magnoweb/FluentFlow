using FluentFlow.Core.Entities;
using FluentFlow.Infrastructure.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FluentFlow.Infrastructure.Data.Configurations;

public class DeckMap : IEntityTypeConfiguration<Deck>
{
    public void Configure(EntityTypeBuilder<Deck> builder)
    {
        builder.HasKey(p => p.Id);
        builder.Property(p => p.Name).IsRequired().HasColumnType("nvarchar(200)");
        builder.Property(p => p.Description).HasColumnType("nvarchar(500)");
        builder.Property(p => p.Language).IsRequired().HasColumnType("nvarchar(10)");
        builder.Property(p => p.NativeLanguage).IsRequired().HasColumnType("nvarchar(10)");
        builder.Property(p => p.CreatedAt).IsRequired();
        builder.Property(p => p.UpdatedAt).IsRequired();

        // A relação com ApplicationUser é configurada aqui, no Infrastructure
        builder.HasOne<ApplicationUser>()
            .WithMany(u => u.Decks)
            .HasForeignKey(d => d.UserId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasMany(p => p.Cards)
            .WithOne(p => p.Deck)
            .HasForeignKey(c => c.DeckId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasMany(p => p.Sessions)
            .WithOne(p => p.Deck)
            .HasForeignKey(c => c.DeckId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasMany(p => p.BatchJobs)
            .WithOne(p => p.Deck)
            .HasForeignKey(c => c.DeckId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.ToTable(schema: "App", name: "Decks");
    }
}