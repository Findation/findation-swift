import SwiftUI

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
                submitRoutine()
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
            getRoutine()
        }
        .padding()
        .alert("결과", isPresented: $showAlert) {
            Button("확인", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    func getRoutine() {
        guard let url = URL(string: "https://api.findation.site/routines/") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let accessToken = KeychainHelper.load(forKey: "accessToken") {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        } else {
            print("accessToken이 없습니다.")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("네트워크 오류:", error.localizedDescription)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("HTTP 응답이 아닙니다.")
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                print("서버 응답 상태 코드: \(httpResponse.statusCode)")
                return
            }
            
            guard let data = data else {
                print("데이터가 없습니다.")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                print("루틴 조회 성공:", json)
            } catch {
                print("JSON 파싱 실패:", error)
            }
        }.resume()
    }

    func submitRoutine() {
        guard let url = URL(string: "https://api.findation.site/routines/") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let accessToken = KeychainHelper.load(forKey: "accessToken") {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        } else {
            print("accessToken이 없습니다.")
        }

        let body: [String: Any] = [
            "title": title,
            "category": category,
            "is_repeated": calculateIsRepeatedBitmask(weekdays)
        ]

        guard let httpBody = try? JSONSerialization.data(withJSONObject: body) else { return }
        request.httpBody = httpBody

        isSubmitting = true

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isSubmitting = false
            }

            if let error = error {
                DispatchQueue.main.async {
                    alertMessage = "네트워크 오류: \(error.localizedDescription)"
                    showAlert = true
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else { return }

            DispatchQueue.main.async {
                if httpResponse.statusCode == 201 {
                    alertMessage = "루틴 등록 성공!"
                } else {
                    alertMessage = "등록 실패 (\(httpResponse.statusCode))"
                }
                showAlert = true
            }
        }.resume()
    }
}
