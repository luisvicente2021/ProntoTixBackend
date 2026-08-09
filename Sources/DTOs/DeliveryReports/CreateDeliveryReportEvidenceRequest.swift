import Vapor

struct CreateDeliveryReportEvidenceRequest: Content, Sendable {
    let imageUrl: String
}