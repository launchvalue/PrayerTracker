
//
//  SignInView.swift
//  PrayerTracker
//
//  Created by Majd Moussa on 6/26/25.
//

import SwiftUI
import CloudKit
import AuthenticationServices

struct SignInView: View {
    @Environment(AuthenticationManager.self) private var authManager
    @State private var illustrationOpacity: Double = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // Full-bleed Hero Image - Runs under status bar
                Image("praying")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.5 + geometry.safeAreaInsets.top)
                    .clipped()
                    .ignoresSafeArea(.all, edges: .top)
                    .opacity(illustrationOpacity)
                    .animation(.easeIn(duration: 0.35), value: illustrationOpacity)
                
                // Content Section - Positioned below hero image
                VStack(spacing: 0) {
                    // Spacer to push content below hero image
                    Spacer()
                        .frame(height: geometry.size.height * 0.5)
                    
                    // Content Section - Bottom 50% of screen
                VStack(spacing: 32) {
                    Spacer(minLength: 24)
                    // Headline Block
                    VStack(spacing: 4) {
                        Text("Welcome to")
                            .font(.system(size: 34, weight: .bold, design: .default))
                            .foregroundColor(.primary)
                        
                        Text("your personal")
                            .font(.system(size: 34, weight: .bold, design: .default))
                            .foregroundColor(.primary)
                        
                        Text("Prayer Tracker")
                            .font(.system(size: 34, weight: .bold, design: .default))
                            .foregroundColor(.primary)
                    }
                    .multilineTextAlignment(.center)
                    .dynamicTypeSize(...DynamicTypeSize.xLarge)
                    .padding(.horizontal, 12)
                    
                    // Primary Sign-In Buttons
                    VStack(spacing: 20) {
                        // Continue with Apple - Primary
                        SignInWithAppleButton(
                            .continue,
                            onRequest: { request in
                                request.requestedScopes = [.fullName, .email]
                            },
                            onCompletion: { result in
                                handleAppleSignIn(result)
                            }
                        )
                        .signInWithAppleButtonStyle(.black)
                        .frame(height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                        )
                        
                        // Continue with Google - Secondary
                        Button(action: {
                            authManager.signIn()
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "g.circle.fill")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.red)
                                
                                Text("Continue with Google")
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(.primary)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                            )
                        }
                        .scaleEffect(1.0)
                        .animation(.easeInOut(duration: 0.1), value: false)
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer(minLength: 20)
                    
                    // Legal Footnote
                    VStack(spacing: 4) {
                        Text("By signing in with an account, you agree to SO's")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 4) {
                            Button("Terms of Service") {
                                // Handle Terms of Service tap
                            }
                            .font(.caption)
                            .foregroundColor(.accentColor)
                            .underline()
                            
                            Text("and")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Button("Privacy Policy") {
                                // Handle Privacy Policy tap
                            }
                            .font(.caption)
                            .foregroundColor(.accentColor)
                            .underline()
                        }
                    }
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
                .frame(maxHeight: .infinity)
                }
            }
        }
        .background(.background)
        .onAppear {
            illustrationOpacity = 1.0
        }
    }
    
    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authResults):
            switch authResults.credential {
            case let appleIDCredential as ASAuthorizationAppleIDCredential:
                print("Apple Sign-In successful for user: \(appleIDCredential.user)")
                DispatchQueue.main.async {
                    authManager.currentUserID = appleIDCredential.user
                    authManager.isSignedIn = true
                }
            default:
                break
            }
        case .failure(let error):
            print("Apple Sign-In error: \(error.localizedDescription)")
            DispatchQueue.main.async {
                authManager.isSignedIn = false
            }
        }
    }
}

#Preview {
    SignInView()
        .environment(AuthenticationManager())
}
