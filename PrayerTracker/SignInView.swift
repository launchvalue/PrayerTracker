
//
//  iCloudSignInView.swift
//  PrayerTracker
//
//  Created by Majd Moussa on 6/26/25.
//

import SwiftUI
import CloudKit
import AuthenticationServices

struct SignInView: View {
    @EnvironmentObject private var authManager: AuthenticationManager

    var body: some View {
        VStack {
            Image(systemName: "cloud.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)
                .padding(.bottom, 20)

            Text("Sign In")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 10)

            Text("Sign in to PrayerTracker to track your prayers.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .padding(.bottom, 30)

            VStack(spacing: 15) {
                Button(action: {
                    authManager.signIn()
                }) {
                    HStack {
                        Image(systemName: "g.circle.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                        Text("Sign In with Google")
                            .fontWeight(.semibold)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                .padding(.horizontal, 20)

                Button(action: {
                    authManager.signIn()
                }) {
                    HStack {
                        Image(systemName: "g.circle.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                        Text("Sign Up with Google")
                            .fontWeight(.semibold)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.horizontal, 20)

                SignInWithAppleButton(
                    .signIn,
                    onRequest: { request in
                        request.requestedScopes = [.fullName, .email]
                    },
                    onCompletion: { result in
                        switch result {
                        case .success(let authResults):
                            switch authResults.credential {
                            case let appleIDCredential as ASAuthorizationAppleIDCredential:
                                // User successfully signed in with Apple ID
                                print("Apple Sign-In successful for user: \(appleIDCredential.user)")
                                DispatchQueue.main.async {
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
                )
                .signInWithAppleButtonStyle(.black)
                .frame(height: 50)
                .padding(.horizontal, 20)
            }
            .padding(.top, 10)
        }
    }
}

#Preview {
    SignInView()
        .environmentObject(AuthenticationManager())
}
