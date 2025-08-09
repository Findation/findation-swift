// 활동 완료 뷰
//  CompletionConfirmationView.swift
//  again
//
//  Created by 변관영 on 8/6/25.
//

import SwiftUI

struct LastModalView: View {
    var title: String
    var proofImage: UIImage
    @Binding var showLastModal: Bool
    var action: () -> Void = {}

    var body: some View {
            VStack(spacing: 8) {
                Text("학습을 종료할까요?")
                    .modifier(Bodytext())
                Text(title)
                    .modifier(Bodytext())
                    .foregroundColor(Color(Color.primaryColor))
       
                Image(uiImage: proofImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
   
                Button(action: {
                    showLastModal = false
                    action()
                }) {
                    Text("완료하기")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(Color.primaryColor))
                        .cornerRadius(12)
                }
                .padding(.top, 10)
                .padding(.horizontal, 73)
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 4)
            .padding(.top, 24)
            .padding(.horizontal, 24)
    }
}
//
//  CompletionConfirmationView.swift
//  Findation
//
//  Created by 변관영 on 8/7/25.
//

//#Preview {
//   LastModalView()
//}
