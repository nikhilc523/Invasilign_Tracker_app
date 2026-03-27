import SwiftUI

/// Watch App Theme - Matches iOS app premium aesthetic
/// Use these colors throughout your watch app for consistency
enum WatchTheme {
    // MARK: - Background Colors
    
    /// Primary dark background - premium feel
    static let background = Color(white: 0.1)
    
    /// Card/container background - subtle elevation
    static let cardBackground = Color.white.opacity(0.08)
    
    /// Ring track background
    static let ringTrack = Color.white.opacity(0.15)
    
    // MARK: - Text Colors
    
    /// Primary text - high contrast
    static let textPrimary = Color.white
    
    /// Secondary text - medium emphasis
    static let textSecondary = Color.white.opacity(0.6)
    
    /// Tertiary text - low emphasis
    static let textTertiary = Color.white.opacity(0.5)
    
    // MARK: - Accent Colors
    
    /// Success state - aligners in, on track
    static let success = Color.green
    
    /// Warning state - aligners removed
    static let warning = Color.orange
    
    /// Info state - neutral information
    static let info = Color.blue
    
    /// Progress color for on-track progress
    static let progressGood = Color.green
    
    /// Progress color for getting close to goal
    static let progressWarning = Color.yellow
    
    // MARK: - Component Styles
    
    /// Corner radius for cards
    static let cardCornerRadius: CGFloat = 12
    
    /// Corner radius for buttons
    static let buttonCornerRadius: CGFloat = 22
    
    /// Standard button height
    static let buttonHeight: CGFloat = 44
    
    /// Activity ring line width
    static let ringLineWidth: CGFloat = 12
    
    /// Activity ring size
    static let ringSize: CGFloat = 140
    
    // MARK: - Typography
    
    /// Large display number (center of ring)
    static func displayNumber(size: CGFloat = 32) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }
    
    /// Timer display (countdown)
    static func timerDisplay(size: CGFloat = 24) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }
    
    /// Section headers
    static func sectionHeader(size: CGFloat = 18) -> Font {
        .system(size: size, weight: .bold)
    }
    
    /// Body text
    static func body(size: CGFloat = 15) -> Font {
        .system(size: size, weight: .medium)
    }
    
    /// Small labels
    static func caption(size: CGFloat = 12) -> Font {
        .system(size: size, weight: .medium)
    }
    
    /// Tiny labels
    static func footnote(size: CGFloat = 11) -> Font {
        .system(size: size, weight: .regular)
    }
}

// MARK: - Example Usage

struct WatchThemeExamples: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Background example
                VStack {
                    Text("Background Colors")
                        .font(WatchTheme.sectionHeader())
                        .foregroundStyle(WatchTheme.textPrimary)
                    
                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(WatchTheme.background)
                            .frame(width: 50, height: 50)
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(WatchTheme.cardBackground)
                            .frame(width: 50, height: 50)
                    }
                }
                
                // Text hierarchy example
                VStack(alignment: .leading, spacing: 8) {
                    Text("Text Hierarchy")
                        .font(WatchTheme.sectionHeader())
                        .foregroundStyle(WatchTheme.textPrimary)
                    
                    Text("Primary text")
                        .font(WatchTheme.body())
                        .foregroundStyle(WatchTheme.textPrimary)
                    
                    Text("Secondary text")
                        .font(WatchTheme.body())
                        .foregroundStyle(WatchTheme.textSecondary)
                    
                    Text("Tertiary text")
                        .font(WatchTheme.caption())
                        .foregroundStyle(WatchTheme.textTertiary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Accent colors example
                VStack {
                    Text("Accent Colors")
                        .font(WatchTheme.sectionHeader())
                        .foregroundStyle(WatchTheme.textPrimary)
                    
                    HStack(spacing: 12) {
                        Circle()
                            .fill(WatchTheme.success)
                            .frame(width: 40, height: 40)
                        
                        Circle()
                            .fill(WatchTheme.warning)
                            .frame(width: 40, height: 40)
                        
                        Circle()
                            .fill(WatchTheme.info)
                            .frame(width: 40, height: 40)
                    }
                }
                
                // Button example
                VStack {
                    Text("Buttons")
                        .font(WatchTheme.sectionHeader())
                        .foregroundStyle(WatchTheme.textPrimary)
                    
                    Button("Success Button") {}
                        .font(WatchTheme.body())
                        .frame(maxWidth: .infinity)
                        .frame(height: WatchTheme.buttonHeight)
                        .background(
                            Capsule()
                                .fill(WatchTheme.success)
                        )
                        .foregroundStyle(.black)
                    
                    Button("Warning Button") {}
                        .font(WatchTheme.body())
                        .frame(maxWidth: .infinity)
                        .frame(height: WatchTheme.buttonHeight)
                        .background(
                            Capsule()
                                .fill(WatchTheme.warning)
                        )
                        .foregroundStyle(.black)
                }
                
                // Card example
                VStack(alignment: .leading, spacing: 8) {
                    Text("Stats Cards")
                        .font(WatchTheme.sectionHeader())
                        .foregroundStyle(WatchTheme.textPrimary)
                    
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(WatchTheme.success)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Worn Time")
                                .font(WatchTheme.caption())
                                .foregroundStyle(WatchTheme.textSecondary)
                            
                            Text("20h 30m")
                                .font(WatchTheme.displayNumber(size: 18))
                                .foregroundStyle(WatchTheme.textPrimary)
                            
                            Text("of 22h goal")
                                .font(WatchTheme.footnote())
                                .foregroundStyle(WatchTheme.textTertiary)
                        }
                        
                        Spacer()
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: WatchTheme.cardCornerRadius)
                            .fill(WatchTheme.cardBackground)
                    )
                }
            }
            .padding()
        }
        .background(WatchTheme.background)
    }
}

