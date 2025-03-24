import SwiftUI

enum Page {
    case dashboard
    case profile
    case library
}

struct ContentView: View {
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var stackVM: StackViewModel
    @AppStorage("isSignedIn") var isSignedIn = false

    @State private var selectedPage: Page = .dashboard

    var body: some View {
        Group {
            if !isSignedIn {
                SplashView()
            } else {
                VStack(spacing: 0) {
                    // Page Content
                    ZStack {
                        switch selectedPage {
                        case .dashboard:
                            Dashboard()
                        case .profile:
                            ProfileView()
                        case .library:
                            LibraryView()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    // Custom Bottom Nav Bar
                    HStack {
                        Spacer()
                        bottomNavButton(label: "Dashboard", systemImage: "rectangle.stack.fill", page: .dashboard)
                        Spacer()
                        bottomNavButton(label: "Profile", systemImage: "person.crop.circle", page: .profile)
                        Spacer()
                        bottomNavButton(label: "Library", systemImage: "book.closed.fill", page: .library)
                        Spacer()
                    }
                    .padding(.vertical, 10)
                    .background(Color(UIColor.systemGray6))
                }
                .environmentObject(auth)
                .environmentObject(stackVM)
            }
        }
    }

    // Custom button for bottom nav
    @ViewBuilder
    private func bottomNavButton(label: String, systemImage: String, page: Page) -> some View {
        Button(action: {
            selectedPage = page
        }) {
            VStack(spacing: 4) {
                Image(systemName: systemImage)
                    .font(.system(size: 20))
                Text(label)
                    .font(.caption)
            }
            .foregroundColor(selectedPage == page ? Color.accentColor : .gray)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
        .environmentObject(StackViewModel())
}
