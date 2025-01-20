import Foundation

@MainActor
class UserState: ObservableObject {
    static let shared = UserState()
    
    @Published var isLoggedIn = false
    @Published var username = "游客"
    @Published var coinCount = 0
    @Published private(set) var collectedArticles: Set<Int> = []  // 收藏的文章ID集合
    @Published var level: Int = 0
    @Published var rank: String = "--"
    
    private let userDefaults = UserDefaults.standard
    private let apiService = UserApiService.shared
    
    private init() {
        // 检查是否有保存的用户信息
        if let savedUsername = userDefaults.string(forKey: "username") {
            self.username = savedUsername
            self.isLoggedIn = true
        }
    }
    
    func login(username: String, password: String) async throws {
        let user = try await apiService.login(username: username, password: password)
        self.isLoggedIn = true
        self.username = user.username
        
        // 保存用户信息
        userDefaults.set(username, forKey: "username")
        await fetchUserInfo()
        await fetchCollectedArticles()
    }
    
    func register(username: String, password: String, repassword: String) async throws {
        let user = try await apiService.register(username: username, password: password, repassword: repassword)
        
        // 注册成功后，直接设置登录状态
        self.isLoggedIn = true
        self.username = user.username
        
        // 保存用户信息
        userDefaults.set(username, forKey: "username")
        
        // 获取用户其他信息
        await fetchUserInfo()
        await fetchCollectedArticles()
        
        // 发送登录状态变化通知
        NotificationCenter.default.post(name: .userLoginStatusChanged, object: nil)
    }
    
    func logout() async {
        do {
            try await apiService.logout()
        } catch {
            print("登出失败: \(error)")
        }
        
        // 无论服务器响应如何，都清除本地状态
        isLoggedIn = false
        username = "游客"
        coinCount = 0
        collectedArticles.removeAll()
        
        // 清除保存的用户信息
        userDefaults.removeObject(forKey: "username")
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
            throw UserError.needLogin
        }
        
        if collectedArticles.contains(articleId) {
            try await apiService.uncollectArticle(id: articleId)
            collectedArticles.remove(articleId)
        } else {
            try await apiService.collectArticle(id: articleId)
            collectedArticles.insert(articleId)
        }
    }
    
    func isCollected(articleId: Int) -> Bool {
        collectedArticles.contains(articleId)
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