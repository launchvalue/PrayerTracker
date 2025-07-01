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
        VStack {
            Text("Tell us about yourself")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            Form {
                Section("Your Name") {
                    TextField("Enter your name", text: $name)
                }

                Section("Your Gender") {
                    Picker("Gender", selection: $gender) {
                        ForEach(genders, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
        }
    }
}
