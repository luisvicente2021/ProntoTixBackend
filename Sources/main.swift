import Vapor

let environment = try Environment.detect()
let app = Application(environment)

defer {
    app.shutdown()
}

try DatabaseConfiguration.configure(app)

let ticketRepository = FluentTicketRepository()

let ticketService = DefaultTicketService(
    repository: ticketRepository
)

try app.register(
    collection: TicketsController(
        service: ticketService
    )
)

app.get {
    request async throws -> String in
    return "ProntoTix API is running"
}

app.http.server.configuration.hostname = "0.0.0.0"

if let portValue = Environment.get("PORT"),
   let port = Int(portValue) {
    app.http.server.configuration.port = port
} else {
    app.http.server.configuration.port = 8080
}

try app.run()