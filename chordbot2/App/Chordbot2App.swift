import SwiftUI

@main
struct Chordbot2App: App {
    @State private var state = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(state)
        }
    }
}
