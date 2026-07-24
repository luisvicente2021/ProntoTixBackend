import Fluent
import Vapor

final class Client: Model, Content {
    static let schema = "clientes"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "nombre")
    var name: String

    @OptionalField(key: "contacto")
    var contact: String?

    @OptionalField(key: "telefono")
    var phone: String?

    @Field(key: "created_at")
    var createdAt: Date

    init() {}

    init(
        id: UUID? = nil,
        name: String,
        contact: String? = nil,
        phone: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.contact = contact
        self.phone = phone
        self.createdAt = createdAt
    }
}