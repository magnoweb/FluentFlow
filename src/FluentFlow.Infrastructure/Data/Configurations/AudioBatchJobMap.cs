using FluentFlow.Core.Entities;
using FluentFlow.Infrastructure.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FluentFlow.Infrastructure.Data.Configurations;

public class AudioBatchJobMap : IEntityTypeConfiguration<AudioBatchJob>
{
    public void Configure(EntityTypeBuilder<AudioBatchJob> builder)
    {
        builder.HasKey(p => p.Id);
        builder.Property(p => p.Status).IsRequired().HasConversion<string>().HasColumnType("nvarchar(30)");

        builder.HasOne<ApplicationUser>()
            .WithMany(u => u.AudioBatchJobs)
            .HasForeignKey(p => p.UserId)
            .OnDelete(DeleteBehavior.Restrict);
        
        builder.HasMany(p => p.Items)
            .WithOne(p => p.BatchJob)
            .HasForeignKey(c => c.BatchJobId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.ToTable(schema: "Media", name: "AudioBatchJobs");
    }
}