import SwiftUI

struct MenuView: View {
    @EnvironmentObject var session: SessionStore
    @State private var userName: String = ""

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 15) {

                    // 1. 내 이름 설정
                    VStack(alignment: .leading) {
                        Text("내 이름 설정")
                            .headline()
                            .foregroundColor(Color("Primary"))

                        TextField("이름을 입력하세요", text: $userName)
                            .padding(6)
                            .background(Color.white)
                            .overlay(
                                Rectangle()
                                    .frame(height: 0.5)
                                    .foregroundColor(Color("MediumGray")),
                                alignment: .bottom
                            )
                    }
                    .padding(20)
                    .background(Color.white)

                    // 2. 친구 목록
                    VStack(alignment: .leading, spacing: 50) {
                        HStack {
                            Text("친구 목록")
                                .headline()
                                .foregroundColor(Color("Primary"))

                            Spacer()

                            NavigationLink(destination: FriendAddView()) {
                                Text("+ 친구추가")
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color("Secondary"))
                                    .font(.subheadline)
                                    .foregroundColor(Color("Primary"))
                                    .cornerRadius(999)
                            }
                        }

                        VStack {
                            Text("아직 추가된 친구가 없어요!")
                                .headline()
                                .frame(maxWidth: .infinity, alignment: .center)

                            Text("‘친구추가'를 눌러 친구를 찾아보세요.")
                                .caption2()
                                .foregroundColor(Color("DarkGray"))
                                .padding(.top, 1)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .padding(.vertical, 100)
                    }
                    .padding(20)
                    .background(Color.white)

                    // 3. 로그아웃 버튼
                    HStack(spacing: 50) {
                        Button("로그아웃") {
                            session.logout()
                        }
                        .foregroundColor(.red)
                        .headline()

                        Spacer()
                    }
                    .padding(20)
                    .background(Color.white)

                    // 4. 푸터
                    Text("Copyright 2025. 박수혜 변관영 임수민 최나영 한요한\nAll rights reserved.\n파인데이션짱~")
                        .padding(.horizontal, 20)
                        .caption1()
                        .foregroundColor(Color("DarkGray"))
                }
                .padding(.top, 60) // ✅ 전체 내용을 아래로 내림
            }
        }
        .background(Color("LightGray"))
        .navigationBarBackButtonHidden(false)
        .navigationBarHidden(false)
    }
}

#Preview {
    NavigationStack {
        MenuView()
            .environmentObject(SessionStore())
    }
}
