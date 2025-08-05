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
    static func getRoutine() {
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
}
