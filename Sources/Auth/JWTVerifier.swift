import Foundation
import JWT
import Vapor

struct JWTVerifier: Sendable {
    private let signers: JWTSigners
    private let expectedIssuer: String
    private let expectedAudience: String

    init(
        jwksJSON: String,
        supabaseURL: String
    ) throws {
        let signers = JWTSigners()

        // Registra todas las claves públicas contenidas en el JWKS.
        // JWTKit seleccionará la clave correcta usando el "kid" del token.
        try signers.use(jwksJSON: jwksJSON)

        self.signers = signers

        let normalizedURL = supabaseURL
            .trimmingCharacters(in: CharacterSet(charactersIn: "/"))

        self.expectedIssuer = "\(normalizedURL)/auth/v1"
        self.expectedAudience = "authenticated"
    }

    func verify(token: String) throws -> SupabaseJWTPayload {
        let payload = try signers.verify(
            token,
            as: SupabaseJWTPayload.self
        )

        guard payload.issuer.value == expectedIssuer else {
            throw Abort(
                .unauthorized,
                reason: "El emisor del token no es válido."
            )
        }

        try payload.audience.verifyIntendedAudience(
            includes: expectedAudience
        )

        guard payload.userId != nil else {
            throw Abort(
                .unauthorized,
                reason: "El identificador del usuario no es válido."
            )
        }

        return payload
    }
}