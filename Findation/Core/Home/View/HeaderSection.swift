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
        VStack(spacing: 30) {

            // MARK: - 이름 & 문장
            VStack(spacing: 12) {
                VStack(spacing: 4) {
                    Text("세이님,")
                    Text("오늘은 뭘 해볼까요?")
                }
                .foregroundColor(Color("Black"))
                .title1()
                
                Text("준비됐다면 꼭 눌러서 루틴을 시작해주세요.")
                    .subhead()
                    .foregroundColor(Color("DarkGray"))
            }

            // MARK: - 날짜 + 추가하기 버튼
            HStack {
                Text(formattedDate(date))
                    .bodytext()
                    .foregroundColor(Color("Primary"))
                Spacer()
                Button(action: {
                    showAddTask = true
                }) {
                    HStack(spacing: 4){
                        Image(systemName: "plus")
                            .font(.system(size:14))
                        Text("추가하기")
                    }
                    .foregroundColor(Color("Primary"))
                    .font(.subheadline)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color("Secondary"))
                    .clipShape(RoundedRectangle(cornerRadius: 999))
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 80)
        .padding(.bottom, 24)
        .background(Color.white)
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일(E)"
        return formatter.string(from: date)
    }
}

// 임시 프리뷰
#Preview {
    PreviewWrapper()
}

struct PreviewWrapper: View {
    @State private var isPresented = false

    var body: some View {
        HeaderSection(date: Date(), showAddTask: $isPresented)
    }
}
