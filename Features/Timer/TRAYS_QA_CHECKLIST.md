# Trays Screen Redesign - QA Checklist

## ✅ Business Logic Integrity

### Add Tray
- [ ] "+ Add" button opens sheet
- [ ] Sheet pre-fills next tray number correctly
- [ ] Sheet pre-fills planned days from settings
- [ ] Validation: tray number must be > 0
- [ ] Validation: planned days must be 1-90
- [ ] Invalid input prevents "Add" action
- [ ] Valid input creates tray with today as start date
- [ ] New tray appears in list immediately
- [ ] Sheet dismisses after successful add
- [ ] Haptic feedback fires on successful add

### Delete Tray
- [ ] "Delete" button shows confirmation dialog
- [ ] Dialog shows correct tray number
- [ ] Dialog message: "Sessions are kept" wording correct
- [ ] Cancel button dismisses without action
- [ ] Delete button removes tray from store
- [ ] Sessions remain in database after deletion
- [ ] Card animates out smoothly
- [ ] Haptic feedback fires on delete
- [ ] Can delete current tray
- [ ] Can delete completed tray
- [ ] Can delete future tray

### Set Current Tray
- [ ] "Set Current" button only appears on non-current trays
- [ ] Tapping "Set Current" updates settings.currentTrayID
- [ ] Previous current tray loses "CURRENT" badge
- [ ] New current tray gains "CURRENT" badge
- [ ] Badge updates immediately without lag
- [ ] Today screen reflects new current tray
- [ ] Timer screen reflects new current tray

### Compliance Calculations
- [ ] Compliance % matches existing formula
- [ ] Days passed counts correctly
- [ ] Days passed caps at plannedDays
- [ ] Avg wear calculates correctly
- [ ] Pass count respects grace minutes
- [ ] Progress bar fills proportionally (0.0-1.0)
- [ ] Future days not included in calculations
- [ ] Today included if not in future

### Tray Status Logic
- [ ] "CURRENT" badge shows only on settings.currentTrayID match
- [ ] "DONE" badge shows when daysRemaining == 0 and not future
- [ ] No badge shows on inactive/future trays
- [ ] Badge changes when tray switched

---

## ✅ Premium Visual Consistency

### Design Tokens Match Today/Timer
- [ ] Background gradient matches HomeVisualTokens.pageGradient
- [ ] Radial accent gradient present
- [ ] Card corner radius: 26pt (continuous)
- [ ] Card uses .regularMaterial
- [ ] Card top highlight present and subtle
- [ ] Card outer stroke warm-tinted (not milky)
- [ ] Card shadow: radius 18, y: 9
- [ ] Progress bar height: 6pt, corner radius: 3pt
- [ ] Action button corner radius: 14pt
- [ ] Add button pill: Capsule shape
- [ ] Typography hierarchy clear and consistent

### Glassmorphism Depth
- [ ] Cards have layered appearance
- [ ] Highlight blend mode: .overlay
- [ ] Shadow color matches scheme (light/dark)
- [ ] Strokes visible but not harsh
- [ ] Material blur visible through cards
- [ ] No washed-out/milky appearance in light mode
- [ ] No harsh whites in dark mode

### Colors & Contrast
- [ ] Text primary readable (AA compliant)
- [ ] Text secondary readable (AA compliant)
- [ ] "CURRENT" badge gradient: orange-to-amber
- [ ] "DONE" badge: green with subtle background
- [ ] Destructive button: red tint
- [ ] Progress fill: AppTheme.textPrimary
- [ ] Progress track: AppTheme.progressTrack
- [ ] All colors match AppTheme palette

### Spacing & Padding
- [ ] Header padding vertical: 6pt
- [ ] Page horizontal padding: 20pt
- [ ] Page top padding: 16pt
- [ ] Page bottom padding: 24pt
- [ ] Card list spacing: 14pt
- [ ] Card internal padding: horizontal 18pt, vertical 17pt
- [ ] Card internal spacing: 14pt
- [ ] Button row spacing: 10pt
- [ ] Metric row spacing: proportional with Spacer()

---

## ✅ UX Enhancements

