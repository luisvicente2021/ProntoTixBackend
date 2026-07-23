import Vapor

struct CreateTicketRequest: Content, Sendable {
    let clientId: UUID
    let title: String
    let description: String
    let priority: String
    let reportedBy: String?
    let reporterPhone: String?
    let department: String?
    let jobTitle: String?
}