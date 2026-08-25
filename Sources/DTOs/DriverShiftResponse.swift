import Vapor

struct DriverShiftResponse: Content {
    let id: UUID
    let userId: UUID
    let startedAt: Date
    let endedAt: Date?
    let status: String
}

struct ActiveDriverShiftResponse: Content {
    let active: Bool
    let shift: DriverShiftResponse?
}