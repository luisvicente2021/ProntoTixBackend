import Vapor
import Fluent

final class DeliveryReportItem: Model, Content {
    static let schema = "delivery_report_items"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "report_id")
    var reportId: UUID

    @Field(key: "material")
    var material: String

    @Field(key: "quantity")
    var quantity: Double

    @Field(key: "unit_price")
    var unitPrice: Double

    @Field(key: "total")
    var total: Double

    init() {}

    init(
        id: UUID? = nil,
        reportId: UUID,
        material: String,
        quantity: Double,
        unitPrice: Double
    ) {
        self.id = id
        self.reportId = reportId
        self.material = material
        self.quantity = quantity
        self.unitPrice = unitPrice
        self.total = quantity * unitPrice
    }
}