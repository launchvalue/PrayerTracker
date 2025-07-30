//
//  AnimationHelper.swift
//  PrayerTracker
//
//  Created by Developer.
//  Shared animation utilities to eliminate code duplication
//

import SwiftUI

/// A reusable view modifier for consistent fade-in animations across the app
struct FadeInOnAppearModifier: ViewModifier {
    @State private var showContent = false
    let delay: Double
    let duration: Double
    
    init(delay: Double = 0.3, duration: Double = 0.6) {
        self.delay = delay
        self.duration = duration
    }
    
    func body(content: Content) -> some View {
        content
            .opacity(showContent ? 1.0 : 0.0)
            .animation(.easeOut(duration: duration), value: showContent)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    showContent = true
                }
            }
    }
}

/// Extension to make the fade-in modifier easily accessible
extension View {
    /// Applies a fade-in animation when the view appears
    /// - Parameters:
    ///   - delay: Delay before animation starts (default: 0.3 seconds)
    ///   - duration: Animation duration (default: 0.6 seconds)
    /// - Returns: View with fade-in animation applied
    func fadeInOnAppear(delay: Double = 0.3, duration: Double = 0.6) -> some View {
        self.modifier(FadeInOnAppearModifier(delay: delay, duration: duration))
    }
}

/// For more complex staggered animations, this provides a reusable helper
struct StaggeredFadeInHelper {
    /// Creates staggered fade-in timing for multiple elements
    /// - Parameters:
    ///   - baseDelay: Base delay before first element animates
    ///   - staggerDelay: Additional delay between each element
    ///   - index: Index of the current element
    /// - Returns: Calculated delay for this element
    static func delay(baseDelay: Double = 0.3, staggerDelay: Double = 0.1, for index: Int) -> Double {
        return baseDelay + (Double(index) * staggerDelay)
    }
}
