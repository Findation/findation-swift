//
//  AuthUtils.swift
//  Findation
//
//  Created by Yoy0z-maps on 8/4/25.
//
import AuthenticationServices
import Foundation
import Alamofire

struct AppleAuthService {
    static var sharedDelegate: AppleAuthDelegate?
    
    static func performAppleLogin(completion: @escaping (String?) -> Void) {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.email, .fullName]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        let delegate = AppleAuthDelegate { identityToken in
             completion(identityToken)
             sharedDelegate = nil
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
        let parameters: [String: Any] = [
            "provider": "apple",
            "credential": [
                "identityToken": identityToken
            ]
        ]
        
        AF.request(API.Auth.socialLogin,
                           method: .post,
                           parameters: parameters,
                           encoding: JSONEncoding.default,
                           headers: ["Content-Type": "application/json"])
                .validate()
                .responseDecodable(of: UserResponse.self) { response in
                    switch response.result {
                    case .success(let token):
                        completion(token.access, token.refresh)
                    case .failure(_):
                        completion(nil, nil)
                    }
                }
    }
}
