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

    let genders = ["Male", "Female"]

    var body: some View {
        ZStack {
            // Background with a subtle gradient
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                Text("Tell Us About Yourself")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Form {
                    Section(header: Text("Your Name").font(.headline).foregroundColor(.primary)) {
                        TextField("Enter your name", text: $name)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(10)
                            .background(.thinMaterial)
                            .cornerRadius(10)
                    }
                    .listRowBackground(Color.white.opacity(0.5))

                    Section(header: Text("Your Gender").font(.headline).foregroundColor(.primary)) {
                        Picker("Gender", selection: $gender) {
                            ForEach(genders, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(.segmented)
                        .background(.ultraThinMaterial)
                        .cornerRadius(8)
                    }
                    .listRowBackground(Color.white.opacity(0.5))
                }
                .scrollContentBackground(.hidden) // Make form background transparent
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }
}
