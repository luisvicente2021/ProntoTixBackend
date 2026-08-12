import Fluent
import Vapor

struct DriversController: RouteCollection {

    private let authenticator: SupabaseAuthMiddleware

    init(
        authenticator: SupabaseAuthMiddleware
    ) {
        self.authenticator = authenticator
    }

    func boot(routes: RoutesBuilder) throws {

        let protected = routes
            .grouped("api", "drivers")
            .grouped(authenticator)
            .grouped(
                AuthenticatedUserContext.guardMiddleware()
            )

        protected.get(use: getAll)
    }

    func getAll(
        request: Request
    ) async throws -> [DriverResponse] {

        let user = try request.auth.require(
            AuthenticatedUserContext.self
        )

        guard user.canViewAllTickets else {
            throw Abort(
                .forbidden,
                reason: "No tienes permiso para consultar diligencieros."
            )
        }

        let profiles = try await Profile.query(
            on: request.db
        )
        .filter(\.$role == "tecnico")
        .sort(\.$name, .ascending)
        .all()

        return profiles.compactMap { profile in
            guard let id = profile.id else {
                return nil
            }

            return DriverResponse(
                id: id,
                name: profile.name ?? "Sin nombre",
                role: profile.role
            )
        }
    }
}