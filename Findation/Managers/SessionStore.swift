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
    
    let accessToken = "accessToken"
    let refreshToken = "refreshToken"
    
    init() {
        checkAuthentication()
    }
    
    func checkAuthentication() {
           if let token = KeychainHelper.load(forKey: accessToken) {
               // 옵션: 만료 검사 로직도 가능 (ex. decode JWT, exp 체크)
               isAuthenticated = true
           } else {
               isAuthenticated = false
           }
       }

    func login(accessToken: String, refreshToken: String) {
        KeychainHelper.save(accessToken, forKey: accessToken)
        KeychainHelper.save(refreshToken, forKey: refreshToken)
        
        DispatchQueue.main.async {
            self.isAuthenticated = true
        }
    }

       func logout() {
           KeychainHelper.delete(forKey: accessToken)
           KeychainHelper.delete(forKey: refreshToken)
           isAuthenticated = false
       }

       func refreshTokenIfNeeded(completion: @escaping (Bool) -> Void) {
//           guard let savedRefreshToken = KeychainHelper.load(forKey: self.refreshToken) else {
//               completion(false)
//               return
//           }
//           
//           print("refreshToken", savedRefreshToken)
//           
//           var request = URLRequest(url: URL(string: "https://api.findation.site/users/auth/token/refresh/")!)
//           request.httpMethod = "POST"
//           request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//           request.httpBody = try? JSONEncoder().encode(["refresh": savedRefreshToken])
//
//           URLSession.shared.dataTask(with: request) { data, response, _ in
//               guard
//                   let data = data,
//                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
//                   let newAccess = json["access"] as? String
//               else {
//                   DispatchQueue.main.async {
//                       self.logout()
//                       completion(false)
//                   }
//                   return
//               }
//
//               KeychainHelper.save(newAccess, forKey: self.accessToken)
//               DispatchQueue.main.async {
//                   completion(true)
//               }
//           }.resume()
       }
    
}
