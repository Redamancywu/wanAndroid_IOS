import Foundation

class UserApiService {
    static let shared = UserApiService()
    private let apiService = ApiService.shared
    
    private init() {}
    
    // 登录
    func login(username: String, password: String) async throws -> LoginResponse {
        let parameters: [String: Any] = [
            "username": username,
            "password": password
        ]
        
        let response: ApiResponse<LoginResponse> = try await apiService.request(
            "/user/login",
            method: .post,
            parameters: parameters,
            responseType: ApiResponse<LoginResponse>.self,
            encoding: .urlEncoded
        )
        
        if response.errorCode == 0 {
            return response.data
        } else {
            throw ApiError.message(response.errorMsg)
        }
    }
    
    // 注册
    func register(username: String, password: String, repassword: String) async throws -> LoginResponse {
        print("发送注册请求") // 调试输出
        print("参数：username=\(username), password=\(password), repassword=\(repassword)") // 调试输出
        
        let parameters: [String: String] = [
            "username": username,
            "password": password,
            "repassword": repassword
        ]
        
        let response: ApiResponse<LoginResponse> = try await apiService.request(
            "/user/register",
            method: .post,
            parameters: parameters,
            responseType: ApiResponse<LoginResponse>.self,
            encoding: .urlEncoded
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
    
    // 获取用户积分信息
    func fetchCoinInfo() async throws -> CoinInfo {
        let response: ApiResponse<CoinInfo> = try await apiService.request(
            "/lg/coin/userinfo/json",
            method: .get,
            responseType: ApiResponse<CoinInfo>.self
        )
        
        if response.errorCode == 0 {
            return response.data
        } else {
            throw ApiError.message(response.errorMsg)
        }
    }
    
    // 收藏文章
    func collectArticle(id: Int) async throws {
        let response: ApiResponse<EmptyResponse> = try await apiService.request(
            "/lg/collect/\(id)/json",
            method: .post,
            responseType: ApiResponse<EmptyResponse>.self
        )
        
        if response.errorCode != 0 {
            throw ApiError.message(response.errorMsg)
        }
    }
    
    // 取消收藏
    func uncollectArticle(id: Int) async throws {
        let response: ApiResponse<EmptyResponse> = try await apiService.request(
            "/lg/uncollect_originId/\(id)/json",
            method: .post,
            responseType: ApiResponse<EmptyResponse>.self
        )
        
        if response.errorCode != 0 {
            throw ApiError.message(response.errorMsg)
        }
    }
    
    // 获取收藏列表
    func fetchCollectedArticles() async throws -> [Article] {
        let response: ApiResponse<ArticleList> = try await apiService.request(
            "/lg/collect/list/0/json",
            method: .get,
            responseType: ApiResponse<ArticleList>.self
        )
        
        if response.errorCode == 0 {
            return response.data.datas
        } else {
            throw ApiError.message(response.errorMsg)
        }
    }
    
    // 获取积分记录
    func fetchCoinRecords(page: Int = 1) async throws -> [CoinRecord] {
        let response: ApiResponse<CoinRecordList> = try await apiService.request(
            "/lg/coin/list/\(page)/json",
            method: .get,
            responseType: ApiResponse<CoinRecordList>.self
        )
        
        if response.errorCode == 0 {
            return response.data.datas
        } else {
            throw ApiError.message(response.errorMsg)
        }
    }
}

// 积分记录列表响应
struct CoinRecordList: Codable {
    let curPage: Int
    let datas: [CoinRecord]
    let offset: Int
    let over: Bool
    let pageCount: Int
    let size: Int
    let total: Int
}   
