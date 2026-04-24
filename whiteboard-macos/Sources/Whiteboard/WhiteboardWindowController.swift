import AppKit
import SwiftUI

final class WhiteboardWindowController: NSWindowController {
    convenience init(model: DrawingModel) {
        let contentView = WhiteboardView(model: model)
        let hosting = NSHostingController(rootView: contentView)
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
