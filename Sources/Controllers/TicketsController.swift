import Vapor

struct TicketsController: RouteCollection {
    private let service: TicketService
    private let authenticator: SupabaseAuthMiddleware

    init(
        service: TicketService,
        authenticator: SupabaseAuthMiddleware
    ) {
        self.service = service
        self.authenticator = authenticator
    }

    func boot(routes: RoutesBuilder) throws {
        let tickets = routes
            .grouped("api", "tickets")
            .grouped(authenticator)
            .grouped(
                AuthenticatedUserContext.guardMiddleware()
            )

        tickets.get(use: index)
        tickets.get(":id", use: show)
        tickets.post(use: create)
        tickets.put(":id", use: update)
        tickets.delete(":id", use: delete)

        tickets
    .grouped(":id", "assignment")
    .patch(use: assignDriver)
    }

    // El resto de tus métodos permanece igual.
   func assignDriver(
    request: Request
) async throws -> Ticket {

    let user = try request.auth.require(
        AuthenticatedUserContext.self
    )

    guard user.canViewAllTickets else {
        throw Abort(
            .forbidden,
            reason: "No tienes permiso para asignar diligencias."
        )
    }

    guard let ticketId = request.parameters.get(
        "id",
        as: Int64.self
    ) else {
        throw Abort(
            .badRequest,
            reason: "El ID de la diligencia no es válido."
        )
    }

    let input = try request.content.decode(
        AssignTicketRequest.self
    )

    guard let ticket = try await Ticket.find(
        ticketId,
        on: request.db
    ) else {
        throw Abort(
            .notFound,
            reason: "La diligencia no existe."
        )
    }

    guard let profile = try await Profile.find(
        input.assignedUserId,
        on: request.db
    ) else {
        throw Abort(
            .badRequest,
            reason: "El diligenciero seleccionado no existe."
        )
    }

    let normalizedRole = profile.role
        .trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        .lowercased()

    guard normalizedRole == "tecnico" else {
        throw Abort(
            .badRequest,
            reason: "El usuario seleccionado no es un diligenciero."
        )
    }

    ticket.assignedUserId =
        input.assignedUserId

    try await ticket.update(
        on: request.db
    )

    return ticket
}

   func index(request: Request) async throws -> [TicketResponse] {
    let authenticatedUser = try request.auth.require(
        AuthenticatedUserContext.self
    )

    guard let profile = try await Profile.find(
        authenticatedUser.userId,
        on: request.db
    ) else {
        throw Abort(
            .forbidden,
            reason: "El usuario autenticado no tiene un perfil asignado."
        )
    }

    return try await service.getAll(
        for: profile,
        on: request.db
    )
}

    func show(request: Request) async throws -> TicketResponse {
    guard let id = request.parameters.get(
        "id",
        as: Int64.self
    ) else {
        throw Abort(
            .badRequest,
            reason: "El ID del ticket no es válido."
        )
    }

    let authenticatedUser = try request.auth.require(
        AuthenticatedUserContext.self
    )

    guard let profile = try await Profile.find(
        authenticatedUser.userId,
        on: request.db
    ) else {
        throw Abort(
            .forbidden,
            reason: "El usuario autenticado no tiene un perfil asignado."
        )
    }

    return try await service.getById(
        id,
        for: profile,
        on: request.db
    )
}

    func create(request: Request) async throws -> TicketResponse {
        let input = try request.content.decode(
            CreateTicketRequest.self
        )

        return try await service.create(
            request: input,
            on: request.db
        )
    }

    func update(request: Request) async throws -> TicketResponse {
        guard let id = request.parameters.get(
            "id",
            as: Int64.self
        ) else {
            throw Abort(
                .badRequest,
                reason: "El ID del ticket no es válido."
            )
        }

        let input = try request.content.decode(
            UpdateTicketRequest.self
        )

        return try await service.update(
            id: id,
            request: input,
            on: request.db
        )
    }

    func delete(request: Request) async throws -> HTTPStatus {
        guard let id = request.parameters.get(
            "id",
            as: Int64.self
        ) else {
            throw Abort(
                .badRequest,
                reason: "El ID del ticket no es válido."
            )
        }

        try await service.delete(
            id: id,
            on: request.db
        )

        return .noContent
    }
}