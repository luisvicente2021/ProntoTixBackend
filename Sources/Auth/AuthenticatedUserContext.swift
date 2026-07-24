import Vapor

struct AuthenticatedUserContext: Authenticatable, Sendable {
    let userId: UUID
    let role: String
    let clientId: UUID?

    var canViewAllTickets: Bool {
        let normalizedRole = role
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        return normalizedRole == "soporte"
            || normalizedRole == "admin"
    }
}