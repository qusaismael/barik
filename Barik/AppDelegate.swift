import Combine
import SwiftUI

/// This class creates the main window and starts the mouse monitor.
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NonFocusableWindow!
    var hoverState = HoverState()
    var monitor: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        configureActivationPolicy()
        setupWindow()
        window.orderFront(nil)
        startMouseMonitor()
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

        // Set the content view with our main SwiftUI view.
        window.contentView = NSHostingView(rootView: MainView().environmentObject(hoverState))
    }

    private func startMouseMonitor() {
        monitor = NSEvent.addGlobalMonitorForEvents(matching: .mouseMoved) { [weak self] event in
            guard let self = self else { return }
            let mouseLocation = NSEvent.mouseLocation
            let windowFrame = self.window.frame

            // Define a rectangle on the right side of the window.
            let rightRect = NSRect(
                x: windowFrame.midX,
                y: windowFrame.maxY - 55,
                width: windowFrame.width / 2,
                height: 55
            )

            DispatchQueue.main.async {
                self.hoverState.isHovered = rightRect.contains(mouseLocation)
            }
        }
    }
}

/// This class holds a hover state.
class HoverState: ObservableObject {
    @Published var isHovered: Bool = false
}
