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
    let LAST_REFRESH_AT = "LAST_REFRESH_AT"
    
    init() {
        checkAuthentication()
    }
    
    private func jwtExpiry(from jwt: String) -> Date? {

        let parts = jwt.split(separator: ".")
        guard parts.count >= 2 else { return nil }

        func base64urlToData(_ s: Substring) -> Data? {
            var str = String(s)
            str = str.replacingOccurrences(of: "-", with: "+")
                     .replacingOccurrences(of: "_", with: "/")
            let pad = 4 - (str.count % 4)
            if pad < 4 { str.append(String(repeating: "=", count: pad)) }
            return Data(base64Encoded: str)
        }

        guard let payloadData = base64urlToData(parts[1]),
              let json = try? JSONSerialization.jsonObject(with: payloadData) as? [String: Any],
              let exp = json["exp"] as? TimeInterval
        else { return nil }

        return Date(timeIntervalSince1970: exp)
    }
    
    private func loadLastRefreshAt() -> Date? {
        guard let s = UserDefaults.standard.string(forKey: LAST_REFRESH_AT) else { return nil }
        return ISO8601DateFormatter().date(from: s)
    }

    private func saveLastRefreshAt(_ date: Date = Date()) {
        let s = ISO8601DateFormatter().string(from: date)
        UserDefaults.standard.set(s, forKey: LAST_REFRESH_AT)
    }
    
    private func shouldRefreshNow(accessToken: String?) -> Bool {
        let now = Date()

        if let token = accessToken, let exp = jwtExpiry(from: token) {
            if exp <= now.addingTimeInterval(5 * 60) {
                return true
            }
        }

        if let last = loadLastRefreshAt() {
            if now.timeIntervalSince(last) >= 24 * 60 * 60 {
                return true
            } else {
                return false
            }
        } else {
            return true
        }
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

    func refreshTokenIfNeeded() async {
        guard let savedRefreshToken = KeychainHelper.load(forKey: REFRESH_TOKEN),
                !savedRefreshToken.isEmpty else {
            await MainActor.run { self.logout() }
            return
        }
        
        let access = KeychainHelper.load(forKey: ACCESS_TOKEN)

        guard shouldRefreshNow(accessToken: access) else {
            await MainActor.run { self.isAuthenticated = (access != nil) }
            return
        }
        
        do {
            struct RefreshResponse: Decodable { let access: String; let refresh: String }
                let params = ["refresh": savedRefreshToken]

                let res = try await AF.request(
                    API.User.refreshToken,
                    method: .post,
                    parameters: params,
                    encoding: JSONEncoding.default
                )
                .validate(statusCode: 200..<300)
                .serializingDecodable(RefreshResponse.self)
                .value

                KeychainHelper.save(res.access, forKey: ACCESS_TOKEN)
                KeychainHelper.save(res.refresh, forKey: REFRESH_TOKEN)

                await MainActor.run { self.isAuthenticated = true }
            } catch {
                await MainActor.run { self.logout() }
            }
    }
}
