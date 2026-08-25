import Fluent
import Vapor

final class DriverShift: Model, Content, @unchecked Sendable {

    static let schema = "driver_shifts"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "user_id")
    var userId: UUID

    @Field(key: "started_at")
    var startedAt: Date

    @OptionalField(key: "ended_at")
    var endedAt: Date?

    @Field(key: "status")
    var status: String

    @Field(key: "created_at")
    var createdAt: Date

    init() {}

    init(
        id: UUID? = nil,
        userId: UUID,
        startedAt: Date = Date(),
        endedAt: Date? = nil,
        status: String = "active",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.status = status
        self.createdAt = createdAt
    }
}