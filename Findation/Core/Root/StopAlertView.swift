import SwiftUI

struct StopAlertView: View {
    @EnvironmentObject var session: SessionStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing:12) {
                VStack(spacing:2){
                    Text("활동을 완료할까요?")
                    Text("유기화학 2단원 복습") //
                        .foregroundColor(Color("Primary"))
                }
                .bodytext()

                Text("01:20:32")
                    .timeSmall()
                    .foregroundColor(Color("Primary"))

                HStack {
                    Button(action: {
                        // 루트로 이동
                    }) {
                        Text("그냥 완료하기")
                            .frame(width: 140, height:55)
                            .background(Color("LightGray"))
                            .foregroundColor(Color("Primary"))
                            .cornerRadius(10)
                            .bodytext()
                    }

                    Button(action: {
                        // 카메라 화면으로 이동
                    }) {
                        Text("사진 인증하기")
                            .frame(width: 140, height:55)
                            .foregroundColor(.white)
                            .background(Color("Primary"))
                            .cornerRadius(10)
                            .bodytext()
                    }
                }
            }

            Button(action: {
                dismiss()
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(Color("DarkGray"))
                    .padding(0)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(width: 333, height: 218)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding(20)
    }
}

#Preview {
    StopAlertView()
}
