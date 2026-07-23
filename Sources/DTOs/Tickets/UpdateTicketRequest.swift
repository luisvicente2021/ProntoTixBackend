import Vapor

struct UpdateTicketRequest: Content {
    let title: String?
    let description: String?
    let priority: String?
    let status: String?
    let reportedBy: String?
    let reporterPhone: String?
    let department: String?
    let jobTitle: String?
}