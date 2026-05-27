using FluentFlow.Core.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FluentFlow.Infrastructure.Data.Configurations;

public class StudyReviewMap : IEntityTypeConfiguration<StudyReview>
{
    public void Configure(EntityTypeBuilder<StudyReview> builder)
    {
        builder.HasKey(p => p.Id);
        builder.Property(p => p.Mode).IsRequired().HasConversion<string>().HasColumnType("nvarchar(20)");
        builder.Property(p => p.SimilarityScore).HasColumnType("float");
        builder.Property(p => p.TranscribedText).HasColumnType("nvarchar(1000)");

        builder.ToTable(schema: "App", name: "StudyReviews");
    }
}