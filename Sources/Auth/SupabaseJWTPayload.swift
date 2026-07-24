import Foundation
import JWT

/// Representa los claims que necesitamos del access token de Supabase.
///
/// Supabase puede incluir otros campos en el JWT, pero Codable
/// ignorará automáticamente los que no estén definidos aquí.
struct SupabaseJWTPayload: JWTPayload {
    /// Identificador del usuario de Supabase Auth.
    let subject: SubjectClaim

    /// Proyecto o servicio que emitió el token.
    let issuer: IssuerClaim

    /// Servicio al que está destinado el token.
    let audience: AudienceClaim

    /// Fecha de expiración.
    let expiration: ExpirationClaim

    /// Correo del usuario. Puede no existir en ciertos proveedores.
    let email: String?

    /// Normalmente contiene "authenticated".
    let role: String?

    enum CodingKeys: String, CodingKey {
        case subject = "sub"
        case issuer = "iss"
        case audience = "aud"
        case expiration = "exp"
        case email
        case role
    }

    func verify(using signer: JWTSigner) throws {
        try expiration.verifyNotExpired()
    }

    var userId: UUID? {
        UUID(uuidString: subject.value)
    }
}