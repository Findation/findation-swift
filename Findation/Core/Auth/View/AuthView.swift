import SwiftUI

struct AuthView: View {
    @EnvironmentObject var session: SessionStore
    
    @State private var email = ""
    @State private var password = ""
    @State private var isLoggingIn = false
    @State private var showPopup = false
    @State private var errorMessage = "잠시 후 다시 시도해 주세요."

    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    Spacer()
                    Image("kor")
                        .contentMargins(.bottom, 30)

                    Spacer().frame(height: 40)

                    CustomTextField(label: "", placeholder: "이메일",
                                    text: $email, isSecure: false)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)

                    Spacer().frame(height: 28)

                    CustomTextField(label: "", placeholder: "비밀번호",
                                    text: $password, isSecure: true)

                    Spacer()

                    // 버튼 내부에서 네비게이션 하지 않음: RootView가 전환
                    SubmitButton(
                        showError: .constant(false),
                        shouldNavigateToNextScreen: .constant(false),
                        isSatisfied: !email.isEmpty && !password.isEmpty,
                        label: "시작하기"
                    ) {
                        isLoggingIn = true
                        defer { isLoggingIn = false }

                        do {
                            let auth = try await UserAPI.signIn(email: email, password: password)
    
                            session.login(accessToken: auth.access,
                                          refreshToken: auth.refresh,
                                          nickname: auth.user.nickname)
                        } catch {
                            errorMessage = "로그인에 실패했어요. 입력 정보를 확인해 주세요."
                            showPopup = true
                        }
                    }
                    .padding(.bottom, 12)

                    NavigationLink {
                        RegisterView()
                    } label: {
                        HStack(spacing: 0) {
                            Text("아직 계정이 없으신가요?")
                                .foregroundColor(Color.darkGrayColor)  
                            Text(" 계정 만들기")
                                .foregroundColor(Color.primaryColor)
                                .fontWeight(.semibold)
                        }
                        .font(.footnote)
                    }

                    Spacer()
                }

                if isLoggingIn {
                    ProgressView()
                        .scaleEffect(1.6)
                        .progressViewStyle(.circular)
                        .padding(20)
                }
            }
            .alert(isPresented: $showPopup) {
                Alert(
                    title: Text("로그인 실패"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("확인"))
                )
            }
        }
    }
}
