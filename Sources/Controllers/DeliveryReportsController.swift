import Vapor

struct DeliveryReportsController: RouteCollection {

    private let service: DeliveryReportService
    private let authenticator: SupabaseAuthMiddleware

    init(
        service: DeliveryReportService,
        authenticator: SupabaseAuthMiddleware
    ) {
        self.service = service
        self.authenticator = authenticator
    }

    func boot(routes: RoutesBuilder) throws {
        let reports = routes
            .grouped(
                "api",
                "tickets",
                ":id",
                "delivery-report"
            )
            .grouped(authenticator)
            .grouped(
                AuthenticatedUserContext.guardMiddleware()
            )

        reports.post(use: create)
        reports.get(use: show)
        reports.patch("files", use: updateFiles)
        reports.post("evidence", use: addEvidence)
    }

    func create(
        request: Request
    ) async throws -> DeliveryReportResponse {

        guard let ticketId = request.parameters.get(
            "id",
            as: Int64.self
        ) else {
            throw Abort(
                .badRequest,
                reason: "El ID del ticket no es válido."
            )
        }

        let input = try request.content.decode(
            CreateDeliveryReportRequest.self
        )

        return try await service.create(
            ticketId: ticketId,
            request: input,
            on: request.db
        )
    }

    func show(
        request: Request
    ) async throws -> DeliveryReportResponse {

        guard let ticketId = request.parameters.get(
            "id",
            as: Int64.self
        ) else {
            throw Abort(
                .badRequest,
                reason: "El ID del ticket no es válido."
            )
        }

        return try await service.getByTicketId(
            ticketId: ticketId,
            on: request.db
        )
    }

    func updateFiles(
    request: Request
) async throws -> DeliveryReportResponse {

    guard let ticketId = request.parameters.get(
        "id",
        as: Int64.self
    ) else {
        throw Abort(
            .badRequest,
            reason: "El ID del ticket no es válido."
        )
    }

    let input = try request.content.decode(
        UpdateDeliveryReportFilesRequest.self
    )

    return try await service.updateFiles(
        ticketId: ticketId,
        request: input,
        on: request.db
    )
}

func addEvidence(
    request: Request
) async throws -> HTTPStatus {

    guard let ticketId = request.parameters.get(
        "id",
        as: Int64.self
    ) else {
        throw Abort(
            .badRequest,
            reason: "El ID del ticket no es válido."
        )
    }

    let input = try request.content.decode(
        CreateDeliveryReportEvidenceRequest.self
    )

    return try await service.addEvidence(
        ticketId: ticketId,
        request: input,
        on: request.db
    )
}
}