# ✅ Apple Watch App - Deployment Checklist

## Pre-Deployment Setup

### 1. Project Generation
- [ ] XcodeGen installed (`brew install xcodegen`)
- [ ] Run `xcodegen generate` successfully
- [ ] .xcodeproj file created
- [ ] All targets visible in Xcode

### 2. Bundle Identifiers
- [ ] Updated `bundleIdPrefix` in project.yml to your domain
- [ ] iOS app: `com.yourcompany.InvisalignTracker`
- [ ] Watch app: `com.yourcompany.InvisalignTracker.watchkitapp`
- [ ] Widget: `com.yourcompany.InvisalignTracker.watchkitapp.widget`
- [ ] All bundle IDs unique and follow naming convention

### 3. Development Team
- [ ] Found your Team ID (Xcode → Preferences → Accounts)
- [ ] Updated `DEVELOPMENT_TEAM` in project.yml
- [ ] Updated `DevelopmentTeam` in attributes
- [ ] Regenerated project with `xcodegen generate`

### 4. App Groups Configuration
- [ ] Opened project in Xcode
- [ ] Selected **iOS App** target
- [ ] Added App Groups capability
- [ ] Checked `group.com.yourcompany.invisaligntracker`
- [ ] Selected **Watch App** target
- [ ] Added App Groups capability (same group)
- [ ] Selected **Watch Widget** target
- [ ] Added App Groups capability (same group)
- [ ] Group identifier matches in `WidgetDataStore.swift`

### 5. File Organization
- [ ] `WatchStatePayload.swift` in root folder
- [ ] `WatchStatePayload.swift` added to iOS target
- [ ] `WatchStatePayload.swift` added to Watch target
- [ ] `WatchStatePayload.swift` added to Widget target
- [ ] All watch files in `InvisalignTrackerWatch/` folder
- [ ] All widget files in `InvisalignTrackerWatchWidget/` folder

---

## iOS Integration

### 6. WatchConnectivity Setup
- [ ] `WatchConnectivityManager_iOS.swift` added to iOS target
- [ ] File compiles without errors
- [ ] Located `AppContext.swift` in your project
- [ ] Added `private let watchConnectivity = WatchConnectivityManager.shared`
- [ ] Called `watchConnectivity.configure(with: store)` in init
- [ ] Added initial sync in Task after store.load()

### 7. Sync Points
- [ ] Located `TrackingStore.swift`
- [ ] Added `WatchConnectivityManager.shared.syncToWatch()` in `toggleAligner()`
- [ ] Added sync in `deleteSession()` (optional but recommended)
- [ ] Added sync in `addTray()` (optional)
- [ ] Added sync in `setCurrentTray()` (optional)
- [ ] Added sync in `updateSettings()` (optional)

### 8. iOS Build
- [ ] iOS app builds successfully
- [ ] No compiler errors
- [ ] No compiler warnings
- [ ] Console shows "📱 [WatchConnectivity] iOS manager initialized"

---

## Watch App Setup

### 9. Watch Files
- [ ] All watch files present in project
- [ ] All files added to Watch App target (not iOS)
- [ ] `WatchConnectivityManager.swift` in Watch target only
- [ ] `WatchTheme.swift` in Watch target
- [ ] `WatchAppStates.swift` in Watch target (optional but recommended)
- [ ] `ContentView.swift` in Watch target
- [ ] `InvisalignTrackerWatchApp.swift` in Watch target

### 10. Widget Files
- [ ] `AlignerWidget.swift` in Widget target
- [ ] `WidgetDataStore.swift` accessible by Widget
- [ ] `WatchStatePayload.swift` accessible by Widget
- [ ] Widget Info.plist configured

### 11. Assets (Optional)
- [ ] App icon for watch (or using placeholder)
- [ ] Colors added to Assets catalog (optional)
- [ ] SF Symbols work as fallback

---

## Build & Deploy

### 12. Hardware Setup
- [ ] iPhone physically connected to Mac
- [ ] Apple Watch paired with that iPhone
- [ ] Both devices unlocked
- [ ] Bluetooth enabled on both
- [ ] Wi-Fi enabled on both
- [ ] Devices on same Wi-Fi network (helps with deployment)

### 13. Xcode Configuration
- [ ] Selected iOS App scheme (InvisalignTracker)
- [ ] Selected your iPhone as destination (not simulator)
- [ ] Signing set to "Automatically manage signing"
- [ ] Your Apple ID added to Xcode Preferences → Accounts
- [ ] Trust established (build once if needed)

