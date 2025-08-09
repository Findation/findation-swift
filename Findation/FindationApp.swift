import SwiftUI

@main
struct FindationApp: App {
    @StateObject private var session = SessionStore()


    var body: some Scene {
        WindowGroup {
            SplashEntranceView()
                .environmentObject(session)
        }
    }
}
