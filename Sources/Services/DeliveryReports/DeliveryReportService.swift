import Fluent
import Vapor

protocol DeliveryReportService {

    func create(
        ticketId: Int64,
        request: CreateDeliveryReportRequest,
        on database: Database
    ) async throws -> DeliveryReportResponse

    func getByTicketId(
        ticketId: Int64,
        on database: Database
    ) async throws -> DeliveryReportResponse

    func updateFiles(
    ticketId: Int64,
    request: UpdateDeliveryReportFilesRequest,
    on database: Database
) async throws -> DeliveryReportResponse

func addEvidence(
    ticketId: Int64,
    request: CreateDeliveryReportEvidenceRequest,
    on database: Database
) async throws -> HTTPStatus
}