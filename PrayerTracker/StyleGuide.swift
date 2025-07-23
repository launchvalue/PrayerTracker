import SwiftUI

// MARK: - App-wide Style Guide
// This file ensures consistent styling across the entire PrayerTracker app

extension View {
    /// Standard card background used throughout the app
    /// Uses .ultraThinMaterial for consistent glassmorphism effect
    func standardCardBackground(cornerRadius: CGFloat = 16) -> some View {
        self.background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
    
    /// Standard card background with shadow
    func standardCardBackgroundWithShadow(cornerRadius: CGFloat = 16) -> some View {
        self.background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: Color.primary.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    /// Enhanced card background with subtle border (for prayer cards)
    func enhancedCardBackground(color: Color, cornerRadius: CGFloat = 16) -> some View {
        self.background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.2),
                                    .clear,
                                    color.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
    }
}

// MARK: - Standard Material Colors
extension Material {
    /// The standard material used throughout the PrayerTracker app
    /// This ensures consistency across all cards and backgrounds
    static let appStandard: Material = .ultraThinMaterial
}

// MARK: - Typography Standards
extension Font {
    /// Standard heading font for sections
    static let sectionHeading = Font.system(size: 22, weight: .bold, design: .rounded)
    
    /// Standard body font for content
    static let standardBody = Font.system(size: 16, weight: .medium, design: .rounded)
    
    /// Standard caption font for secondary text
    static let standardCaption = Font.system(size: 14, weight: .medium, design: .rounded)
}

// MARK: - Color Standards
extension Color {
    /// Standard shadow color used throughout the app
    static let standardShadow = Color.primary.opacity(0.05)
    
    /// Standard border color for subtle dividers
    static let standardBorder = Color.primary.opacity(0.1)
}

// MARK: - Corner Radius Standards
struct CornerRadius {
    static let small: CGFloat = 12
    static let medium: CGFloat = 16
    static let large: CGFloat = 20
}

// MARK: - Spacing Standards
struct AppSpacing {
    static let small: CGFloat = 8
    static let medium: CGFloat = 16
    static let large: CGFloat = 24
    static let extraLarge: CGFloat = 32
}
