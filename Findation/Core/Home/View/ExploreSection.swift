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
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 4){
                Text("탐색")
                    .bodytext()
                    .foregroundColor(Color("Primary"))
                Text("다른 분들은 어떤 활동을 하고 있는지 살펴보세요.")
                    .footNote()
                    .foregroundColor(Color("DarkGray"))
            }
            
            HStack {
                Text("#공부")
                    .footNote()
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .foregroundColor(Color("Primary"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 999)
                            .stroke(Color("Primary"), lineWidth: 1)
                    )
                    .cornerRadius(999)
                Text("#공부")
                    .footNote()
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .foregroundColor(Color("Primary"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 999)
                            .stroke(Color("Primary"), lineWidth: 1)
                    )
                    .cornerRadius(999)
                Spacer()
                Image(systemName: "plus.circle")
                    .foregroundColor(Color("Primary"))
                    .font(.system(size: 20))
            }
            
            VStack(spacing: 5) {
                ForEach(["유기화학 3단원 예습", "SwiftUI 공부", "Figma 강의 4강 시청", "컴활 문제집 풀기"], id: \.self) { item in
                    Text(item)
                        .subhead()
                        .foregroundColor(Color("Black"))
                        .padding(.vertical, 7)
                        .padding(.horizontal, 12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color("LightGray"))
                        .cornerRadius(999)
                }
            }
        }
        .padding(15)
        .background(Color.white)
        .cornerRadius(15)
        .padding(.horizontal)
    }
}

#Preview {
    ExploreSection()
        .background(Color.blue)
}
