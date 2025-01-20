import Foundation

class UserApiService {
    static let shared = UserApiService()
    private let networkManager = NetworkManager.shared
    
    private init() {}
    
    func login(username: String, password: String) async throws -> User {
        return try await withCheckedThrowingContinuation { continuation in
            let parameters = [
                "username": username,
                "password": password
            ]
            
            networkManager.request("/user/login",
                                 method: .post,
                                 parameters: parameters) { (result: Result<LoginResponse, NetworkError>) in
                switch result {
                case .success(let response):
                    if response.errorCode == 0 {
                        continuation.resume(returning: response.data)
                    } else {
                        continuation.resume(throwing: ApiError.message(response.errorMsg))
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func register(username: String, password: String, repassword: String) async throws -> User {
        return try await withCheckedThrowingContinuation { continuation in
            let parameters = [
                "username": username,
                "password": password,
                "repassword": repassword
            ]
            
            networkManager.request("/user/register",
                                 method: .post,
                                 parameters: parameters) { (result: Result<LoginResponse, NetworkError>) in
                switch result {
                case .success(let response):
                    if response.errorCode == 0 {
                        continuation.resume(returning: response.data)
                    } else {
                        continuation.resume(throwing: ApiError.message(response.errorMsg))
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func logout() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            networkManager.request("/user/logout/json",
                                 method: .get) { (result: Result<BaseResponse, NetworkError>) in
                switch result {
                case .success(let response):
                    if response.errorCode == 0 {
                        continuation.resume()
                    } else {
                        continuation.resume(throwing: ApiError.message(response.errorMsg))
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // 获取用户积分信息
    func fetchCoinInfo() async throws -> CoinInfo {
        return try await withCheckedThrowingContinuation { continuation in
            networkManager.request("/lg/coin/userinfo/json",
                                 method: .get) { (result: Result<CoinInfoResponse, NetworkError>) in
                switch result {
                case .success(let response):
                    if response.errorCode == 0 {
                        continuation.resume(returning: response.data)
                    } else {
                        continuation.resume(throwing: ApiError.message(response.errorMsg))
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // 收藏文章
    func collectArticle(id: Int) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            networkManager.request("/lg/collect/\(id)/json",
                                 method: .post) { (result: Result<BaseResponse, NetworkError>) in
                switch result {
                case .success(let response):
                    if response.errorCode == 0 {
                        continuation.resume()
                    } else {
                        continuation.resume(throwing: ApiError.message(response.errorMsg))
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // 取消收藏
    func uncollectArticle(id: Int) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            networkManager.request("/lg/uncollect_originId/\(id)/json",
                                 method: .post) { (result: Result<BaseResponse, NetworkError>) in
                switch result {
                case .success(let response):
                    if response.errorCode == 0 {
                        continuation.resume()
                    } else {
                        continuation.resume(throwing: ApiError.message(response.errorMsg))
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // 获取收藏列表
    func fetchCollectedArticles() async throws -> [CollectionArticle] {
        return try await withCheckedThrowingContinuation { continuation in
            networkManager.request("/lg/collect/list/0/json",
                                 method: .get) { (result: Result<CollectionListResponse, NetworkError>) in
                switch result {
                case .success(let response):
                    if response.errorCode == 0 {
                        continuation.resume(returning: response.data.datas)
                    } else {
                        continuation.resume(throwing: ApiError.message(response.errorMsg))
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // 获取积分记录
    func fetchCoinRecords(page: Int = 1) async throws -> [CoinRecord] {
        return try await withCheckedThrowingContinuation { continuation in
            networkManager.request("/lg/coin/list/\(page)/json",
                                 method: .get) { (result: Result<CoinRecordResponse, NetworkError>) in
                switch result {
                case .success(let response):
                    if response.errorCode == 0 {
                        continuation.resume(returning: response.data.datas)
                    } else {
                        continuation.resume(throwing: ApiError.message(response.errorMsg))
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

enum ApiError: Error {
    case message(String)
}

extension ApiError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .message(let message):
            return message
        }
    }
} 