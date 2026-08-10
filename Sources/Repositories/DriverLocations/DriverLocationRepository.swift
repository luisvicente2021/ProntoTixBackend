import Fluent

protocol DriverLocationRepository {

    func getAll(
        on database: Database
    ) async throws -> [DriverLocation]

}