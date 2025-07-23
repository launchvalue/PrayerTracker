# PrayerTracker iOS 18+ Style Guide

## Overview
This style guide extracts design patterns from the successfully implemented onboarding pages and HomeView to standardize all remaining views with modern iOS 18+ design principles.

## 🎨 Design System Analysis

### Extracted from WelcomeView, HomeView, and Onboarding Views

## 1. Typography System

### Primary Hierarchy
```swift
// Hero titles (Welcome screens)
.font(.system(size: 36, weight: .bold, design: .rounded))

// Large titles (Page headers)
.font(.system(size: 28, weight: .bold, design: .rounded))

// Section titles
.font(.system(size: 22, weight: .bold, design: .rounded))

// Card titles
.font(.system(size: 18, weight: .bold, design: .rounded))

// Button text
.font(.system(size: 18, weight: .semibold, design: .rounded))

// Body text
.font(.system(size: 16, weight: .medium))

// Caption/secondary text
.font(.system(size: 14, weight: .medium))
```

### Key Typography Principles
- **Use `.rounded` design for titles and buttons** (modern iOS feel)
- **Limit Dynamic Type to `.xLarge`** for layout stability
- **Semantic font weights**: `.bold`, `.semibold`, `.medium`
- **Consistent hierarchy**: 36pt → 28pt → 22pt → 18pt → 16pt → 14pt

## 2. Spacing System

### Standard Spacing Values
```swift
// Based on existing DesignSystem.swift
DesignSystem.Spacing.xs = 4pt    // Micro spacing
DesignSystem.Spacing.sm = 8pt    // Small spacing  
DesignSystem.Spacing.md = 16pt   // Medium spacing
DesignSystem.Spacing.lg = 24pt   // Large spacing
DesignSystem.Spacing.xl = 32pt   // Extra large spacing
DesignSystem.Spacing.xxl = 40pt  // Double extra large spacing

// Content spacing
Section spacing: 24pt
Card spacing: 20pt
Element spacing: 16pt
Compact spacing: 8pt

// Padding system
Horizontal padding: 24pt (onboarding) / 16pt (existing system)
Vertical padding: 16pt
Card padding: 20pt
Button padding: 16pt
```

### Spacing Application
```swift
// Use existing DesignSystem modifiers
.adaptiveHorizontalPadding()  // 16pt standard
.adaptiveVerticalPadding()    // 16pt standard
.adaptiveContentMargin()      // 20pt content margins

// For onboarding-style layouts, use 24pt horizontal padding
.padding(.horizontal, 24)
```

## 3. Color System

### Semantic Colors (iOS 18+ Best Practice)
```swift
// Primary colors
Color.primary           // Adapts to light/dark mode
Color.secondary         // Secondary text color
Color.accentColor       // App accent color

// Background colors
Color.clear                    // Transparent backgrounds
Color.primary.opacity(0.05)    // Subtle card backgrounds
Color.primary.opacity(0.1)     // Slightly more prominent backgrounds

// Prayer type colors (from HomeView)
Color.blue     // Fajr
Color.orange   // Dhuhr  
Color.yellow   // Asr
Color.pink     // Maghrib
Color.purple   // Isha
```

### Background Gradients
```swift
// Welcome/onboarding gradient
LinearGradient(
    gradient: Gradient(colors: [
        Color.accentColor.opacity(0.1),
        Color.clear,
        Color.accentColor.opacity(0.05)
    ]),
    startPoint: .topLeading,
    endPoint: .bottomTrailing
)
.ignoresSafeArea(.all)

// Success/completion gradient
LinearGradient(
    gradient: Gradient(colors: [
        Color.accentColor.opacity(0.1),
        Color.clear,
        Color.green.opacity(0.05)
    ]),
    startPoint: .topLeading,
    endPoint: .bottomTrailing
)
```

## 4. Corner Radius System

