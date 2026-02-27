# Reminder Notifications Feature

## Overview
Implemented smart reminder notifications that alert users to put their aligners back in after removal.

## How It Works

### Timeline
1. **User removes aligners** → Presses "Remove Aligners" button
2. **After 20 minutes** → First notification: "It's been 20 minutes. Are you still eating? If not, put your aligners back in."
3. **Every 10 minutes after** → Follow-up notifications: "Don't forget to put your aligners back in!"
4. **User puts aligners back** → All pending notifications are cancelled

### Settings Configuration

**New Settings in `TrackerSettings`:**
- `remindersEnabled: Bool` - Toggle reminders on/off (default: `true`)
- `firstReminderMinutes: Int` - Time until first reminder (default: `20` minutes)
- `followUpReminderMinutes: Int` - Interval for follow-ups (default: `10` minutes)

**User Controls (in Settings tab):**
```
Reminders
┌─────────────────────────────────────┐
│ Enable Reminders          [Toggle]  │
│ Get notified to put aligners back   │
│                                     │
│ First Reminder            20m       │
│ After removing aligners    [-] [+]  │
│                                     │
│ Follow-up Interval        10m       │
│ Repeat reminder every      [-] [+]  │
└─────────────────────────────────────┘
```

**Customization Ranges:**
- First reminder: 10-60 minutes (steps of 5)
- Follow-up interval: 5-30 minutes (steps of 5)

## Technical Implementation

### 1. ReminderNotificationManager
New singleton class that handles all notification scheduling:

```swift
@MainActor
final class ReminderNotificationManager {
    static let shared = ReminderNotificationManager()
    
    // Request notification permissions
    func requestAuthorization() async -> Bool
    
    // Schedule reminder notifications
    func scheduleReminders(
        firstReminderMinutes: Int,
        followUpReminderMinutes: Int,
        removalTime: Date
    ) async
    
    // Cancel all pending reminders
    func cancelAllReminders() async
}
```

**Notification Schedule:**
- 1st reminder: After `firstReminderMinutes` (e.g., 20 min)
- 2nd reminder: First + `followUpReminderMinutes` (e.g., 30 min)
- 3rd reminder: First + 2×`followUpReminderMinutes` (e.g., 40 min)
- ...continues up to 6 follow-ups (total ~80 minutes of reminders)

### 2. TrackingStore Integration
Updated `toggleAligner()` to automatically handle notifications:

```swift
func toggleAligner(now: Date = Date()) async {
    try await repository.toggleAligner(at: now)
    await load()
    
    if settings.remindersEnabled {
        if isAlignerOut {
            // Schedule reminders
            await ReminderNotificationManager.shared.scheduleReminders(...)
        } else {
            // Cancel all reminders
            await ReminderNotificationManager.shared.cancelAllReminders()
        }
    }
}
```

### 3. Settings UI
New components:
- `SettingsToggleRow` - Toggle switch for enabling/disabling reminders
- Updated `SettingsViewModel` with reminder update methods

## User Experience

### Example Timeline (Default Settings)

**9:00 AM** - User removes aligners for breakfast
- App schedules notifications

**9:20 AM** - First reminder notification
> "It's been 20 minutes. Are you still eating? If not, put your aligners back in."

**9:30 AM** - Follow-up reminder (if aligners still out)
> "Don't forget to put your aligners back in!"

**9:40 AM** - Another follow-up
> "Don't forget to put your aligners back in!"

**9:45 AM** - User puts aligners back in
- All remaining notifications automatically cancelled

### Notification Permissions

On first enable, the app requests notification permissions:
```
"Invisalign Tracker" Would Like to Send You Notifications
Notifications may include alerts, sounds, and icon badges.
[Don't Allow]  [Allow]
```

## Benefits

✅ **Smart timing** - First reminder after eating time, then persistent follow-ups
✅ **Customizable** - Users can adjust timing to their schedule
✅ **Non-intrusive** - Auto-cancels when aligners are back in
✅ **Helps compliance** - Prevents forgetting aligners for extended periods
✅ **Flexible** - Can be disabled entirely in settings

## Files Modified/Created

**Created:**
- `ReminderNotificationManager.swift` - Core notification logic

**Modified:**
- `TrackerSettings.swift` - Added reminder settings
- `TrackingStore.swift` - Integrated notification scheduling
- `SettingsView.swift` - Added reminder controls
- `SettingsComponents.swift` - Added SettingsToggleRow
- `SettingsViewModel.swift` - Added reminder update methods

## Future Enhancements

Potential improvements:
- Different notification sounds
- Custom notification messages
- Smart scheduling (e.g., skip reminders during typical meal times)
- Notification history/analytics
- Integration with iOS Focus modes
