//
//  UserResponse.swift
//  Findation
//
//  Created by Yoy0z-maps on 8/5/25.
//

import Foundation

struct UserResponse: Decodable {
    let access: String
    let refresh: String
    let user: User
    let isNewUser: Bool

    enum CodingKeys: String, CodingKey {
        case access
        case refresh
        case user
        case isNewUser = "is_new_user"
    }
}
