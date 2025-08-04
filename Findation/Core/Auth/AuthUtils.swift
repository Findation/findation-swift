//
//  AuthUtils.swift
//  Findation
//
//  Created by Yoy0z-maps on 8/4/25.
//
import AuthenticationServices
import Foundation

struct AppleAuthService {
    static var sharedDelegate: AppleAuthDelegate?
    
    static func performAppleLogin(completion: @escaping (String?) -> Void) {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.email, .fullName]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        let delegate = AppleAuthDelegate { identityToken in
             completion(identityToken)
             sharedDelegate = nil  // 메모리 릭 방지
         }
        
        controller.delegate = delegate
        controller.presentationContextProvider = delegate
        
        AppleAuthService.sharedDelegate = delegate
        
        controller.performRequests()
    }
}
 
class AppleAuthDelegate: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    let completion: (String?) -> Void

    init(completion: @escaping (String?) -> Void) {
        self.completion = completion
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared
            .connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            fatalError("presentationAnchor: No key window found")
        }
        return window
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
           let tokenData = credential.identityToken,
           let token = String(data: tokenData, encoding: .utf8) {
            completion(token)
        } else {
            print("토큰 추출 실패")
            completion(nil)
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Apple 인증 실패: \(error.localizedDescription)")
        completion(nil)
    }
}

struct AuthAPI {
    static func loginWithApple(identityToken: String, completion: @escaping (String?, String?) -> Void) {
        guard let url = URL(string: "https://api.findation.site/users/auth/social-login/") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "provider": "apple",
            "credential": [
                "identityToken": identityToken
            ]
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, _ in
            guard
                let data = data,
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let access = json["access"] as? String,
                let refresh = json["refresh"] as? String
            else {
                completion(nil, nil)
                return
            }

            completion(access, refresh)
        }.resume()
    }
}
