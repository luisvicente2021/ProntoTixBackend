import Vapor

struct UpdateDeliveryReportFilesRequest: Content, Sendable {
    let receiptUrl: String?
    let signatureUrl: String?
    let pdfUrl: String?
}