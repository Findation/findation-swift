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
    @State var selectedCategory: String = "study"
    let dummyData: [String: [String]] = [
        "study": ["유기화학 3단원 예습", "SwiftUI 공부", "Figma 강의 4강 시청", "컴활 문제집 풀기"],
        "exercise": ["왼손 드리볼 300회", "풀업 30개", "트레디밀러닝 40분"]
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8){
                Text("탐색")
                    .bodytext()
                    .foregroundColor(Color(Color.primaryColor))
                Text("다른 분들은 어떤 활동을 하고 있는지 살펴보세요.")
                    .footNote()
                    .foregroundColor(Color(Color.darkGrayColor))
            }
            
            HStack {
                CategoryButton(
                            title: "운동",
                            isSelected: selectedCategory == "exercise"
                        ) {
                            selectedCategory = "exercise"
                        }

                        CategoryButton(
                            title: "공부",
                            isSelected: selectedCategory == "study"
                        ) {
                            selectedCategory = "study"
                        }
                Spacer()
                Image(systemName: "plus.circle")
                    .foregroundColor(Color("Primary"))
                    .font(.system(size: 20))
            }
            
            VStack(spacing: 5) {
                ForEach(dummyData[selectedCategory, default: []], id: \.self) { item in
                    Text(item)
                        .subhead()
                        .foregroundColor(Color(Color.darkGrayColor))
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(Color.lightGrayColor))
                        .cornerRadius(999)
                }
            }
        }
        .padding(15)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color(hex: "A2C6FF"), radius: 4, x: 0, y: 2)
        .padding(.horizontal, 20)
    }
}

struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("#\(title)")
                .footNote()
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    isSelected ? Color(Color.primaryColor) : Color.clear
                )
                .foregroundColor(
                    isSelected ? Color.white :Color(Color.primaryColor)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 999)
                        .stroke(Color(Color.primaryColor), lineWidth: isSelected ? 0 : 1)
                )
                .cornerRadius(999)
        }
    }
}

#Preview {
    ExploreSection()
        .background(Color.blue)
}
