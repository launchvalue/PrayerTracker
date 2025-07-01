
//
//  iCloudSignInView.swift
//  PrayerTracker
//
//  Created by Majd Moussa on 6/26/25.
//

import SwiftUI
import CloudKit

struct iCloudSignInView: View {
    let iCloudAccountStatus: CKAccountStatus

    var body: some View {
        VStack {
            Image(systemName: "cloud.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)
                .padding(.bottom, 20)

            Text("iCloud Required")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 10)

            Text("PrayerTracker uses iCloud to securely store and sync your prayer data across all your devices. Please sign in to iCloud on your device to continue.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .padding(.bottom, 30)

            if iCloudAccountStatus == .noAccount || iCloudAccountStatus == .restricted {
                Button(action: openSettings) {
                    Text("Open Settings")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 20)
            } else {
                Text("Waiting for iCloud sign-in...")
                    .font(.headline)
                    .foregroundColor(.gray)
            }
        }
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    iCloudSignInView(iCloudAccountStatus: .noAccount)
}
