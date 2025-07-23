# PrayerTracker iOS 18+ Style Guide

A comprehensive technical style guide extracted from the onboarding pages and HomeView, designed to standardize all views with modern iOS 18+ design principles.

## 📐 Spacing System

### Constants (from DesignSystem.swift)
```swift
// Standard spacing constants
static let xs: CGFloat = 4      // Micro spacing
static let sm: CGFloat = 8      // Small spacing
static let md: CGFloat = 12     // Medium spacing
static let lg: CGFloat = 16     // Large spacing
static let xl: CGFloat = 20     // Extra large spacing
static let xxl: CGFloat = 24    // Double extra large
static let xxxl: CGFloat = 32   // Triple extra large

// Semantic spacing
static let contentMargin: CGFloat = 24      // Standard content padding
static let sectionSpacing: CGFloat = 24     // Between major sections
static let cardSpacing: CGFloat = 20        // Between cards
```

### Usage Patterns
- **Horizontal padding**: 24pt for main content areas
- **Section spacing**: 24pt between major UI sections
- **Card spacing**: 20pt between cards in lists
- **Internal padding**: 16-20pt inside cards and containers

## 🎨 Typography System

### Font Hierarchy
```swift
// Hero titles (Welcome screens)
.font(.system(size: 36, weight: .bold, design: .rounded))

// Large titles (Page headers)
.font(.system(size: 28, weight: .bold, design: .rounded))

// Section headers
.font(.system(size: 20, weight: .bold, design: .rounded))

// Button text
.font(.system(size: 18, weight: .semibold, design: .rounded))

// Body text
.font(.system(size: 16, weight: .medium))

// Caption text
.font(.system(size: 14, weight: .medium))
```

### Design Principles
- **Use `.rounded` design** for titles and buttons for modern appearance
- **Limit Dynamic Type** to `.xLarge` for layout stability
- **Semantic colors** for automatic dark mode support
- **Clear hierarchy** with consistent weight and size relationships

## 🎨 Color System

### Semantic Colors
```swift
// Primary colors (automatic dark mode support)
Color.primary           // Main text color
Color.secondary         // Subtitle/caption text
Color.accentColor       // Brand color for buttons and highlights

// Background colors
Color.primary.opacity(0.05)     // Card backgrounds
Color.clear                     // Transparent backgrounds
```

### Prayer Type Colors
```swift
"Fajr": .blue
"Dhuhr": .orange  
"Asr": .yellow
"Maghrib": .pink
"Isha": .purple
```

### Gradient Backgrounds
```swift
// Subtle page backgrounds
LinearGradient(
    gradient: Gradient(colors: [
        Color.accentColor.opacity(0.1),
        Color.clear,
        Color.accentColor.opacity(0.05)
    ]),
    startPoint: .topLeading,
    endPoint: .bottomTrailing
)
```

## 🎭 Animation System

### Timing Constants
```swift
// Content animations
duration: 0.6           // Main content fade-in
delay: 0.4              // Initial content delay

// Button animations  
duration: 0.6           // Button appearance
delay: 1.0              // Button delay after content

// Staggered animations
delay: 0.1 * index      // Sequential element delays
```

### Animation Patterns
```swift
// Fade-in with slide up
.opacity(showContent ? 1.0 : 0.0)
.offset(y: showContent ? 0 : 20)
.animation(.easeOut(duration: 0.6).delay(0.4), value: showContent)

// Button press feedback
.scaleEffect(isPressed ? 0.95 : 1.0)
.animation(.easeInOut(duration: 0.1), value: isPressed)

// Spring animations for interactive elements
.animation(.spring(), value: someState)
```

## 📱 Layout Patterns

### Standard Page Structure
```swift
GeometryReader { geometry in
    ScrollView {
        VStack(spacing: 0) {
            // Header Section (25% of screen height)
            headerSection
                .frame(minHeight: geometry.size.height * 0.25)
            
            // Content Section
            contentSection
            
            // Bottom spacing
            Spacer(minLength: DesignSystem.Spacing.xl)
        }
    }
    .scrollIndicators(.hidden)
}
```

### Card Components
```swift
// Standard card styling
.padding(DesignSystem.Spacing.contentMargin)
.background(
    RoundedRectangle(cornerRadius: 16, style: .continuous)
        .fill(Color.primary.opacity(0.05))
)
.shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
```

## 🔘 Button Styles

