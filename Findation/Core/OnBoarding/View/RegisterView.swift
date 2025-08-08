//
//  RegisterView.swift
//  Findation
//
//  Created by Yoy0z-maps on 8/7/25.
//

import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var session: SessionStore
    
    // API POST 요청에 들어갈 상태
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var nickname: String = ""
    
    // 네비게이션, UI 변경에 필요한 상태
    @State private var isLoggingIn = false
    @State private var showError: Bool = false
    @State private var showPopup: Bool = false
    @State private var shouldNavigateToNextScreen: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    OnBoardingTitle(title: "회원가입", subTitle: "어푸 서비스에서 사용할 정보를 입력해주세요.")
                    CustomTextField(label:"이메일",placeholder: "iamlearner@apple.com", text: $email, isSecure: false)
                    Spacer()
                        .frame(height: 28)
                    CustomTextField(label:"비밀번호",placeholder: "password", text: $password, isSecure: true)
                    PasswordStrengthBar(strength: calculateStrength(password: password))
                    Spacer()
                        .frame(height: 28)
                    CustomTextField(label:"닉네임",placeholder: "예: 헤엄치는 뚱이", text: $nickname, isSecure: false)
                    Spacer()
                    SubmitButton(showError: $showError, shouldNavigateToNextScreen: $shouldNavigateToNextScreen, isSatisfied: isRegisterFormValid(email: email, password: password, nickname: nickname), label: "다음으로") {
                        do {
                            let auth = try await UserAPI.signUp(email: email, password: password, nickname: nickname)
                            print("access:", auth.access)
                            print("refresh:", auth.refresh)
                            // TODO: Keychain 저장
                            session.login(accessToken: auth.access, refreshToken: auth.refresh)
                            
                        } catch {
                            showPopup = true
                            print("SignUp failed:", error)
                        }
                    }
                        .padding(.bottom, 60)
                }
                .frame(maxHeight: .infinity, alignment: .top)
                if isLoggingIn {
                    ProgressView()
                        .scaleEffect(2.0)
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .padding(20)
                        .cornerRadius(10)
                }
            }
            //.ignoresSafeArea(.keyboard) 필요할까?
            .navigationDestination(isPresented: $shouldNavigateToNextScreen) {
                OnboardingView()
            }
            .alert(isPresented: $showPopup) {
                Alert(
                    title: Text("회원가입 실패"),
                    message: Text("잠시 후 다시 시도해 주세요."),
                    dismissButton: .default(Text("확인"))
                )
            }
        }
    }
}

#Preview {
    RegisterView()
}
