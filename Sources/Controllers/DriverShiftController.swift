import Fluent
import Vapor

struct DriverShiftController: RouteCollection {

    private let authenticator: SupabaseAuthMiddleware

    init(
        authenticator: SupabaseAuthMiddleware
    ) {
        self.authenticator = authenticator
    }

    func boot(routes: RoutesBuilder) throws {

        let protected = routes
            .grouped("api")
            .grouped(authenticator)
            .grouped(
                AuthenticatedUserContext.guardMiddleware()
            )

        let shifts = protected
            .grouped("driver-shifts")

        shifts
            .grouped("start")
            .post(use: startShift)

        shifts
            .grouped("active")
            .get(use: getActiveShift)

        shifts
            .grouped("end")
            .post(use: endShift)
    }

    // MARK: - Iniciar jornada

    func startShift(
        request: Request
    ) async throws -> DriverShiftResponse {

        let user = try request.auth.require(
            AuthenticatedUserContext.self
        )

        // Comprobar que realmente sea diligenciero
        guard user.role.lowercased() == "tecnico" else {
            throw Abort(
                .forbidden,
                reason: "Solo los diligencieros pueden iniciar una jornada."
            )
        }

        // Evitar dos jornadas activas
        let existing = try await DriverShift.query(
            on: request.db
        )
        .filter(
            \.$userId == user.userId
        )
        .filter(
            \.$status == "active"
        )
        .first()

        if let existing {
            return try response(from: existing)
        }

        let shift = DriverShift(
            userId: user.userId
        )

        try await shift.create(
            on: request.db
        )

        return try response(from: shift)
    }

    // MARK: - Consultar jornada activa

    func getActiveShift(
    request: Request
) async throws -> ActiveDriverShiftResponse {

    let user = try request.auth.require(
        AuthenticatedUserContext.self
    )

    guard user.role
        .trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        .lowercased() == "tecnico"
    else {
        throw Abort(
            .forbidden,
            reason:
                "Solo los diligencieros pueden consultar su jornada."
        )
    }

    let shift = try await DriverShift.query(
        on: request.db
    )
    .filter(
        \.$userId == user.userId
    )
    .filter(
        \.$status == "active"
    )
    .sort(
        \.$startedAt,
        .descending
    )
    .first()

    guard let shift else {
        return ActiveDriverShiftResponse(
            active: false,
            shift: nil
        )
    }

    return ActiveDriverShiftResponse(
        active: true,
        shift: try response(
            from: shift
        )
    )
}

    // MARK: - Finalizar jornada

    func endShift(
        request: Request
    ) async throws -> DriverShiftResponse {

        let user = try request.auth.require(
            AuthenticatedUserContext.self
        )

        guard user.role.lowercased() == "tecnico" else {
            throw Abort(
                .forbidden,
                reason: "Solo los diligencieros pueden finalizar su jornada."
            )
        }

        guard let shift = try await DriverShift.query(
            on: request.db
        )
        .filter(
            \.$userId == user.userId
        )
        .filter(
            \.$status == "active"
        )
        .sort(
            \.$startedAt,
            .descending
        )
        .first()
        else {
            throw Abort(
                .notFound,
                reason: "No existe una jornada activa."
            )
        }

        shift.status = "finished"
        shift.endedAt = Date()

        try await shift.update(
            on: request.db
        )

        return try response(from: shift)
    }

    // MARK: - Mapper

    private func response(
        from shift: DriverShift
    ) throws -> DriverShiftResponse {

        guard let id = shift.id else {
            throw Abort(
                .internalServerError,
                reason: "La jornada no tiene identificador."
            )
        }

        return DriverShiftResponse(
            id: id,
            userId: shift.userId,
            startedAt: shift.startedAt,
            endedAt: shift.endedAt,
            status: shift.status
        )
    }
}