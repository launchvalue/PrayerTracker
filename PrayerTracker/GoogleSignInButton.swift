import SwiftUI
import GoogleSignIn
import GoogleSignInSwift
import Combine // For ObservableObject protocol

struct GoogleSignInButton: View {
    @EnvironmentObject var authManager: AuthenticationManager

    var body: some View {
        Button(action: {
            authManager.signIn()
        }) {
            HStack {
                Image("google_logo") // Make sure to add a Google logo to your assets
                    .resizable()
                    .frame(width: 20, height: 20)
                Text("Sign in with Google")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.red)
            .cornerRadius(10)
        }
    }
}