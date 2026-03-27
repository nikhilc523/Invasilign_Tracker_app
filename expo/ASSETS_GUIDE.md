# 🎨 Assets & App Icons Guide

## Watch App Icon Requirements

### Sizes Needed for watchOS App Icon

The watch app needs specific icon sizes. Create a circular icon (the system will mask it).

**Required Sizes:**
- 48x48 @2x (96x96 pixels) - Notification Center
- 55x55 @2x (110x110 pixels) - Notification Center
- 58x58 @2x (116x116 pixels) - Settings
- 87x87 @2x (174x174 pixels) - Settings
- 80x80 @2x (160x160 pixels) - Home Screen (38mm)
- 88x88 @2x (176x176 pixels) - Home Screen (40mm)
- 92x92 @2x (184x184 pixels) - Home Screen (41mm)
- 100x100 @2x (200x200 pixels) - Home Screen (44mm)
- 102x102 @2x (204x204 pixels) - Home Screen (45mm)
- 108x108 @2x (216x216 pixels) - Home Screen (49mm)
- 1024x1024 @1x - App Store

### Icon Design Recommendations

**Colors:**
- Background: Gradient from #1FD173 (green) to #D98F3A (orange)
- Or solid: #1FD173 (your success green)
- White icon/glyph on top

**Symbol Options:**
- Tooth icon
- Aligner tray outline
- Timer/clock symbol
- Circular progress ring
- Combination of above

**Style:**
- Simple, bold shapes
- High contrast
- Recognizable at small sizes
- Consistent with iOS app icon

### Creating Icons

**Option 1: Use SF Symbols**
```swift
// In code, you can use SF Symbols for prototype:
Image(systemName: "timer")
    .font(.system(size: 60, weight: .semibold))
    .foregroundStyle(.white)
```

**Option 2: Design Tools**
- Figma (free)
- Sketch
- Adobe Illustrator
- Canva (simple option)

**Quick Template:**
1. Create 1024x1024 artboard
2. Add circular background with your brand color
3. Center a white icon/symbol
4. Export at various sizes using asset generator

### Asset Catalog Structure

```
Assets.xcassets/
├── AppIcon.appiconset/          # iOS app icons
│   └── Contents.json
│
└── WatchAssets.xcassets/        # Watch app icons
    ├── AppIcon.appiconset/
    │   ├── Icon-48@2x.png
    │   ├── Icon-55@2x.png
    │   ├── Icon-58@2x.png
    │   ├── Icon-87@2x.png
    │   ├── Icon-80@2x.png
    │   ├── Icon-88@2x.png
    │   ├── Icon-92@2x.png
    │   ├── Icon-100@2x.png
    │   ├── Icon-102@2x.png
    │   ├── Icon-108@2x.png
    │   ├── Icon-1024.png
    │   └── Contents.json
    │
    └── Complication.imageset/      # Optional complication assets
        ├── complication@2x.png
        ├── complication@3x.png
        └── Contents.json
```

---

## Complication Graphics (Optional)

If you want custom graphics in complications instead of SF Symbols:

### Circular Complication
- Size: 84x84 @2x (168x168 pixels)
- Template image (single color with transparency)
- Will be tinted by system

### Graphic Complication
- Full color version
- Size: 84x84 @2x (168x168 pixels)
- Can include your brand colors

### Example Assets

**Ring Progress Icon:**
```
- Circular outline
- Partially filled (suggests progress)
- 2pt stroke weight
- Transparent background
```

**Tooth Icon:**
```
- Simple tooth shape
- Bold outline
- Centered
- Works at 16x16 pixels
```

---

## Quick Icon Generation Script

If you have ImageMagick installed:

