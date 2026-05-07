import SwiftUI

@main
struct ChordbotLiteApp: App {
    @State private var state = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(state)
        }
    }
}