### Primary Button (CTA)
```swift
Button(action: action) {
    HStack(spacing: DesignSystem.Spacing.md) {
        if let icon = icon {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
        }
        Text(title)
            .font(.system(size: 18, weight: .semibold, design: .rounded))
    }
    .foregroundColor(.white)
    .frame(maxWidth: .infinity)
    .frame(height: 56)
    .background(
        LinearGradient(
            gradient: Gradient(colors: [Color.accentColor, Color.accentColor.opacity(0.8)]),
            startPoint: .leading,
            endPoint: .trailing
        ),
        in: RoundedRectangle(cornerRadius: 28, style: .continuous)
    )
    .shadow(color: Color.accentColor.opacity(0.3), radius: 8, x: 0, y: 4)
}
```

### Secondary Button
```swift
Button(action: action) {
    Text(title)
        .font(.system(size: 18, weight: .semibold, design: .rounded))
        .foregroundColor(.accentColor)
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.accentColor, lineWidth: 2)
        )
}
```

## 🌟 iOS 18+ Features

### Continuous Corner Style
```swift
// Use .continuous for all rounded rectangles
RoundedRectangle(cornerRadius: 16, style: .continuous)
```

### Material Backgrounds
```swift
// For overlays and cards (when available)
.background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))

// Fallback for compatibility
.background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 16))
```

### Enhanced Shadows
```swift
// Modern shadow system
.shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)

// Colored shadows for accent elements
.shadow(color: Color.accentColor.opacity(0.3), radius: 8, x: 0, y: 4)
```

## 🔄 State Management Patterns

### Loading States
```swift
@State private var showContent = false

// Trigger animations on appear
.onAppear {
    withAnimation(.easeOut(duration: 0.5).delay(0.1)) {
        showContent = true
    }
}
```

### Error States
```swift
// Consistent error presentation
VStack(spacing: DesignSystem.Spacing.lg) {
    Image(systemName: "exclamationmark.triangle")
        .font(.system(size: 40, weight: .medium))
        .foregroundColor(.orange)
    
    Text("Error Title")
        .font(.system(size: 20, weight: .bold, design: .rounded))
    
    Text("Error description")
        .font(.system(size: 16, weight: .medium))
        .foregroundColor(.secondary)
}
```

## 📐 Responsive Design

### Adaptive Padding
```swift
// Use existing design system extensions
.adaptiveHorizontalPadding()  // Responsive horizontal padding
.adaptivePadding()           // All-around adaptive padding
```

### Safe Area Handling
```swift
// For full-screen backgrounds
.ignoresSafeArea(.all, edges: .all)

// For content that should respect safe areas
Spacer(minLength: max(20, geometry.safeAreaInsets.top + 10))
```

## 🎯 Implementation Checklist

### For Each New View:
- [ ] Use GeometryReader for responsive layout
- [ ] Implement header section (25% screen height)
- [ ] Add gradient background with edge-to-edge display
- [ ] Use consistent spacing constants from DesignSystem
- [ ] Apply rounded typography for titles and buttons
- [ ] Implement staggered fade-in animations
- [ ] Use continuous corner radius for all rounded elements
- [ ] Add proper shadow system
- [ ] Include loading, error, and empty states
- [ ] Test on multiple device sizes
- [ ] Verify dark mode compatibility

### Navigation:
- [ ] Use `.navigationBarTitleDisplayMode(.inline)`
- [ ] Style toolbar buttons with accent color
- [ ] Implement proper back navigation
- [ ] Add refresh capability where appropriate

## 🔧 Reusable Components

### Standard Card
```swift
struct StandardCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(DesignSystem.Spacing.contentMargin)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.primary.opacity(0.05))
            )
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
}
```

### Section Header
```swift
struct SectionHeader: View {
    let title: String
    let icon: String?
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.accentColor)
            }
            
            Text(title)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
        }
    }
}
```

## 📚 Usage Examples

### Modernizing an Existing View
1. **Replace layout structure** with GeometryReader + ScrollView pattern
2. **Add gradient background** with proper safe area handling
3. **Update typography** to use rounded design and consistent sizing
4. **Implement card-based layout** with standard spacing and shadows
5. **Add staggered animations** for smooth content appearance
6. **Include proper state management** for loading/error/empty states

### Example Implementation
See `ModernStatsView.swift` for a complete example of applying this style guide to modernize an existing view with:
- Responsive layout with header/content sections
- Card-based information display
- Consistent typography and spacing
- Smooth animations and state transitions
- Modern iOS 18+ design patterns

## 🎨 Design Philosophy

This style guide emphasizes:
- **Consistency**: Unified spacing, typography, and color usage
- **Accessibility**: Semantic colors and proper contrast ratios
- **Performance**: Efficient animations and responsive layouts
- **Modularity**: Reusable components and patterns
- **Modern iOS**: Latest design trends and platform conventions

By following these guidelines, all views in PrayerTracker will maintain a cohesive, professional, and modern user experience that aligns with iOS 18+ design principles.
