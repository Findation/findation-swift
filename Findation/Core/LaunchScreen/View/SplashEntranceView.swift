//
//  SplashEntranceView.swift
//  Findation
//
//  Created by 최나영 on 8/8/25.
//

import SwiftUI

struct SplashEntranceView: View {
    @EnvironmentObject var session: SessionStore
    @State private var finished = false

    var body: some View {
        Group {
            if finished {
                RootView()
                    .environmentObject(session)
                    .transition(.opacity)
            } else {
                ZStack {
                    // LaunchScreen.storyboard와 동일한 배경색 권장
                    Color.white.ignoresSafeArea()

                    LottieView(
                        name: "splash",
                        loopMode: .playOnce,
                        contentMode: .scaleAspectFill
                    ) {
                        withAnimation(.easeIn(duration: 0.25)) {
                            finished = true
                        }
                    }
                    .ignoresSafeArea()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                // 부모가 사이즈를 제한하지 않도록 한 번 더 보장
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}
