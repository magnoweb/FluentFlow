using FluentFlow.Core.Entities;
using FluentFlow.Infrastructure.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FluentFlow.Infrastructure.Data.Configurations;

public class StudySessionMap : IEntityTypeConfiguration<StudySession>
{
    public void Configure(EntityTypeBuilder<StudySession> builder)
    {
        builder.HasKey(p => p.Id);
        builder.Property(p => p.Mode).IsRequired().HasConversion<string>().HasColumnType("nvarchar(20)");

        // A relação com ApplicationUser é configurada aqui, no Infrastructure
        builder.HasOne<ApplicationUser>()
            .WithMany(u => u.StudySessions)
            .HasForeignKey(d => d.UserId)
            .OnDelete(DeleteBehavior.Restrict);
        
        builder.HasMany(p => p.Reviews)
            .WithOne(p => p.Session)
            .HasForeignKey(c => c.SessionId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.ToTable(schema: "App", name: "StudySessions");
    }
}