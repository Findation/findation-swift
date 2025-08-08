import Alamofire

enum UserAPI {
    static func signUp(email: String, password: String, nickname: String) async throws -> AuthResponse {
        let params = ["email": email, "password": password, "nickname": nickname]
        let headers: HTTPHeaders = ["Accept": "application/json", "Content-Type": "application/json"]

        return try await AF.request(API.User.signUp,
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

    static func searchUser(with accessToken: String, nickname: String) async throws -> [User] {
        let params = ["nickname": nickname]
        let headers: HTTPHeaders = ["Authorization": "Bearer \(accessToken)"]

        // GET은 보통 query string → URLEncoding
        return try await AF.request(API.User.searchUser,
                                    method: .get,
                                    parameters: params,
                                    encoding: URLEncoding.default,
                                    headers: headers)
            .validate(statusCode: 200..<300)
            .serializingDecodable([User].self)
            .value
    }

    static func refreshAccessToken(refreshToken: String) async throws -> RefreshResponse {
        // DRF SimpleJWT는 기본적으로 키가 "refresh"
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