### Header
- [ ] Title: "Trays" in .largeTitle.bold()
- [ ] Title tracking: -0.5
- [ ] Add button: pill style with icon + text
- [ ] Add button: haptic feedback on press
- [ ] Add button: scale animation on press (0.94)
- [ ] Add button: clear tap target (44x44 min)

### Tray Cards
- [ ] Cards have entrance animation (scale + opacity)
- [ ] Animation delay: 0.04s per card index
- [ ] Spring animation: response 0.45, damping 0.82
- [ ] Animation respects reduceMotion
- [ ] Tray name: .title3.weight(.bold)
- [ ] Date range: .subheadline, secondary color
- [ ] Badge positioned top-right
- [ ] Progress bar: clear track and fill distinction
- [ ] Progress label: descriptive ("Day X of Y · Zd remaining")
- [ ] Metrics: 3-column layout with labels below values
- [ ] Action buttons: full width or 50/50 split

### Empty State
- [ ] Large tray icon (size 32, weight medium)
- [ ] Icon in circular background
- [ ] Heading: "No trays yet"
- [ ] Subheading: descriptive CTA text
- [ ] Primary button: "Add First Tray" with icon
- [ ] Primary button: dark background, light text
- [ ] Primary button: haptic feedback
- [ ] Card has glass treatment matching other cards
- [ ] Transitions smoothly when first tray added

### Action Buttons
- [ ] "Set Current": icon + text, secondary style
- [ ] "Delete": icon + text, destructive style
- [ ] Buttons scale on press (0.96)
- [ ] Spring animation: response 0.25, damping 0.70
- [ ] Haptic feedback: light impact
- [ ] Current tray: only "Delete" button (full width)
- [ ] Non-current tray: "Set Current" + "Delete" (50/50)
- [ ] Destructive button: red tint with subtle background

---

## ✅ Accessibility

### VoiceOver
- [ ] Header: "Trays, Heading"
- [ ] Add button: "Add new tray, Button"
- [ ] Empty state: combines elements, "No trays yet. Add your first..., Button"
- [ ] Tray card: "Tray [number], Heading" announced first
- [ ] "CURRENT" badge: "Current tray" label
- [ ] "DONE" badge: "Completed tray" label
- [ ] Progress: "Progress: Day X of Y · Zd remaining"
- [ ] Compliance metric: "compliance: X%"
- [ ] Days passed metric: "days passed: X/Y"
- [ ] Avg wear metric: "avg wear: Xh Ym"
- [ ] "Set Current" button: clear label
- [ ] "Delete" button: clear label
- [ ] Confirmation dialog: reads correctly

### Dynamic Type
- [ ] .largeTitle scales correctly
- [ ] .title3 scales correctly
- [ ] Body text scales correctly
- [ ] Layout doesn't break at larger sizes
- [ ] Buttons remain tappable
- [ ] Cards don't overflow
- [ ] minimumScaleFactor applied where needed
- [ ] dynamicTypeSize limit set on header (...accessibility2)

### Contrast
- [ ] Text primary on card: AA compliant
- [ ] Text secondary on card: AA compliant
- [ ] Badge text on background: AA compliant
- [ ] Button text on background: AA compliant
- [ ] Progress fill vs track: clear distinction
- [ ] Strokes visible but not glaring

### Focus & Navigation
- [ ] Add button: keyboard focusable
- [ ] Action buttons: keyboard focusable
- [ ] Swipe actions work (if added)
- [ ] Focus order logical (top to bottom)

---

## ✅ Dark Mode

### Visual Consistency
- [ ] Background gradient: darker tones
- [ ] Radial accent: subtle (0.06 opacity)
- [ ] Card material: maintains depth
- [ ] Highlight: reduced opacity (0.12)
- [ ] Strokes: white 0.18 opacity
- [ ] Shadows: black 0.50 opacity
- [ ] Text primary: readable on dark
- [ ] Text secondary: readable on dark
- [ ] "CURRENT" badge: same gradient (works on dark)
- [ ] "DONE" badge: same green (readable on dark)

### Color Palette
- [ ] All colors adapt from TraysVisualTokens
- [ ] No hardcoded light-mode-only colors
- [ ] Action button backgrounds: white 0.08 opacity
- [ ] Action button strokes: white 0.16 opacity
- [ ] Destructive button: same red (readable)

---

## ✅ Edge Cases

