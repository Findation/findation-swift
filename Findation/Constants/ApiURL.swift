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
    }
    
    enum Routines {
        static let routineList = "\(baseURL)/routines/"
        static func routineDetail(id: String) -> String {
            return "\(baseURL)/routines/\(id)/"
        }
    }
}
