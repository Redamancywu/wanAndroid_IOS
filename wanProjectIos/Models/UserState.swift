import Foundation
import SwiftUI

@MainActor
class UserState: ObservableObject {
    static let shared = UserState()
    
    @Published private(set) var currentUser: LoginResponse?
    @Published private(set) var isLoggedIn = false
    @AppStorage("token") private var token: String?
    
    @Published var username = "游客"
    @Published var coinCount = 0
    @Published private(set) var collectedArticles: Set<Int> = []  // 收藏的文章ID集合
    @Published var level: Int = 0
    @Published var rank: String = "--"
    
    private let userDefaults = UserDefaults.standard
    private let apiService = UserApiService.shared
    
    private init() {
        // 从 UserDefaults 恢复用户状态
        if let userData = UserDefaults.standard.data(forKey: "currentUser"),
           let user = try? JSONDecoder().decode(LoginResponse.self, from: userData) {
            self.currentUser = user
            self.isLoggedIn = true
        }
    }
    
    func login(user: LoginResponse) {
        currentUser = user
        isLoggedIn = true
        token = user.token
        username = user.nickname  // 更新用户名
        saveUserInfo(user)
        // 发送通知
        NotificationCenter.default.post(name: .userLoginStatusChanged, object: nil)
    }
    
    func logout() {
        currentUser = nil
        isLoggedIn = false
        token = nil
        username = "游客"
        coinCount = 0
        level = 0
        rank = "--"
        collectedArticles.removeAll()
        // 清除用户信息
        clearUserInfo()
        // 发送通知
        NotificationCenter.default.post(name: .userLoginStatusChanged, object: nil)
    }
    
    private func saveUserInfo(_ user: LoginResponse) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(user) {
            UserDefaults.standard.set(encoded, forKey: "currentUser")
        }
    }
    
    private func clearUserInfo() {
        UserDefaults.standard.removeObject(forKey: "currentUser")
    }
    
    func fetchUserInfo() async {
        do {
            let coinInfo = try await apiService.fetchCoinInfo()
            self.coinCount = coinInfo.coinCount
            self.level = coinInfo.level
            self.rank = coinInfo.rank
        } catch {
            print("获取用户信息失败: \(error)")
        }
    }
    
    func fetchCollectedArticles() async {
        do {
            let articles = try await apiService.fetchCollectedArticles()
            collectedArticles = Set(articles.map { $0.id })
        } catch {
            print("获取收藏列表失败: \(error)")
        }
    }
    
    func toggleCollect(articleId: Int) async throws {
        guard isLoggedIn else {
            throw ApiError.message("请先登录")
        }
        // TODO: 实现收藏/取消收藏
    }
    
    func isCollected(articleId: Int) -> Bool {
        // TODO: 实现收藏状态检查
        return false
    }
}

enum UserError: LocalizedError {
    case needLogin
    
    var errorDescription: String? {
        switch self {
        case .needLogin:
            return "需要登录"
        }
    }
} 