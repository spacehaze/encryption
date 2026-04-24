import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var windowController: WhiteboardWindowController?
    private var commandServer: CommandServer?
    private let model = DrawingModel()

    func applicationDidFinishLaunching(_ notification: Notification) {
        buildStatusItem()
        showWhiteboard()
        startCommandServer()
    }

    func applicationWillTerminate(_ notification: Notification) {
        commandServer?.stop()
    }

    private func buildStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.button?.title = "Whiteboard"
        item.button?.image = NSImage(systemSymbolName: "rectangle.on.rectangle", accessibilityDescription: "Whiteboard")
        let menu = NSMenu()
        menu.addItem(withTitle: "Show Whiteboard", action: #selector(showWhiteboardMenu), keyEquivalent: "w").target = self
        menu.addItem(withTitle: "Toggle Fullscreen", action: #selector(toggleFullscreenMenu), keyEquivalent: "f").target = self
        menu.addItem(withTitle: "Clear Canvas", action: #selector(clearMenu), keyEquivalent: "k").target = self
        menu.addItem(.separator())
        menu.addItem(withTitle: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        item.menu = menu
        statusItem = item
    }

    @objc private func showWhiteboardMenu() { showWhiteboard() }
    @objc private func toggleFullscreenMenu() { windowController?.window?.toggleFullScreen(nil) }
    @objc private func clearMenu() { model.clear() }

    private func showWhiteboard() {
        if windowController == nil {
            windowController = WhiteboardWindowController(model: model)
        }
        windowController?.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func startCommandServer() {
        let server = CommandServer(model: model, port: 7017)
        do {
            try server.start()
            commandServer = server
            NSLog("Whiteboard command server listening on 127.0.0.1:7017")
        } catch {
            NSLog("Failed to start command server: \(error)")
        }
    }
}
