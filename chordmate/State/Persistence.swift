import Foundation

/// Saves the active progression to `UserDefaults` so the app reopens with the
/// user's last edit. JSON-encoded so it's debuggable from `defaults read`.
enum Persistence {
    private static let key = "Chordmate.progression.v1"

    static func save(_ progression: Progression) {
        guard let data = try? JSONEncoder().encode(progression) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    static func load() -> Progression? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(Progression.self, from: data)
    }
}
