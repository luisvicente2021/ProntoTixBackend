import Fluent
import Foundation

protocol DeliveryReportRepository {
    func create(
        report: DeliveryReport,
        items: [DeliveryReportItem],
        on database: Database
    ) async throws

    func findByTicketId(
        ticketId: Int64,
        on database: Database
    ) async throws -> DeliveryReport?

    func findItems(
        reportId: UUID,
        on database: Database
    ) async throws -> [DeliveryReportItem]

    func createEvidence(
    _ evidence: DeliveryReportEvidence,
    on database: Database
) async throws
}