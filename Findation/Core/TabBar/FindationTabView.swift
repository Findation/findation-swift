//
//  FindationTabView.swift
//  Findation
//
//  Created by Yoy0z-maps on 8/4/25.
//

import SwiftUI

struct FindationTabView: View {
    @EnvironmentObject var session: SessionStore
    @Environment(\.scenePhase) private var phase
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            MainView()
                .tabItem {
                    VStack {
                        Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                            .environment(\.symbolVariants, selectedTab == 0 ? .fill : .none)
                        Text("홈")
                            .foregroundColor(selectedTab == 0 ? .accentColor : .gray)
                    }
                }
                .tag(0)
            MyPageScreen()
                .tabItem {
                    VStack {
                        Image(systemName: selectedTab == 1 ? "person.fill" : "person")
                            .environment(\.symbolVariants, selectedTab == 0 ? .fill : .none)
                        Text("마이페이지")
                            .foregroundColor(selectedTab == 0 ? .accentColor : .gray)
                    }
                }
                .tag(1)
        }
        .task {
            await session.refreshTokenIfNeeded()
        }
        .onChange(of: phase) { _, newPhase in
            if newPhase == .active {
                Task { await session.refreshTokenIfNeeded() }
            }
        }
    }
}

#Preview {
    FindationTabView()
}
