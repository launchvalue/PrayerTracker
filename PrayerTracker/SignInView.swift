
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
                        // Handle Apple ID sign-in request
                    },
                    onCompletion: { result in
                        // Handle Apple ID sign-in completion
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