### Empty State
- [ ] Shows when trays.isEmpty
- [ ] Transitions out when first tray added
- [ ] Scale + opacity animation

### Single Tray
- [ ] List renders correctly
- [ ] No layout issues
- [ ] Current badge shows if applicable

### Many Trays
- [ ] ScrollView scrolls smoothly
- [ ] Cards don't overlap
- [ ] Spacing consistent
- [ ] Performance acceptable (no lag)

### Future Trays
- [ ] daysPassed shows 0
- [ ] Compliance shows "—"
- [ ] Avg wear shows "—"
- [ ] Progress bar empty (0.0)
- [ ] No "remaining" text

### Completed Trays
- [ ] "DONE" badge shows
- [ ] Progress bar full (1.0)
- [ ] No "remaining" text
- [ ] "Set Current" button available
- [ ] Metrics calculated correctly for full duration

### Current Tray (Mid-Progress)
- [ ] "CURRENT" badge shows
- [ ] Progress bar partial
- [ ] "Xd remaining" text shows
- [ ] Only "Delete" button shows
- [ ] Metrics accurate for days elapsed

### Tray Number Edge Cases
- [ ] Tray number 1 works
- [ ] Tray number 999 works (layout doesn't break)
- [ ] Tray numbers sort ascending

### Planned Days Edge Cases
- [ ] 1 day tray: works correctly
- [ ] 90 day tray: works correctly
- [ ] Progress bar scales appropriately

---

## ✅ Performance

### Animations
- [ ] Card entrance: smooth (60fps)
- [ ] Button press: smooth (60fps)
- [ ] List scroll: smooth (60fps)
- [ ] No janky transitions
- [ ] reduceMotion respected

### Memory
- [ ] No memory leaks when adding/deleting trays
- [ ] Timer in ViewModel cleaned up (deinit)
- [ ] Sheet dismisses cleanly

### Responsiveness
- [ ] Add button responds immediately
- [ ] Action buttons respond immediately
- [ ] Scroll responds immediately
- [ ] No blocking operations on main thread

---

## ✅ Integration with App

### Navigation
- [ ] Tab bar shows "Trays" tab
- [ ] Tab bar icon correct
- [ ] Tapping tab scrolls to top (if already selected)

### Data Flow
- [ ] TraysViewModel observes TrackingStore
- [ ] Changes to trays reflect immediately
- [ ] Changes to sessions update metrics
- [ ] Timer updates metrics every 60s
- [ ] No stale data shown

### Cross-Tab Consistency
- [ ] Today screen uses same current tray
- [ ] Timer screen uses same current tray
- [ ] Calendar screen reflects tray periods
- [ ] Settings changes propagate correctly

---

## ✅ Final Visual QA

### Light Mode
- [ ] Screenshot: empty state
- [ ] Screenshot: single current tray
- [ ] Screenshot: multiple trays
- [ ] Screenshot: all badge types
- [ ] Screenshot: action buttons
- [ ] Compare side-by-side with Today/Timer screens
- [ ] Confirm visual consistency achieved

### Dark Mode
- [ ] Screenshot: empty state (dark)
- [ ] Screenshot: single current tray (dark)
- [ ] Screenshot: multiple trays (dark)
- [ ] Compare side-by-side with Today/Timer screens (dark)
- [ ] Confirm visual consistency achieved

---

## ✅ Regression Testing

### Existing Features (Must Not Break)
- [ ] Today screen: unchanged
- [ ] Timer screen: unchanged
- [ ] Calendar screen: unchanged
- [ ] Settings screen: unchanged
- [ ] Root tab navigation: unchanged
- [ ] Data persistence: unchanged
- [ ] Session tracking: unchanged
- [ ] Tray switching from Today: still works
- [ ] Tray switching from Settings: still works

---

## Sign-Off

- [ ] All checklist items verified
- [ ] No business logic regressions
- [ ] Premium glassmorphism style achieved
- [ ] Visual consistency with Today/Timer confirmed
- [ ] Accessibility standards met
- [ ] Dark mode fully supported
- [ ] Edge cases handled
- [ ] Performance acceptable

**Reviewer:** _________________  
**Date:** _________________  
**Status:** ☐ Approved  ☐ Needs Revision
