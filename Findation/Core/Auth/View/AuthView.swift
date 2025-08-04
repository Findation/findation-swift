//
//  AuthView.swift
//  Findation
//
//  Created by Yoy0z-maps on 8/4/25.
//

import SwiftUI

struct AuthView: View {
    @EnvironmentObject var session: SessionStore
    
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
                            print("백엔드 인증 실패")
                            // 인증 실패시 Alert 구현해야함
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    AuthView()
}
