import Vapor
import Fluent

protocol TicketRepository {
    func findAllWithClient(
        on database: Database
    ) async throws -> [TicketWithClient]

    func findWithClient(
        id: Int64,
        on database: Database
    ) async throws -> TicketWithClient?

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