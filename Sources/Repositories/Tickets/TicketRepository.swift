import Vapor
import Fluent

protocol TicketRepository {
    func findAll(on database: Database) async throws -> [Ticket]

    func find(
        id: Int64,
        on database: Database
    ) async throws -> Ticket?

    func create(
        _ ticket: Ticket,
        on database: Database
    ) async throws

    func update(
        _ ticket: Ticket,
        on database: Database
    ) async throws

    func delete(
        _ ticket: Ticket,
        on database: Database
    ) async throws
}