import Fluent
import Vapor

struct FluentDeliveryReportRepository: DeliveryReportRepository {

    func create(
        report: DeliveryReport,
        items: [DeliveryReportItem],
        on database: Database
    ) async throws {
        try await database.transaction { transaction in
            try await report.create(on: transaction)

            guard let reportId = report.id else {
                throw Abort(
                    .internalServerError,
                    reason: "El reporte fue creado sin ID."
                )
            }

            for item in items {
                item.reportId = reportId
                try await item.create(on: transaction)
            }
        }
    }

    func findByTicketId(
        ticketId: Int64,
        on database: Database
    ) async throws -> DeliveryReport? {
        try await DeliveryReport.query(on: database)
            .filter(\.$ticketId == ticketId)
            .sort(\.$createdAt, .descending)
            .first()
    }

    func findItems(
        reportId: UUID,
        on database: Database
    ) async throws -> [DeliveryReportItem] {
        try await DeliveryReportItem.query(on: database)
            .filter(\.$reportId == reportId)
            .all()
    }

    func createEvidence(
    _ evidence: DeliveryReportEvidence,
    on database: Database
) async throws {
    try await evidence.create(on: database)
}
}