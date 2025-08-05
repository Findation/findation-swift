import SwiftUI
import Alamofire

struct TestView: View {
    @State private var title = ""
    @State private var category = ""
    @State private var weekdays = Array(repeating: false, count: 7)
    
    @State private var isSubmitting = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    let weekdayLabels = ["월", "화", "수", "목", "금", "토", "일"]

    var body: some View {
        VStack(spacing: 20) {
            TextField("루틴 제목", text: $title)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            TextField("카테고리", text: $category)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            HStack {
                ForEach(0..<7, id: \.self) { index in
                    Button(action: {
                        weekdays[index].toggle()
                    }) {
                        Text(weekdayLabels[index])
                            .frame(width: 32, height: 32)
                            .background(weekdays[index] ? Color.blue : Color.gray.opacity(0.3))
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                }
            }

            Button(action: {
                RoutineAPI.postRoutine(title: title, category: category, weekdays: weekdays) { result in
                        switch result {
                        case .success:
                            title = ""
                            category = ""
                            weekdays = Array(repeating: false, count: 7)
                            alertMessage = "루틴 등록 성공!"
                            showAlert = true
                        case .failure:
                            alertMessage = "루틴 등록 실패!"
                            showAlert = true
                        }
                    }
                
            }) {
                if isSubmitting {
                    ProgressView()
                } else {
                    Text("루틴 등록")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
            }
            .disabled(isSubmitting)
        }
        .onAppear{
            RoutineAPI.getRoutine()
        }
        .padding()
        .alert("결과", isPresented: $showAlert) {
            Button("확인", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
}
