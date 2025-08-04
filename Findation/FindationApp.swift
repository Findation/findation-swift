//
//  FindationApp.swift
//  Findation
//
//  Created by Yoy0z-maps on 8/3/25.
//

import SwiftUI

@main
struct FindationApp: App {
    @StateObject private var session = SessionStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(session)
        }
    }
}
