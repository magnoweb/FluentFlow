using FluentFlow.Core.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FluentFlow.Infrastructure.Data.Configurations;

public class TranslationCacheMap : IEntityTypeConfiguration<TranslationCache>
{
    public void Configure(EntityTypeBuilder<TranslationCache> builder)
    {
        builder.HasKey(p => p.Id);
        builder.Property(p => p.SourceText).IsRequired().HasColumnType("nvarchar(1000)");
        builder.Property(p => p.TranslatedText).IsRequired().HasColumnType("nvarchar(1000)");
        builder.Property(p => p.FromLanguage).IsRequired().HasColumnType("nvarchar(10)");
        builder.Property(p => p.ToLanguage).IsRequired().HasColumnType("nvarchar(10)");

        // Índice para lookup rápido
        builder.HasIndex(p => new { p.SourceText, p.FromLanguage, p.ToLanguage })
            .IsUnique();

        builder.ToTable(schema: "App", name: "TranslationCache");
    }
}