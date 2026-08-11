import Vapor

struct DriverLocationResponse: Content {
    let userId: UUID
    let name: String?
    let latitude: Double
    let longitude: Double
    let updatedAt: Date
}