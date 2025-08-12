//
//  FriendsAPI.swift
//  Findation
//
//  Created by Yoy0z-maps on 8/6/25.
//

import Foundation
import Alamofire

enum FriendsAPI {
    // 친구 추가
    static func addFriend(accessToken: String, friendID: Int) async throws {
        let params = ["friend_id": friendID]
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
        
        try await AF.request("http://findation-backend/api/friends/",
                            method: .post,
                            parameters: params,
                            encoding: JSONEncoding.default,
                            headers: headers)
            .validate(statusCode: 200..<300)
            .serializingData()  // 응답 데이터가 필요 없으면 Data로 처리
            .value
    }
    
    // 친구 목록 조회
    static func fetchFriends(accessToken: String) async throws -> [Friend] {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)",
            "Accept": "application/json"
        ]
        
        return try await AF.request("http://findation-backend/api/users/",
                                   method: .get,
                                   headers: headers)
            .validate(statusCode: 200..<300)
            .serializingDecodable([Friend].self)
            .value
    }
}

