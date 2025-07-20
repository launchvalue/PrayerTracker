
import SwiftUI
import GoogleSignIn

@Observable
class AuthenticationManager {
    var isSignedIn: Bool = false
    var currentUserID: String? = nil
    var isAuthenticationComplete: Bool = false
    var shouldRefreshAppState: Bool = false

    init() {
        // Check if there's a previous Google Sign-In when the app starts
        restorePreviousSignIn()
    }

    func restorePreviousSignIn(completion: (() -> Void)? = nil) {
        GIDSignIn.sharedInstance.restorePreviousSignIn { [weak self] user, error in
            if let user = user, error == nil {
                print("Restored previous sign-in for user: \(user.profile?.name ?? "Unknown") with ID: \(user.userID ?? "Unknown ID")")
                DispatchQueue.main.async {
                    self?.currentUserID = user.userID
                    self?.isSignedIn = true
                    self?.isAuthenticationComplete = true
                    completion?()
                }
            } else {
                print("No previous sign-in found or error: \(error?.localizedDescription ?? "Unknown error")")
                DispatchQueue.main.async {
                    self?.currentUserID = nil
                    self?.isSignedIn = false
                    self?.isAuthenticationComplete = true
                    completion?()
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
            
            print("Google Sign-In successful for user: \(result.user.profile?.name ?? "Unknown") with ID: \(result.user.userID ?? "Unknown ID")")
            
            DispatchQueue.main.async {
                self.currentUserID = result.user.userID
                self.isSignedIn = true
            }
        }
    }

    func signOut() {
        let previousUserID = self.currentUserID
        GIDSignIn.sharedInstance.signOut()
        DispatchQueue.main.async {
            self.currentUserID = nil
            self.isSignedIn = false
            
            // Post notification for cleanup
            NotificationCenter.default.post(
                name: NSNotification.Name("UserSignedOut"),
                object: nil,
                userInfo: ["previousUserID": previousUserID ?? "unknown"]
            )
        }
    }
    
    func triggerAppStateRefresh() {
        DispatchQueue.main.async {
            self.shouldRefreshAppState.toggle()
        }
    }
}
