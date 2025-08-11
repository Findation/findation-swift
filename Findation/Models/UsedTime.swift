//
//  UserResponse.swift
//  Findation
//
//  Created by Yoy0z-maps on 8/5/25.
//

import Foundation

struct UsedTime: Decodable {
    let date: Date
    let usedTime: Int

    enum CodingKeys: String, CodingKey {
        case date
        case usedTime = "used_time"
    }
}
