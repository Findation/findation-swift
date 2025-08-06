import SwiftUI

struct RootView: View {
    @EnvironmentObject var session: SessionStore

    var body: some View {
        let isAuth = session.isAuthenticated

        return Group {
            ContentView()
//            if isAuth {
//                ContentView()
//            } else {
//                AuthView()
//            }
        }
    }
}
