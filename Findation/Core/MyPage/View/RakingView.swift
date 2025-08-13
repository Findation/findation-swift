import Foundation
import SwiftUI

struct RankingView: View {
    @State private var friends: [SearchUser] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    // 시간이 짧은 순(오름차순). “누적시간 많은 사람이 1등”이면 '>'로 바꿔.
    var sortedFriends: [SearchUser] {
        friends.sorted { $0.timeInterval > $1.timeInterval }
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("랭킹")
                .bodytext()
                .foregroundColor(Color("Primary"))
                .padding(15)

            if isLoading {
                ProgressView("불러오는 중…")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 8)
            }
            if let e = errorMessage {
                Text(e).foregroundColor(.red).font(.caption)
                    .padding(.horizontal, 15)
            }

            VStack(alignment: .leading, spacing: 10) {
                ForEach(sortedFriends.indices, id: \.self) { index in
                    let friend = sortedFriends[index]
                    HStack {
                        Text("\(index + 1)")
                            .subhead()
                            .foregroundColor(Color("Black"))

                        Image(systemName: "fish_sunglasses")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.gray)

                        Text(friend.nickname)          // ← name → nickname
                            .bodytext()
                            .foregroundColor(Color("Black"))

                        Spacer()

                        Text(friend.timeString)        // ← time → 계산된 문자열
                            .timeSmall2()
                            .foregroundColor(Color("Primary"))
                    }
                    .padding(.horizontal, 15)
                    .padding(.top, 7)
                    .overlay(alignment: .top) {
                        if index > 0 {
                            Rectangle().frame(height: 1)
                                .foregroundColor(Color("MediumGray"))
                        }
                    }
                }
            }
            .padding(.bottom, 15)
        }
        .frame(minWidth: 353, maxWidth: 353, minHeight: 336, alignment: .topLeading)
        .background(Color.white)
        .cornerRadius(10)
        .task { await loadRanking() }
    }

    private func loadRanking() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let result = try await FriendsAPI.getFriendsList() // ← [SearchUser]
            print(result)
            await MainActor.run {
                self.friends = result   // 타입 일치
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "랭킹 불러오기 실패: \(error.localizedDescription)"
            }
        }
    }
}
