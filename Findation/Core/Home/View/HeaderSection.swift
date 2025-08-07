// 머릿말? 입ㄴㅣ다
//  HeaderSection.swift
//  Findation
//
//  Created by 변관영 on 8/7/25.
//

import SwiftUI

struct HeaderSection: View {
    var date: Date
    @Binding var showAddTask: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            // MARK: - 이름 & 문장
            VStack(alignment: .leading, spacing: 4) {
                Text("세이님,")
                    .font(.system(size: 28, weight: .bold))

                Text("오늘은 뭘 해볼까요?")
                    .font(.system(size: 28))

                Text("준비됐다면 꼭 눌러서 루틴을 시작해주세요.")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }

            // MARK: - 날짜 + 추가하기 버튼
            HStack {
                Text(formattedDate(date))
                    .foregroundColor(.blue)
                    .font(.subheadline)
                Spacer()
                Button(action: {
                    showAddTask = true
                }) {
                    Text("+ 추가하기")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 24)
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일(E)"
        return formatter.string(from: date)
    }
}
