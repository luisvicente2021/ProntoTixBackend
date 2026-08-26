import Fluent
import Vapor

struct DriverShiftController: RouteCollection {

    private let authenticator: SupabaseAuthMiddleware

    init(
        authenticator: SupabaseAuthMiddleware
    ) {
        self.authenticator = authenticator
    }

    func boot(
        routes: RoutesBuilder
    ) throws {

        let protected = routes
            .grouped("api")
            .grouped(authenticator)
            .grouped(
                AuthenticatedUserContext
                    .guardMiddleware()
            )

        let shifts = protected
            .grouped("driver-shifts")

        /*
         * Iniciar jornada del
         * diligenciero autenticado.
         */
        shifts
            .grouped("start")
            .post(
                use: startShift
            )

        /*
         * Consultar la jornada activa
         * del diligenciero autenticado.
         */
        shifts
            .grouped("active")
            .get(
                use: getActiveShift
            )

        /*
         * Consultar TODAS las jornadas
         * activas.
         *
         * Esta ruta será utilizada por
         * la web de monitoreo.
         */
        shifts
            .grouped(
                "active",
                "all"
            )
            .get(
                use:
                    getAllActiveShifts
            )

        /*
         * Finalizar jornada del
         * diligenciero autenticado.
         */
        shifts
            .grouped("end")
            .post(
                use: endShift
            )
    }

    // MARK: - Iniciar jornada

    func startShift(
        request: Request
    ) async throws
        -> DriverShiftResponse {

        let user =
            try request.auth.require(
                AuthenticatedUserContext.self
            )

        let normalizedRole =
            user.role
                .trimmingCharacters(
                    in:
                        .whitespacesAndNewlines
                )
                .lowercased()

        /*
         * Solo los diligencieros
         * pueden iniciar jornada.
         */
        guard
            normalizedRole ==
                "tecnico" ||
            normalizedRole ==
                "técnico" ||
            normalizedRole ==
                "diligenciero"
        else {
            throw Abort(
                .forbidden,
                reason:
                    "Solo los diligencieros pueden iniciar una jornada."
            )
        }

        /*
         * Evitamos crear dos jornadas
         * activas para el mismo usuario.
         */
        let existing =
            try await DriverShift
                .query(
                    on: request.db
                )
                .filter(
                    \.$userId ==
                        user.userId
                )
                .filter(
                    \.$status ==
                        "active"
                )
                .sort(
                    \.$startedAt,
                    .descending
                )
                .first()

        /*
         * Si ya tiene una jornada activa,
         * devolvemos esa misma.
         */
        if let existing {
            return try response(
                from: existing
            )
        }

        let shift =
            DriverShift(
                userId:
                    user.userId
            )

        try await shift.create(
            on: request.db
        )

        return try response(
            from: shift
        )
    }

    // MARK: - Consultar jornada activa propia

    func getActiveShift(
        request: Request
    ) async throws
        -> ActiveDriverShiftResponse {

        let user =
            try request.auth.require(
                AuthenticatedUserContext.self
            )

        let normalizedRole =
            user.role
                .trimmingCharacters(
                    in:
                        .whitespacesAndNewlines
                )
                .lowercased()

        guard
            normalizedRole ==
                "tecnico" ||
            normalizedRole ==
                "técnico" ||
            normalizedRole ==
                "diligenciero"
        else {
            throw Abort(
                .forbidden,
                reason:
                    "Solo los diligencieros pueden consultar su jornada."
            )
        }

        let shift =
            try await DriverShift
                .query(
                    on: request.db
                )
                .filter(
                    \.$userId ==
                        user.userId
                )
                .filter(
                    \.$status ==
                        "active"
                )
                .sort(
                    \.$startedAt,
                    .descending
                )
                .first()

        guard let shift else {
            return
                ActiveDriverShiftResponse(
                    active: false,
                    shift: nil
                )
        }

        return
            ActiveDriverShiftResponse(
                active: true,
                shift:
                    try response(
                        from: shift
                    )
            )
    }

    // MARK: - Consultar todas las jornadas activas

    func getAllActiveShifts(
        request: Request
    ) async throws
        -> [DriverShiftResponse] {

        let user =
            try request.auth.require(
                AuthenticatedUserContext.self
            )

        let normalizedRole =
            user.role
                .trimmingCharacters(
                    in:
                        .whitespacesAndNewlines
                )
                .lowercased()

        /*
         * Los diligencieros solamente
         * pueden consultar su propia
         * jornada.
         *
         * La web administrativa puede
         * consultar todas.
         */
        let driverRoles:
            Set<String> = [
                "tecnico",
                "técnico",
                "diligenciero"
            ]

        guard
            !driverRoles.contains(
                normalizedRole
            )
        else {
            throw Abort(
                .forbidden,
                reason:
                    "Los diligencieros no pueden consultar las jornadas de otros usuarios."
            )
        }

        let shifts =
            try await DriverShift
                .query(
                    on: request.db
                )
                .filter(
                    \.$status ==
                        "active"
                )
                .sort(
                    \.$startedAt,
                    .descending
                )
                .all()

        return try shifts.map {
            shift in

            try response(
                from: shift
            )
        }
    }

    // MARK: - Finalizar jornada

    func endShift(
        request: Request
    ) async throws
        -> DriverShiftResponse {

        let user =
            try request.auth.require(
                AuthenticatedUserContext.self
            )

        let normalizedRole =
            user.role
                .trimmingCharacters(
                    in:
                        .whitespacesAndNewlines
                )
                .lowercased()

        guard
            normalizedRole ==
                "tecnico" ||
            normalizedRole ==
                "técnico" ||
            normalizedRole ==
                "diligenciero"
        else {
            throw Abort(
                .forbidden,
                reason:
                    "Solo los diligencieros pueden finalizar su jornada."
            )
        }

        guard let shift =
            try await DriverShift
                .query(
                    on: request.db
                )
                .filter(
                    \.$userId ==
                        user.userId
                )
                .filter(
                    \.$status ==
                        "active"
                )
                .sort(
                    \.$startedAt,
                    .descending
                )
                .first()
        else {
            throw Abort(
                .notFound,
                reason:
                    "No existe una jornada activa."
            )
        }

        shift.status =
            "finished"

        shift.endedAt =
            Date()

        try await shift.update(
            on: request.db
        )

        return try response(
            from: shift
        )
    }

    // MARK: - Mapper

    private func response(
        from shift: DriverShift
    ) throws
        -> DriverShiftResponse {

        guard let id =
            shift.id
        else {
            throw Abort(
                .internalServerError,
                reason:
                    "La jornada no tiene identificador."
            )
        }

        return
            DriverShiftResponse(
                id: id,
                userId:
                    shift.userId,
                startedAt:
                    shift.startedAt,
                endedAt:
                    shift.endedAt,
                status:
                    shift.status
            )
    }
}