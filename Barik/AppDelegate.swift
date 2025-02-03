import Combine
import SwiftUI

/// This class creates the main window.
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NonFocusableWindow!

    func applicationDidFinishLaunching(_ notification: Notification) {
        configureActivationPolicy()
        setupWindow()
        window.orderFront(nil)
    }

    private func configureActivationPolicy() {
        NSApp.setActivationPolicy(.accessory)
    }

    private func setupWindow() {
        guard let screen = NSScreen.main?.visibleFrame else { return }
        let windowFrame = NSRect(x: 0, y: 0, width: screen.size.width, height: screen.size.height)

        window = NonFocusableWindow(
            contentRect: windowFrame,
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        window.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopWindow)))
        window.backgroundColor = .clear
        window.hasShadow = false
        window.collectionBehavior = [.canJoinAllSpaces]
        window.ignoresMouseEvents = false
        window.acceptsMouseMovedEvents = true

        window.contentView = NSHostingView(rootView: MainView())
    }
}
