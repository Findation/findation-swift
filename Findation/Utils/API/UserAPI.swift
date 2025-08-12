import Alamofire

enum UserAPI {
    static func signUp(email: String, password: String, nickname: String) async throws -> AuthResponse {
        let params = ["email": email, "password": password, "nickname": nickname]
        let headers: HTTPHeaders = ["Accept": "application/json", "Content-Type": "application/json"]

        return try await AF.request(Findation.API.User.signUp,
                                    method: .post,
                                    parameters: params,
                                    encoding: JSONEncoding.default,
                                    headers: headers)
            .validate(statusCode: 200..<300)
            .serializingDecodable(AuthResponse.self)
            .value
    }

    static func signIn(email: String, password: String) async throws -> AuthResponse {
        let params = ["email": email, "password": password]
        let headers: HTTPHeaders = ["Accept": "application/json", "Content-Type": "application/json"]

        return try await AF.request(API.User.signIn,
                                    method: .post,
                                    parameters: params,
                                    encoding: JSONEncoding.default,
                                    headers: headers)
            .validate(statusCode: 200..<300)
            .serializingDecodable(AuthResponse.self)
            .value
    }

    static func searchUser(nickname: String) async throws -> [SearchUser] {
        let token = KeychainHelper.load(forKey: "accessToken") ?? ""
        
        let params = ["nickname": nickname]
        let headers: HTTPHeaders = ["Authorization": "Bearer \(token)"]

        return try await AF.request(API.User.searchUser,
                                    method: .get,
                                    parameters: params,
                                    encoding: URLEncoding.default,
                                    headers: headers)
            .validate(statusCode: 200..<300)
            .serializingDecodable([SearchUser].self)
            .value
    }

    static func refreshAccessToken(refreshToken: String) async throws -> RefreshResponse {
        let params = ["refresh": refreshToken]
        let headers: HTTPHeaders = ["Accept": "application/json", "Content-Type": "application/json"]

        return try await AF.request(API.User.refreshToken,
                                    method: .post,
                                    parameters: params,
                                    encoding: JSONEncoding.default,
                                    headers: headers)
            .validate(statusCode: 200..<300)
            .serializingDecodable(RefreshResponse.self)
            .value
    }
}
