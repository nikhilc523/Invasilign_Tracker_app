# Invisalign Tracker

A native iOS app for tracking Invisalign aligner wear time with precision timing, live activities, and an Apple Watch companion app.

Built entirely in **SwiftUI** with **SwiftData** persistence and **MVVM** architecture.

![Swift](https://img.shields.io/badge/Swift-5.10-F05138?logo=swift&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-17.0+-000000?logo=apple&logoColor=white)
![watchOS](https://img.shields.io/badge/watchOS-10.0+-000000?logo=apple&logoColor=white)
![SwiftUI](https://img.shields.io/badge/SwiftUI-blue?logo=swift&logoColor=white)
![SwiftData](https://img.shields.io/badge/SwiftData-FF2D55)
![Architecture](https://img.shields.io/badge/MVVM-Clean_Architecture-purple)

---

## Screenshots

### iPhone

<p>
  <img src="ios_screenshots/iphone/iphone_1.png" width="180" alt="Today - Aligners Out">
  <img src="ios_screenshots/iphone/iphone_2.png" width="180" alt="Today - Aligners In">
  <img src="ios_screenshots/iphone/iphone_3.png" width="180" alt="Timer View">
  <img src="ios_screenshots/iphone/iphone_4.png" width="180" alt="Calendar View">
</p>
<p>
  <img src="ios_screenshots/iphone/iphone_5.png" width="180" alt="Trays View">
  <img src="ios_screenshots/iphone/iphone_6.png" width="180" alt="Settings">
</p>

### Apple Watch

<p>
  <img src="ios_screenshots/watch/watch_1.png" width="150" alt="Watch - Tracking">
  <img src="ios_screenshots/watch/watch_2.png" width="150" alt="Watch - Summary">
  <img src="ios_screenshots/watch/watch_3.png" width="150" alt="Watch - Timer">
  <img src="ios_screenshots/watch/watch_4.png" width="150" alt="Watch - Tray Deficit">
</p>

---

## Features

- **Wear Tracking** -- Toggle aligner state (In/Out) with millisecond-accurate timestamps and a live UI timer
- **Dynamic Island & Live Activities** -- Monitor active removal sessions from the Lock Screen and Dynamic Island without opening the app
- **Apple Watch Companion** -- Full watchOS app with bidirectional sync via WatchConnectivity, progress rings, and haptic feedback
- **Calendar & History** -- Monthly calendar with color-coded compliance markers (pass/warn/fail) and detailed daily logs
- **Tray Management** -- Track multiple trays, monitor progress per tray, and get smart prompts to extend when wear time remains
- **Metrics Dashboard** -- Daily wear %, streak count, life debt, tray progress, and compliance stats displayed in animated progress rings
- **Smart Notifications** -- Scheduled reminders when aligners are removed, with configurable follow-up intervals
- **Configurable Settings** -- Daily target hours, grace minutes, default tray duration, and compliance mode (Daily Pass/Fail or Total Hours carry-forward)

---

## Architecture

The project follows **MVVM with Clean Architecture** principles, separating concerns across distinct layers:

```
App/                            # Entry point, root navigation, dependency wiring
Domain/                         # Pure Swift models, services, repository protocols
  Models/                       #   Tray, RemovalSession, TrackerSettings, DayStatus
  Services/                     #   TrackerCalculator, DateService, Formatters
  Repositories/                 #   TrackingRepository protocol
Data/                           # SwiftData persistence layer
  Models/                       #   TrayRecord, RemovalSessionRecord, SettingsRecord
  Repositories/                 #   SwiftDataTrackingRepository, TrackingStore
Features/                       # Feature modules (each with View + ViewModel)
  Today/                        #   Dashboard with progress rings & live activities
  Timer/                        #   Active session tracking
  Calendar/                     #   Monthly compliance calendar & notifications
  Trays/                        #   Tray lifecycle management
  Settings/                     #   User preferences & cloud sync
Shared/                         # Reusable components, theme, glassmorphic UI
InvisalignTrackerWatch/         # watchOS companion app
InvisalignTrackerWatchWidget/   # watchOS widgets (ring gauge, stats)
LiveActivitiesExtension/        # Dynamic Island & Lock Screen widget
Tests/                          # Unit tests for domain logic
```

---

## Tech Stack

| Category | Technology |
|---|---|
| **UI** | SwiftUI |
| **Persistence** | SwiftData |
| **Concurrency** | Swift async/await |
| **State Management** | Combine, @Observable |
| **Live Activities** | ActivityKit, WidgetKit |
| **Watch Integration** | WatchConnectivity (bidirectional sync) |
| **Notifications** | UserNotifications |
| **Shared Data** | App Groups |
| **Architecture** | MVVM + Repository Pattern |
| **Testing** | XCTest |

---

## Technical Highlights

**Wear Calculation Engine** -- `TrackerCalculator` handles all compliance math: overlaying removal sessions across calendar day boundaries, computing streaks by scanning backward from today, calculating life debt across trays, and supporting two compliance modes.

**Bidirectional Watch Sync** -- iPhone and Watch communicate via `WatchConnectivity` using interactive messages when reachable and application context transfers when offline, keeping state consistent across both devices.

**Live Activity Lifecycle** -- `AlignerLiveActivityManager` starts a Live Activity when aligners are removed and ends it when put back in, showing an elapsed timer on the Dynamic Island and Lock Screen with deep link support.

**Repository Pattern** -- `TrackingRepository` protocol in the Domain layer is implemented by `SwiftDataTrackingRepository` in the Data layer, keeping persistence details out of business logic and enabling testability.

---

## Getting Started

**Prerequisites:** Xcode 15+, [XcodeGen](https://github.com/yonaskolb/XcodeGen)

```bash
# Install XcodeGen
brew install xcodegen

# Generate the Xcode project
xcodegen generate

# Open in Xcode
open InvisalignTracker.xcodeproj
```

Build and run on a simulator or device with `Cmd + R`.

> An Apple Developer account is required for testing Live Activities and the Watch app on a physical device.

---

## License

MIT
