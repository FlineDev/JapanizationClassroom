import FluentPostgreSQL
import Leaf
import Vapor

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // Register providers first
    try services.register(LeafProvider())
    try services.register(FluentPostgreSQLProvider())

    // Configure a database
    let dbConfig: PostgreSQLDatabaseConfig
    if let url = Environment.get("DATABASE_URL"), let psqlConfig = PostgreSQLDatabaseConfig(url: url) {
        dbConfig = psqlConfig
    } else {
        dbConfig = try PostgreSQLDatabaseConfig.default()
    }

    let postgresql = PostgreSQLDatabase(config: dbConfig)

    /// Register the configured SQLite database to the database config.
    var databases = DatabasesConfig()
    databases.add(database: postgresql, as: .psql)
    services.register(databases)


    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
    
    // Use Leaf for rendering views
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)

    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    // Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: Member.self, database: .psql)
    services.register(migrations)

    // Configure custom tags
    services.register { container -> LeafTagConfig in
        var config = LeafTagConfig.default()
        config.use(RoundTag(), as: "round")
        return config
    }
}
