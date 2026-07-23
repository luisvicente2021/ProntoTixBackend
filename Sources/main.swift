import Vapor

let environment = try Environment.detect()
let app = Application(environment)

defer {
    app.shutdown()
}

// CORS para permitir peticiones desde el frontend React
let corsConfiguration = CORSMiddleware.Configuration(
    allowedOrigin: .all,
    allowedMethods: [
        .GET,
        .POST,
        .PUT,
        .PATCH,
        .DELETE,
        .OPTIONS
    ],
    allowedHeaders: [
        .accept,
        .authorization,
        .contentType,
        .origin,
        .xRequestedWith
    ]
)

app.middleware.use(
    CORSMiddleware(
        configuration: corsConfiguration
    ),
    at: .beginning
)

// Base de datos
try DatabaseConfiguration.configure(app)

// Dependencias
let ticketRepository = FluentTicketRepository()

let ticketService = DefaultTicketService(
    repository: ticketRepository
)

// Rutas de tickets
try app.register(
    collection: TicketsController(
        service: ticketService
    )
)

// Ruta de prueba
app.get {
    request async throws -> String in
    return "ProntoTix API is running"
}

// Configuración del servidor
app.http.server.configuration.hostname = "0.0.0.0"

if let portValue = Environment.get("PORT"),
   let port = Int(portValue) {
    app.http.server.configuration.port = port
} else {
    app.http.server.configuration.port = 8080
}

try app.run()