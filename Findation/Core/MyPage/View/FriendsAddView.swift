import SwiftUI

struct FriendAddView: View {
    @State private var friendEmail: String = ""

    var body: some View {
        VStack(spacing: 24) {
            // ✅ 이메일 입력 필드
            VStack(spacing: 16) {
                HStack {
                    TextField("친구의 이메일을 입력하세요", text: $friendEmail)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color("MediumGray"), lineWidth: 0.5)
                        )
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()

                    Button(action: {
                        print("친구 이메일 검색 버튼 클릭. 입력된 이메일: \(friendEmail)")
                    }) {
                        Image(systemName: "magnifyingglass")
                            .font(.title3)
                            .foregroundColor(Color("Primary"))
                            .padding(.leading, 8)
                    }
                }
                .padding(.horizontal)
            }

            Spacer()
        }
        .padding(.top, 32)
        .background(Color("LightGray").ignoresSafeArea())
        .navigationTitle("친구 추가")                        // ✅ 시스템 타이틀
        .navigationBarTitleDisplayMode(.inline)             // ✅ 상단에 작게 표시
        .navigationBarBackButtonHidden(false)               // ✅ ← 시스템 back 버튼 표시
    }
}

#Preview {
    FriendAddView()
}
