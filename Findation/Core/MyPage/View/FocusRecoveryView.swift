import SwiftUI

struct FocusRecoveryView: View {
    // 임의 데이터 (예: 집중력 점수)
    let dataPoints: [CGFloat] = [20, 40, 35, 70, 55, 90, 75]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 헤더
            Text("집중력 회복")
                .font(.body)
                .foregroundColor(Color("Primary"))
                .padding(15)

            // 그래프 영역
            VStack {
                GeometryReader { geo in
                    let width = geo.size.width
                    let height = geo.size.height
                    let maxVal = (dataPoints.max() ?? 1)
                    let stepX = width / CGFloat(dataPoints.count - 1)

                    ZStack {
                        // 곡선 + 채우기
                        Path { path in
                            guard dataPoints.count > 1 else { return }

                            // 시작점
                            path.move(to: CGPoint(x: 0, y: height - (dataPoints[0] / maxVal) * height))

                            // 나머지 포인트
                            for i in 1..<dataPoints.count {
                                let point = CGPoint(
                                    x: CGFloat(i) * stepX,
                                    y: height - (dataPoints[i] / maxVal) * height
                                )
                                path.addLine(to: point)
                            }

                            // 채우기용: 마지막 점 -> 아래 -> 첫 점 아래로 닫기
                            path.addLine(to: CGPoint(x: width, y: height))
                            path.addLine(to: CGPoint(x: 0, y: height))
                            path.closeSubpath()
                        }
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color("Primary").opacity(0.3), .clear]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                        // 곡선 라인
                        Path { path in
                            guard dataPoints.count > 1 else { return }
                            path.move(to: CGPoint(x: 0, y: height - (dataPoints[0] / maxVal) * height))
                            for i in 1..<dataPoints.count {
                                let point = CGPoint(
                                    x: CGFloat(i) * stepX,
                                    y: height - (dataPoints[i] / maxVal) * height
                                )
                                path.addLine(to: point)
                            }
                        }
                        .stroke(Color("Primary"), lineWidth: 2)
                    }
                }
                .frame(height: 220)
                .padding(.horizontal, 15)
            }
            .padding(.bottom, 15)
        }
        .frame(minWidth: 353, maxWidth: 353, minHeight: 336, alignment: .topLeading)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 10)
    }
}

#Preview {
    FocusRecoveryView()
}
