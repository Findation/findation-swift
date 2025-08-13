//
//  SearchUser.swift
//  Findation
//
//  Created by Yoy0z-maps on 8/12/25.
//

import Foundation

struct FriendRequestResponse: Decodable, Identifiable {
    let id:String
    let user: FriendRequestUserResponse
    let friend: FriendRequestUserResponse
    let status: String
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, user, friend, status
        case createdAt  = "created_at"
    }
}

struct FriendRequestUserResponse: Decodable, Identifiable {
    let id: String
    let username: String
}
