//
//  AuthResponse.swift
//  Findation
//
//  Created by Yoy0z-maps on 8/4/25.
//

import Foundation

struct RefreshResponse: Decodable {
    let access: String
    let refresh: String
}
