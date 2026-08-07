import Vapor

struct CreateDeliveryReportRequest: Content, Sendable {
    let provider: String
    let receiverName: String
    let observations: String?
    let items: [CreateDeliveryReportItemRequest]
}

struct CreateDeliveryReportItemRequest: Content, Sendable {
    let material: String
    let quantity: Double
    let unitPrice: Double
}