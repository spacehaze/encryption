import AppKit
import SwiftUI
import WhiteboardCore

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
        addMenuItem(to: menu, title: "Show Whiteboard", key: "w", action: #selector(showWhiteboardMenu))
        addMenuItem(to: menu, title: "Toggle Fullscreen", key: "f", action: #selector(toggleFullscreenMenu))
        addMenuItem(to: menu, title: "Clear Canvas", key: "k", action: #selector(clearMenu))
        menu.addItem(.separator())
        menu.addItem(withTitle: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        item.menu = menu
        statusItem = item
    }

    private func addMenuItem(to menu: NSMenu, title: String, key: String, action: Selector) {
        let item = menu.addItem(withTitle: title, action: action, keyEquivalent: key)
        item.target = self
    }

    @objc private func showWhiteboardMenu() { showWhiteboard() }
    @objc private func toggleFullscreenMenu() { windowController?.window?.toggleFullScreen(nil) }
    @objc private func clearMenu() { model.apply(.clear) }

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
