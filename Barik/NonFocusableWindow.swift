import Cocoa

/// This window does not accept focus.
class NonFocusableWindow: NSWindow {
    override var canBecomeKey: Bool {
        return false
    }

    override var canBecomeMain: Bool {
        return false
    }
}
