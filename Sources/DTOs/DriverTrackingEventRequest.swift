import Vapor

struct DriverTrackingEventRequest:
    Content
{
    let eventType: String
}