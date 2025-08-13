//
//  SearchUser.swift
//  Findation
//
//  Created by Yoy0z-maps on 8/12/25.
//

import Foundation

struct SearchUser: Decodable, Identifiable {
    let id:String
    let nickname: String
    let total_time: Float?
}

extension SearchUser {
    var totalSeconds: Int { Int(total_time ?? 0) }      // 서버 값(초) → Int
    var timeInterval: TimeInterval { TimeInterval(totalSeconds) }
    var timeString: String {
        let h = totalSeconds / 3600
        let m = (totalSeconds % 3600) / 60
        let s = totalSeconds % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }
}
