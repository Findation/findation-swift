import SwiftUI

struct FriendAddView: View {
    @State private var nickname: String = ""
    @State private var searchResults: [SearchUser] = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var showAlert: Bool = false
    
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                HStack {
                    TextField("친구의 닉네임을 입력하세요", text: $nickname)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color("MediumGray"), lineWidth: 0.5)
                        )
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                    
                    Button(action: {
                        Task {
                            isLoading = true
                            searchResults = try await UserAPI.searchUser(nickname: nickname)
                            isLoading = false
                        }
                    }) {
                        Image(systemName: "magnifyingglass")
                            .font(.title3)
                            .foregroundColor(Color("Primary"))
                            .padding(.leading, 8)
                    }
                }
                .padding(.horizontal)
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("친구 추가 완료"),
                        message: Text("친구의 요청 수락을 기다려주세요."),
                        primaryButton: .destructive(Text("확인")) {
                            showAlert = false
                        },
                        secondaryButton: .cancel {  }
                    )
                }
            }
            
            if isLoading {
                ProgressView("검색 중...")
            }
            
            if let error = errorMessage {
                Text(error).foregroundColor(.red)
            }
            
            if !searchResults.isEmpty {
                List(searchResults, id: \.id) {(friend: SearchUser) in
                    HStack {
                        Image(systemName: "person.circle")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.gray)
                            .padding(.trailing, 8)
                        
                        Text(friend.nickname)
                                .headline()
                        
                        Spacer()
                        
                        Button(action: {
                            Task {
                                print("clicked")
                                try await FriendsAPI.addFriend(friendID: friend.id)
                                showAlert = true
                            }
                        }) {
                            Text("+ 추가하기")
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color("Secondary"))
                                .font(.subheadline)
                                .foregroundColor(Color("Primary"))
                                .cornerRadius(999)
                        }
                    }
                    .padding(.vertical, 6)
                }
                .listStyle(.plain)
            }
            
            Spacer()
        }
        .padding(.top, 32)
        .background(Color("LightGray").ignoresSafeArea())
        .navigationTitle("친구 추가")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
    }
}

#Preview {
    NavigationStack {
        FriendAddView()
    }
}

#Preview {
    FriendAddView()
}
