import Vapor

struct AssignTicketRequest: Content {
    let assignedUserId: UUID
}