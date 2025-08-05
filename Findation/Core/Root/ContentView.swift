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
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .onAppear{
        }
    }
}

#Preview {
    ContentView()
}
