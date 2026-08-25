import Vapor
import Fluent

final class Ticket: Model, Content {
    static let schema = "tickets"

    @ID(custom: "id", generatedBy: .database)
    var id: Int64?

    @Field(key: "cliente_id")
    var clientId: UUID

    @OptionalField(key: "assigned_user_id")
    var assignedUserId: UUID?

    @Field(key: "titulo")
    var title: String

    @Field(key: "descripcion")
    var description: String

    @Field(key: "prioridad")
    var priority: String

    @Field(key: "estado")
    var status: String

    @Field(key: "fecha_apertura")
    var openedAt: Date

    @OptionalField(key: "fecha_cierre")
    var closedAt: Date?

    @OptionalField(key: "reportado_por")
    var reportedBy: String?

    @OptionalField(key: "telefono_reportante")
    var reporterPhone: String?

    @OptionalField(key: "area")
    var department: String?

    @OptionalField(key: "puesto")
    var jobTitle: String?

    @OptionalField(key: "archived_at")
    var archivedAt: Date?

    init() {}

    init(
        id: Int64? = nil,
        clientId: UUID,
        assignedUserId: UUID? = nil,
        title: String,
        description: String,
        priority: String,
        status: String = "Abierta",
        openedAt: Date = Date(),
        closedAt: Date? = nil,
        reportedBy: String? = nil,
        reporterPhone: String? = nil,
        department: String? = nil,
        jobTitle: String? = nil,
        archivedAt: Date? = nil
    ) {
        self.id = id
        self.clientId = clientId
        self.assignedUserId = assignedUserId
        self.title = title
        self.description = description
        self.priority = priority
        self.status = status
        self.openedAt = openedAt
        self.closedAt = closedAt
        self.reportedBy = reportedBy
        self.reporterPhone = reporterPhone
        self.department = department
        self.jobTitle = jobTitle
        self.archivedAt = archivedAt
    }
}