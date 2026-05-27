using FluentFlow.Core.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FluentFlow.Infrastructure.Data.Configurations;

public class CardMap : IEntityTypeConfiguration<Card>
{
    public void Configure(EntityTypeBuilder<Card> builder)
    {
        builder.HasKey(p => p.Id);
        builder.Property(p => p.Front).IsRequired().HasColumnType("nvarchar(1000)");
        builder.Property(p => p.Back).IsRequired().HasColumnType("nvarchar(1000)");
        builder.Property(p => p.Pronunciation).HasColumnType("nvarchar(500)");
        builder.Property(p => p.AudioPath).HasColumnType("nvarchar(500)");
        builder.Property(p => p.ListeningEaseFactor).HasColumnType("float");
        builder.Property(p => p.SpeakingEaseFactor).HasColumnType("float");

        builder.HasMany(p => p.Reviews)
            .WithOne(p => p.Card)
            .HasForeignKey(c => c.CardId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.ToTable(schema: "App", name: "Cards");
    }
}