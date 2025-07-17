import SwiftUI

// MARK: - Adaptive Design System

/// Centralized design system for consistent, adaptive UI across all devices and accessibility settings
struct DesignSystem {
    
    // MARK: - Spacing Constants
    
    struct Spacing {
        /// Extra small spacing
        static let xs: CGFloat = 4
        
        /// Small spacing
        static let sm: CGFloat = 8
        
        /// Medium spacing
        static let md: CGFloat = 16
        
        /// Large spacing
        static let lg: CGFloat = 24
        
        /// Extra large spacing
        static let xl: CGFloat = 32
        
        /// Extra extra large spacing
        static let xxl: CGFloat = 40
        
        /// Standard horizontal padding for most content
        static let horizontal: CGFloat = 16
        
        /// Standard vertical padding for most content
        static let vertical: CGFloat = 16
        
        /// Content margins for main areas
        static let contentMargin: CGFloat = 20
        
        /// Compact spacing for smaller devices
        static let compactHorizontal: CGFloat = 12
        static let compactVertical: CGFloat = 12
        
        /// Large spacing for bigger devices
        static let largeHorizontal: CGFloat = 32
        static let largeVertical: CGFloat = 24
    }
    
    // MARK: - Typography Scale
    
    struct Typography {
        /// Adaptive font sizes that scale with Dynamic Type
        static func title1() -> Font {
            .system(.title, design: .default, weight: .bold)
        }
        
        static func title2() -> Font {
            .system(.title2, design: .default, weight: .semibold)
        }
        
        static func title3() -> Font {
            .system(.title3, design: .default, weight: .medium)
        }
        
        static func headline() -> Font {
            .system(.headline, design: .default, weight: .semibold)
        }
        
        static func body() -> Font {
            .system(.body, design: .default)
        }
        
        static func caption() -> Font {
            .system(.caption, design: .default)
        }
    }
    
    // MARK: - Layout Constants
    
    struct Layout {
        /// Minimum touch target size for accessibility
        static let minTouchTarget: CGFloat = 44
        
        /// Card corner radius
        static let cardCornerRadius: CGFloat = 12
        
        /// Button corner radius
        static let buttonCornerRadius: CGFloat = 8
        
        /// Maximum content width for readability
        static let maxContentWidth: CGFloat = 600
        
        /// Grid spacing for layouts
        static let gridSpacing: CGFloat = 16
    }
}

// MARK: - View Extensions for Adaptive Padding

extension View {
    /// Apply standard horizontal padding
    func adaptiveHorizontalPadding() -> some View {
        self.padding(.horizontal, DesignSystem.Spacing.horizontal)
    }
    
    /// Apply standard vertical padding
    func adaptiveVerticalPadding() -> some View {
        self.padding(.vertical, DesignSystem.Spacing.vertical)
    }
    
    /// Apply content margins
    func adaptiveContentMargin() -> some View {
        self.padding(.horizontal, DesignSystem.Spacing.contentMargin)
    }
    
    /// Apply adaptive padding for all sides
    func adaptivePadding() -> some View {
        self.padding(.horizontal, DesignSystem.Spacing.horizontal)
            .padding(.vertical, DesignSystem.Spacing.vertical)
    }
    
    /// Limit Dynamic Type size for better layout control
    func limitedDynamicType() -> some View {
        self.dynamicTypeSize(...DynamicTypeSize.xLarge)
    }
    
    /// Apply consistent card styling
    func cardStyle() -> some View {
        self
            .background(.regularMaterial)
            .cornerRadius(DesignSystem.Layout.cardCornerRadius)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    /// Apply consistent button styling
    func primaryButtonStyle() -> some View {
        self
            .frame(minHeight: DesignSystem.Layout.minTouchTarget)
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(DesignSystem.Layout.buttonCornerRadius)
    }
    
    /// Apply secondary button styling
    func secondaryButtonStyle() -> some View {
        self
            .frame(minHeight: DesignSystem.Layout.minTouchTarget)
            .background(.quaternary)
            .foregroundColor(.primary)
            .cornerRadius(DesignSystem.Layout.buttonCornerRadius)
    }
    
    /// Ensure content doesn't exceed maximum readable width
    func limitContentWidth() -> some View {
        self.frame(maxWidth: DesignSystem.Layout.maxContentWidth)
    }
}

// MARK: - Adaptive ScrollView

struct AdaptiveScrollView<Content: View>: View {
    let content: Content
    let showsIndicators: Bool
    
    init(showsIndicators: Bool = true, @ViewBuilder content: () -> Content) {
        self.showsIndicators = showsIndicators
        self.content = content()
    }
    
    var body: some View {
        ScrollView(showsIndicators: showsIndicators) {
            LazyVStack(spacing: DesignSystem.Spacing.md) {
                content
            }
            .adaptiveContentMargin()
            .padding(.bottom, DesignSystem.Spacing.xl) // Extra bottom padding for safe area
        }
        .limitedDynamicType()
    }
}
