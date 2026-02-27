# Apple Watch Integration - Setup Guide

## 📋 Complete File Structure

```
InvisalignTracker/
├── project.yml (UPDATED)
├── WatchStatePayload.swift (NEW - Shared between iOS & Watch)
├── WatchConnectivityManager_iOS.swift (NEW - iOS side)
├── iOS_Integration_Instructions.swift (INTEGRATION GUIDE)
│
InvisalignTrackerWatch/ (NEW FOLDER)
├── InvisalignTrackerWatchApp.swift
├── ContentView.swift
├── WatchConnectivityManager.swift
├── WidgetDataStore.swift
├── Info.plist
│
InvisalignTrackerWatchWidget/ (NEW FOLDER)
├── AlignerWidget.swift
├── Info.plist
```

## 🚀 Setup Steps

### 1. Generate Xcode Project
```bash
# Install XcodeGen if you haven't
brew install xcodegen

# Generate the project from project.yml
xcodegen generate
```

### 2. Configure App Groups (Required for Widgets)
Open the generated `.xcodeproj` file in Xcode:

**For iOS App (InvisalignTracker):**
1. Select the iOS app target
2. Go to "Signing & Capabilities"
3. Click "+ Capability" → Add "App Groups"
4. Check or add: `group.com.yourcompany.invisaligntracker`

**For Watch App (InvisalignTrackerWatch):**
1. Select the Watch app target
2. Add "App Groups" capability
3. Use the same group: `group.com.yourcompany.invisaligntracker`

**For Watch Widget (InvisalignTrackerWatchWidget):**
1. Select the Widget extension target
2. Add "App Groups" capability
3. Use the same group: `group.com.yourcompany.invisaligntracker`

### 3. Integrate WatchConnectivity into iOS App

Open your `AppContext.swift` and add:

```swift
import Foundation

@MainActor
final class AppContext: ObservableObject {
    let store: TrackingStore
    private let watchConnectivity = WatchConnectivityManager.shared  // ADD THIS
    
    init(modelContext: ModelContext) {
        // ... existing initialization ...
        
        // ADD THESE LINES:
        watchConnectivity.configure(with: store)
        
        Task {
            await store.load()
            watchConnectivity.syncToWatch()
        }
    }
}
```

Open your `TrackingStore.swift` and add sync calls:

```swift
func toggleAligner(now: Date = Date()) async {
    do {
        try await repository.toggleAligner(at: now)
        await load()
        
        // ADD THIS LINE:
        WatchConnectivityManager.shared.syncToWatch()
        
        // ... rest of existing code ...
    }
}

// Add the same sync call to these methods after `await load()`:
// - deleteSession
// - addTray
// - setCurrentTray
// - updateSettings
```

### 4. Add WatchStatePayload.swift to Both Targets

In Xcode:
1. Add `WatchStatePayload.swift` to your project
2. In Target Membership (File Inspector), check:
   - ✅ InvisalignTracker (iOS)
   - ✅ InvisalignTrackerWatch (watchOS)
   - ✅ InvisalignTrackerWatchWidget (watchOS extension)

This file needs to be shared across all targets.

### 5. Configure Bundle Identifiers

In `project.yml`, update the bundle ID prefix:
```yaml
options:
  bundleIdPrefix: com.yourcompany  # Change this to your identifier
```

### 6. Set Development Team

In `project.yml`, add your Team ID in all target configurations:
```yaml
settings:
  DEVELOPMENT_TEAM: "YOUR_TEAM_ID"
attributes:
  DevelopmentTeam: "YOUR_TEAM_ID"
```

Find your Team ID:
- Xcode → Preferences → Accounts → Select your Apple ID → Manage Certificates
- Or use the free personal team (will be something like "xxxxxxxxxx")

### 7. Build and Run

1. **Connect your iPhone** to your Mac
2. **Pair your Apple Watch** with that iPhone
3. In Xcode, select the **iOS App scheme** and your iPhone as destination
4. Build and run (⌘R)
5. The watch app will automatically install on your paired Apple Watch

### 8. Add Complication to Watch Face

