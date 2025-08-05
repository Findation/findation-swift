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
                postRoutine()
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
        guard let token = KeychainHelper.load(forKey: "accessToken") else {
            print("Cannot Find an Access Token")
            return
        }

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)"
        ]
        
        let decoder = DateDecoderFactory.iso8601WithFractionalSecondsDecoder()

        AF.request(API.Routines.routineList, method: .get, headers: headers)
            .validate()
            .responseDecodable(of: [RoutineResponse].self, decoder: decoder) { response in
                switch response.result {
                case .success(let routineResponse):
                    print(routineResponse)
                case .failure(let error):
                    print("에러:", error)
                }
            }
    }
    
    func postRoutine() {
        guard let token = KeychainHelper.load(forKey: "accessToken") else {
            print("Cannot Find an Access Token")
            return
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)"
        ]
        
        let parameters: [String: Any] = [
            "title": title,
            "category": category,
            "is_repeated": calculateIsRepeatedBitmask(weekdays)
        ]
        
        AF.request(API.Routines.routineList, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .response { response in
                switch response.result {
                case .success(_):
                   print("success")
                    self.title = ""
                    self.category = ""
                    self.weekdays = Array(repeating: false, count: 7)
                    self.alertMessage = "루틴 등록 성공!"
                    self.showAlert = true
                case .failure(_):
                   print("failure")
                    self.alertMessage = "루틴 등록 실패!"
                   self.showAlert = true
                }
            }
    }
}
