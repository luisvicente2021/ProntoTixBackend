import Vapor

struct DriverResponse: Content {
    let id: UUID
    let name: String
    let role: String
}