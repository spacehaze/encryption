import SwiftUI

@main
struct ChordmateApp: App {
    @State private var state = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(state)
        }
    }
}
