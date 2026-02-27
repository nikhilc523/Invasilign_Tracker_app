<div align="center">
  <h1>🦷 InvisalignTracker iOS</h1>
  <p><strong>A high-compliance, metric-driven aligner tracking ecosystem built natively for iOS.</strong></p>

  <p>
    <img src="https://img.shields.io/badge/Swift-5.10-F05138.svg?style=flat-square&logo=swift" alt="Swift 5.10">
    <img src="https://img.shields.io/badge/iOS-17.0+-000000.svg?style=flat-square&logo=apple" alt="iOS 17.0+">
    <img src="https://img.shields.io/badge/Architecture-MVVM-blue.svg?style=flat-square" alt="Architecture MVVM">
    <img src="https://img.shields.io/badge/Storage-SwiftData-FF2D55.svg?style=flat-square" alt="SwiftData">
    <img src="https://img.shields.io/badge/UI-SwiftUI-3478f6.svg?style=flat-square" alt="SwiftUI">
    <img src="https://img.shields.io/badge/License-MIT-green.svg?style=flat-square" alt="License">
    <img src="https://img.shields.io/badge/Build-Passing-brightgreen.svg?style=flat-square" alt="Build Status">
  </p>
</div>

---

## 🎯 Who is this for?

**InvisalignTracker** is designed for **high-tech professionals, engineers, and data-driven individuals** who treat their aligner compliance with the same rigor they apply to their daily workflows. 

If you love configuring metrics, obsess over your daily 'wear time deficit', and prefer a beautiful, native iOS experience over generic cross-platform apps, this tracker is built exclusively for you. 

Watch your compliance through granular data points, live Dynamic Island activities, and Apple Watch integrations—all crafted with a premium, glassmorphic aesthetic.

## ✨ Key Features

- **Precision Tracking:** Toggle aligner state (IN/OUT) with millisecond-accurate timestamps and live UI timers.
- **Dynamic Island & Live Activities:** Monitor active removal sessions instantly without opening the app.
- **Apple Watch Companion App:** Check and update your status directly from your wrist with rich complications and progress rings.
- **Deep Metrics & Analytics:** Track Daily Wear vs. Removal calculation, Life Debt, Streak, Tray Progress, and Compliance Stats.
- **Granular Configurations:** Set daily targets, grace minutes, default tray durations, and rigorous compliance modes.
- **Calendar & History:** A comprehensive monthly calendar with pass/warn/fail day markers and detailed daily logs.
- **Native Performance:** Fully built in SwiftUI and powered by SwiftData for ultra-fast, local-first persistence.

## 🛠 Tech Stack & Architecture

Engineered with modern Apple technologies and clean architecture principles.

### Core Stack
- **Language:** Swift 5.10+
- **Framework:** SwiftUI
- **Persistence:** SwiftData (Sessions, Trays, Settings)
- **Concurrency:** Modern `async`/`await` for repository and store operations
- **Target OS:** iOS 17.0+ & watchOS 10.0+

### Project Structure (MVVM)
- 📁 **`App/`** — App entry, root tabs, and dependency wiring.
- 📁 **`Features/`** — Modularized views and ViewModels (Today, Timer, Calendar, Trays, Settings).
- 📁 **`Domain/`** — Pure models, robust services, and business rules isolated from UI.
- 📁 **`Data/`** — SwiftData entities, repository implementations, and state store.
- 📁 **`Shared/`** — Reusable UI components, typography, glassmorphism logic, and app themes.
- 📁 **`LiveActivitiesExtension/`** — WidgetExtension for Dynamic Island interactions.
- 📁 **`Tests/`** — Comprehensive domain-level testing suites.

## 🚀 Getting Started

To run the project locally on your machine, follow these steps:

1. **Prerequisite:** Install [XcodeGen](https://github.com/yonaskolb/XcodeGen) if you don't have it installed.
   ```bash
   brew install xcodegen
   ```
2. **Generate the Xcode Project:**
   ```bash
   cd ios-native/InvisalignTracker && xcodegen generate
   ```
3. **Open Xcode:**
   Open `InvisalignTracker.xcodeproj` in Xcode 15 or later.
4. **Run:** Select your preferred simulator or physical device and hit `Cmd + R` to build and run.

*(Note: Ensure you have an active Apple Developer account configured if testing the Apple Watch companion app or Live Activities on a physical device).*

## 📌 iOS 16 Fallback
The current infrastructure leverages **iOS 17's native SwiftData**. For iOS 16 support, you can easily swap the SwiftData models and repository layer with Core Data (implementing the exact same generic repository protocols) while keeping the `Domain` and `Features` layers entirely untouched.

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
