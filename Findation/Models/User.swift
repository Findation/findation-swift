//
//  User.swift
//  Findation
//
//  Created by Yoy0z-maps on 8/4/25.
//

import Foundation

struct User: Decodable {
    let id: String
    let email: String
    let nickname: String
    let rank: Int
    let totalTime: Double
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case nickname
        case rank
        case totalTime = "total_time"
        case createdAt = "created_at"
    }
}
