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
    @Published private(set) var collectedArticles: [Article] = []
    
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
            HiLog.i("用户登录成功，用户名：\(username)")
            
            // 检查 Cookie
            if let cookies = HTTPCookieStorage.shared.cookies {
                HiLog.i("登录后的 Cookies: \(cookies)")
                for cookie in cookies {
                    HiLog.i("Cookie: \(cookie.name) = \(cookie.value)")
                }
            } else {
                HiLog.e("登录后没有找到 Cookie")
            }
            
            await loadCollectedArticles()
            await fetchUserInfo()
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
    func loadCollectedArticles() async {
        do {
            let articleList = try await apiService.fetchCollectedArticles()
            collectedArticles = articleList.datas
            HiLog.i("加载收藏文章成功，数量：\(collectedArticles.count)")
        } catch {
            HiLog.e("加载收藏文章失败: \(error)")
        }
    }
    
    /// 收藏或取消收藏文章
    func toggleCollect(article: Article) async throws {
        HiLog.i("开始\(article.collect ? "取消收藏" : "收藏")文章: \(article.title)")
        
        do {
            if article.collect {
                if let originId = article.originId {
                    // 从收藏页面取消收藏
                    try await apiService.uncollectFromMyCollections(article.id, originId: originId)
                    collectedArticles.removeAll { $0.id == article.id }
                } else {
                    // 从文章列表取消收藏
                    try await apiService.uncollectFromList(article.id)
                }
                HiLog.i("取消收藏成功")
            } else {
                // 收藏文章
                try await apiService.collectInternalArticle(article.id)
                // 创建新的文章对象，设置 collect 为 true
                let collectedArticle = Article(
                    id: article.id,
                    title: article.title,
                    desc: article.desc,
                    link: article.link,
                    author: article.author,
                    shareUser: article.shareUser,
                    niceDate: article.niceDate,
                    publishTime: article.publishTime,
                    collect: true,
                    superChapterName: article.superChapterName,
                    chapterName: article.chapterName,
                    type: article.type,
                    fresh: article.fresh,
                    tags: article.tags,
                    envelopePic: article.envelopePic,
                    projectLink: article.projectLink,
                    apkLink: article.apkLink,
                    prefix: article.prefix,
                    originId: article.id  // 设置原始文章ID
                )
                collectedArticles.append(collectedArticle)
                HiLog.i("收藏成功")
            }
            
            // 发送收藏状态变化通知
            NotificationCenter.default.post(name: .articleCollectionChanged, object: nil)
            
        } catch {
            HiLog.e("收藏操作失败: \(error)")
            throw error
        }
    }
    
    /// 检查文章是否已收藏
    func isCollected(articleId: Int) -> Bool {
        collectedArticles.contains { $0.id == articleId }
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