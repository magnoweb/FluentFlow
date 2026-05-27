using FluentFlow.Core.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace FluentFlow.Infrastructure.Data.Configurations;

public class LogMap : IEntityTypeConfiguration<Log>
{
    public void Configure(EntityTypeBuilder<Log> builder)
    {
        builder.HasKey(p => p.Id);
        builder.Property(p => p.Id).ValueGeneratedOnAdd();
        builder.Property(p => p.Message).HasColumnType("nvarchar(max)");
        builder.Property(p => p.MessageTemplate).HasColumnType("nvarchar(max)");
        builder.Property(p => p.Level).HasColumnType("nvarchar(128)");
        builder.Property(p => p.Exception).HasColumnType("nvarchar(max)");
        builder.Property(p => p.LogEvent).HasColumnType("nvarchar(max)");

        // Properties é XML no DB — lido como string
        builder.Property(p => p.Properties).HasColumnType("xml").HasColumnName("Properties");

        // Tabela gerida pelo Serilog — EF só lê, nunca escreve
        builder.ToTable(schema: "Core", name: "Logs");
        builder.HasAnnotation("Relational:IsTableExcludedFromMigrations", true);
    }
}