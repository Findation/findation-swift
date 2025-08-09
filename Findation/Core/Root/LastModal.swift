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

    var body: some View {
            VStack(spacing: 16) {
                Text("학습을 종료할까요?")
                Text(title)
       
                Image(uiImage: proofImage)
                    .resizable()
                    .scaledToFit() // 비율 유지해서 맞춤
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
   
                Button(action: {
                    showLastModal = false
                }) {
                    Text("완료하기")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(Color.primaryColor))
                        .cornerRadius(12)
                }
            }
            .padding(24)
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
