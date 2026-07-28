import Vapor
import Fluent

protocol TicketService {
    func getAll(
    for profile: Profile,
    on database: Database
) async throws -> [TicketResponse]

    func getById(
    _ id: Int64,
    for profile: Profile,
    on database: Database
) async throws -> TicketResponse

    func create(
        request: CreateTicketRequest,
        on database: Database
    ) async throws -> TicketResponse

    func update(
        id: Int64,
        request: UpdateTicketRequest,
        on database: Database
    ) async throws -> TicketResponse

    func delete(
        id: Int64,
        on database: Database
    ) async throws
}