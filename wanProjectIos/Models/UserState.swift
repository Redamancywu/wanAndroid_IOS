import Foundation
import SwiftUI

extension Notification.Name {
    static let articleCollectionChanged = Notification.Name("articleCollectionChanged")
}

@MainActor
class UserState: ObservableObject {
    static let shared = UserState()
    
    // MARK: - Published Properties
    @Published private(set) var currentUser: LoginResponse?
    @Published private(set) var isLoggedIn = false
    @Published var username = "游客"
    @Published var coinCount = 0
    @Published var level: Int = 0
    @Published var rank: String = "--"
    @Published private(set) var collectedArticles: Set<Int> = []
    
    // MARK: - Private Properties
    @AppStorage("token") private var token: String?
    private let userDefaults = UserDefaults.standard
    private let apiService = ApiService.shared
    
    // MARK: - Initialization
    private init() {
        restoreUserState()
    }
    
    // MARK: - User State Management
    private func restoreUserState() {
        if let userData = userDefaults.data(forKey: "currentUser"),
           let user = try? JSONDecoder().decode(LoginResponse.self, from: userData) {
            currentUser = user
            isLoggedIn = true
            username = user.nickname
            
            // 恢复用户状态后加载收藏列表
            Task {
                await loadCollectedArticles()
                await fetchUserInfo()
            }
        }
    }
    
    func login(user: LoginResponse) {
        currentUser = user
        isLoggedIn = true
        token = user.token
        username = user.nickname
        saveUserInfo(user)
        
        // 登录后加载用户数据
        Task {
            HiLog.i("用户登录成功，开始加载用户数据")
            await loadCollectedArticles()
            await fetchUserInfo()
            
            // 打印 Cookie 状态
            if let cookies = HTTPCookieStorage.shared.cookies {
                HiLog.i("登录后的 Cookies: \(cookies)")
            }
        }
        
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
        clearUserInfo()
        
        NotificationCenter.default.post(name: .userLoginStatusChanged, object: nil)
    }
    
    // MARK: - User Info Management
    private func saveUserInfo(_ user: LoginResponse) {
        if let encoded = try? JSONEncoder().encode(user) {
            userDefaults.set(encoded, forKey: "currentUser")
        }
    }
    
    private func clearUserInfo() {
        userDefaults.removeObject(forKey: "currentUser")
    }
    
    func fetchUserInfo() async {
        do {
            let coinInfo = try await apiService.fetchCoinInfo()
            self.coinCount = coinInfo.coinCount
            self.level = coinInfo.level
            self.rank = coinInfo.rank
        } catch {
            HiLog.e("获取用户信息失败: \(error)")
        }
    }
    
    // MARK: - Collection Management
    /// 加载收藏文章列表
    func loadCollectedArticles(page: Int = 0, pageSize: Int? = nil) async {
        guard isLoggedIn else { return }
        
        do {
            let articleList = try await apiService.fetchCollectedArticles(page: page, pageSize: pageSize)
            let newIds = Set(articleList.datas.map { $0.id })
            
            if page == 0 {
                collectedArticles = newIds
            } else {
                collectedArticles.formUnion(newIds)
            }
            HiLog.i("更新本地收藏状态成功，数量：\(collectedArticles.count)")
        } catch {
            HiLog.e("加载收藏列表失败: \(error)")
        }
    }
    
    /// 切换文章收藏状态
    func toggleCollect(articleId: Int) async throws {
        guard isLoggedIn else { throw UserError.needLogin }
        
        do {
            if isCollected(articleId: articleId) {
                try await apiService.uncollectFromList(articleId)
                collectedArticles.remove(articleId)
                HiLog.i("取消收藏成功")
            } else {
                try await apiService.collectInternalArticle(articleId)
                collectedArticles.insert(articleId)
                HiLog.i("收藏成功")
            }
            
            // 发送收藏状态变化通知
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                NotificationCenter.default.post(name: .articleCollectionChanged, object: nil)
            }
        } catch {
            HiLog.e("收藏操作失败: \(error)")
            throw error
        }
    }
    
    /// 检查文章是否已收藏
    func isCollected(articleId: Int) -> Bool {
        collectedArticles.contains(articleId)
    }
}

// MARK: - Error Types
enum UserError: LocalizedError {
    case needLogin
    
    var errorDescription: String? {
        switch self {
        case .needLogin:
            return "需要登录"
        }
    }
} 