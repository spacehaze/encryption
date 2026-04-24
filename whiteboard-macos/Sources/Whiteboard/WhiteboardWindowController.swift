import AppKit
import SwiftUI
import WhiteboardCore

final class WhiteboardWindowController: NSWindowController {
    convenience init(model: DrawingModel) {
        let hosting = NSHostingController(rootView: WhiteboardView(model: model))
        let window = NSWindow(contentViewController: hosting)
        window.title = "Whiteboard"
        window.setContentSize(NSSize(width: 1280, height: 800))
        window.styleMask = [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView]
        window.collectionBehavior = [.fullScreenPrimary]
        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = true
        window.backgroundColor = .white
        window.center()
        self.init(window: window)
    }
}
