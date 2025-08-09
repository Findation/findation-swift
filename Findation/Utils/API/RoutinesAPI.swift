//
//  RoutinesAPI.swift
//  Findation
//
//  Created by Yoy0z-maps on 8/5/25.
//

import Foundation
import Alamofire

enum APIError: Error {
    case invalidURL
    case responseError
    case decodingError
    case tokenMissing
}

enum RoutineAPI {
    static func getRoutines() async throws -> [Routine] {
        let token = KeychainHelper.load(forKey: "accessToken") ?? ""
        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
        
        let decoder = DateDecoderFactory.iso8601WithFractionalSecondsDecoder()

        return try await AF.request(API.Routines.routineList,
                                    method: .get,
                                    headers: headers)
            .validate(statusCode: 200..<300)
            .serializingDecodable([Routine].self, decoder: decoder)
            .value
    }
    
    static func postRoutine(
        title: String,
        category: String,
        weekdays: [Bool],
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let token = KeychainHelper.load(forKey: "accessToken") else {
            print("Cannot Find an Access Token")
            completion(.failure(APIError.tokenMissing))
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

        AF.request(API.Routines.routineList,
                   method: .post,
                   parameters: parameters,
                   encoding: JSONEncoding.default,
                   headers: headers)
        .validate()
        .response { response in
            switch response.result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    static func deleteRoutine(id: String, completion: @escaping (Bool) -> Void) {
        let token = KeychainHelper.load(forKey: "accessToken")
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token ?? "")"
        ]
        
        AF.request(API.Routines.routineDetail(id: id),
                   method: .delete,
                   headers: headers)
        .validate()
        .response { response in
            switch response.result {
            case .success:
                completion(true)
            case .failure:
                completion(false)
            }
        }
    }
    
    static func patchRoutine(id: String, title: String?, category: String?, is_repeated: Int?, comletion: @escaping (Bool) -> Void) {
        let token = KeychainHelper.load(forKey: "accessToken")
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token ?? "")"
        ]
        
        var parameters: [String: Any] = [:]
        if let title { parameters["title"] = title }
        if let category { parameters["category"] = category }
        if let is_repeated { parameters["is_repeated"] = is_repeated }
        
        AF.request(API.Routines.routineDetail(id: id), method: .patch, headers: headers)
            .validate()
            .response { response in
                switch response.result {
                case .success:
                    comletion(true)
                case .failure:
                    comletion(false)
                }
            }
    }
}

// completion 사용예제
//func login(email: String, password: String, completion: @escaping (Bool) -> Void) {
//    // 서버에 로그인 요청 보냄
//    DispatchQueue.global().async {
//        let success = (email == "test" && password == "1234")
//        
//        // 결과 전달
//        DispatchQueue.main.async {
//            completion(success)
//        }
//    }
//}
//
//login(email: "test", password: "1234") { isSuccess in
//    if isSuccess {
//        print("로그인 성공!")
//    } else {
//        print("로그인 실패!")
//    }
//}
