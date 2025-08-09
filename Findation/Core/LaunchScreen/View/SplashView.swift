//
//  SplashView.swift
//  Findation
//
//  Created by 최나영 on 8/8/25.
//

import Foundation
import SwiftUI

struct SplashView: View {
    @State private var finished = false

    var body: some View {
        Group {
            if finished {
                ContentView() // 기존 메인 화면 진입
                    .transition(.opacity)
            } else {
                ZStack {
                    // LaunchScreen.storyboard와 동일한 배경색으로 깜빡임 최소화
                    Color.white.ignoresSafeArea()
                    LottieView(name: "splash") {
                        withAnimation(.easeIn(duration: 0.25)) {
                            finished = true
                        }
                    }
                    .padding(24) // 필요 시 크기 조절
                }
            }
        }
    }
}
