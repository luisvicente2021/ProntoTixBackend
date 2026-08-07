import Vapor

struct DeliveryReportResponse: Content {
    let id: UUID?
    let ticketId: Int64
    let provider: String
    let receiverName: String
    let observations: String?
    let totalAmount: Double
    let receiptUrl: String?
    let signatureUrl: String?
    let pdfUrl: String?
    let createdAt: Date
    let items: [DeliveryReportItemResponse]
}

struct DeliveryReportItemResponse: Content {
    let id: UUID?
    let material: String
    let quantity: Double
    let unitPrice: Double
    let total: Double
}