### iOS 18+ Continuous Corners
```swift
// Always use .continuous style for modern appearance
RoundedRectangle(cornerRadius: 16, style: .continuous)
RoundedRectangle(cornerRadius: 28, style: .continuous) // For buttons
RoundedRectangle(cornerRadius: 12, style: .continuous) // For text fields

// Standard radius values
Small: 8pt
Medium: 12pt  
Large: 16pt
XL: 20pt
XXL: 24pt
Button: 28pt (for 56pt height buttons)
Card: 16pt
Text field: 12pt
```

## 5. Animation System

### Standard Animations
```swift
// Content fade-ins
.animation(.easeOut(duration: 0.6).delay(0.4), value: showContent)

// Staggered animations
.animation(.easeOut(duration: 0.5).delay(Double(index) * 0.1), value: showContent)

// Button animations
.animation(.easeOut(duration: 0.6).delay(1.0), value: showContent)

// Spring animations for interactions
.animation(.spring(response: 0.6, dampingFraction: 0.8), value: animationPhase)

// Quick feedback animations
.animation(.easeInOut(duration: 0.1), value: isPressed)
```

### Animation Principles
- **Staggered delays**: 0.1s between elements
- **Content delay**: 0.4s for main content
- **Button delay**: 1.0s for call-to-action buttons
- **Spring animations**: For interactive elements
- **Quick feedback**: 0.1s for button presses

## 6. Layout Patterns

### Standard Page Layout
```swift
GeometryReader { geometry in
    ScrollView {
        VStack(spacing: 0) {
            // Header Section (25% of screen height)
            VStack(spacing: 16) {
                Spacer(minLength: 8)
                
                // Title Section
                VStack(spacing: 8) {
                    Text("Page Title")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text("Subtitle text")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .opacity(showContent ? 1.0 : 0.0)
                .offset(y: showContent ? 0 : 20)
                .animation(.easeOut(duration: 0.6).delay(0.4), value: showContent)
                
                Spacer(minLength: 16)
            }
            .frame(minHeight: geometry.size.height * 0.25)
            
            // Content Section
            // ... your content here
            
            Spacer(minLength: 32)
        }
    }
    .scrollIndicators(.hidden)
}
.background(
    // Gradient background
    LinearGradient(...)
        .ignoresSafeArea(.all)
)
```

### Card Pattern
```swift
VStack {
    // Card content
}
.padding(20)
.background(
    RoundedRectangle(cornerRadius: 16, style: .continuous)
        .fill(Color.primary.opacity(0.05))
)
.shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
```

### Modern Button Pattern
```swift
Button(action: action) {
    Text("Button Text")
        .font(.system(size: 18, weight: .semibold, design: .rounded))
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
.buttonStyle(PlainButtonStyle())
.scaleEffect(isPressed ? 0.98 : 1.0)
.animation(.easeInOut(duration: 0.1), value: isPressed)
```

## 7. iOS 18+ Specific Features

### Enhanced Button Feedback
```swift
.buttonStyle(PlainButtonStyle())
.scaleEffect(configuration.isPressed ? 0.98 : 1.0)
.opacity(configuration.isPressed ? 0.9 : 1.0)
.animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
```

### Semantic Color Usage
- Always use `Color.primary`, `Color.secondary`, `Color.accentColor`
- Avoid hardcoded colors for text
- Use opacity modifiers for subtle backgrounds: `.opacity(0.05)`

### Modern Navigation
```swift
.navigationBarTitleDisplayMode(.inline)
.toolbar {
    ToolbarItem(placement: .navigationBarTrailing) {
        Button("Done") {
            dismiss()
        }
        .font(.system(size: 18, weight: .semibold, design: .rounded))
        .foregroundColor(.accentColor)
    }
}
```

## 8. Component Standardization

### Progress Indicators
```swift
HStack(spacing: 8) {
    ForEach(0..<totalSteps, id: \.self) { index in
        Circle()
            .fill(index <= currentStep ? Color.accentColor : Color.accentColor.opacity(0.2))
            .frame(width: 8, height: 8)
            .scaleEffect(index == currentStep ? 1.2 : 1.0)
            .animation(.spring(response: 0.3), value: currentStep)
    }
}
```

