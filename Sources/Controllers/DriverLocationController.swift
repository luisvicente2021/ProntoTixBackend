import Fluent
import Vapor

struct DriverLocationController: RouteCollection {

    private let authenticator: SupabaseAuthMiddleware
    private let service: DriverLocationService

    init(
        service: DriverLocationService,
        authenticator: SupabaseAuthMiddleware
    ) {
        self.service = service
        self.authenticator = authenticator
    }

    func boot(routes: RoutesBuilder) throws {

        let protected = routes
            .grouped("api")
            .grouped(authenticator)
            .grouped(
                AuthenticatedUserContext.guardMiddleware()
            )

        protected
            .grouped("driver-location")
            .post(use: updateLocation)

        protected
            .grouped("driver-locations")
            .get(use: getAll)
    }

    func updateLocation(
        request: Request
    ) async throws -> HTTPStatus {

        let user = try request.auth.require(
            AuthenticatedUserContext.self
        )

        let input = try request.content.decode(
            DriverLocationRequest.self
        )

        let existing = try await DriverLocation.query(
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

            let location = DriverLocation(
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

    func getAll(
        request: Request
    ) async throws -> [DriverLocationResponse] {

        let user = try request.auth.require(
            AuthenticatedUserContext.self
        )

        guard user.canViewAllTickets else {
            throw Abort(
                .forbidden,
                reason: "No tienes permiso para consultar ubicaciones."
            )
        }

        return try await service.getAll(
            on: request.db
        )
    }
}