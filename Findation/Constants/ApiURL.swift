//
//  ApiURL.swift
//  Findation
//
//  Created by Yoy0z-maps on 8/4/25.
//

import Foundation

enum API {
    static let baseURL = "https://api.findation.site"

    enum User {
        static let signUp = "\(baseURL)/users/auth/register/"
        static let signIn = "\(baseURL)/users/auth/login/"
        static let refreshToken = "\(baseURL)/users/auth/token/refresh/"
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