### 14. Build iOS App
- [ ] Clean build folder (⌘⇧K)
- [ ] Build iOS app (⌘B)
- [ ] Build succeeds
- [ ] No errors in Issue Navigator
- [ ] Certificate provisioning succeeded

### 15. Deploy to iPhone
- [ ] Run iOS app (⌘R)
- [ ] App launches on iPhone
- [ ] Console shows app startup logs
- [ ] No crashes on launch
- [ ] App is functional

### 16. Watch App Installation
- [ ] Wait 30-60 seconds after iOS app launches
- [ ] Watch app appears in Watch app list automatically
- [ ] Or check iPhone → Watch app → scroll to InvisalignTracker
- [ ] Toggle "Show App on Apple Watch" if present
- [ ] Watch app icon appears on Apple Watch home screen
- [ ] Can launch watch app

---

## Testing

### 17. Watch App Functionality
- [ ] Launch watch app from home screen
- [ ] App shows loading state initially
- [ ] App loads successfully (not stuck on loading)
- [ ] Activity ring displays
- [ ] Can see current wear time or timer
- [ ] Button appears ("Remove" or "Put Back In")

### 18. Timer Control
- [ ] Tap "Remove Aligners" button
- [ ] Button changes to "Put Back In"
- [ ] Timer starts counting
- [ ] Ring color changes to orange
- [ ] Haptic feedback felt
- [ ] iPhone app updates automatically

### 19. Sync to iPhone
- [ ] Open iPhone app
- [ ] Verify status matches watch
- [ ] Timer shows as active
- [ ] Session recorded
- [ ] Toggle on iPhone
- [ ] Watch updates within seconds

### 20. Sync from iPhone
- [ ] Close watch app
- [ ] Toggle aligner on iPhone
- [ ] Open watch app
- [ ] Status reflects iPhone change
- [ ] No stale data

### 21. Summary View
- [ ] Swipe up on watch (or scroll with crown)
- [ ] Summary view appears
- [ ] Shows today's stats
- [ ] Session list displays
- [ ] Numbers are accurate
- [ ] Layout looks good

---

## Complications

### 22. Add Complication to Watch Face
- [ ] Long-press current watch face
- [ ] Tap "Edit"
- [ ] Swipe to complications screen
- [ ] Tap a complication slot
- [ ] Scroll to find "Aligner Tracker"
- [ ] Select complication
- [ ] Complication appears on face

### 23. Complication Types
- [ ] Try Circular complication
- [ ] Ring shows progress
- [ ] Icon displays correctly
- [ ] Try Rectangular complication
- [ ] Status text shows
- [ ] Try Inline complication
- [ ] Text is readable

### 24. Complication Updates
- [ ] Complication shows current data
- [ ] Toggle aligner status
- [ ] Complication updates (may take 1-5 minutes)
- [ ] Tap complication
- [ ] Opens watch app

---

## Edge Cases

### 25. Offline Behavior
- [ ] Turn off iPhone
- [ ] Toggle on watch
- [ ] No crash, action queued
- [ ] Turn iPhone back on
- [ ] Command processes automatically
- [ ] Data syncs

### 26. Background Behavior
- [ ] Start session on watch
- [ ] Dismiss watch app (press crown)
- [ ] Wait 30 seconds
- [ ] Check iPhone - session active
- [ ] Stop session on iPhone
- [ ] Reopen watch app
- [ ] Status correct

### 27. Disconnected State
- [ ] Turn off Bluetooth on iPhone
- [ ] Open watch app
- [ ] Shows "Not Connected" or queues update
- [ ] Turn Bluetooth back on
- [ ] App reconnects automatically

### 28. Multiple Days
- [ ] Use app normally for a day
- [ ] Check summary shows today only
- [ ] Next day, open watch app
- [ ] Yesterday's data not shown
- [ ] New day starts fresh

---

## Performance

### 29. Battery Impact
- [ ] Use watch normally for a day
- [ ] Check battery usage (Watch app on iPhone → Battery)
- [ ] App uses <5% battery
- [ ] No overheating
- [ ] No excessive background activity

### 30. Sync Speed
- [ ] Toggle on watch
- [ ] iPhone updates within 2-3 seconds
- [ ] Toggle on iPhone
- [ ] Watch updates within 5 seconds
- [ ] Acceptable latency

### 31. Widget Performance
- [ ] Complication doesn't drain battery
- [ ] Updates regularly (every 5-10 minutes)
- [ ] No lag when viewing
- [ ] Tap response is instant

---

## Console Verification

