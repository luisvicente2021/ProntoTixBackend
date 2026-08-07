import Vapor
import Fluent

final class DeliveryReport: Model, Content {
    static let schema = "delivery_reports"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "ticket_id")
    var ticketId: Int64

    @Field(key: "provider")
    var provider: String

    @Field(key: "receiver_name")
    var receiverName: String

    @OptionalField(key: "observations")
    var observations: String?

    @Field(key: "total_amount")
    var totalAmount: Double

    @OptionalField(key: "receipt_url")
    var receiptUrl: String?

    @OptionalField(key: "signature_url")
    var signatureUrl: String?

    @OptionalField(key: "pdf_url")
    var pdfUrl: String?

    @Field(key: "created_at")
    var createdAt: Date

    init() {}

    init(
        id: UUID? = nil,
        ticketId: Int64,
        provider: String,
        receiverName: String,
        observations: String? = nil,
        totalAmount: Double,
        receiptUrl: String? = nil,
        signatureUrl: String? = nil,
        pdfUrl: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.ticketId = ticketId
        self.provider = provider
        self.receiverName = receiverName
        self.observations = observations
        self.totalAmount = totalAmount
        self.receiptUrl = receiptUrl
        self.signatureUrl = signatureUrl
        self.pdfUrl = pdfUrl
        self.createdAt = createdAt
    }
}