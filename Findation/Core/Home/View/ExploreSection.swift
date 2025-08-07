// 탐색 뷰입니다.
//  ExploreSection.swift
//  Findation
//
//  Created by 변관영 on 8/7/25.
//

//
//  ExploreSection.swift
//  again
//
//  Created by 변관영 on 8/3/25.
//

import SwiftUI

struct ExploreSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("탐색")
                .font(.headline)
            Text("다른 분들은 어떤 활동을 하고 있는지 살펴보세요.")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            HStack {
                Text("#공부")
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.2))
                    .foregroundColor(.blue)
                    .cornerRadius(12)
                Text("#공부")
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.2))
                    .foregroundColor(.blue)
                    .cornerRadius(12)
                Spacer()
                Image(systemName: "plus.circle")
            }
            
            VStack(spacing: 10) {
                ForEach(["유기화학 3단원 예습", "SwiftUI 공부", "Figma 강의 4강 시청", "컴활 문제집 풀기"], id: \.self) { item in
                    Text(item)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
            }
        }
        .padding()
    }
}
