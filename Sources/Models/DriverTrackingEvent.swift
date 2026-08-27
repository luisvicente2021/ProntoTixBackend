import Fluent
import Vapor

final class DriverTrackingEvent:
    Model,
    Content,
    @unchecked Sendable
{
    static let schema =
        "driver_tracking_events"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "user_id")
    var userId: UUID

    @Field(key: "event_type")
    var eventType: String

    @Field(key: "created_at")
    var createdAt: Date

    init() {}

    init(
        id: UUID? = nil,
        userId: UUID,
        eventType: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.eventType = eventType
        self.createdAt = createdAt
    }
}