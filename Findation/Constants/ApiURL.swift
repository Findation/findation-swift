//
//  ApiURL.swift
//  Findation
//
//  Created by Yoy0z-maps on 8/4/25.
//

import Foundation

enum API {
    static let baseURL = "https://api.findation.site"

    enum Auth {
        static let socialLogin = "\(baseURL)/users/auth/social-login/"
        static let tokenRefresh = "\(baseURL)/users/auth/token/refresh/"
        static let searchUser = "\(baseURL)/users/search/"
    }
    
    enum Routines {
        static let routineList = "\(baseURL)/routines/"
        static func routineDetail(id: String) -> String {
            return "\(baseURL)/routines/\(id)/"
        }
    }
    
    enum Friends {
        static let friends = "\(baseURL)/friends/"
        static let friendsList = "\(baseURL)/friends/list/"
        static func friendDetail (id: String) -> String {
            return "\(baseURL)/friends/\(id)/"
        }
        static func friendRoutines (id: String) -> String {
            return "\(baseURL)/friends/routines/\(id)/"
        }
    }
}