On your Apple Watch:
1. Long-press on your current watch face
2. Tap "Edit"
3. Swipe to complications selection
4. Tap a complication slot
5. Scroll to find "Aligner Tracker"
6. Select the complication style you prefer:
   - **Circular**: Shows progress ring with hours
   - **Rectangular**: Shows status with progress bar
   - **Inline**: Shows compact text status

## 🎨 Customization

### Change Colors

Edit `ContentView.swift` in the watch app:

```swift
// Activity ring colors
private var ringColor: Color {
    if isAlignerOut {
        return .orange  // Change removal color
    } else if progress >= 1.0 {
        return .green   // Change success color
    }
    // ... etc
}
```

### Adjust Update Frequency

Edit `AlignerWidget.swift`:

```swift
// Update every 5 minutes (default)
let nextUpdate = Calendar.current.date(byAdding: .minute, value: 5, to: Date())!

// Change to update more/less frequently:
let nextUpdate = Calendar.current.date(byAdding: .minute, value: 10, to: Date())!
```

## 🐛 Troubleshooting

### Watch app not installing?
1. Make sure your iPhone and Watch are paired
2. Check that both devices are on the same Wi-Fi
3. Restart both devices
4. In Xcode: Product → Clean Build Folder

### Complication not updating?
1. Force-quit the watch app
2. Relaunch from watch home screen
3. Wait a few seconds for sync

### "Watch not reachable" in logs?
- This is normal when the watch is asleep
- Messages will queue and deliver when watch wakes up
- Interactive commands require the watch to be awake

### Data not syncing?
1. Check that App Groups are configured identically on all 3 targets
2. Verify the group identifier matches in `WidgetDataStore.swift`
3. Check console logs for "WatchConnectivity" messages

## 📊 Architecture Overview

```
┌─────────────┐         ┌──────────────┐         ┌────────────┐
│   iPhone    │◄───────►│ WCSession    │◄───────►│   Watch    │
│             │         │ (Bluetooth/  │         │            │
│ TrackingStore         │  Wi-Fi)      │         │ ContentView│
│     │       │         └──────────────┘         │     │      │
│     ▼       │                                   │     ▼      │
│ WatchConn-  │         ┌──────────────┐         │ WatchConn- │
│ ectivity    │         │  App Group   │         │ ectivity   │
│ Manager     │────────►│  Shared      │◄────────│ Manager    │
│             │         │  Storage     │         │     │      │
└─────────────┘         └──────────────┘         │     ▼      │
                               ▲                 │ WidgetData-│
                               │                 │ Store      │
                               │                 └────────────┘
                               │                        │
                               │                        ▼
                               │                 ┌────────────┐
                               └─────────────────│ Widget     │
                                                 │ (Complica- │
                                                 │  tion)     │
                                                 └────────────┘
```

### Data Flow:

1. **User toggles on Watch** → Command sent to iPhone via WatchConnectivity
2. **iPhone processes** → Updates SwiftData → Syncs state back to Watch
3. **Watch receives state** → Updates UI + saves to App Group storage
4. **Widget reads** → Loads from App Group → Shows on watch face

## ⚡️ Performance Notes

- **Battery Impact**: Minimal. WatchConnectivity is designed for this use case
- **Sync Speed**: Near-instant when both devices are awake and connected
- **Offline Handling**: Commands queue automatically and deliver when connected
- **Widget Updates**: Every 5 minutes (configurable)

## 🎯 Feature Checklist

- ✅ Start/Stop timer from watch
- ✅ Live countdown when aligners are out
- ✅ Activity ring showing daily progress
- ✅ Today's summary with session list
- ✅ Watch face complications (3 styles)
- ✅ Automatic syncing with iPhone
- ✅ Dark premium UI matching iOS app
- ✅ Works offline (queues commands)

## 📱 Testing on Free Developer Account

With the free plan:
- Deploy both iOS app and Watch app together
- They share the same 7-day certificate
- When you rebuild the iOS app weekly, the watch app gets rebuilt too
- Just make sure both your iPhone and Watch are connected when you deploy

Good luck! 🚀
