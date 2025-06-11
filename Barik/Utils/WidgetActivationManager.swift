import Foundation
import SwiftUI

/// Manages which widgets are actively displayed and controls their lifecycle
class WidgetActivationManager: ObservableObject {
    static let shared = WidgetActivationManager()
    
    @Published private(set) var activeWidgets: Set<String> = []
    private let configManager = ConfigManager.shared
    
    private init() {
        updateActiveWidgets()
        
        // Listen for config changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(configDidChange),
            name: NSNotification.Name("ConfigChanged"),
            object: nil
        )
    }
    
    @objc private func configDidChange() {
        updateActiveWidgets()
    }
    
    private func updateActiveWidgets() {
        let displayedWidgets = configManager.config.rootToml.widgets.displayed
        let newActiveWidgets = Set(displayedWidgets.map { $0.id })
        
        DispatchQueue.main.async {
            self.activeWidgets = newActiveWidgets
        }
        
        // Notify about widget activation changes
        NotificationCenter.default.post(
            name: NSNotification.Name("WidgetActivationChanged"),
            object: newActiveWidgets
        )
    }
    
    /// Checks if a widget with the given ID is currently active (displayed)
    func isWidgetActive(_ widgetId: String) -> Bool {
        return activeWidgets.contains(widgetId)
    }
    
    /// Get all active widget IDs
    func getActiveWidgets() -> Set<String> {
        return activeWidgets
    }
}

/// A protocol for widgets that can be conditionally activated
protocol ConditionallyActivatableWidget {
    func activate()
    func deactivate()
    var widgetId: String { get }
}

/// Extension to help with conditional widget activation
extension ObservableObject {
    func activateIfNeeded(widgetId: String) {
        let activationManager = WidgetActivationManager.shared
        
        // Only activate if the widget is being displayed
        if activationManager.isWidgetActive(widgetId) {
            if let activatable = self as? ConditionallyActivatableWidget {
                activatable.activate()
            }
        }
    }
    
    func deactivateIfNeeded(widgetId: String) {
        let activationManager = WidgetActivationManager.shared
        
        // Deactivate if the widget is not being displayed
        if !activationManager.isWidgetActive(widgetId) {
            if let activatable = self as? ConditionallyActivatableWidget {
                activatable.deactivate()
            }
        }
    }
} 