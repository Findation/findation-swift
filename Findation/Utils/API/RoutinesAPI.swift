//
//  RoutinesAPI.swift
//  Findation
//
//  Created by Yoy0z-maps on 8/5/25.
//

//import Foundation
//
//struct RoutineResponse: Codable {
//    let id: String
//    let title: String
//    let category: String
//    let createdAt: String
//    let isRepeated: Int
//    let user: String
//}
//
//enum RoutineAPI {
//    static func fetchRoutines(completion: @escaping (Result<[RoutineResponse], APIError>) -> Void) {
//        guard let url = URL(string: "\(APIConstants.baseURL)/routines/") else {
//            return completion(.failure(.invalidURL))
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//
//        if let token = KeychainHelper.load(forKey: "accessToken") {
//            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        }
//
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            if let _ = error {
//                return completion(.failure(.responseError))
//            }
//
//            guard let data = data else {
//                return completion(.failure(.responseError))
//            }
//
//            do {
//                let decoded = try JSONDecoder().decode([RoutineResponse].self, from: data)
//                completion(.success(decoded))
//            } catch {
//                completion(.failure(.decodingError))
//            }
//        }.resume()
//    }
//}
//
//RoutineAPI.fetchRoutines { result in
//    switch result {
//    case .success(let routines):
//        print("✅ 루틴 개수: \(routines.count)")
//        print("첫 번째 루틴 제목: \(routines.first?.title ?? "")")
//    case .failure(let error):
//        print("❌ 에러 발생: \(error)")
//    }
//}
