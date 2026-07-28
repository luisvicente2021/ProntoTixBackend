import Vapor

struct CurrentUserResponse: Content {
    let id: UUID
    let name: String?
    let role: String
    let clientId: UUID?
    let clientName: String?
}