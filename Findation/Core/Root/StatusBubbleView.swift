import SwiftUI

// MARK: - StatusBubbleShape
// 말풍선의 기본 형태를 정의하는 Shape
struct StatusBubbleShape: Shape {
    var tailWidth: CGFloat
    var tailHeight: CGFloat
    var cornerRadius: CGFloat
    var tailCornerRadius: CGFloat = 4

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let bubbleWidth = rect.width
        let bubbleHeight = rect.height

        let topLeft = CGPoint(x: rect.minX, y: rect.minY)
        let topRight = CGPoint(x: rect.minX + bubbleWidth, y: rect.minY)
        let bottomLeft = CGPoint(x: rect.minX, y: rect.minY + bubbleHeight)
        let bottomRight = CGPoint(x: rect.minX + bubbleWidth, y: rect.minY + bubbleHeight)

        let tailBaseLeft = CGPoint(x: rect.minX + bubbleWidth / 2 - tailWidth / 2, y: bubbleHeight)
        let tailBaseRight = CGPoint(x: rect.minX + bubbleWidth / 2 + tailWidth / 2, y: bubbleHeight)
        let tailTipX = rect.minX + bubbleWidth / 2
        let tailTipY = bubbleHeight + tailHeight

        // --- 패스를 하나의 연속된 라인으로 그리기 시작 ---
        path.move(to: CGPoint(x: topLeft.x + cornerRadius, y: topLeft.y))
        path.addLine(to: CGPoint(x: topRight.x - cornerRadius, y: topRight.y))
        path.addArc(center: CGPoint(x: topRight.x - cornerRadius, y: topRight.y + cornerRadius),
                    radius: cornerRadius,
                    startAngle: .degrees(-90), endAngle: .degrees(0), clockwise: false)
        path.addLine(to: CGPoint(x: bottomRight.x, y: bottomRight.y - cornerRadius))
        path.addArc(center: CGPoint(x: bottomRight.x - cornerRadius, y: bottomRight.y - cornerRadius),
                    radius: cornerRadius,
                    startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
        path.addLine(to: tailBaseRight)
        path.addLine(to: CGPoint(x: tailTipX + tailWidth / 2 - tailCornerRadius, y: tailTipY - tailCornerRadius))
        path.addQuadCurve(
            to: CGPoint(x: tailTipX - tailWidth / 2 + tailCornerRadius, y: tailTipY - tailCornerRadius),
            control: CGPoint(x: tailTipX, y: tailTipY + tailCornerRadius) // 꼬리 끝이 안으로 오목하게 들어가는 컨트롤 포인트
        )
        path.addLine(to: tailBaseLeft)
        path.addLine(to: CGPoint(x: bottomLeft.x + cornerRadius, y: bottomLeft.y))
        path.addArc(center: CGPoint(x: bottomLeft.x + cornerRadius, y: bottomLeft.y - cornerRadius),
                    radius: cornerRadius,
                    startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
        path.addLine(to: CGPoint(x: topLeft.x, y: topLeft.y + cornerRadius))
        path.addArc(center: CGPoint(x: topLeft.x + cornerRadius, y: topLeft.y + cornerRadius),
                    radius: cornerRadius,
                    startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
        
        return path
    }
}

struct StatusBubbleView: View {
    let text: String

    var bubbleTailWidth: CGFloat = 13
    var bubbleTailHeight: CGFloat = 15
    var bubbleCornerRadius: CGFloat = 10
    var bubbleTailCornerRadius: CGFloat = 4

    var bubbleFill: some ShapeStyle = LinearGradient(
        gradient: Gradient(colors: [
            Color.white.opacity(0.2),
            Color("Primary").opacity(0.6)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    var bubbleStrokeColor: Color? = .white
    var bubbleStrokeLineWidth: CGFloat = 0.75
    var textColor: Color = .white

    var body: some View {
        Text(text)
            .footNote()
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                GeometryReader { geometry in
                    StatusBubbleShape(
                        tailWidth: bubbleTailWidth,
                        tailHeight: bubbleTailHeight,
                        cornerRadius: bubbleCornerRadius,
                        tailCornerRadius: bubbleTailCornerRadius
                    )
                    .fill(bubbleFill)
                    .stroke(bubbleStrokeColor ?? .clear, lineWidth: bubbleStrokeLineWidth)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
            )
            .foregroundColor(Color.white)
            .fixedSize(horizontal: false, vertical: true)
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 30) {
        StatusBubbleView(text: "요즘 집중이 부족해서 배고파요ㅠ", bubbleTailCornerRadius: 4)
    }
    .frame(width:300, height:600)
    .background(Color.gray)
}
