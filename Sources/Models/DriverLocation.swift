import Fluent
import Vapor

final class DriverLocation: Model, Content, @unchecked Sendable {

    static let schema = "driver_locations"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "user_id")
    var userId: UUID

    @Field(key: "latitude")
    var latitude: Double

    @Field(key: "longitude")
    var longitude: Double

    @Field(key: "updated_at")
    var updatedAt: Date

    init() {}

    init(
        id: UUID? = nil,
        userId: UUID,
        latitude: Double,
        longitude: Double,
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.latitude = latitude
        self.longitude = longitude
        self.updatedAt = updatedAt
    }
}