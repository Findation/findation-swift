import SwiftUI

struct RootView: View {
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding = false
    @EnvironmentObject var session: SessionStore

    var body: some View {
        Group {
            if hasSeenOnboarding {
                if session.isAuthenticated {
                    FindationTabView()
                } else {
                    RegisterView()
                }
            } else {
                AuthView()
            }
        }
    }
}
