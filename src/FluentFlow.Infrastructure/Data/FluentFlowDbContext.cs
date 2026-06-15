using FluentFlow.Core.Entities;
using FluentFlow.Infrastructure.Identity;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;

namespace FluentFlow.Infrastructure.Data;

public class FluentFlowDbContext : IdentityDbContext<ApplicationUser, IdentityRole<Guid>, Guid>
{
    public FluentFlowDbContext(DbContextOptions<FluentFlowDbContext> options) : base(options) { }

    public DbSet<Deck> Decks => Set<Deck>();
    public DbSet<Card> Cards => Set<Card>();
    public DbSet<StudySession> StudySessions => Set<StudySession>();
    public DbSet<StudyReview> StudyReviews => Set<StudyReview>();
    public DbSet<ReviewHistory> ReviewHistory => Set<ReviewHistory>();
    public DbSet<AudioBatchJob> AudioBatchJobs => Set<AudioBatchJob>();
    public DbSet<AudioBatchItem> AudioBatchItems => Set<AudioBatchItem>();
    public DbSet<TranslationCache> TranslationCache => Set<TranslationCache>();
    public DbSet<RefreshToken> RefreshTokens => Set<RefreshToken>();
    public DbSet<AccessLog> AccessLogs => Set<AccessLog>();
    
    // Apenas leitura — gerido pelo Serilog
    public DbSet<Log> Logs => Set<Log>();

    protected override void OnModelCreating(ModelBuilder builder)
    {
        base.OnModelCreating(builder);

        // Identity → schema Core
        builder.Entity<ApplicationUser>(e => { e.ToTable(schema: "Core", name: "Users"); });
        builder.Entity<IdentityRole<Guid>>(e => { e.ToTable(schema: "Core", name: "Roles"); });
        builder.Entity<IdentityUserClaim<Guid>>(e => { e.ToTable(schema: "Core", name: "UserClaims"); });
        builder.Entity<IdentityUserLogin<Guid>>(e => { e.ToTable(schema: "Core", name: "UserLogins"); });
        builder.Entity<IdentityRoleClaim<Guid>>(e => { e.ToTable(schema: "Core", name: "RoleClaims"); });
        builder.Entity<IdentityUserRole<Guid>>(e => { e.ToTable(schema: "Core", name: "UserRoles"); });
        builder.Entity<IdentityUserToken<Guid>>(e => { e.ToTable(schema: "Core", name: "UserTokens"); });

        // Aplicar todas as configurações do assembly
        builder.ApplyConfigurationsFromAssembly(typeof(FluentFlowDbContext).Assembly);
    }

    public override Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        // Auto-update UpdatedAt
        foreach (var entry in ChangeTracker.Entries()
            .Where(e => e.State == EntityState.Modified &&
                        e.Entity.GetType().GetProperty("UpdatedAt") != null))
        {
            entry.Property("UpdatedAt").CurrentValue = DateTime.UtcNow;
        }
        return base.SaveChangesAsync(cancellationToken);
    }
}