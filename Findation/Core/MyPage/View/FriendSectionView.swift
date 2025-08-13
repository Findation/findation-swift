import SwiftUI

// MARK: - 섹션 뷰 (친구/요청 통합)
struct FriendRequestsSection: View {
    @EnvironmentObject var session: SessionStore
    
    @State private var requests: [FriendRequestResponse] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // 1) 받은 요청 (내가 friend.id)
            if !incomingPending.isEmpty {
                SectionHeader(title: "받은 친구 요청")
                ForEach(incomingPending) { r in
                    RequestRowIncoming(request: r, onAccept: accept, onReject: reject, myId: myId)
                }
            }

            // 2) 보낸 요청 (내가 user.id)
            if !outgoingPending.isEmpty {
                SectionHeader(title: "보낸 친구 요청")
                ForEach(outgoingPending) { r in
                    RequestRowOutgoing(request: r, myId: myId)
                }
            }

            // 3) 이미 친구 (accepted)
            if !accepted.isEmpty {
                SectionHeader(title: "친구")
                ForEach(accepted) { r in
                    FriendRow(request: r, myId: myId)
                }
            }

            // 빈 상태
            if !isLoading && requests.isEmpty {
                EmptyHint()
            }

            // 로딩/에러
            if isLoading {
                ProgressView("불러오는 중…")
            }
            if let e = errorMessage {
                Text(e).foregroundColor(.red).font(.caption)
            }
        }
        .task(load)
    }

    // MARK: - Helpers

    private var myId: String {
        KeychainHelper.load(forKey: "userID") ?? ""
    }

    private var incomingPending: [FriendRequestResponse] {
        requests.filter { $0.status == "pending" && $0.friend.id == myId }
    }

    private var outgoingPending: [FriendRequestResponse] {
        requests.filter { $0.status == "pending" && $0.user.id == myId }
    }

    private var accepted: [FriendRequestResponse] {
        requests.filter { $0.status == "accepted" }
    }

    private func counterpart(of r: FriendRequestResponse, myId: String) -> FriendRequestUserResponse {
        // accepted이든 pending이든, 내 반대편 유저를 뽑아 UI에 쓰기
        r.user.id == myId ? r.friend : r.user
    }

    private func load() async {
        isLoading = true; errorMessage = nil
        defer { isLoading = false }
        do {
            let list = try await FriendsAPI.getRequestList()
            await MainActor.run { self.requests = list }
        } catch {
            await MainActor.run { self.errorMessage = "목록 불러오기 실패: \(error.localizedDescription)" }
        }
    }

    private func accept(_ r: FriendRequestResponse) {
        Task {
            do {
                try await FriendsAPI.fetchFriends(requestId: r.id, action: .accept)
                await refreshStatus(for: r.id, newStatus: "accepted")
            } catch {
                await MainActor.run { errorMessage = "수락 실패: \(error.localizedDescription)" }
            }
        }
    }

    private func reject(_ r: FriendRequestResponse) {
        Task {
            do {
                try await FriendsAPI.fetchFriends(requestId: r.id, action: .reject)
                await MainActor.run {
                    // 거절 시 목록에서 제거(혹은 상태만 바꾸고 숨기기)
                    requests.removeAll { $0.id == r.id }
                }
            } catch {
                await MainActor.run { errorMessage = "거절 실패: \(error.localizedDescription)" }
            }
        }
    }

    @MainActor
    private func refreshStatus(for id: String, newStatus: String) {
        guard let idx = requests.firstIndex(where: { $0.id == id }) else { return }
        var copy = requests[idx]
        // FriendRequestResponse가 let 프로퍼티면, 새 인스턴스 만들어 교체
        copy = .init(id: copy.id, user: copy.user, friend: copy.friend, status: newStatus, createdAt: copy.createdAt)
        requests[idx] = copy
    }
}

// MARK: - Row들

/// 내가 받은 요청: 수락/거절 버튼
private struct RequestRowIncoming: View {
    let request: FriendRequestResponse
    let onAccept: (FriendRequestResponse) -> Void
    let onReject: (FriendRequestResponse) -> Void
    let myId: String

    var body: some View {
        HStack(spacing: 12) {
            Avatar()

            VStack(alignment: .leading, spacing: 2) {
                Text(counter.nickname).font(.headline)
                Text("친구 요청").font(.caption).foregroundColor(.gray)
            }

            Spacer()

            HStack(spacing: 8) {
                Button {
                    onReject(request)
                } label: {
                    Text("거절")
                        .font(.subheadline)
                        .padding(.horizontal, 10).padding(.vertical, 6)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.4)))
                }

                Button {
                    onAccept(request)
                } label: {
                    Text("수락")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(Color("Primary"))
                        .cornerRadius(8)
                }
            }
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 6)
    }

    private var counter: FriendRequestUserResponse {
        request.user.id == myId ? request.friend : request.user
    }

    private func Avatar() -> some View {
        Image(systemName: "person.circle")
            .resizable()
            .frame(width: 40, height: 40)
            .foregroundColor(.gray)
    }
}

/// 내가 보낸 요청: ‘수락 대기중’ 배지
private struct RequestRowOutgoing: View {
    let request: FriendRequestResponse
    let myId: String

    var body: some View {
        HStack(spacing: 12) {
            Avatar()
            VStack(alignment: .leading, spacing: 2) {
                Text(counter.nickname).font(.headline)
                Text("수락 대기중").font(.caption).foregroundColor(.orange)
            }
            Spacer()
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 6)
    }

    private var counter: FriendRequestUserResponse {
        request.user.id == myId ? request.friend : request.user
    }

    private func Avatar() -> some View {
        Image(systemName: "person.circle")
            .resizable()
            .frame(width: 40, height: 40)
            .foregroundColor(.gray)
    }
}

/// 친구(accepted): 버튼 없이 이름만
private struct FriendRow: View {
    let request: FriendRequestResponse
    let myId: String

    var body: some View {
        HStack(spacing: 12) {
            Avatar()
            VStack(alignment: .leading, spacing: 2) {
                Text(counter.nickname).font(.headline)
                Text("친구").font(.caption).foregroundColor(.green)
            }
            Spacer()
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 6)
    }

    private var counter: FriendRequestUserResponse {
        request.user.id == myId ? request.friend : request.user
    }

    private func Avatar() -> some View {
        Image(systemName: "person.circle")
            .resizable()
            .frame(width: 40, height: 40)
            .foregroundColor(.gray)
    }
}

// MARK: - 보조 UI

private struct SectionHeader: View {
    let title: String
    var body: some View {
        HStack {
            Text(title).font(.headline).foregroundColor(Color("Primary"))
            Spacer()
        }
        .padding(.top, 8)
    }
}

private struct EmptyHint: View {
    var body: some View {
        VStack(spacing: 6) {
            Text("아직 친구가 없어요").font(.headline)
            Text("위에서 친구를 추가하거나, 받은 요청을 수락해보세요.")
                .font(.caption).foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, minHeight: 120)
    }
}
