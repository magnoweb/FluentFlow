using FluentFlow.Core.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FluentFlow.Infrastructure.Data.Configurations;

public class AudioBatchItemMap : IEntityTypeConfiguration<AudioBatchItem>
{
    public void Configure(EntityTypeBuilder<AudioBatchItem> builder)
    {
        builder.HasKey(p => p.Id);
        builder.Property(p => p.FileName).IsRequired().HasColumnType("nvarchar(260)");
        builder.Property(p => p.FilePath).IsRequired().HasColumnType("nvarchar(500)");
        builder.Property(p => p.Status).IsRequired().HasConversion<string>().HasColumnType("nvarchar(30)");
        builder.Property(p => p.TranscribedText).HasColumnType("nvarchar(max)");
        builder.Property(p => p.TranslatedText).HasColumnType("nvarchar(max)");
        builder.Property(p => p.ErrorMessage).HasColumnType("nvarchar(1000)");

        builder.ToTable(schema: "Media", name: "AudioBatchItems");
    }
}