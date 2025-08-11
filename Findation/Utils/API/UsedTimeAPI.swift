//
//  UsedTimeAPI.swift
//  Findation
//
//  Created by Yoy0z-maps on 8/10/25.
//

import Foundation
import Alamofire

enum UsedTimeAPI {
    static func getUsedTime() async throws -> [UsedTime] {
        let token = KeychainHelper.load(forKey: "accessToken") ?? ""
        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
        
        let decoder = DateDecoderFactory.iso8601WithFractionalSecondsDecoder()

        return try await AF.request(API.UsedTime.usedTime,
                                    method: .get,
                                    headers: headers)
            .validate(statusCode: 200..<300)
            .serializingDecodable([UsedTime].self, decoder: decoder)
            .value
    }
    
    static func getUsedTimeByStartEndData() async throws -> [UsedTime] {
        let token = KeychainHelper.load(forKey: "accessToken") ?? ""
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Accept": "application/json"
        ]

        let df = DateFormatter()
        df.calendar = Calendar(identifier: .gregorian)
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = TimeZone(secondsFromGMT: 0)
        df.dateFormat = "yyyy-MM-dd"

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(df)

        return try await AF.request(API.UsedTime.usedTimeRange, method: .get, headers: headers)
            .validate(statusCode: 200..<300)
            .serializingDecodable([UsedTime].self, decoder: decoder)
            .value
    }
    
    static func postUsedTime(
            usedTime: Int,
            satisfaction: Int,
            image: Data?,
            completion: @escaping (Result<Void, Error>) -> Void
        ) {
            guard let token = KeychainHelper.load(forKey: "accessToken") else {
                completion(.failure(APIError.tokenMissing))
                return
            }

            let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
            
            AF.upload(multipartFormData: { form in
                form.append(Data("\(usedTime)".utf8), withName: "used_time")
                form.append(Data("\(satisfaction)".utf8), withName: "satisfaction")
                if let imageData = image {
                    let uniqueFileName = "proof_\(UUID().uuidString).jpg"
                    form.append(imageData, withName: "image", fileName: uniqueFileName, mimeType: "image/jpeg")
                }
            }, to: API.UsedTime.usedTime /* https://.../used_time/ */, method: .post, headers: headers)
            .validate()
            .responseString { resp in
                print("status:", resp.response?.statusCode as Any)
                print("body:", resp.value ?? String(data: resp.data ?? Data(), encoding: .utf8) ?? "nil")
            }
        }
}
