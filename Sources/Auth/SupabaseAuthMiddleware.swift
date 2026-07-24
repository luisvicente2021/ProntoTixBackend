import Fluent
import Vapor

struct SupabaseAuthMiddleware: BearerAuthenticator {
    let verifier: JWTVerifier

    func authenticate(
        bearer: BearerAuthorization,
        for request: Request
    ) -> EventLoopFuture<Void> {
        request.eventLoop.makeFutureWithTask {
            let payload: SupabaseJWTPayload

            do {
                payload = try verifier.verify(
                    token: bearer.token
                )
            } catch {
                request.logger.warning(
                    "Token rechazado: \(error.localizedDescription)"
                )

                throw Abort(
                    .unauthorized,
                    reason: "El token de acceso no es válido."
                )
            }

            guard let userId = payload.userId else {
                throw Abort(
                    .unauthorized,
                    reason: "El token no contiene un usuario válido."
                )
            }

            guard let profile = try await Profile.find(
                userId,
                on: request.db
            ) else {
                throw Abort(
                    .forbidden,
                    reason: "El usuario no tiene un perfil configurado."
                )
            }

            let normalizedRole = profile.role
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .lowercased()

            guard !normalizedRole.isEmpty else {
                throw Abort(
                    .forbidden,
                    reason: "El usuario no tiene un rol válido."
                )
            }

            if normalizedRole == "cliente",
               profile.clientId == nil {
                throw Abort(
                    .forbidden,
                    reason: "El usuario cliente no está relacionado con un residencial."
                )
            }

            let authenticatedUser = AuthenticatedUserContext(
                userId: userId,
                role: normalizedRole,
                clientId: profile.clientId
            )

            request.auth.login(authenticatedUser)
        }
    }
}