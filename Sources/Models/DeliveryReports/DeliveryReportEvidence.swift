import Vapor
import Fluent

final class DeliveryReportEvidence: Model, Content {
    static let schema = "delivery_report_evidence"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "report_id")
    var reportId: UUID

    @Field(key: "image_url")
    var imageUrl: String

    @Field(key: "created_at")
    var createdAt: Date

    init() {}

    init(
        id: UUID? = nil,
        reportId: UUID,
        imageUrl: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.reportId = reportId
        self.imageUrl = imageUrl
        self.createdAt = createdAt
    }
}