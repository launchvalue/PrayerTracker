//
//  WelcomeView.swift
//  PrayerTracker
//
//  Created by Majd Moussa on 6/25/25.
//

import SwiftUI

struct WelcomeView: View {
    @Binding var currentStep: Int
    @State private var animationPhase = 0
    @State private var showContent = false
    
    var body: some View {
        ZStack {
            // Full-screen background that covers everything
            Color.accentColor.opacity(0.1)
                .ignoresSafeArea(.all)
            
            // Main content
            ScrollView {
                VStack(spacing: 0) {
                    // Top safe area spacer
                    Spacer()
                        .frame(height: 50) // Fixed spacing instead of safe area
                    
                    // Hero Section
                    VStack(spacing: 24) {
                        // Animated Icon
                        ZStack {
                            Circle()
                                .fill(Color.accentColor.opacity(0.1))
                                .frame(width: 120, height: 120)
                                .scaleEffect(animationPhase >= 1 ? 1.0 : 0.8)
                                .opacity(animationPhase >= 1 ? 1.0 : 0.0)
                            
                            Image(systemName: "moon.stars.fill")
                                .font(.system(size: 40, weight: .medium))
                                .foregroundColor(.accentColor)
                                .scaleEffect(animationPhase >= 2 ? 1.0 : 0.5)
                                .opacity(animationPhase >= 2 ? 1.0 : 0.0)
                        }
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: animationPhase)
                        
                        // Title with Animation
                        VStack(spacing: 8) {
                            Text("Welcome to")
                                .font(.system(size: 24, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                                .opacity(animationPhase >= 3 ? 1.0 : 0.0)
                                .offset(y: animationPhase >= 3 ? 0 : 20)
                            
                            Text("PrayerTracker")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                                .opacity(animationPhase >= 4 ? 1.0 : 0.0)
                                .offset(y: animationPhase >= 4 ? 0 : 20)
                        }
                        .multilineTextAlignment(.center)
                        .animation(.easeOut(duration: 0.5).delay(0.1), value: animationPhase)
                        
                        // Subtitle
                        Text("Your personal companion for\nspiritual growth and accountability")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .opacity(showContent ? 1.0 : 0.0)
                            .offset(y: showContent ? 0 : 20)
                            .animation(.easeOut(duration: 0.6).delay(0.8), value: showContent)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                    
                    // Features Section
                    VStack(spacing: 32) {
                        // Section Header
                        VStack(spacing: 12) {
                            Text("Why Choose PrayerTracker?")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Text("Transform your spiritual journey with intelligent tracking")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .opacity(showContent ? 1.0 : 0.0)
                        .offset(y: showContent ? 0 : 30)
                        .animation(.easeOut(duration: 0.6).delay(1.0), value: showContent)
                        
                        // Feature Cards
                        VStack(spacing: 20) {
                            FeatureCard(
                                icon: "chart.line.uptrend.xyaxis",
                                title: "Smart Progress Tracking",
                                description: "Visualize your journey with detailed analytics and motivation...",
                                delay: 1.2
                            )
                            
                            FeatureCard(
                                icon: "target",
                                title: "Personalized Goals",
                                description: "Set achievable daily targets that adapt to your lifestyle and capa...",
                                delay: 1.4
                            )
                            
                            FeatureCard(
                                icon: "lock.shield",
                                title: "Privacy First",
                                description: "Your spiritual journey stays private with secure local storage",
                                delay: 1.6
                            )
                        }
                        .opacity(showContent ? 1.0 : 0.0)
                        
                        // CTA Section
                        VStack(spacing: 20) {
                            Text("Ready to transform your spiritual routine?")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                                .opacity(showContent ? 1.0 : 0.0)
                                .offset(y: showContent ? 0 : 20)
                                .animation(.easeOut(duration: 0.6).delay(1.6), value: showContent)
                            
                            Button(action: {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                    currentStep = 1
                                }
                            }) {
                                HStack(spacing: 12) {
                                    Text("Begin Your Journey")
                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    
                                    Image(systemName: "arrow.right.circle.fill")
                                        .font(.system(size: 20, weight: .medium))
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
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                                .shadow(color: Color.accentColor.opacity(0.3), radius: 12, x: 0, y: 4)
                            }
                            .scaleEffect(showContent ? 1.0 : 0.9)
                            .opacity(showContent ? 1.0 : 0.0)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(1.8), value: showContent)
                        }
                        .padding(.top, 20)
                    }
                    .padding(.horizontal, 24)
                    
                    // Bottom safe area spacer
                    Spacer()
                        .frame(height: 100) // Fixed spacing instead of safe area
                }
            }
            .ignoresSafeArea(.all)
        }
        .onAppear {
            startAnimationSequence()
        }
    }
    
    private func startAnimationSequence() {
        // Staggered animation sequence
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            animationPhase = 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            animationPhase = 2
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            animationPhase = 3
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            animationPhase = 4
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            showContent = true
        }
    }
}

// MARK: - Feature Card Component
struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    let delay: Double
    @State private var isVisible = false
    
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
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.primary.opacity(0.05))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .scaleEffect(isVisible ? 1.0 : 0.9)
        .opacity(isVisible ? 1.0 : 0.0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay), value: isVisible)
        .onAppear {
            isVisible = true
        }
    }
}