import Fluent
import Vapor

struct FluentTicketRepository: TicketRepository {
    func findAll(on database: Database) async throws -> [Ticket] {
        try await Ticket.query(on: database)
            .sort(\.$openedAt, .descending)
            .all()
    }

    func find(
        id: Int64,
        on database: Database
    ) async throws -> Ticket? {
        try await Ticket.find(id, on: database)
    }

    func create(
        _ ticket: Ticket,
        on database: Database
    ) async throws {
        try await ticket.create(on: database)
    }

    func update(
        _ ticket: Ticket,
        on database: Database
    ) async throws {
        try await ticket.update(on: database)
    }

    func delete(
        _ ticket: Ticket,
        on database: Database
    ) async throws {
        try await ticket.delete(on: database)
    }
}