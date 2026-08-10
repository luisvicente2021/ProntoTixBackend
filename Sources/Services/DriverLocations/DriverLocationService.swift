import Fluent

protocol DriverLocationService {

    func getAll(
        on database: Database
    ) async throws -> [DriverLocationResponse]
}