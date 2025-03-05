import SwiftUI

@main
struct ProfileAppApp: App {
    @StateObject var auth = AuthManager() // Initialize AuthManager

    var body: some Scene {
        WindowGroup {
            ProfileView()
                .environmentObject(auth) // Pass it into the whole app
        }
    }
}
