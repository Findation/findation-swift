//
//  RoutineResponse.swift
//  Findation
//
//  Created by Yoy0z-maps on 8/5/25.
//

import Foundation

struct Routine: Codable, Identifiable {
    let id: UUID
    let title: String
    let category: String
    let isRepeated: Int
    let createdAt: Date
    let user: UUID

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case category
        case isRepeated = "is_repeated"
        case createdAt = "created_at"
        case user
    }
}
