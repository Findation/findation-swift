//
//  MyPageView.swift
//  Findation
//
//  Created by Yoy0z-maps on 8/4/25.
//

import SwiftUI

struct MyPageView: View {
    @EnvironmentObject var session: SessionStore
    
    var body: some View {
        VStack {
            Text("Hello, World!")
            Text("MyPageView")
            Button("Logout") {
                self.session.logout()
            }
        }
    }
}

#Preview {
    MyPageView()
}
