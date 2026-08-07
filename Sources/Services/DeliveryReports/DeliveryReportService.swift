import Fluent

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
}