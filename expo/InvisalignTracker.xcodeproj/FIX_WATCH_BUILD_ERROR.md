# 🔧 Fix: Multiple Commands Produce Error

## ❌ The Problem

Your Watch app target is configured incorrectly:
- **InvisalignTrackerWatch** target has Widget files instead of Watch app files
- This causes the build system to fail because it can't find the actual Watch app entry point

## ✅ The Solution

You need to:
1. **Remove** Widget files from Watch app target
2. **Add** Watch app files to Watch app target

---

## 📋 Step-by-Step Fix (5 minutes)

### Step 1: Clean Everything First

1. **Close Xcode completely** (⌘+Q)
2. Open Terminal and run:
```bash
rm -rf ~/Library/Developer/Xcode/DerivedData/InvisalignTracker-*
```
3. Reopen Xcode

### Step 2: Fix InvisalignTrackerWatch Target

1. Select **InvisalignTrackerWatch** target (in project settings)
2. Go to **Build Phases** tab
3. Expand **Compile Sources**

4. **REMOVE these files** (select and press Delete/−):
   - ❌ `AlignerWidget.swift` (Widget only)
   - ❌ `WidgetDataStore.swift` (Widget only)

5. Click the **+** button in Compile Sources
6. **ADD these files** from the file browser:
   - ✅ `InvisalignTrackerWatchApp.swift`
   - ✅ `ContentView.swift` (Watch version)
   - ✅ `WatchConnectivityManager.swift`
   - ✅ `WatchStatePayload.swift`
   - ✅ `WatchTheme.swift`
   - ✅ `WatchAppStates.swift`

### Step 3: Verify InvisalignTrackerWatchWidget Target

1. Select **InvisalignTrackerWatchWidget** target
2. Go to **Build Phases** > **Compile Sources**
3. Should ONLY have:
   - ✅ `AlignerWidget.swift`
   - ✅ `WidgetDataStore.swift`

### Step 4: Verify iOS Target

1. Select **InvisalignTracker** (iOS) target
2. Go to **Build Phases** > **Compile Sources**
3. Should NOT have any Watch-specific files like:
   - ❌ `InvisalignTrackerWatchApp.swift`
   - ❌ Watch-specific `WatchConnectivityManager.swift`

### Step 5: Build

1. Clean Build Folder: **⌘+Shift+K**
2. Build: **⌘+B**

---

## 🎯 Alternative: Use Target Membership in File Inspector

For each file, set correct target membership:

### InvisalignTrackerWatchApp.swift
- ❌ InvisalignTracker
- ✅ InvisalignTrackerWatch
- ❌ InvisalignTrackerWatchWidget

### ContentView.swift (Watch version)
- ❌ InvisalignTracker
- ✅ InvisalignTrackerWatch
- ❌ InvisalignTrackerWatchWidget

### WatchConnectivityManager.swift
- ❌ InvisalignTracker
- ✅ InvisalignTrackerWatch
- ❌ InvisalignTrackerWatchWidget

### WatchStatePayload.swift
- ✅ InvisalignTracker (shared)
- ✅ InvisalignTrackerWatch (shared)
- ❌ InvisalignTrackerWatchWidget

### WatchTheme.swift
- ❌ InvisalignTracker
- ✅ InvisalignTrackerWatch
- ❌ InvisalignTrackerWatchWidget

### WatchAppStates.swift
- ❌ InvisalignTracker
- ✅ InvisalignTrackerWatch
- ❌ InvisalignTrackerWatchWidget

### AlignerWidget.swift
- ❌ InvisalignTracker
- ❌ InvisalignTrackerWatch
- ✅ InvisalignTrackerWatchWidget (only!)

### WidgetDataStore.swift
- ❌ InvisalignTracker
- ❌ InvisalignTrackerWatch
- ✅ InvisalignTrackerWatchWidget (only!)

---

## 🚨 Quick Method: Select Multiple Files at Once

1. In Project Navigator, **⌘+Click** to select these Watch app files:
   - `InvisalignTrackerWatchApp.swift`
   - `ContentView.swift` (Watch version)
   - `WatchConnectivityManager.swift`
   - `WatchTheme.swift`
   - `WatchAppStates.swift`

2. Open **File Inspector** (⌘+Option+1)

3. Under **Target Membership**:
   - ❌ Uncheck **InvisalignTracker**
   - ✅ Check **InvisalignTrackerWatch**
   - ❌ Uncheck **InvisalignTrackerWatchWidget**

4. Select the Widget files:
   - `AlignerWidget.swift`
   - `WidgetDataStore.swift`

5. In File Inspector:
   - ❌ Uncheck **InvisalignTracker**
   - ❌ Uncheck **InvisalignTrackerWatch**
   - ✅ Check **InvisalignTrackerWatchWidget**

6. For **WatchStatePayload.swift** only:
   - ✅ Check **InvisalignTracker**
   - ✅ Check **InvisalignTrackerWatch**
   - ❌ Uncheck **InvisalignTrackerWatchWidget**

---

## ✅ After Fixing

Your targets should look like this:

### InvisalignTracker (iOS App)
```
Compile Sources:
- InvisalignTrackerApp.swift
- TrackingStore.swift
- WatchStatePayload.swift (shared)
- WatchConnectivityManager_iOS.swift
- (all other iOS files...)
```

### InvisalignTrackerWatch (Watch App)
```
Compile Sources:
- InvisalignTrackerWatchApp.swift ← Entry point!
- ContentView.swift
- WatchConnectivityManager.swift
- WatchStatePayload.swift (shared)
- WatchTheme.swift
- WatchAppStates.swift
```

### InvisalignTrackerWatchWidget (Widget Extension)
```
Compile Sources:
- AlignerWidget.swift
- WidgetDataStore.swift
```

---

## 🎯 Build and Run

After fixing:
1. **Clean**: ⌘+Shift+K
2. **Build**: ⌘+B
3. **Run**: ⌘+R

The error should be gone! ✨

---

## 🆘 Still Having Issues?

If the error persists, check:

1. **Info.plist paths** in Build Settings
   - InvisalignTrackerWatch should point to its own Info.plist
   
2. **Watch App designation**
   - Build Settings > `WATCHOS_DEPLOYMENT_TARGET` should be set
   
3. **Product Name**
   - Build Settings > `PRODUCT_NAME` should be unique per target

4. **Nuclear option**: Delete the Watch targets and recreate them from scratch in Xcode
