import SwiftUI

struct RootView: View {
    @EnvironmentObject var session: SessionStore

    var body: some View {
        let isAuth = session.isAuthenticated
        print("🟡 RootView body - isAuthenticated:", isAuth)

        return Group {
            if isAuth {
                ContentView()
            } else {
                AuthView()
            }
        }
    }
}
