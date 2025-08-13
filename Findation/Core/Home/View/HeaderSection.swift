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
        VStack(spacing: 20) {
            // MARK: - 이름 & 문장
            VStack(spacing: 12) {
                VStack(spacing: 4) {
                    (
                        Text(nickname)
                            .foregroundColor(Color("Primary"))
                        + Text("님,")
                            .foregroundColor(Color("Black"))
                    )
                    .title1()
                    Text("오늘은 뭘 해볼까요?")
                        .foregroundColor(Color("Black"))
                        .title1()
                }

                
                Text("준비됐다면 꼭 눌러서 루틴을 시작해주세요.")
                    .subhead()
                    .foregroundColor(Color("DarkGray"))
            }
            
            // MARK: - 날짜 + 추가하기 버튼
            HStack {
                Text(DateDecoderFactory.formattedDate(date: date))
                    .bodytext()
                    .foregroundColor(Color("Primary"))
                Spacer()
                Button(action: {
                    showAddTask = true
                }) {
                    HStack(spacing: 4){
                        Image(systemName: "plus")
                            .font(.system(size:25))
                    }
                    .frame(width: 50, height: 50)
                    .foregroundColor(Color.white)
                    .font(.subheadline)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color(Color.primaryColor))
                    .clipShape(Circle())
                }
            }
        }
        .padding(.horizontal, 4)
        .padding(.top, 80)
        .background(Color.white)
    }
}

#Preview {
    HeaderSection(date: Date(timeIntervalSince1970: 1_725_000_000), nickname: "아뇨뚱인데요", showAddTask: .constant(false))
}
