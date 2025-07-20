//
//  WelcomeView.swift
//  PrayerTracker
//
//  Created by Majd Moussa on 6/25/25.
//

import SwiftUI

struct WelcomeView: View {
    @Binding var currentStep: Int
    @State private var illustrationOpacity: Double = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // Full-bleed Hero Image - Runs under status bar
                Image("welcome")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.35 + geometry.safeAreaInsets.top)
                    .clipped()
                    .ignoresSafeArea(.all, edges: .top)
                    .opacity(illustrationOpacity)
                    .animation(.easeIn(duration: 0.35), value: illustrationOpacity)
                
                // Content Section - Positioned below hero image
                VStack(spacing: 0) {
                    // Spacer to push content below hero image
                    Spacer()
                        .frame(height: geometry.size.height * 0.35)
                    
                    // Content Section - Bottom 50% of screen
                    VStack(spacing: 20) {
                        Spacer(minLength: 24)
                        
                        // Headline
                        VStack(spacing: 2) {
                            Text("Welcome to")
                                .font(.system(size: 28, weight: .bold, design: .default))
                                .foregroundColor(.primary)
                            
                            Text("PrayerTracker")
                                .font(.system(size: 28, weight: .bold, design: .default))
                                .foregroundColor(.primary)
                        }
                        .multilineTextAlignment(.center)
                        .dynamicTypeSize(...DynamicTypeSize.xLarge)
                        .padding(.horizontal, 12)
                        
                        // Content Section - Problem, Value, and CTA
                // Problem Block
                VStack(spacing: 12) {
                    Text("Problem")
                        .font(.system(size: 16, weight: .semibold, design: .default))
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                        .tracking(0.5)
                    
                    Text("Keeping track of missed prayers is hard: notebooks get lost, mental counts drift, and motivation fades.")
                        .font(.system(size: 16, weight: .medium, design: .default))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 24)
                
                // Why PrayerTracker? Block
                VStack(spacing: 12) {
                    Text("Why PrayerTracker?")
                        .font(.system(size: 16, weight: .semibold, design: .default))
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                        .tracking(0.5)
                    
                    // 3 Quick Bullets
                    VStack(spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.accentColor)
                                .font(.system(size: 14, weight: .medium))
                            Text("Accurate totals")
                                .font(.system(size: 15, weight: .medium, design: .default))
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.accentColor)
                                .font(.system(size: 14, weight: .medium))
                            Text("Guided daily goals")
                                .font(.system(size: 15, weight: .medium, design: .default))
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.accentColor)
                                .font(.system(size: 14, weight: .medium))
                            Text("Sync & privacy")
                                .font(.system(size: 15, weight: .medium, design: .default))
                                .foregroundColor(.primary)
                            Spacer()
                        }
                    }
                    .padding(.horizontal, 8)
                }
                .padding(.horizontal, 24)
                
                // Payoff Line
                Text("Turn backlog into clear, achievable milestones.")
                    .font(.system(size: 16, weight: .medium, design: .default))
                    .foregroundColor(.accentColor)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 24)
                
                Spacer(minLength: 16)
                
                // Get Started CTA Button
                Button(action: {
                    withAnimation {
                        currentStep = 1
                    }
                }) {
                    Text("Get Started")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                        )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, max(32, geometry.safeAreaInsets.bottom + 16))
                    }
                }
            }
        }
        .background(.background)
        .onAppear {
            illustrationOpacity = 1.0
        }
    }
}