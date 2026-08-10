import Fluent

struct DefaultDriverLocationService: DriverLocationService {

    private let repository: DriverLocationRepository

    init(
        repository: DriverLocationRepository
    ) {
        self.repository = repository
    }

    func getAll(
        on database: Database
    ) async throws -> [DriverLocationResponse] {

        let locations = try await repository.getAll(
            on: database
        )

        return locations.map { location in
            DriverLocationResponse(
                userId: location.userId,
                latitude: location.latitude,
                longitude: location.longitude,
                updatedAt: location.updatedAt
            )
        }
    }
}