using FluentFlow.Core.Entities;
using FluentFlow.Infrastructure.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FluentFlow.Infrastructure.Data.Configurations;

public class RefreshTokenMap : IEntityTypeConfiguration<RefreshToken>
{
    public void Configure(EntityTypeBuilder<RefreshToken> builder)
    {
        builder.HasKey(p => p.Id);
        builder.Property(p => p.Token).IsRequired().HasColumnType("nvarchar(500)");
        builder.Property(p => p.ReplacedByToken).HasColumnType("nvarchar(500)");
        builder.Property(p => p.CreatedByIp).HasColumnType("nvarchar(50)");

        builder.HasOne<ApplicationUser>()
            .WithMany()
            .HasForeignKey(p => p.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasIndex(p => p.Token).IsUnique();
        builder.HasIndex(p => p.UserId);

        builder.ToTable(schema: "Core", name: "RefreshTokens");
    }
}