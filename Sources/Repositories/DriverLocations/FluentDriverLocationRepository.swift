import Fluent

struct FluentDriverLocationRepository: DriverLocationRepository {

    func getAll(
        on database: Database
    ) async throws -> [DriverLocation] {

        try await DriverLocation.query(
            on: database
        )
        .sort(\.$updatedAt, .descending)
        .all()
    }
}