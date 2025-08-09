import SwiftUI

struct RootView: View {
    @EnvironmentObject var session: SessionStore

    var body: some View {
        Group {
            if session.isAuthenticated {
                FindationTabView()
            } else {
                AuthView()
            }
        }
        .id(session.isAuthenticated)
        .animation(.default, value: session.isAuthenticated)
    }
}
