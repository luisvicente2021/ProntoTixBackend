import Fluent
import Vapor

struct DriverLocationController: RouteCollection {

    private let authenticator: SupabaseAuthMiddleware

    init(
        authenticator: SupabaseAuthMiddleware
    ) {
        self.authenticator = authenticator
    }

    func boot(routes: RoutesBuilder) throws {

        let protected = routes
            .grouped("api", "driver-location")
            .grouped(authenticator)
            .grouped(
                AuthenticatedUserContext.guardMiddleware()
            )

        protected.post(use: updateLocation)
    }

    func updateLocation(
        request: Request
    ) async throws -> HTTPStatus {

        let user =
            try request.auth.require(
                AuthenticatedUserContext.self
            )

        let input =
            try request.content.decode(
                DriverLocationRequest.self
            )

        let existing =
            try await DriverLocation.query(
                on: request.db
            )
            .filter(
                \.$userId == user.userId
            )
            .first()

        if let existing {

            existing.latitude = input.latitude
            existing.longitude = input.longitude
            existing.updatedAt = Date()

            try await existing.update(
                on: request.db
            )

        } else {

            let location =
                DriverLocation(
                    userId: user.userId,
                    latitude: input.latitude,
                    longitude: input.longitude
                )

            try await location.create(
                on: request.db
            )
        }

        return .ok
    }
}