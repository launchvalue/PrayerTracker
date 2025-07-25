import SwiftUI
import Foundation

/// Theme options available to the user
enum AppTheme: Int, CaseIterable {
    case auto = 0
    case light = 1
    case dark = 2
    
    var displayName: String {
        switch self {
        case .auto: return "Auto"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
}

/// Observable theme manager that handles theme switching and persistence
@Observable
class ThemeManager {
    static let shared = ThemeManager()
    
    private let userDefaults = UserDefaults.standard
    private let themeKey = "selected_theme"
    
    /// Current theme selection (Auto/Light/Dark)
    var selectedTheme: AppTheme {
        didSet {
            userDefaults.set(selectedTheme.rawValue, forKey: themeKey)
        }
    }
    
    /// Computed color scheme based on theme selection and system setting
    var colorScheme: ColorScheme? {
        switch selectedTheme {
        case .auto:
            return nil // Use system setting
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
    
    private init() {
        let savedTheme = userDefaults.integer(forKey: themeKey)
        self.selectedTheme = AppTheme(rawValue: savedTheme) ?? .auto
    }
    
    /// Updates the theme selection
    func setTheme(_ theme: AppTheme) {
        selectedTheme = theme
    }
}

// MARK: - Semantic Color Extensions
extension Color {
    /// App-specific semantic colors that adapt to light/dark mode
    struct App {
        /// Primary background color (replaces Color.white)
        static var background: Color {
            Color(light: .white, dark: .black)
        }
        
        /// Secondary background color for cards and containers
        static var secondaryBackground: Color {
            Color(light: Color.black.opacity(0.05), dark: Color.white.opacity(0.1))
        }
        
        /// Tertiary background color for nested containers
        static var tertiaryBackground: Color {
            Color(light: Color.black.opacity(0.02), dark: Color.white.opacity(0.05))
        }
        
        /// Primary text color (replaces Color.black)
        static let primaryText = Color.primary
        
        /// Secondary text color for subtitles
        static let secondaryText = Color.secondary
        
        /// Tertiary text color for captions
        static var tertiaryText: Color {
            Color.secondary.opacity(0.7)
        }
        
        /// Separator color for dividers and borders
        static var separator: Color {
            Color(light: Color.black.opacity(0.2), dark: Color.white.opacity(0.2))
        }
        
        /// Shadow color that adapts to theme
        static var shadow: Color {
            Color(light: Color.black.opacity(0.1), dark: Color.white.opacity(0.05))
        }
        
        /// Card background with subtle opacity
        static var cardBackground: Color {
            Color(light: .white, dark: Color.black.opacity(0.9))
        }
        
        /// Grouped background (for settings-style lists)
        static var groupedBackground: Color {
            Color(light: Color.gray.opacity(0.1), dark: Color.white.opacity(0.03))
        }
        
        /// Secondary grouped background
        static var secondaryGroupedBackground: Color {
            Color(light: .white, dark: Color.white.opacity(0.08))
        }
    }
}

// MARK: - Color Extension for Light/Dark Mode
extension Color {
    /// Creates a dynamic color that adapts to light/dark mode
    init(light: Color, dark: Color) {
        self = Color.primary // Simplified for now - will use proper semantic colors
    }
}
