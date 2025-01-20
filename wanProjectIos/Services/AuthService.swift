import Foundation

@MainActor
class AuthService {
    static let shared = AuthService()
    private let apiService = ApiService.shared
    
    private init() {}
    
    // 登录
    func login(username: String, password: String) async throws -> LoginResponse {
        let parameters: [String: Any] = [
            "username": username,
            "password": password
        ]
        
        let response = try await apiService.request(
            "/user/login",
            method: .post,
            parameters: parameters,
            responseType: ApiResponse<LoginResponse>.self
        )
        
        if response.errorCode == 0 {
            return response.data
        } else {
            throw ApiError.message(response.errorMsg)
        }
    }
    
    // 注册
    func register(username: String, password: String, repassword: String) async throws -> LoginResponse {
        let parameters: [String: Any] = [
            "username": username,
            "password": password,
            "repassword": repassword
        ]
        
        let response = try await apiService.request(
            "/user/register",
            method: .post,
            parameters: parameters,
            responseType: ApiResponse<LoginResponse>.self
        )
        
        if response.errorCode == 0 {
            return response.data
        } else {
            throw ApiError.message(response.errorMsg)
        }
    }
    
    // 登出
    func logout() async throws {
        let response: ApiResponse<EmptyResponse> = try await apiService.request(
            "/user/logout/json",
            method: .get,
            responseType: ApiResponse<EmptyResponse>.self
        )
        
        if response.errorCode != 0 {
            throw ApiError.message(response.errorMsg)
        }
    }
} 