// MARK: - Design Guidelines

/*
 WATCH APP DESIGN GUIDELINES
 ===========================
 
 1. READABILITY FIRST
    - Use large, bold numbers for key metrics
    - High contrast (white on dark)
    - Rounded fonts for modern feel
    - MonospacedDigit() for numbers that update
 
 2. TAP TARGETS
    - Minimum 44pt height for buttons
    - Full-width buttons when possible
    - Proper spacing between interactive elements
 
 3. GLANCEABILITY
    - Most important info at top
    - Use icons to reduce text
    - Color-code different states
    - Show progress visually (rings, bars)
 
 4. HIERARCHY
    - Primary: Large, bold, white
    - Secondary: Medium, 60% opacity
    - Tertiary: Small, 50% opacity
 
 5. PERFORMANCE
    - Minimize animations
    - Use simple shapes
    - Avoid complex gradients
    - Optimize for battery
 
 6. ACCESSIBILITY
    - Support Dynamic Type where possible
    - Use SF Symbols (they scale)
    - Maintain contrast ratios
    - Test on small watch sizes (38mm/40mm)
 
 7. CONSISTENCY WITH iOS
    - Use same color palette
    - Match interaction patterns
    - Align terminology
    - Keep visual language similar
 
 8. WATCH-SPECIFIC
    - Optimize for quick glances (5 seconds)
    - Design for single-hand use
    - Account for crown scrolling
    - Support Digital Crown zoom where relevant
 
 COMPLICATION GUIDELINES
 =======================
 
 1. CIRCULAR
    - Use progress ring around edge
    - Icon + number in center
    - 2-3 elements max
 
 2. RECTANGULAR
    - Left-to-right layout
    - Icon on left
    - Text/progress on right
    - 2 lines of text max
 
 3. INLINE
    - Single line only
    - Icon + text combo
    - Use • separator for multiple info
    - Keep under 20 characters
 
 COLOR MEANINGS
 ==============
 
 GREEN (Success)
 - Aligners are in
 - Daily goal met
 - Progress on track
 
 ORANGE (Warning)
 - Aligners are out
 - Active removal session
 - Need to put back soon
 
 YELLOW (Caution)
 - Getting close to goal
 - 80%+ progress
 - Almost there
 
 BLUE (Info)
 - Neutral information
 - Remaining time
 - General stats
 
 WHITE (Primary)
 - All primary text
 - Numbers and values
 - Main content
 
 WHITE 60% (Secondary)
 - Labels and descriptions
 - Supporting information
 - Subtitles
 
 WHITE 50% (Tertiary)
 - Timestamps
 - Metadata
 - Less important info
 */
