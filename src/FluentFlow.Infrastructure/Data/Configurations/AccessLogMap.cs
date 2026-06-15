using FluentFlow.Core.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FluentFlow.Infrastructure.Data.Configurations;

public class AccessLogMap : IEntityTypeConfiguration<AccessLog>
{
    public void Configure(EntityTypeBuilder<AccessLog> builder)
    {
        builder.ToTable("AccessLogs");
        builder.HasKey(a => a.Id);

        builder.Property(a => a.Platform).HasMaxLength(20).IsRequired();
        builder.Property(a => a.IpAddress).HasMaxLength(64).IsRequired();
        builder.Property(a => a.UserAgent).HasMaxLength(500);

        builder.HasIndex(a => a.UserId);
        builder.HasIndex(a => a.LoggedInAt);

        // Relação configurada sem navegação inversa em AccessLog
        builder.HasOne<Identity.ApplicationUser>()
            .WithMany()
            .HasForeignKey(a => a.UserId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}