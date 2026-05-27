using System.Collections.ObjectModel;
using System.Data;
using Serilog;
using Serilog.Events;
using Serilog.Sinks.MSSqlServer;

namespace FluentFlow.Api.Extensions;

public static class InjectionConfig
{
    #region Serilog
    
    public static void SerilogConfig(this WebApplicationBuilder builder, IConfiguration configuration)
    {
        builder.Host.UseSerilog((ctx, services, config) =>
        {
            var connStr = ctx.Configuration.GetConnectionString("Default")!;

            var columnOptions = new ColumnOptions();

            // Define explicitamente as colunas padrão
            columnOptions.Store = new Collection<StandardColumn>
            {
                StandardColumn.Id,
                StandardColumn.Message,
                StandardColumn.MessageTemplate,
                StandardColumn.Level,
                StandardColumn.TimeStamp,
                StandardColumn.Exception,
                StandardColumn.Properties,
                StandardColumn.LogEvent
            };

            // Colunas customizadas
            columnOptions.AdditionalColumns = new Collection<SqlColumn>
            {
                new SqlColumn { ColumnName = "UserId", DataType = SqlDbType.UniqueIdentifier, AllowNull = true },
                new SqlColumn { ColumnName = "CardId", DataType = SqlDbType.UniqueIdentifier, AllowNull = true }
            };

            // Remover colunas que não usamos
            // columnOptions.Store.Add(StandardColumn.LogEvent);

            var sinkOptions = new MSSqlServerSinkOptions
            {
                SchemaName = "Core",
                TableName = "Logs",
                AutoCreateSqlTable = false,
                BatchPostingLimit  = 50,
                BatchPeriod = TimeSpan.FromSeconds(5)
            };

            config.ReadFrom.Configuration(ctx.Configuration)
                .ReadFrom.Services(services)
                .Enrich.FromLogContext()
                .Enrich.WithMachineName()
                .Enrich.WithThreadId()
                .WriteTo.Console()
                .WriteTo.MSSqlServer(
                    connectionString: connStr, 
                    sinkOptions: sinkOptions, 
                    columnOptions: columnOptions, 
                    restrictedToMinimumLevel: LogEventLevel.Warning
                );
        });
    }
    
    public static void SerilogUse(this WebApplication app)
    {
        app.UseSerilogRequestLogging(options =>
        {
            options.MessageTemplate = "HTTP {RequestMethod} {RequestPath} → {StatusCode} ({Elapsed:0.000}ms)";
        });
    }
    
    #endregion
}