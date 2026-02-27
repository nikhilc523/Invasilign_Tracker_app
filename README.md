# InvisalignTracker (Native iOS Rewrite)

Native SwiftUI + SwiftData rewrite of the Expo app with feature parity.

## Stack
- Swift 5.10+
- SwiftUI
- SwiftData (sessions, trays, settings)
- async/await in repository/store operations
- iOS 17.0+

## Architecture
- `App/`: app entry, root tabs, dependency wiring
- `Features/`: Today, Timer, Calendar, Trays, Settings (each with `View` + `ViewModel`)
- `Domain/`: pure models/services/business rules
- `Data/`: SwiftData models + repository + state store
- `Shared/`: UI components + theme
- `Tests/`: domain-level tests

## Build
1. Install XcodeGen (if needed): `brew install xcodegen`
2. Generate project: `cd ios-native/InvisalignTracker && xcodegen generate`
3. Open `InvisalignTracker.xcodeproj` in Xcode 15+
4. Run on iOS simulator/device

## Feature Parity Implemented
- Aligner out/in toggle with start/end timestamps
- Live timer for active removal session
- Daily wear/removal calculation
- Daily target/grace progress and on-track state
- Tray management (add/delete/set current)
- Tray progress/compliance stats
- Monthly calendar with pass/warn/fail/day markers
- Settings for target/grace/default tray days/compliance mode
- Full local persistence using SwiftData
- Reset all data

## iOS 16 Fallback
Current code targets iOS 17 to use SwiftData natively. For iOS 16 support, replace SwiftData models/repository with Core Data (same repository protocol), keep Domain/Features unchanged.

---

## Screenshots

### iOS App

<div style="display: flex; flex-wrap: wrap; gap: 10px;">
  <img src="ios_screenshots/iphone/iphone_1.png" width="30%" alt="Today view with aligners marked as OUT. Shows circular progress rings for Wear, Streak, and Life. Displays a prominent green 'Aligners Back In' button.">
  <img src="ios_screenshots/iphone/iphone_2.png" width="30%" alt="Today view with aligners marked as IN. Similar layout with circular progress rings and week view, but features an orange 'Remove Aligners' button.">
  <img src="ios_screenshots/iphone/iphone_3.png" width="30%" alt="Timer view indicating current removal session duration. Shows simple large typography and recent 'Today's Removals' list below an 'Aligners Back In' button.">
  <img src="ios_screenshots/iphone/iphone_4.png" width="30%" alt="Calendar view showing a month overview with color-coded dates indicating compliance (Met, Partial, Missed). Selected date displays detailed daily summary of worn time, removals, and compliance.">
  <img src="ios_screenshots/iphone/iphone_5.png" width="30%" alt="Trays view showing details for the current tray (Tray 1) including compliance percentage, days passed, life debt, and little progress circles for life debt.">
  <img src="ios_screenshots/iphone/iphone_6.png" width="30%" alt="Settings view with controls to adjust Wear Target (Target Hours / Day, Grace Minutes), Tray Settings (Default Days / Tray), and Reminder intervals.">
</div>

### Apple Watch App

<div style="display: flex; flex-wrap: wrap; gap: 10px;">
  <img src="ios_screenshots/watch/watch_1.png" width="45%" alt="Watch app tracking interface showing wear time inside a circular golden progress ring. Displays state as 'IN' with a 'Remove' button.">
  <img src="ios_screenshots/watch/watch_2.png" width="45%" alt="Watch app 'Today's Summary' listing the Worn Time and Removed Time cleanly on separate cards.">
  <img src="ios_screenshots/watch/watch_3.png" width="45%" alt="Watch view showing the timer indicating aligners are 'OUT' for a brief session, with an orange ring and 'Put Back In' button.">
  <img src="ios_screenshots/watch/watch_4.png" width="45%" alt="Watch view showing a stack or complication indicating a 'Tray 1 Deficit' with a red warning stating 'Behind by 2h 5m' and an interactive slider.">
</div>
