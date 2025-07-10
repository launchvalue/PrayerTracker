
import SwiftUI
import GoogleSignIn
import Combine

class AuthenticationManager: ObservableObject {
    @Published var isSignedIn: Bool = false

    init() {
        // Check if there's a previous Google Sign-In when the app starts
        // restorePreviousSignIn()
    }

    func restorePreviousSignIn() {
        GIDSignIn.sharedInstance.restorePreviousSignIn { [weak self] user, error in
            if let user = user, error == nil {
                print("Restored previous sign-in for user: \(user.profile?.name ?? "Unknown")")
                DispatchQueue.main.async {
                    self?.isSignedIn = true
                }
            } else {
                DispatchQueue.main.async {
                    self?.isSignedIn = false
                }
            }
        }
    }

    func signIn() {
        guard let presentingViewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else {
            print("Could not find a presenting view controller.")
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { [weak self] signInResult, error in
            guard let self = self else { return }
            if let error = error {
                print("Google Sign-In error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.isSignedIn = false
                }
                return
            }
            guard let result = signInResult else {
                DispatchQueue.main.async {
                    self.isSignedIn = false
                }
                return
            }
            
            print("Google Sign-In successful for user: \(result.user.profile?.name ?? "Unknown")")
            
            DispatchQueue.main.async {
                self.isSignedIn = true
            }
        }
    }

    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        DispatchQueue.main.async {
            self.isSignedIn = false
        }
    }
}