### 32. iOS Console Logs
- [ ] See "📱 [WatchConnectivity] iOS manager initialized"
- [ ] See "📱 [WatchConnectivity] Configured with TrackingStore"
- [ ] See "📱 [WatchConnectivity] Session activated"
- [ ] See "📱 [WatchConnectivity] Sent state to watch" when syncing
- [ ] See command logs when watch sends actions

### 33. Watch Console Logs
- [ ] See "⌚️ [WatchConnectivity] Watch manager initialized"
- [ ] See "⌚️ [WatchConnectivity] Session activated"
- [ ] See "⌚️ [WatchConnectivity] State updated" when receiving
- [ ] See command logs when buttons pressed
- [ ] No error messages

---

## 7-Day Certificate

### 34. Certificate Expiration
- [ ] Calendar reminder set for 6 days from now
- [ ] Know you need to rebuild weekly
- [ ] Both iOS and Watch apps expire together
- [ ] Rebuilding iOS also rebuilds Watch

### 35. Rebuilding Process
- [ ] Connect iPhone (Watch paired)
- [ ] Open Xcode
- [ ] Select iOS app scheme
- [ ] Press ⌘R
- [ ] Wait for both to deploy
- [ ] Test both apps still work
- [ ] Another 7 days of use!

---

## Troubleshooting

### 36. If Watch App Won't Install
- [ ] Restart iPhone
- [ ] Restart Apple Watch
- [ ] Unpair and re-pair watch (last resort)
- [ ] Clean build folder in Xcode
- [ ] Delete app from iPhone, rebuild
- [ ] Check both devices on same Wi-Fi

### 37. If Sync Not Working
- [ ] Check all 3 App Group checkboxes
- [ ] Verify group name identical
- [ ] Check `WidgetDataStore.swift` group name
- [ ] Rebuild both apps
- [ ] Check console for error messages
- [ ] Verify WatchConnectivity integration

### 38. If Complications Not Showing
- [ ] Force-quit watch app
- [ ] Relaunch from home screen
- [ ] Wait 1 minute
- [ ] Try removing and re-adding complication
- [ ] Check Widget target has App Groups
- [ ] Verify `WidgetDataStore` accessible

---

## Final Verification

### 39. Full User Flow
- [ ] Start with aligners in
- [ ] Open watch app
- [ ] Remove aligners (tap button)
- [ ] Timer counts up
- [ ] Wait a few minutes
- [ ] Put back in (tap button)
- [ ] Session appears in summary
- [ ] iPhone shows same session
- [ ] Complication reflects change

### 40. Production Ready
- [ ] All features work
- [ ] No crashes
- [ ] Sync reliable
- [ ] UI looks good
- [ ] Performance acceptable
- [ ] Battery usage reasonable
- [ ] Happy with result! 🎉

---

## Optional Enhancements

### 41. Customization (If Desired)
- [ ] Changed colors to your preference
- [ ] Adjusted ring size
- [ ] Modified widget update frequency
- [ ] Added custom haptics
- [ ] Tweaked typography

### 42. Polish (If Time Permits)
- [ ] Custom app icons
- [ ] Custom complication graphics
- [ ] Additional stats in summary
- [ ] More detailed session info
- [ ] Extra watch faces tested

---

## Success Metrics

### You're Done When:
✅ Can start/stop timer from watch
✅ Data syncs between iPhone and watch
✅ Summary view shows accurate info
✅ Complications work on watch face
✅ No crashes or major bugs
✅ Acceptable performance
✅ Happy with user experience

---

## Post-Deployment

### 43. Regular Use
- [ ] Set weekly rebuild reminder
- [ ] Use app daily
- [ ] Note any issues
- [ ] Track battery impact
- [ ] Enjoy the convenience! ⌚️

### 44. Future Improvements (Ideas)
- [ ] Add more stats
- [ ] Historical trends
- [ ] Week view
- [ ] Custom notifications
- [ ] More complication styles
- [ ] Shortcuts integration

---

**Congratulations! Your Apple Watch integration is complete!** 🎉

You now have:
- ⌚️ Full watch app with timer control
- 📊 Activity rings and progress tracking
- 📋 Daily summary view
- 🎨 Watch face complications
- 🔄 Real-time synchronization
- 💎 Premium dark UI

**Estimated Time:** 15-20 minutes for basic setup
**Complexity:** Moderate (but I did the hard parts!)
**Cost:** $0 (free developer account)
**Value:** Priceless convenience 😊

Enjoy tracking your Invisalign from your wrist!
