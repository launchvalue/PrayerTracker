//
//  UserInfoView.swift
//  PrayerTracker
//
//  Created by Majd Moussa on 6/25/25.
//

import SwiftUI

struct UserInfoView: View {
    @Binding var name: String
    @Binding var gender: String
    @Binding var currentStep: Int
    @State private var isNameFocused = false
    @State private var showContent = false
    @FocusState private var isTextFieldFocused: Bool

    let genders = ["Male", "Female"]

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 24) {
                    // Header Section
                    VStack(spacing: 16) {
                        Spacer(minLength: 8)
                        
                        // Progress Indicator
                        HStack(spacing: 8) {
                            ForEach(0..<5) { index in
                                Circle()
                                    .fill(index == 1 ? Color.accentColor : Color.accentColor.opacity(0.2))
                                    .frame(width: 8, height: 8)
                                    .scaleEffect(index == 1 ? 1.2 : 1.0)
                                    .animation(.spring(response: 0.3), value: index == 1)
                            }
                        }
                        .opacity(showContent ? 1.0 : 0.0)
                        .animation(.easeOut(duration: 0.5).delay(0.2), value: showContent)
                        .padding(.bottom, 16)
                        
                        // Title Section
                        VStack(spacing: 6) {
                            Text("Tell us about yourself")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                            
                            Text("Help us personalize your experience")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .opacity(showContent ? 1.0 : 0.0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.6).delay(0.4), value: showContent)
                        

                    }
                    .frame(minHeight: geometry.size.height * 0.20)
                    
                    // Form Section
                    VStack(spacing: 24) {
                        // Name Input Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(spacing: 12) {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundColor(.accentColor)
                                
                                Text("What should we call you?")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundColor(.primary)
                            }
                            
                            VStack(spacing: 8) {
                                TextField("Enter your name", text: $name)
                                    .font(.system(size: 16, weight: .medium))
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .fill(Color.primary.opacity(0.05))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                    .stroke(isTextFieldFocused ? Color.accentColor : Color.clear, lineWidth: 2)
                                            )
                                    )
                                    .focused($isTextFieldFocused)
                                    .onTapGesture {
                                        isTextFieldFocused = true
                                    }
                                
                                if name.isEmpty && !isTextFieldFocused {
                                    HStack {
                                        Image(systemName: "info.circle")
                                            .font(.system(size: 12))
                                            .foregroundColor(.secondary)
                                        
                                        Text("This helps us create a personalized experience")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.secondary)
                                        
                                        Spacer()
                                    }
                                    .transition(.opacity.combined(with: .move(edge: .top)))
                                }
                            }
                        }
                        .opacity(showContent ? 1.0 : 0.0)
                        .offset(y: showContent ? 0 : 30)
                        .animation(.easeOut(duration: 0.6).delay(0.6), value: showContent)
                        
                        // Gender Selection Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(spacing: 12) {
                                Image(systemName: "figure.and.child.holdinghands")
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundColor(.accentColor)
                                
                                Text("Gender")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundColor(.primary)
                            }
                            
                            VStack(spacing: 12) {
                                Text("This helps us calculate prayer obligations accurately")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                // Custom Gender Picker
                                HStack(spacing: 12) {
                                    ForEach(genders, id: \.self) { genderOption in
                                        Button(action: {
                                            withAnimation(.spring(response: 0.3)) {
                                                gender = genderOption
                                            }
                                        }) {
                                            HStack(spacing: 8) {
                                                Image(systemName: gender == genderOption ? "checkmark.circle.fill" : "circle")
                                                    .font(.system(size: 16, weight: .medium))
                                                    .foregroundColor(gender == genderOption ? .accentColor : .secondary)
                                                
                                                Text(genderOption)
                                                    .font(.system(size: 16, weight: .medium))
                                                    .foregroundColor(gender == genderOption ? .accentColor : .primary)
                                            }
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 16)
                                            .padding(.horizontal, 20)
                                            .background(
                                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                    .fill(gender == genderOption ? Color.accentColor.opacity(0.1) : Color.primary.opacity(0.05))
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                            .stroke(gender == genderOption ? Color.accentColor.opacity(0.3) : Color.clear, lineWidth: 1)
                                                    )
                                            )
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                        }
                        .opacity(showContent ? 1.0 : 0.0)
                        .offset(y: showContent ? 0 : 30)
                        .animation(.easeOut(duration: 0.6).delay(0.8), value: showContent)
                        
                        // Navigation Buttons
                        SimpleNavigationButtons(
                            backAction: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentStep -= 1
                                }
                            },
                            continueAction: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentStep += 1
                                }
                            },
                            canGoBack: true,
                            canContinue: !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        )
                        .padding(.top, 32)
                        .opacity(showContent ? 1.0 : 0.0)
                        .animation(.easeOut(duration: 0.6).delay(1.0), value: showContent)
                        
                        // Bottom spacing
                        Spacer(minLength: 32)
                    }
                    .padding(.horizontal, 24)
                }
            }
            .scrollIndicators(.hidden)
        }
        .onAppear {
            showContent = true
        }
        .onTapGesture {
            isTextFieldFocused = false
        }
    }
}