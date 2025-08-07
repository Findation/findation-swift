//
//  StatSection.swift
//  again
//
//  Created by 변관영 on 8/3/25.
//

import SwiftUI

struct StatSection: View {
    var data: [Double] = [3, 4, 2, 5, 6, 4, 7] // 임의의 예시 데이터

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("내 통계")
                .font(.headline)
                .foregroundColor(.primary)

            Text("지난 일주일 간의 성취도를 확인하세요.")
                .font(.subheadline)
                .foregroundColor(.gray)

            GeometryReader { geometry in
                let maxData = data.max() ?? 1
                let width = geometry.size.width
                let height = geometry.size.height
                let stepWidth = width / CGFloat(data.count - 1)

                Path { path in
                    for index in data.indices {
                        let x = stepWidth * CGFloat(index)
                        let y = height - (CGFloat(data[index]) / CGFloat(maxData)) * height
                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(Color.blue, lineWidth: 2)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(8)
            }
            .frame(height: 120)

            HStack {
                Text("일주일 전")
                Spacer()
                Text("오늘")
            }
            .font(.caption)
            .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .padding(.horizontal)
    }
}
