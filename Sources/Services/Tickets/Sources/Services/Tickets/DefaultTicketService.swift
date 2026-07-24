import Vapor
import Fluent

struct DefaultTicketService: TicketService {
    private let repository: TicketRepository

    init(repository: TicketRepository) {
        self.repository = repository
    }

    func getAll(
        on database: Database
    ) async throws -> [TicketResponse] {
        let tickets =
            try await repository.findAllWithClient(
                on: database
            )

        return tickets.map {
            $0.toResponse()
        }
    }

    func getById(
        _ id: Int64,
        on database: Database
    ) async throws -> TicketResponse {
        guard let result =
            try await repository.findWithClient(
                id: id,
                on: database
            )
        else {
            throw Abort(
                .notFound,
                reason:
                    "No se encontró el ticket con ID \(id)."
            )
        }

        return result.toResponse()
    }

    func create(
        request: CreateTicketRequest,
        on database: Database
    ) async throws -> TicketResponse {
        let ticket = Ticket(
            clientId: request.clientId,
            title: request.title,
            description: request.description,
            priority: request.priority,
            status: "Abierta",
            openedAt: Date(),
            closedAt: nil,
            reportedBy: request.reportedBy,
            reporterPhone: request.reporterPhone,
            department: request.department,
            jobTitle: request.jobTitle
        )

        try await repository.create(
            ticket,
            on: database
        )

        guard let ticketId = ticket.id else {
            throw Abort(
                .internalServerError,
                reason:
                    "El ticket fue creado, pero no recibió un ID."
            )
        }

        guard let result =
            try await repository.findWithClient(
                id: ticketId,
                on: database
            )
        else {
            throw Abort(
                .internalServerError,
                reason:
                    "El ticket fue creado, pero no se pudo consultar."
            )
        }

        return result.toResponse()
    }

    func update(
        id: Int64,
        request: UpdateTicketRequest,
        on database: Database
    ) async throws -> TicketResponse {
        guard let ticket =
            try await repository.find(
                id: id,
                on: database
            )
        else {
            throw Abort(
                .notFound,
                reason:
                    "No se encontró el ticket con ID \(id)."
            )
        }

        if let title = request.title {
            ticket.title = title
        }

        if let description = request.description {
            ticket.description = description
        }

        if let priority = request.priority {
            ticket.priority = priority
        }

        if let status = request.status {
            ticket.status = status

            if status == "Cerrada" {
                ticket.closedAt = Date()
            } else {
                ticket.closedAt = nil
            }
        }

        if let reportedBy = request.reportedBy {
            ticket.reportedBy = reportedBy
        }

        if let reporterPhone =
            request.reporterPhone
        {
            ticket.reporterPhone =
                reporterPhone
        }

        if let department =
            request.department
        {
            ticket.department =
                department
        }

        if let jobTitle = request.jobTitle {
            ticket.jobTitle = jobTitle
        }

        try await repository.update(
            ticket,
            on: database
        )

        guard let result =
            try await repository.findWithClient(
                id: id,
                on: database
            )
        else {
            throw Abort(
                .internalServerError,
                reason:
                    "El ticket se actualizó, pero no se pudo consultar."
            )
        }

        return result.toResponse()
    }

    func delete(
        id: Int64,
        on database: Database
    ) async throws {
        guard let ticket =
            try await repository.find(
                id: id,
                on: database
            )
        else {
            throw Abort(
                .notFound,
                reason:
                    "No se encontró el ticket con ID \(id)."
            )
        }

        try await repository.delete(
            ticket,
            on: database
        )
    }
}