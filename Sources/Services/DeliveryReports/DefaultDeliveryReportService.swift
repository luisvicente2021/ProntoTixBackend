import Vapor
import Fluent

struct DefaultDeliveryReportService: DeliveryReportService {

    private let repository: DeliveryReportRepository

    init(
        repository: DeliveryReportRepository
    ) {
        self.repository = repository
    }

    func create(
        ticketId: Int64,
        request: CreateDeliveryReportRequest,
        on database: Database
    ) async throws -> DeliveryReportResponse {

        // Verificamos que el ticket exista.
        guard try await Ticket.find(
            ticketId,
            on: database
        ) != nil else {
            throw Abort(
                .notFound,
                reason: "No se encontró el ticket."
            )
        }

        guard !request.receiverName
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            .isEmpty
        else {
            throw Abort(
                .badRequest,
                reason: "El nombre de quien recibe es obligatorio."
            )
        }

        guard !request.items.isEmpty else {
            throw Abort(
                .badRequest,
                reason: "Debes agregar al menos un material."
            )
        }

        // El backend calcula el total.
        var totalAmount = 0.0

        for item in request.items {
            guard !item.material
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
                .isEmpty
            else {
                throw Abort(
                    .badRequest,
                    reason: "La descripción del material es obligatoria."
                )
            }

            guard item.quantity > 0 else {
                throw Abort(
                    .badRequest,
                    reason: "La cantidad debe ser mayor a cero."
                )
            }

            guard item.unitPrice >= 0 else {
                throw Abort(
                    .badRequest,
                    reason: "El precio no puede ser negativo."
                )
            }

            totalAmount +=
                item.quantity * item.unitPrice
        }

        let report = DeliveryReport(
            ticketId: ticketId,
            provider: request.provider
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                ),
            receiverName: request.receiverName
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                ),
            observations: request.observations,
            totalAmount: totalAmount
        )

        // Necesitamos el UUID antes de crear los items.
        report.id = UUID()

        guard let reportId = report.id else {
            throw Abort(
                .internalServerError,
                reason: "No fue posible generar el ID del reporte."
            )
        }

        let items = request.items.map { input in
            DeliveryReportItem(
                reportId: reportId,
                material: input.material
                    .trimmingCharacters(
                        in: .whitespacesAndNewlines
                    ),
                quantity: input.quantity,
                unitPrice: input.unitPrice
            )
        }

        try await repository.create(
            report: report,
            items: items,
            on: database
        )

        return makeResponse(
            report: report,
            items: items
        )
    }

    func getByTicketId(
        ticketId: Int64,
        on database: Database
    ) async throws -> DeliveryReportResponse {

        guard let report =
            try await repository.findByTicketId(
                ticketId: ticketId,
                on: database
            )
        else {
            throw Abort(
                .notFound,
                reason: "Este ticket no tiene reporte de entrega."
            )
        }

        guard let reportId = report.id else {
            throw Abort(
                .internalServerError,
                reason: "El reporte no tiene un ID válido."
            )
        }

        let items = try await repository.findItems(
            reportId: reportId,
            on: database
        )

        return makeResponse(
            report: report,
            items: items
        )
    }

    private func makeResponse(
        report: DeliveryReport,
        items: [DeliveryReportItem]
    ) -> DeliveryReportResponse {

        DeliveryReportResponse(
            id: report.id,
            ticketId: report.ticketId,
            provider: report.provider,
            receiverName: report.receiverName,
            observations: report.observations,
            totalAmount: report.totalAmount,
            receiptUrl: report.receiptUrl,
            signatureUrl: report.signatureUrl,
            pdfUrl: report.pdfUrl,
            createdAt: report.createdAt,
            items: items.map { item in
                DeliveryReportItemResponse(
                    id: item.id,
                    material: item.material,
                    quantity: item.quantity,
                    unitPrice: item.unitPrice,
                    total: item.total
                )
            }
        )
    }
}