import Vapor
import Fluent

struct CurrentUserController: RouteCollection {
    private let authenticator: SupabaseAuthMiddleware

    init(authenticator: SupabaseAuthMiddleware) {
        self.authenticator = authenticator
    }

    func boot(routes: RoutesBuilder) throws {
        let protectedRoutes = routes
            .grouped("api")
            .grouped(authenticator)
            .grouped(
                AuthenticatedUserContext.guardMiddleware()
            )

        protectedRoutes.get(
            "me",
            use: show
        )
    }

    func show(
        request: Request
    ) async throws -> CurrentUserResponse {
        let authenticatedUser = try request.auth.require(
            AuthenticatedUserContext.self
        )

        guard let profile = try await Profile.find(
            authenticatedUser.userId,
            on: request.db
        ) else {
            throw Abort(
                .notFound,
                reason: "No se encontró el perfil del usuario."
            )
        }

        var clientName: String?

        if let clientId = profile.clientId {
            let client = try await Client.find(
                clientId,
                on: request.db
            )

            clientName = client?.name
        }

        guard let profileId = profile.id else {
            throw Abort(
                .internalServerError,
                reason: "El perfil no tiene un ID válido."
            )
        }

        return CurrentUserResponse(
            id: profileId,
            name: profile.name,
            role: profile.role,
            clientId: profile.clientId,
            clientName: clientName
        )
    }
}