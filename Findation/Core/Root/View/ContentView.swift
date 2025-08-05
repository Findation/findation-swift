//
//  ContentView.swift
//  Findation
//
//  Created by Yoy0z-maps on 8/3/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var session: SessionStore
    
    var body: some View {
        FindationTabView()
        .onAppear{
            //session.logout()
            session.refreshTokenIfNeeded()
        }
    }
}

#Preview {
    ContentView()
}
