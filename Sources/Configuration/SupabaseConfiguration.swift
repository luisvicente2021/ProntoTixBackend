import Vapor

struct SupabaseConfiguration: Sendable {
    let url: String
    let publishableKey: String

    static func fromEnvironment() throws -> SupabaseConfiguration {
        guard let url = Environment.get("SUPABASE_URL"),
              !url.isEmpty else {
            throw Abort(
                .internalServerError,
                reason: "Falta la variable SUPABASE_URL."
            )
        }

        guard let publishableKey =
                Environment.get("SUPABASE_PUBLISHABLE_KEY"),
              !publishableKey.isEmpty else {
            throw Abort(
                .internalServerError,
                reason: "Falta la variable SUPABASE_PUBLISHABLE_KEY."
            )
        }

        return SupabaseConfiguration(
            url: url.trimmingCharacters(
                in: CharacterSet(charactersIn: "/")
            ),
            publishableKey: publishableKey
        )
    }
}