// 머릿말? 입ㄴㅣ다
//  HeaderSection.swift
//  Findation
//
//  Created by 변관영 on 8/7/25.
//

import SwiftUI

struct HeaderSection: View {
    var date: Date
    var nickname: String
    @Binding var showAddTask: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // MARK: - 이름 & 문장
            VStack(alignment: .leading, spacing: 4) {
                Text("\(nickname)님")
                    .font(.system(size: 28, weight: .bold))
                
                Text("오늘은 뭘 해볼까요?")
                    .font(.system(size: 28))
                
                Text("준비됐다면 꼭 눌러서 루틴을 시작해주세요.")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            
            // MARK: - 날짜 + 추가하기 버튼
            HStack {
                Text(DateDecoderFactory.formattedDate(date: date))
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
}

#Preview {
    HeaderSection(date: Date(timeIntervalSince1970: 1_725_000_000), nickname: "아뇨뚱인데요", showAddTask: .constant(false))
}
