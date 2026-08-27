import Fluent
import Vapor

struct DriverTrackingEventController:
    RouteCollection
{
    private let authenticator:
        SupabaseAuthMiddleware

    init(
        authenticator:
            SupabaseAuthMiddleware
    ) {
        self.authenticator =
            authenticator
    }

    func boot(
        routes: RoutesBuilder
    ) throws {

        let protected =
            routes
                .grouped("api")
                .grouped(authenticator)
                .grouped(
                    AuthenticatedUserContext
                        .guardMiddleware()
                )

        protected
            .grouped(
                "driver-tracking",
                "events"
            )
            .post(
                use: createEvent
            )
    }

    func createEvent(
        request: Request
    ) async throws -> HTTPStatus {

        /*
         * El userId NO viene del teléfono.
         * Se obtiene del token autenticado.
         */
        let user =
            try request.auth.require(
                AuthenticatedUserContext.self
            )

        let input =
            try request.content.decode(
                DriverTrackingEventRequest.self
            )

        let eventType =
            input.eventType
                .trimmingCharacters(
                    in:
                        .whitespacesAndNewlines
                )
                .uppercased()

        /*
         * Por seguridad solamente
         * aceptamos eventos conocidos.
         */
        let allowedEvents:
            Set<String> = [
                "GPS_ENABLED",
                "GPS_DISABLED"
            ]

        guard allowedEvents.contains(
            eventType
        ) else {
            throw Abort(
                .badRequest,
                reason:
                    "Tipo de evento no válido."
            )
        }

        let event =
            DriverTrackingEvent(
                userId:
                    user.userId,
                eventType:
                    eventType
            )

        try await event.create(
            on: request.db
        )

        request.logger.info(
            "Driver tracking event: \(eventType) user=\(user.userId)"
        )

        return .created
    }
}