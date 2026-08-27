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

        let events =
            protected.grouped(
                "driver-tracking",
                "events"
            )

        /*
         * Android envía eventos:
         *
         * POST
         * /api/driver-tracking/events
         */
        events.post(
            use: createEvent
        )

        /*
         * React consulta el último
         * evento GPS de cada usuario:
         *
         * GET
         * /api/driver-tracking/events/latest
         */
        events
            .grouped("latest")
            .get(
                use: getLatestEvents
            )
    }

    /*
     * Guarda GPS_ENABLED / GPS_DISABLED.
     */
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

    /*
     * Devuelve solamente el evento
     * más reciente de cada usuario.
     *
     * Esto permite que React sepa
     * si el último estado conocido
     * del GPS fue:
     *
     * GPS_ENABLED
     * GPS_DISABLED
     */
    func getLatestEvents(
        request: Request
    ) async throws
        -> [DriverTrackingEvent]
    {
        let user =
            try request.auth.require(
                AuthenticatedUserContext.self
            )

        /*
         * Solamente usuarios con permiso
         * para monitorear diligencieros
         * pueden consultar los eventos.
         */
        guard user.canViewAllTickets else {
            throw Abort(
                .forbidden,
                reason:
                    "No tienes permiso para consultar eventos GPS."
            )
        }

        /*
         * Obtenemos eventos ordenados
         * del más reciente al más antiguo.
         */
        let events =
            try await DriverTrackingEvent
                .query(
                    on: request.db
                )
                .sort(
                    \.$createdAt,
                    .descending
                )
                .all()

        /*
         * Como están ordenados de más
         * reciente a más antiguo,
         * conservamos solamente el primero
         * que aparezca para cada userId.
         */
        var seenUsers =
            Set<UUID>()

        var latestEvents:
            [DriverTrackingEvent] = []

        for event in events {

            if seenUsers.contains(
                event.userId
            ) {
                continue
            }

            seenUsers.insert(
                event.userId
            )

            latestEvents.append(
                event
            )
        }

        return latestEvents
    }
}