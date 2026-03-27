import Foundation

/// Shared storage between Watch App and Watch Widgets using App Groups
/// Note: You'll need to enable App Groups capability in Xcode for both targets
/// Use the same group identifier across iOS app + watch app + widget.

enum WidgetDataStore {
    private static let groupIdentifier = "group.com.example.invisaligntracker"
    private static var defaults: UserDefaults? {
        UserDefaults(suiteName: groupIdentifier)
    }
    
    // Keys
    private enum Keys {
        static let isAlignerOut = "widget_isAlignerOut"
        static let wornMinutes = "widget_wornMinutes"
        static let outMinutes = "widget_outMinutes"
        static let targetMinutes = "widget_targetMinutes"
        static let deficitMinutes = "widget_deficitMinutes"
        static let sessionStart = "widget_sessionStart"
        static let trayNumber = "widget_trayNumber"
        static let lastUpdate = "widget_lastUpdate"
    }
    
    /// Save current state for widget consumption.
    static func saveState(
        isAlignerOut: Bool,
        wornTodayMinutes: Int,
        outTodayMinutes: Int,
        targetMinutes: Int,
        cumulativeDeficitMinutes: Int,
        sessionStart: Date?,
        currentTrayNumber: Int?
    ) {
        guard let defaults = defaults else {
            print("⌚️ [WidgetDataStore] App Group not configured")
            return
        }
        
        defaults.set(isAlignerOut, forKey: Keys.isAlignerOut)
        defaults.set(wornTodayMinutes, forKey: Keys.wornMinutes)
        defaults.set(outTodayMinutes, forKey: Keys.outMinutes)
        defaults.set(targetMinutes, forKey: Keys.targetMinutes)
        defaults.set(cumulativeDeficitMinutes, forKey: Keys.deficitMinutes)
        defaults.set(sessionStart, forKey: Keys.sessionStart)
        
        if let trayNumber = currentTrayNumber {
            defaults.set(trayNumber, forKey: Keys.trayNumber)
        } else {
            defaults.removeObject(forKey: Keys.trayNumber)
        }
        
        defaults.set(Date(), forKey: Keys.lastUpdate)
        
        print("⌚️ [WidgetDataStore] Saved state for widgets")
    }
    
    /// Load current state (used by widgets)
    static func loadState() -> (isOut: Bool, worn: Int, outToday: Int, target: Int, deficit: Int, sessionStart: Date?, tray: Int?) {
        guard let defaults = defaults else {
            return (false, 0, 0, 1320, 0, nil, nil)
        }
        
        return (
            defaults.bool(forKey: Keys.isAlignerOut),
            defaults.integer(forKey: Keys.wornMinutes),
            defaults.integer(forKey: Keys.outMinutes),
            defaults.integer(forKey: Keys.targetMinutes),
            defaults.integer(forKey: Keys.deficitMinutes),
            defaults.object(forKey: Keys.sessionStart) as? Date,
            defaults.object(forKey: Keys.trayNumber) as? Int
        )
    }
}
