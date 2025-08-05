//
//  AuthView.swift
//  Findation
//
//  Created by Yoy0z-maps on 8/4/25.
//

import SwiftUI

struct AuthView: View {
    @State private var showLoginError = false
    @State private var isLoggingIn = false
    @EnvironmentObject var session: SessionStore
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                Image(systemName: "apple.logo").resizable().frame(width: 90, height: 110).contentMargins(.bottom, 30)
                Text("Findation - App Name")
                Spacer()
                AppleLoginButton(showLoginError: $showLoginError, isLoggedIn: $isLoggingIn)
                Spacer()
            }
            if isLoggingIn {
                ProgressView()
                    .scaleEffect(2.0)
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .padding(20)
                    .cornerRadius(10)
            }
        }
        .alert(isPresented: $showLoginError) {
                    Alert(
                        title: Text("애플 로그인 실패"),
                        message: Text("잠시 후 다시 시도해 주세요."),
                        dismissButton: .default(Text("확인"))
                    )
                }
    }
}

#Preview {
    AuthView()
}
