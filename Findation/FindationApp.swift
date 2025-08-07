import SwiftUI

@main
struct FindationApp: App {
//    @StateObject private var session = SessionStore()
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding = false

    var body: some Scene {
        WindowGroup {
            if hasSeenOnboarding {
                FindationTabView()
            } else {
                OnboardingView()
                   
            }
        }
    }
}
