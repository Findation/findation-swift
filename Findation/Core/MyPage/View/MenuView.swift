//
//  MenuView.swift
//  again
//
//  Created by 변관영 on 8/6/25.
//

import SwiftUI

struct MenuView: View {
    @EnvironmentObject var session: SessionStore
    @State private var userName: String = ""
    // ⭐️ @State 변수: NavigationLink의 활성화를 제어합니다.
    @State private var showingFriendAddView: Bool = false
    
    var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 15) { // 메인 VStack
                    // 1. 내 이름 설정
                    VStack(alignment: .leading) {
                        Text("내 이름 설정")
                            .headline()
                        
                        TextField("이름을 입력하세요", text: $userName)
                            .padding(6) // 텍스트 필드 내부에 패딩 추가
                            .background(Color.white)
                            .overlay(Rectangle().frame(height: 0.5, alignment: .bottom)
                                .foregroundColor(Color("MediumGray")),
                                alignment: .bottom)
                    }
                    .padding(20)
                    .background(Color.white)
                    
                    // 2. 친구 목록
                    VStack(alignment: .leading, spacing: 50) {
                        HStack{
                            Text("친구 목록")
                                .headline()
                            
                            Spacer()
                            
                            // ⭐️ 이 NavigationLink 부분을 수정했습니다.
                            NavigationLink(destination: MenuView(), isActive: $showingFriendAddView) { // ⭐️ destination을 FriendAddView로 변경
                                Text("친구 추가") // ⭐️ NavigationLink의 label은 Text만 사용 (Button 제거)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color("Secondary"))
                                    .font(.subheadline)
                                    .foregroundColor(Color("Primary"))
                                    .cornerRadius(999)
                            }
                            // ⭐️ NavigationLink가 활성화될 때 실행될 액션 (버튼의 action과 동일한 역할)
                            .onTapGesture {
                                self.showingFriendAddView = true
                                print("친구 추가 버튼 클릭! -> FriendAddView로 이동 (NavigationLink 활성화)")
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
                    
                    HStack(spacing: 50) {
                        Button("로그아웃") {
                            self.session.logout()
                        }
                        .foregroundColor(.red)
                        .headline()
                        Spacer()
                    }
                    .padding(20)
                    .background(Color.white)
                    
                    Text("Copyright 2025. 박수혜 변관영 임수민 최나영 한요한\nAll rights reserved.\n파인데이션짱~")
                        .padding(.horizontal, 20)
                        .caption1()
                        .foregroundColor(Color("DarkGray"))
                }
                .padding(.top, 108) // 전체 VStack의 상단 패딩
            }
            .background(Color("LightGray"))
            .ignoresSafeArea() // ScrollView가 모든 Safe Area 무시
            // ⭐️ 이 NavigationView에는 기본적으로 내비게이션 바가 표시됩니다.
            // MyPageView와 연결되어 커스텀 바를 사용하려면 .navigationBarHidden(true)를 추가하세요.
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView { // 미리보기에서 NavigationView로 감싸야 올바른 컨텍스트를 제공해요.
            MenuView()
        }
    }
}