### Navigation Button Pairs
```swift
HStack(spacing: 16) {
    // Back button
    Button("Back") { /* action */ }
        .font(.system(size: 18, weight: .semibold, design: .rounded))
        .foregroundColor(.accentColor)
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.accentColor, lineWidth: 2)
        )
    
    // Continue button  
    Button("Continue") { /* action */ }
        .font(.system(size: 18, weight: .semibold, design: .rounded))
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background(
            LinearGradient(...),
            in: RoundedRectangle(cornerRadius: 28, style: .continuous)
        )
}
.padding(.top, 32)
.animation(.easeOut(duration: 0.6).delay(1.0), value: showContent)
```

## 9. Implementation Strategy

### Phase 1: Update Existing Views
1. **Apply consistent typography** using the font system above
2. **Standardize spacing** using DesignSystem.Spacing constants
3. **Update corner radius** to use `.continuous` style
4. **Add modern animations** with staggered fade-ins

### Phase 2: Enhance with iOS 18+ Features
1. **Implement semantic colors** throughout
2. **Add enhanced button feedback** 
3. **Update navigation patterns**
4. **Apply gradient backgrounds** where appropriate

### Phase 3: Component Library
1. **Extract reusable components** (cards, buttons, headers)
2. **Create view extensions** for common patterns
3. **Standardize animation timing**
4. **Document component usage**

## 10. Usage Examples

### Modernizing a Settings-Style View
```swift
// Before: Standard Form
Form {
    Section("Settings") {
        // content
    }
}

// After: Modern Card Layout
ScrollView {
    VStack(spacing: 24) {
        // Header with modern typography
        VStack(spacing: 8) {
            Text("Settings")
                .font(.system(size: 28, weight: .bold, design: .rounded))
            Text("Customize your experience")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
        }
        
        // Card-based content
        VStack(spacing: 16) {
            // Setting cards
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.primary.opacity(0.05))
        )
    }
    .padding(.horizontal, 24)
}
.background(gradientBackground)
```

### Modernizing Navigation Links
```swift
// Before: Standard NavigationLink
NavigationLink("Settings", destination: SettingsView())

// After: Modern Card-Style Link
NavigationLink(destination: SettingsView()) {
    HStack(spacing: 12) {
        Image(systemName: "gear")
            .font(.system(size: 24, weight: .medium))
            .foregroundColor(.accentColor)
        
        VStack(alignment: .leading, spacing: 4) {
            Text("Settings")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text("Customize your experience")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
        }
        
        Spacer()
        
        Image(systemName: "chevron.right")
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.secondary)
    }
    .padding(20)
    .background(
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color.primary.opacity(0.05))
    )
    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
}
.buttonStyle(PlainButtonStyle())
```

## 11. Quality Checklist

When updating any view, ensure:

- [ ] **Typography**: Uses `.rounded` design for titles, consistent font sizes
- [ ] **Spacing**: Uses DesignSystem.Spacing constants or 24pt horizontal padding
- [ ] **Colors**: Uses semantic colors (Color.primary, Color.secondary, Color.accentColor)
- [ ] **Corners**: Uses `.continuous` style for all rounded rectangles
- [ ] **Animations**: Includes staggered fade-ins with proper delays
- [ ] **Buttons**: 56pt height, 28pt corner radius, proper feedback animations
- [ ] **Cards**: 16pt corner radius, 20pt padding, subtle shadow
- [ ] **Layout**: Responsive with GeometryReader, proper safe area handling
- [ ] **Accessibility**: Limited Dynamic Type, proper semantic colors
- [ ] **Navigation**: Modern toolbar styling, inline title display mode

## 12. Next Steps

1. **Apply this guide to remaining views** (StatsView, ProfileView, etc.)
2. **Create reusable components** based on these patterns
3. **Test on multiple device sizes** (iPhone SE to iPhone Pro Max)
4. **Verify dark mode compatibility** with semantic colors
5. **Ensure accessibility compliance** with Dynamic Type limits

This style guide provides the foundation for a cohesive, modern iOS 18+ design system that maintains consistency across your entire app while leveraging the latest iOS design patterns.
