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

// Base de datoss
try DatabaseConfiguration.configure(app)



let supabaseConfiguration =
    try SupabaseConfiguration.fromEnvironment()


    let jwksURL = URI(
    string: "\(supabaseConfiguration.url)/auth/v1/.well-known/jwks.json"
)

let jwksResponse = try app.client
    .get(jwksURL)
    .wait()

guard jwksResponse.status == .ok else {
    throw Abort(
        .internalServerError,
        reason: "No fue posible descargar las claves públicas de Supabase."
    )
}

guard let body = jwksResponse.body,
      let jwksJSON = body.getString(
          at: body.readerIndex,
          length: body.readableBytes
      ),
      !jwksJSON.isEmpty else {
    throw Abort(
        .internalServerError,
        reason: "La respuesta JWKS de Supabase está vacía."
    )
}

let jwtVerifier = try JWTVerifier(
    jwksJSON: jwksJSON,
    supabaseURL: supabaseConfiguration.url
)

let supabaseAuthenticator = SupabaseAuthMiddleware(
    verifier: jwtVerifier
)

// Dependencias
let ticketRepository = FluentTicketRepository()

let ticketService = DefaultTicketService(
    repository: ticketRepository
)

let deliveryReportRepository =
    FluentDeliveryReportRepository()

let deliveryReportService =
    DefaultDeliveryReportService(
        repository: deliveryReportRepository
    )

let driverLocationRepository =
    FluentDriverLocationRepository()

let driverLocationService =
    DefaultDriverLocationService(
        repository: driverLocationRepository
    )

try app.register(
    collection: DriverLocationController(
        service: driverLocationService,
        authenticator: supabaseAuthenticator
    )
)

// Rutas de tickets
try app.register(
    collection: TicketsController(
        service: ticketService,
        authenticator: supabaseAuthenticator
    )
)

// Rutas de reportes de entrega
try app.register(
    collection: DeliveryReportsController(
        service: deliveryReportService,
        authenticator: supabaseAuthenticator
    )
)

// Ruta del usuario autenticado
try app.register(
    collection: CurrentUserController(
        authenticator: supabaseAuthenticator
    )
)

try app.register(
    collection: DriversController(
        authenticator: supabaseAuthenticator
    )
)

try app.register(
    collection: DriverShiftController(
        authenticator: supabaseAuthenticator
    )
)

try app.register(
    collection:
        DriverTrackingEventController(
            authenticator:
                supabaseAuthenticator
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