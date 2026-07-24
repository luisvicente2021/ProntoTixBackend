import Fluent
import Vapor

struct FluentTicketRepository: TicketRepository {
    func findAllWithClient(
        on database: Database
    ) async throws -> [TicketWithClient] {
        let tickets = try await Ticket
            .query(on: database)
            .join(
                Client.self,
                on: \Ticket.$clientId == \Client.$id
            )
            .sort(
                \Ticket.$openedAt,
                .descending
            )
            .all()

        return try tickets.map { ticket in
            let client = try ticket.joined(
                Client.self
            )

            return TicketWithClient(
                ticket: ticket,
                clientName: client.name
            )
        }
    }

    func findWithClient(
        id: Int64,
        on database: Database
    ) async throws -> TicketWithClient? {
        guard let ticket = try await Ticket
            .query(on: database)
            .filter(\.$id == id)
            .join(
                Client.self,
                on: \Ticket.$clientId == \Client.$id
            )
            .first()
        else {
            return nil
        }

        let client = try ticket.joined(
            Client.self
        )

        return TicketWithClient(
            ticket: ticket,
            clientName: client.name
        )
    }

    func find(
        id: Int64,
        on database: Database
    ) async throws -> Ticket? {
        try await Ticket.find(
            id,
            on: database
        )
    }

    func create(
        _ ticket: Ticket,
        on database: Database
    ) async throws {
        try await ticket.create(
            on: database
        )
    }

    func update(
        _ ticket: Ticket,
        on database: Database
    ) async throws {
        try await ticket.update(
            on: database
        )
    }

    func delete(
        _ ticket: Ticket,
        on database: Database
    ) async throws {
        try await ticket.delete(
            on: database
        )
    }
}