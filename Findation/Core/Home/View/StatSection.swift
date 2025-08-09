import SwiftUI

struct StatSection: View {
    var data: [Double] = [3, 4, 2, 5, 6, 4, 7] // 예시 데이터

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 8){
                Text("내 통계")
                    .bodytext()
                    .foregroundColor(Color(Color.primaryColor))
                Text("지난 일주일 간의 성취도를 확인하세요.")
                    .footNote()
                    .foregroundColor(Color(Color.darkGrayColor))
            }

            GeometryReader { geo in
                let maxValue = max(data.max() ?? 1, 1)
                let w = geo.size.width
                let h = geo.size.height
                let stepX = data.count > 1 ? w / CGFloat(data.count - 1) : 0

                // 모든 포인트 좌표
                let points: [CGPoint] = data.enumerated().map { i, v in
                    let x = stepX * CGFloat(i)
                    let y = h - (CGFloat(v) / CGFloat(maxValue)) * h
                    return CGPoint(x: x, y: y)
                }

                ZStack {
                    // 영역(아래 채우기)
                    if let first = points.first, let last = points.last {
                        Path { p in
                            p.move(to: CGPoint(x: first.x, y: h)) // 바닥에서 시작
                            for pt in points { p.addLine(to: pt) }
                            p.addLine(to: CGPoint(x: last.x, y: h)) // 바닥으로 닫기
                            p.closeSubpath()
                        }
                        .fill(
//                            LinearGradient(
//                                colors: [Color.blue.opacity(0.22), Color.blue.opacity(0.05)],
//                                startPoint: .top,
//                                endPoint: .bottom
//                            )
                            Color.secondaryColor
                        )
                    }

                    // 라인
                    Path { p in
                        guard let first = points.first else { return }
                        p.move(to: first)
                        for pt in points.dropFirst() { p.addLine(to: pt) }
                    }
                    .stroke(Color.primaryColor, lineWidth: 1.5)

                    // 포인트(점)
                    ForEach(points.indices, id: \.self) { i in
                        Circle()
                            .fill(Color.primaryColor)
                            .frame(width: 4, height: 4)
                            .position(points[i])
                    }
                }
            }
            .frame(height: 120)
            HStack {
                Text("일주일 전")
                Spacer()
                Text("오늘")
            }
            .font(.caption)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color(hex: "A2C6FF"), radius: 4, x: 0, y: 2)
        .padding(.horizontal, 20)
    }
}
