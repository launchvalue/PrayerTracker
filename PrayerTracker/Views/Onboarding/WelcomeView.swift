//
//  WelcomeView.swift
//  PrayerTracker
//
//  Created by Majd Moussa on 6/25/25.
//

import SwiftUI

struct WelcomeView: View {
    @Binding var currentStep: Int
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Full-screen background that covers everything
                Color.accentColor.opacity(0.1)
                    .ignoresSafeArea(.all)
                
                // Main content
                ScrollView {
                    VStack(spacing: 24) {
                        // Top safe area spacer
                        Spacer()
                            .frame(height: max(20, geometry.safeAreaInsets.top + 20))
                    
                    // Hero Section
                    VStack(spacing: 30) {
                        // Title
                        VStack(spacing: 6) {
                            Text("Welcome to")
                                .font(.system(size: 24, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                            
                            Text("QadaaTracker")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                        }
                        .multilineTextAlignment(.center)
                        
                        // Subtitle
                        Text("Turn your missed prayers into a plan.")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 14)
                    
                    // Features Section
                    VStack(spacing: 24) {
                        // Section Header
                        VStack(spacing: 16) {
                            Text("Why Choose QadaaTracker?")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Text("QadaaTracker turns overwhelming counts into doable, daily action.")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                        }
                        
                        // Feature Cards
                        VStack(spacing: 24) {
                            FeatureCard(
                                icon: "chart.line.uptrend.xyaxis",
                                title: "Smart Progress Tracking",
                                description: "Visualize your journey with detailed analytics."
                            )
                            
                            FeatureCard(
                                icon: "target",
                                title: "Personalized Goals",
                                description: "Set achievable daily targets that adapt to your lifestyle."
                            )
                            
                            FeatureCard(
                                icon: "lock.shield",
                                title: "Privacy First",
                                description: "Your spiritual journey stays private with secure local storage"
                            )
                        }
                        
                        // CTA Section
                        VStack(spacing: 20) {                            
                            Button(action: {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    currentStep += 1
                                }
                            }) {
                                HStack(spacing: 12) {
                                    Text("Get Started")
                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 16, weight: .medium))
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
                                .overlay(
                                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                                        .stroke(Color.primary.opacity(0.2), lineWidth: 1)
                                )
                                .shadow(color: Color.accentColor.opacity(0.3), radius: 8, x: 0, y: 4)
                            }

                        }
                        .padding(.top, 20)
                    }
                    .padding(.horizontal, 24)
                    
                    // Bottom safe area spacer
                    Spacer()
                        .frame(height: 32) // Fixed spacing instead of safe area
                                }
                    .modifier(FadeInOnAppearModifier(delay: 0.3, duration: 0.8))
                }
                .ignoresSafeArea(.all)
            }
        }

    }
}

// MARK: - Feature Card Component
struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon Container
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.accentColor.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.accentColor)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.primary.opacity(0.05))
        )
    }
}