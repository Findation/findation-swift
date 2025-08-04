//
//  SessionStore.swift
//  Findation
//
//  Created by Yoy0z-maps on 8/4/25.
//

import Combine
import Foundation

class SessionStore: ObservableObject {
    @Published var isAuthenticated: Bool = false
    
    let ACCESS_TOKEN = "accessToken"
    let REFRESH_TOKEN = "refreshToken"
    
    init() {
        checkAuthentication()
    }
    
    func checkAuthentication() {
           if let token = KeychainHelper.load(forKey: ACCESS_TOKEN) {
               // 옵션: 만료 검사 로직도 가능 (ex. decode JWT, exp 체크)
               isAuthenticated = true
           } else {
               isAuthenticated = false
           }
       }

    func login(accessToken: String, refreshToken: String) {
        KeychainHelper.save(accessToken, forKey: ACCESS_TOKEN)
        KeychainHelper.save(refreshToken, forKey: REFRESH_TOKEN)
        DispatchQueue.main.async {
            self.isAuthenticated = true
        }
    }

       func logout() {
           KeychainHelper.delete(forKey: ACCESS_TOKEN)
           KeychainHelper.delete(forKey: REFRESH_TOKEN)
           isAuthenticated = false
       }

    func refreshTokenIfNeeded() {
        guard let savedRefreshToken = KeychainHelper.load(forKey: REFRESH_TOKEN) else {
            // 에러 처리 필요함
            return
        }
        
        
        
        var request = URLRequest(url: URL(string: "https://api.findation.site/users/auth/token/refresh/")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(["refresh": savedRefreshToken])
        
        URLSession.shared.dataTask(with: request) { data, response, _ in
            guard
                let data = data,
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let newAccess = json["access"] as? String,
                let newRefresh = json["refresh"] as? String
            else {
                // 에러 처리 필요함
                return
            }
            
            KeychainHelper.save(newAccess, forKey: self.ACCESS_TOKEN)
            KeychainHelper.save(newRefresh, forKey: self.REFRESH_TOKEN)
//            DispatchQueue.main.async {
//                //completion(true)
//            }
        }.resume()
    }
}
