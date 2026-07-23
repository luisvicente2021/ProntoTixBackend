import Vapor

struct TicketResponse: Content {
    let id: Int64?
    let clientId: UUID
    let title: String
    let description: String
    let priority: String
    let status: String
    let openedAt: Date
    let closedAt: Date?
    let reportedBy: String?
    let reporterPhone: String?
    let department: String?
    let jobTitle: String?
}

extension Ticket {
    func toResponse() -> TicketResponse {
        TicketResponse(
            id: id,
            clientId: clientId,
            title: title,
            description: description,
            priority: priority,
            status: status,
            openedAt: openedAt,
            closedAt: closedAt,
            reportedBy: reportedBy,
            reporterPhone: reporterPhone,
            department: department,
            jobTitle: jobTitle
        )
    }
}