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
        VStack(spacing: 30) {
            Text("Tell Us About Yourself")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            VStack(alignment: .leading, spacing: 20) {
                Text("What should we call you?")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondary)

                TextField("Your Name", text: $name)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(16)
                    .font(.system(size: 18, weight: .regular, design: .rounded))

                Text("Please select your gender.")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondary)

                Picker("Gender", selection: $gender) {
                    ForEach(genders, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(.segmented)
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding()
    }
}