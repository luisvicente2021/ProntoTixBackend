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

        var result: [DriverLocationResponse] = []

        for location in locations {

            let profile = try await Profile.find(
                location.userId,
                on: database
            )

            result.append(
                DriverLocationResponse(
                    userId: location.userId,
                    name: profile?.name,
                    latitude: location.latitude,
                    longitude: location.longitude,
                    updatedAt: location.updatedAt
                )
            )
        }

        return result
    }
}