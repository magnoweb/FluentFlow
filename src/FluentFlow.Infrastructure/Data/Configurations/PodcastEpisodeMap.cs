using FluentFlow.Core.Entities;
using FluentFlow.Infrastructure.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FluentFlow.Infrastructure.Data.Configurations;

public class PodcastEpisodeMap : IEntityTypeConfiguration<PodcastEpisode>
{
    public void Configure(EntityTypeBuilder<PodcastEpisode> builder)
    {
        builder.HasKey(p => p.Id);

        builder.Property(p => p.ExternalId).HasMaxLength(100).IsRequired();
        builder.Property(p => p.Title).HasMaxLength(200).IsRequired();
        builder.Property(p => p.Description).HasMaxLength(1000);
        builder.Property(p => p.Language).HasMaxLength(20).IsRequired();
        builder.Property(p => p.Level).HasMaxLength(20);
        builder.Property(p => p.Series).HasMaxLength(200);
        builder.Property(p => p.AudioPath).HasMaxLength(500).IsRequired();
        builder.Property(p => p.SlowAudioPath).HasMaxLength(500);
        builder.Property(p => p.TranscriptJson).HasColumnType("nvarchar(max)").IsRequired();

        // Reenviar o mesmo episódio substitui-o (o índice também serve a FK de UserId)
        builder.HasIndex(p => new { p.UserId, p.ExternalId }).IsUnique();

        // Restrict (como nos Decks) para evitar múltiplos caminhos de cascade até ao progresso
        builder.HasOne<ApplicationUser>()
            .WithMany()
            .HasForeignKey(p => p.UserId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasMany(p => p.Progress)
            .WithOne(p => p.PodcastEpisode)
            .HasForeignKey(p => p.PodcastEpisodeId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.ToTable(schema: "App", name: "PodcastEpisodes");
    }
}
