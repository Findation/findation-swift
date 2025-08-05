//
//  AppleLoginButton.swift
//  Findation
//
//  Created by Yoy0z-maps on 8/5/25.
//

import SwiftUI

struct AppleLoginButton: View {
    @EnvironmentObject var session: SessionStore
    @Binding var showLoginError: Bool
    
    var body: some View {
        Button(action: {
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
        }) {
            HStack(alignment: .center) {
                Image(systemName: "apple.logo")
                    .resizable()
                    .frame(width: 16, height: 19)
                Spacer()
                Text("Apple 계정으로 로그인")
                Spacer()
                Image(systemName: "apple.logo")
                    .resizable()
                    .frame(width: 16, height: 19)
                    .opacity(0)
            }
            .foregroundColor(.black)
            .padding(.horizontal, 15)
            .frame(width: 353, height: 45)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color.black, lineWidth: 1)
            )
            .cornerRadius(25)
        }
    }
}

#Preview {
    AppleLoginButton(showLoginError: .constant(false))
        .environmentObject(SessionStore())
}
