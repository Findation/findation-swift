//
//  AuthView.swift
//  Findation
//
//  Created by Yoy0z-maps on 8/4/25.
//

import SwiftUI

struct AuthView: View {
    @EnvironmentObject var session: SessionStore
    
    @State private var email: String = ""
    @State private var password: String = ""
    
    @State private var isLoggingIn = false
    @State private var showError: Bool = false
    @State private var showPopup: Bool = false
    @State private var shouldNavigateToNextScreen: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    Spacer()
                    Image("kor").contentMargins(.bottom, 30)
                    Spacer().frame(height: 40)
                    CustomTextField(label:"",placeholder: "이메일", text: $email, isSecure: false)
                    Spacer()
                        .frame(height: 28)
                    CustomTextField(label:"",placeholder: "비밀번호", text: $password, isSecure: true)
                    Spacer()
                    SubmitButton(showError: $showError, shouldNavigateToNextScreen: $shouldNavigateToNextScreen, isSatisfied: email.isEmpty == false && password.isEmpty == false, label: "시작하기") {
                        do {
                            let auth = try await UserAPI.signIn(email: email, password: password)
                            // TODO: Keychain 저장
                            session.login(accessToken: auth.access, refreshToken: auth.refresh, nickname: auth.user.nickname)
                        } catch {
                            shouldNavigateToNextScreen = false
                            showPopup = true
                            print("SignUp failed:", error)
                        }
                    }
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
            .navigationDestination(isPresented: $shouldNavigateToNextScreen) {
                FindationTabView()
            }
            .alert(isPresented: $showPopup) {
                Alert(
                    title: Text("애플 로그인 실패"),
                    message: Text("잠시 후 다시 시도해 주세요."),
                    dismissButton: .default(Text("확인"))
                )
            }
        }
    }
}

#Preview {
    AuthView()
}
