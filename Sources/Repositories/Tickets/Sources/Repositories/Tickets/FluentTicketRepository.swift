import Fluent
import Vapor

struct FluentTicketRepository: TicketRepository {

    func findAllWithClient(
        on database: Database
    ) async throws -> [TicketWithClient] {

        let tickets = try await Ticket
            .query(on: database)
            .join(
                Client.self,
                on: \Ticket.$clientId == \Client.$id
            )
            .sort(
                \Ticket.$openedAt,
                .descending
            )
            .all()

        var result: [TicketWithClient] = []

        for ticket in tickets {

            let client = try ticket.joined(
                Client.self
            )

            var assignedUserName: String? = nil

            if let assignedUserId =
                ticket.assignedUserId {

                let profile = try await Profile.find(
                    assignedUserId,
                    on: database
                )

                assignedUserName =
                    profile?.name
            }

            result.append(
                TicketWithClient(
                    ticket: ticket,
                    clientName: client.name,
                    assignedUserName:
                        assignedUserName
                )
            )
        }

        return result
    }

    func findWithClient(
        id: Int64,
        on database: Database
    ) async throws -> TicketWithClient? {

        guard let ticket = try await Ticket
            .query(on: database)
            .filter(\.$id == id)
            .join(
                Client.self,
                on: \Ticket.$clientId == \Client.$id
            )
            .first()
        else {
            return nil
        }

        let client = try ticket.joined(
            Client.self
        )

        var assignedUserName: String? = nil

        if let assignedUserId =
            ticket.assignedUserId {

            let profile = try await Profile.find(
                assignedUserId,
                on: database
            )

            assignedUserName =
                profile?.name
        }

        return TicketWithClient(
            ticket: ticket,
            clientName: client.name,
            assignedUserName:
                assignedUserName
        )
    }

    func find(
        id: Int64,
        on database: Database
    ) async throws -> Ticket? {

        try await Ticket.find(
            id,
            on: database
        )
    }

    func create(
        _ ticket: Ticket,
        on database: Database
    ) async throws {

        try await ticket.create(
            on: database
        )
    }

    func update(
        _ ticket: Ticket,
        on database: Database
    ) async throws {

        try await ticket.update(
            on: database
        )
    }

    func delete(
        _ ticket: Ticket,
        on database: Database
    ) async throws {

        try await ticket.delete(
            on: database
        )
    }
}