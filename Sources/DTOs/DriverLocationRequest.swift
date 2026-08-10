import Vapor

struct DriverLocationRequest: Content {
    let latitude: Double
    let longitude: Double
}