import SwiftUI

struct Friend: Identifiable, Codable {
    let id: Int
    let name: String
    let totalTime: String?
    let profileImage: String?
}

struct FriendAddView: View {
    @State private var friendNickname: String = ""
    @State private var searchResults: [Friend] = []
    @State private var showResults: Bool = false
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    
    let baseURL = "http://10.141.59.73:8000"
    let token = "YOUR_ACCESS_TOKEN"
    
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                HStack {
                    TextField("친구의 닉네임을 입력하세요", text: $friendNickname)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color("MediumGray"), lineWidth: 0.5)
                        )
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                    
                    Button(action: searchFriend) {
                        Image(systemName: "magnifyingglass")
                            .font(.title3)
                            .foregroundColor(Color("Primary"))
                            .padding(.leading, 8)
                    }
                }
                .padding(.horizontal)
            }
            
            if isLoading {
                ProgressView("검색 중...")
            }
            
            if let error = errorMessage {
                Text(error).foregroundColor(.red)
            }
            
            if showResults {
                List(searchResults) { friend in
                    HStack {
                        Image(systemName: "person.circle")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.gray)
                            .padding(.trailing, 8)
                        
                        VStack(alignment: .leading) {
                            Text(friend.name)
                                .headline()
                            if let totalTime = friend.totalTime {
                                Text(totalTime)
                                    .subhead()
                                    .foregroundColor(Color("Primary"))
                                
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            addFriend(friendID: friend.id)
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
    
    func searchFriend() {
        
        guard var urlComponents = URLComponents(string: "\(baseURL)/users/search/") else { return }
        urlComponents.queryItems = [
            URLQueryItem(name: "nickname", value: friendNickname)
        ]
        guard let url = urlComponents.url else { return }

        print("Request URL:", url.absoluteString)
        
        guard !friendNickname.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = "네트워크 오류: \(error.localizedDescription)"
                }
                return
            }
            
            guard let data = data else { return }
            
            do {
                let result = try JSONDecoder().decode([Friend].self, from: data)
                DispatchQueue.main.async {
                    self.searchResults = result
                    self.showResults = true
                }
            } catch {
                DispatchQueue.main.async {
                    errorMessage = "데이터 파싱 오류"
                }
            }
        }.resume()
    }
    
    func addFriend(friendID: Int) {
        guard let url = URL(string: "\(baseURL)/friends/") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["friend_id": friendID]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = "친구 추가 실패: \(error.localizedDescription)"
                }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                DispatchQueue.main.async {
                    if httpResponse.statusCode == 201 {
                        errorMessage = "친구 요청이 전송되었습니다."
                    } else {
                        errorMessage = "친구 추가 실패 (\(httpResponse.statusCode))"
                    }
                }
            }
        }.resume()
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
