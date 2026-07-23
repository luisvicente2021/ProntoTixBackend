import Vapor
import Fluent
import FluentPostgresDriver
import NIOSSL

enum DatabaseConfiguration {
    static func configure(_ app: Application) throws {
        guard
            let hostname = Environment.get("DATABASE_HOST"),
            let username = Environment.get("DATABASE_USERNAME"),
            let password = Environment.get("DATABASE_PASSWORD"),
            let database = Environment.get("DATABASE_NAME")
        else {
            throw Abort(
                .internalServerError,
                reason: "Faltan variables de entorno de PostgreSQL."
            )
        }

        let port = Environment.get("DATABASE_PORT")
            .flatMap(Int.init) ?? 5432

        var tlsConfiguration = TLSConfiguration.makeClientConfiguration()

        // Solo para desarrollo local
        tlsConfiguration.certificateVerification = .none

        let sslContext = try NIOSSLContext(
            configuration: tlsConfiguration
        )

        app.databases.use(
            .postgres(
                configuration: .init(
                    hostname: hostname,
                    port: port,
                    username: username,
                    password: password,
                    database: database,
                    tls: .require(sslContext)
                )
            ),
            as: .psql
        )
    }
}