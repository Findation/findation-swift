//
//  FriendsAPI.swift
//  Findation
//
//  Created by Yoy0z-maps on 8/6/25.
//

import Foundation
import Alamofire

enum FriendsAPI {
    static func getRequestList() async throws -> [FriendRequestResponse] {
        let token = KeychainHelper.load(forKey: "accessToken") ?? ""
        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
        
        let decoder = DateDecoderFactory.iso8601WithFractionalSecondsDecoder()
        
        return try await AF.request(API.Friends.friends,
                            method: .get,
                            headers: headers)
            .validate(statusCode: 200..<300)
            .serializingDecodable([FriendRequestResponse].self, decoder: decoder)
            .value
    }
    
    static func addFriend(friendID: String) async throws {
        let token = KeychainHelper.load(forKey: "accessToken") ?? ""
        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
        
        let params = ["friend_id": friendID]
        
        let result = try await AF.request(API.Friends.friends,
                            method: .post,
                            parameters: params,
                            encoding: JSONEncoding.default,
                            headers: headers)
            .validate(statusCode: 200..<300)
            .serializingData()
            .value
        print(result)
    }
    
    enum FriendAction: String { case accept, reject }
    
    static func fetchFriends(requestId: String, action: FriendAction) async throws {
        let token = KeychainHelper.load(forKey: "accessToken") ?? ""
        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
        
        let payload = ["action": action.rawValue]
        
        let request = AF.request(
               API.Friends.friendDetail(id: requestId),
               method: .patch,
               parameters: payload,
               encoding: JSONEncoding.default,
               headers: headers
           )
           // 응답 받기
           let response = await request.validate().serializingData().response

           // 상태/헤더/본문 로깅
           let status = response.response?.statusCode ?? -1
           let headersOut = response.response?.allHeaderFields ?? [:]
           let data = response.data ?? Data()

           print("STATUS:", status)
           print("HEADERS:", headersOut)

           // 1) UTF-8 시도
           if let s = String(data: data, encoding: .utf8) { print("BODY(utf8):", s) }
           else {
               // 2) 손실복구 디코딩(대부분의 바이너리도 대충 문자열화됨)
               let s = String(decoding: data, as: UTF8.self)
               print("BODY(lossy):", s)
               print("BYTES:", data.count) // 정말 문자열이 아니면 여기만 의미 있음
           }

           // 2xx면 성공 처리로 리턴
           guard (200..<300).contains(status) else {
               throw URLError(.badServerResponse)
           }
    }
    
    static func getFriendsList() async throws -> [SearchUser] {
        let token = KeychainHelper.load(forKey: "accessToken") ?? ""
        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]
        
        let decoder = DateDecoderFactory.iso8601WithFractionalSecondsDecoder()
        
        return try await AF.request(API.Friends.friendsList,
                            method: .get,
                            headers: headers)
            .validate(statusCode: 200..<300)
            .serializingDecodable([SearchUser].self, decoder: decoder)
            .value
    }
}

