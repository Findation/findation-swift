//
//  SessionStore.swift
//  Findation
//
//  Created by Yoy0z-maps on 8/4/25.
//

import Combine
import Foundation
import Alamofire

class SessionStore: ObservableObject {
    @Published var isAuthenticated: Bool = false
    
    let ACCESS_TOKEN = "accessToken"
    let REFRESH_TOKEN = "refreshToken"
    
    init() {
        checkAuthentication()
    }
    
    func checkAuthentication() {
        if KeychainHelper.load(forKey: ACCESS_TOKEN) != nil {
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
            self.logout()
            return
        }
        
        let params = ["refresh": savedRefreshToken]

        AF.request(API.Auth.tokenRefresh, method: .post, parameters: params, encoder: JSONParameterEncoder.default)
            .validate()
            .responseDecodable(of: RefreshResponse.self) { response in
                switch response.result {
                case .success(let data):
                    KeychainHelper.save(data.access, forKey: self.ACCESS_TOKEN)
                    KeychainHelper.save(data.refresh, forKey: self.REFRESH_TOKEN)
                    DispatchQueue.main.async {
                        self.isAuthenticated = true
                        //completion(true)
                    }
                case .failure(_):
                    DispatchQueue.main.async {
                        self.logout()
                        //completion(false)
                    }
                }
            }
    }
}
