//
//  ContentView.swift
//  Findation
//
//  Created by Nico on 8/3/25.
//

import SwiftUI

struct PhotoStampView: View {
    @EnvironmentObject var session: SessionStore

    var body: some View {
            VStack(spacing: 15) {
                VStack(spacing: 2) {
                    Text("활동을 완료할까요?")
                    Text("유기화학 2단원 복습") // 실행했던 루틴 문자열
                        .foregroundColor(Color("Primary"))
                }
                .bodytext()

                ZStack {
                    Text("01:30:23")
                        .timeLarge()
                        .foregroundColor(.white)
                }
                .frame(width: 286, height: 286)
                .background(Color("DarkGray"))
                .cornerRadius(5)

                Button(action: {
                    // 메인페이지로 이동
                }) {
                    Text("완료하기")
                        .frame(width: 140, height: 55)
                        .foregroundColor(.white)
                        .background(Color("Primary"))
                        .cornerRadius(10)
                        .bodytext()
                }
            }
            .frame(maxWidth: .infinity)
            .frame(width: 333, height: 455)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 10)
            .padding(20)
        }
    }

#Preview {
    PhotoStampView()
}
