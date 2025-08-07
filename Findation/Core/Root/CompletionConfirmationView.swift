// 활동 완료 뷰
//  CompletionConfirmationView.swift
//  again
//
//  Created by 변관영 on 8/6/25.
//

import SwiftUI

struct CompletionConfirmationView: View {
    var routineTitle: String
    var elapsedTime: TimeInterval
    var onComplete: () -> Void
    var onPhotoProof: () -> Void
    var onDismiss: () -> Void   // ← 닫기용 콜백 추가

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 16) {
                Text("활동을 완료할까요?")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)

                Text(routineTitle)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.blue)

                Text(timerString(from: elapsedTime))
                    .font(.system(size: 36, weight: .semibold, design: .monospaced))
                    .foregroundColor(.blue)

                HStack(spacing: 12) {
                    Button(action: onComplete) {
                        Text("그냥 완료하기")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .foregroundColor(.blue)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.blue, lineWidth: 1)
                            )
                    }

                    Button(action: onPhotoProof) {
                        Text("사진 인증하기")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
            }
            .padding(24)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 4)
            .padding(.top, 24)

            // X 버튼
            Button(action: onDismiss) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.gray.opacity(0.7))
                    .padding(12)
            }
        }
        .padding(.horizontal, 24)
    }

    func timerString(from time: TimeInterval) -> String {
        let h = Int(time) / 3600
        let m = Int(time) % 3600 / 60
        let s = Int(time) % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }
}
//
//  CompletionConfirmationView.swift
//  Findation
//
//  Created by 변관영 on 8/7/25.
//