```bash
#!/bin/bash
# Resize master icon to all watch sizes

MASTER="icon-master-1024.png"

# Watch sizes
convert $MASTER -resize 96x96 icon-48@2x.png
convert $MASTER -resize 110x110 icon-55@2x.png
convert $MASTER -resize 116x116 icon-58@2x.png
convert $MASTER -resize 174x174 icon-87@2x.png
convert $MASTER -resize 160x160 icon-80@2x.png
convert $MASTER -resize 176x176 icon-88@2x.png
convert $MASTER -resize 184x184 icon-92@2x.png
convert $MASTER -resize 200x200 icon-100@2x.png
convert $MASTER -resize 204x204 icon-102@2x.png
convert $MASTER -resize 216x216 icon-108@2x.png
```

---

## Color Assets

Add these to your Assets catalog for consistent colors:

### InvisalignTrackerWatch/Assets.xcassets/Colors/

**SuccessGreen.colorset/Contents.json:**
```json
{
  "colors" : [
    {
      "color" : {
        "color-space" : "srgb",
        "components" : {
          "red" : "0.122",
          "green" : "0.820",
          "blue" : "0.451",
          "alpha" : "1.000"
        }
      },
      "idiom" : "universal"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
```

**WarningOrange.colorset/Contents.json:**
```json
{
  "colors" : [
    {
      "color" : {
        "color-space" : "srgb",
        "components" : {
          "red" : "0.949",
          "green" : "0.561",
          "blue" : "0.129",
          "alpha" : "1.000"
        }
      },
      "idiom" : "universal"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
```

---

## Using Assets in Code

### Colors from Asset Catalog:
```swift
// Define in WatchTheme.swift
static let success = Color("SuccessGreen")
static let warning = Color("WarningOrange")
```

### Images from Asset Catalog:
```swift
Image("ComplicationIcon")
    .resizable()
    .frame(width: 20, height: 20)
```

---

## Testing Your Icons

### In Xcode:
1. Build and run watch app
2. Check Home Screen (watch app grid)
3. Add complication to watch face
4. View in different lighting conditions

### Checklist:
- [ ] Visible at small sizes (16x16)
- [ ] Recognizable in monochrome
- [ ] High contrast
- [ ] Matches brand
- [ ] Works on different watch faces
- [ ] No jagged edges

---

## Placeholder Icons

For quick testing, you can use SF Symbols as placeholders:

**In Assets catalog, add a symbol:**
1. Right-click Assets.xcassets
2. New Symbol Set
3. Name: "AppSymbol"
4. Use SF Symbol: "timer"

Then in code:
```swift
Image(systemName: "timer")
    .symbolRenderingMode(.hierarchical)
```

---

## App Store Assets (If Publishing Later)

If you decide to publish (after paying $99/year):

**Watch App Screenshots:**
- 396x484 (40mm)
- 448x552 (44mm)
- Multiple screenshots showing:
  - Main timer view
  - Summary view
  - Complications on watch face

**App Preview Video (Optional):**
- 30 seconds max
- Show key features
- Record from watch simulator

---

## Resources

**Free Icon Tools:**
- SF Symbols app (built into macOS)
- Figma (figma.com)
- Canva (canva.com)

**Paid Icon Tools:**
- Icon Slate ($19)
- Asset Catalog Creator ($4.99)

**Icon Design Services:**
- Fiverr (from $5)
- 99designs (from $99)

**Apple Guidelines:**
- Human Interface Guidelines - watchOS
- App Icon Design Guide

---

## Quick Start Without Custom Icons

If you want to launch **immediately** without custom icons:

1. **Use iOS app icon** as placeholder
   - Xcode will auto-generate watch sizes
   - Not ideal but works for personal use

2. **Use SF Symbols** everywhere
   - timer, checkmark.circle.fill, etc.
   - Built-in, no assets needed
   - Professional looking

3. **Add custom icons later**
   - App works fine without them
   - Can update anytime
   - Not critical for personal use

---

**Bottom Line:**

For personal use (free account), you can:
- Use placeholder icons
- Use SF Symbols everywhere
- Skip custom graphics
- Add them later if you want

For App Store release, you'll need:
- All required icon sizes
- Professional design
- Screenshots
- Proper branding

Start simple, improve later! 🎨
