import Fluent
import Vapor

final class Profile: Model, Content, @unchecked Sendable {
    static let schema = "profiles"

    @ID(key: .id)
    var id: UUID?

    @OptionalField(key: "cliente_id")
    var clientId: UUID?

    @Field(key: "role")
    var role: String

    @OptionalField(key: "nombre")
    var name: String?

    @OptionalField(key: "created_at")
    var createdAt: Date?

    init() {}

    init(
        id: UUID? = nil,
        clientId: UUID? = nil,
        role: String,
        name: String? = nil,
        createdAt: Date? = nil
    ) {
        self.id = id
        self.clientId = clientId
        self.role = role
        self.name = name
        self.createdAt = createdAt
    }
}
