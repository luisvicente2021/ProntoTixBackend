import Vapor

struct TicketResponse: Content {

    let id: Int64?

    let clientId: UUID
    let clientName: String

    let assignedUserId: UUID?
    let assignedUserName: String?

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

    func toResponse(
        clientName: String,
        assignedUserName: String? = nil
    ) -> TicketResponse {

        TicketResponse(
            id: id,

            clientId: clientId,
            clientName: clientName,

            assignedUserId:
                assignedUserId,

            assignedUserName:
                assignedUserName,

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

extension TicketWithClient {

    func toResponse() -> TicketResponse {

        ticket.toResponse(
            clientName: clientName,
            assignedUserName:
                assignedUserName
        )
    }
}