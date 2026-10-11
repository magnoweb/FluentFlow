using FluentFlow.Core.Entities;
using FluentFlow.Infrastructure.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FluentFlow.Infrastructure.Data.Configurations;

public class PodcastProgressMap : IEntityTypeConfiguration<PodcastProgress>
{
    public void Configure(EntityTypeBuilder<PodcastProgress> builder)
    {
        builder.HasKey(p => p.Id);

        // Um registo por utilizador/episódio (o índice também serve a FK de UserId)
        builder.HasIndex(p => new { p.UserId, p.PodcastEpisodeId }).IsUnique();

        builder.HasOne<ApplicationUser>()
            .WithMany()
            .HasForeignKey(p => p.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        // A relação com PodcastEpisode (cascade) está em PodcastEpisodeMap

        builder.ToTable(schema: "App", name: "PodcastProgress");
    }
}
