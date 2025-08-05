//
//  User.swift
//  Findation
//
//  Created by Yoy0z-maps on 8/4/25.
//

import Foundation

struct User: Decodable {
    let id: String
    let username: String
    let provider: String
    let rank: Int
    let totalTime: Double
    let createdAt: String
    let socialId: String?
    let socialEmail: String?

    enum CodingKeys: String, CodingKey {
        case id
        case username
        case provider
        case rank
        case totalTime = "total_time"
        case createdAt = "created_at"
        case socialId = "social_id"
        case socialEmail = "social_email"
    }
}
