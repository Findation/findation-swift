//
//  RakingView.swift
//  Findation
//
//  Created by 변관영 on 8/11/25.
//

//
//  RankingView.swift
//  Findation
//
//  Created by Soomin Im on 8/9/25.
//

import SwiftUI

struct Friend {
    let name: String
    let image: String
    let time: String
    
    var timeInterval: TimeInterval {
        let parts = time.split(separator: ":").compactMap { Double($0) }
        guard parts.count == 3 else { return 0 }
        return parts[0] * 3600 + parts[1] * 60 + parts[2]
    }
}

struct RankingView: View {
    let friends: [Friend] = [
        Friend(name: "영광", image: "fish", time: "01:30:20"),
        Friend(name: "세이", image: "fish", time: "01:35:10"),
        Friend(name: "니코", image: "fish", time: "01:40:05"),
        Friend(name: "니나", image: "fish", time: "01:45:50"),
        Friend(name: "오즈", image: "fish", time: "01:50:15")
    ]
    
    // 시간이 짧은 순서대로 정렬 (오름차순)
    var sortedFriends: [Friend] {
        friends.sorted { $0.timeInterval < $1.timeInterval }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("랭킹")
                .bodytext()
                .foregroundColor(Color("Primary"))
                .padding(15)
            
            VStack(alignment: .leading, spacing: 10) {
                ForEach(sortedFriends.indices, id: \.self) { index in
                    let friend = sortedFriends[index]
                    HStack {
                        Text("\(index + 1)")
                            .subhead()
                            .foregroundColor(Color("Black"))
                        Image(friend.image)
                            .resizable()
                            .frame(width: 40, height: 40)
                        Text(friend.name)
                            .bodytext()
                            .foregroundColor(Color("Black"))
                        Spacer()
                        Text(friend.time)
                            .timeSmall2()
                            .foregroundColor(Color("Primary"))
                    }
                    .padding(.horizontal, 15)
                    .padding(.top, 7)
                    .overlay(alignment: .top) {
                        if index > 0 {
                            Rectangle()
                                .frame(height: 1)
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
        .shadow(radius: 10)
    }
}

#Preview {
    RankingView()
}
