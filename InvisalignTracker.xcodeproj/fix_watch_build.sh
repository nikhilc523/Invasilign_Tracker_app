#!/bin/bash

# 🔧 Watch App Build Error - Automated Fix Script
# This script helps diagnose and provides instructions to fix the build error

set -e

echo "🔍 Diagnosing Watch App Build Configuration..."
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Find the Xcode project
PROJECT_FILE=$(find . -maxdepth 2 -name "*.xcodeproj" | head -1)

if [ -z "$PROJECT_FILE" ]; then
    echo "${RED}❌ No Xcode project found!${NC}"
    exit 1
fi

echo "${GREEN}✅ Found project: $PROJECT_FILE${NC}"
echo ""

# Clean DerivedData
echo "🧹 Cleaning DerivedData..."
rm -rf ~/Library/Developer/Xcode/DerivedData/InvisalignTracker-*
echo "${GREEN}✅ DerivedData cleaned${NC}"
echo ""

# Check if files exist
echo "📋 Checking Watch App files..."
echo ""

WATCH_FILES=(
    "InvisalignTrackerWatchApp.swift"
    "WatchConnectivityManager.swift"
    "WatchTheme.swift"
    "WatchAppStates.swift"
    "WatchStatePayload.swift"
)

WIDGET_FILES=(
    "AlignerWidget.swift"
    "WidgetDataStore.swift"
)

echo "${BLUE}Watch App Files (should be in InvisalignTrackerWatch target):${NC}"
for file in "${WATCH_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "  ${GREEN}✅ $file${NC}"
    else
        FOUND=$(find . -name "$file" | head -1)
        if [ -n "$FOUND" ]; then
            echo "  ${YELLOW}⚠️  $file found at: $FOUND${NC}"
        else
            echo "  ${RED}❌ $file NOT FOUND${NC}"
        fi
    fi
done

echo ""
echo "${BLUE}Widget Files (should be in InvisalignTrackerWatchWidget target):${NC}"
for file in "${WIDGET_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "  ${GREEN}✅ $file${NC}"
    else
        FOUND=$(find . -name "$file" | head -1)
        if [ -n "$FOUND" ]; then
            echo "  ${YELLOW}⚠️  $file found at: $FOUND${NC}"
        else
            echo "  ${RED}❌ $file NOT FOUND${NC}"
        fi
    fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "${YELLOW}⚠️  MANUAL FIX REQUIRED${NC}"
echo ""
echo "The build error occurs because files are in the wrong target."
echo "Unfortunately, Xcode project files must be edited in Xcode."
echo ""
echo "${BLUE}📋 Follow these steps in Xcode:${NC}"
echo ""
echo "1. Open: $PROJECT_FILE"
echo ""
echo "2. Select ${YELLOW}InvisalignTrackerWatch${NC} target"
echo "   → Build Phases → Compile Sources"
echo "   → ${RED}REMOVE${NC}: AlignerWidget.swift, WidgetDataStore.swift"
echo "   → ${GREEN}ADD${NC}: InvisalignTrackerWatchApp.swift and other Watch files"
echo ""
echo "3. Select ${YELLOW}InvisalignTrackerWatchWidget${NC} target"
echo "   → Build Phases → Compile Sources"
echo "   → Should ${GREEN}ONLY${NC} have: AlignerWidget.swift, WidgetDataStore.swift"
echo ""
echo "4. Clean Build Folder: ${BLUE}⌘+Shift+K${NC}"
echo "5. Build: ${BLUE}⌘+B${NC}"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "${GREEN}📄 See FIX_WATCH_BUILD_ERROR.md for detailed instructions${NC}"
echo ""
