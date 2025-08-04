//
//  AuthView.swift
//  Findation
//
//  Created by Yoy0z-maps on 8/4/25.
//

import SwiftUI

struct AuthView: View {
    @EnvironmentObject var session: SessionStore
    @State private var showLoginError = false
    
    var body: some View {
        VStack {
            Text("Auth View").padding(.bottom, 20)
            
            Button("Apple로 로그인") {
                AppleAuthService.performAppleLogin { identityToken in
                    guard let token = identityToken else {
                        return
                    }

                    AuthAPI.loginWithApple(identityToken: token) { access, refresh in
                        if let access, let refresh {
                            DispatchQueue.main.async {
                                session.login(accessToken: access, refreshToken: refresh)
                            }
                        } else {
                            DispatchQueue.main.async {
                                   showLoginError = true
                               }
                        }
                    }
                }
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
