import SwiftUI

struct CompletionConfirmationView: View {
    var routineTitle: String
    var elapsedTime: TimeInterval
    var onComplete: () -> Void
    var onPhotoProof: () -> Void
    var onDismiss: () -> Void

    @State private var selectedRating: Int = 0

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 20) {
                Text("루틴 완료")
                    .bodytext()
                    .foregroundColor(Color("Black"))

                ZStack {
                    Circle()
                        .stroke(Color("Primary"), lineWidth: 1)
                        .frame(width: 230, height: 230)

                    VStack(spacing: 5) {
                        Text(routineTitle)
                            .bodytext()
                            .foregroundColor(Color("Primary"))

                        Text(timerString(from: elapsedTime))
                            .timeSmall()
                            .foregroundColor(Color("Primary"))
                    }
                }

                VStack {
                    Text("오늘의 집중도는 어땠나요?")
                        .caption1()
                        .foregroundColor(Color("Black"))

                    HStack(spacing: 5) {
                        ForEach(1...5, id: \.self) { index in
                            Image(index <= selectedRating ? "fish_true" : "fish_false")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .onTapGesture {
                                    selectedRating = index
                                }
                        }
                    }
                }

                HStack(spacing: 7) {
                    Button(action: onComplete) {
                        Text("그냥 완료하기")
                            .bodytext()
                            .padding(14)
                            .frame(width: 140, height: 55)
                            .foregroundColor(Color("Primary"))
                            .overlay(
                                RoundedRectangle(cornerRadius: 999)
                                    .stroke(Color("Primary"), lineWidth: 1)
                            )
                    }

                    Button(action: onPhotoProof) {
                        Text("사진 인증하기")
                            .bodytext()
                            .padding(14)
                            .frame(width: 140, height: 55)
                            .foregroundColor(.white)
                            .background(
                                RoundedRectangle(cornerRadius: 999)
                                    .fill(Color("Primary"))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 999)
                                    .stroke(Color("Primary"), lineWidth: 1)
                            )
                    }
                }
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 4)

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 22))
                    .foregroundColor(Color("DarkGray"))
                    .padding(.top, 20)
                    .padding(.trailing, 20)
            }
        }
        .frame(width: 333, height: 456)
    }

    func timerString(from time: TimeInterval) -> String {
        let h = Int(time) / 3600
        let m = Int(time) % 3600 / 60
        let s = Int(time) % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }
}
