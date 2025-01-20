import Foundation

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var username = "游客"
    @Published var coinCount = 0
    @Published var level = 0
    @Published var rank = "--"
    @Published var isLoggedIn = false
    @Published var showLoginSheet = false
    @Published var showLoginAlert = false
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    // 登录表单数据
    @Published var loginUsername = ""
    @Published var loginPassword = ""
    
    // 注册表单数据
    @Published var registerUsername = ""
    @Published var registerPassword = ""
    @Published var registerConfirmPassword = ""
    
    private let userState = UserState.shared
    private let authService = AuthService.shared
    private let userApiService = UserApiService.shared
    
    init() {
        // 监听用户状态变化
        setupObservers()
        
        // 如果已登录，获取用户信息
        if userState.isLoggedIn {
            Task {
                await fetchUserInfo()
            }
        }
    }
    
    private func setupObservers() {
        // 监听登录状态变化
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLoginStatusChanged),
            name: .userLoginStatusChanged,
            object: nil
        )
    }
    
    @objc private func handleLoginStatusChanged() {
        isLoggedIn = userState.isLoggedIn
        if isLoggedIn {
            Task {
                await fetchUserInfo()
            }
        }
    }
    
    func showLogin() {
        showLoginSheet = true
    }
    
    func login(username: String, password: String) async throws {
        let response = try await authService.login(username: username, password: password)
        userState.login(user: response)
        await fetchUserInfo()
    }
    
    func register(username: String, password: String, repassword: String) async throws {
        let response = try await authService.register(
            username: username,
            password: password,
            repassword: repassword
        )
        userState.login(user: response)
        await fetchUserInfo()
    }
    
    func logout() async {
        do {
            try await authService.logout()
            userState.logout()
            resetUserInfo()
        } catch {
            print("登出失败: \(error)")
        }
    }
    
    private func resetUserInfo() {
        username = "游客"
        coinCount = 0
        level = 0
        rank = "--"
        isLoggedIn = false
    }
    
    func fetchUserInfo() async {
        guard userState.isLoggedIn else { return }
        
        do {
            let coinInfo = try await userApiService.fetchCoinInfo()
            self.coinCount = coinInfo.coinCount
            self.level = coinInfo.level
            self.rank = coinInfo.rank
            
            if let user = userState.currentUser {
                self.username = user.nickname
            }
        } catch {
            print("获取用户信息失败: \(error)")
        }
    }
    
    // 处理需要登录的功能点击
    func handleLoginRequired(action: @escaping () async -> Void) {
        if userState.isLoggedIn {
            Task {
                await action()
            }
        } else {
            showLoginAlert = true
        }
    }
    
    // 第三方登录
    func thirdPartyLogin(type: String) async {
        isLoading = true
        do {
            switch type {
            case "Apple":
                // TODO: 实现 Apple 登录
                print("开始 Apple 登录")
            case "Google":
                // TODO: 实现 Google 登录
                print("开始 Google 登录")
            case "WeChat":
                // TODO: 实现微信登录
                print("开始微信登录")
            case "QQ":
                // TODO: 实现 QQ 登录
                print("开始 QQ 登录")
            default:
                throw LoginError.unsupportedLoginType
            }
            
            // 模拟登录成功
            try await Task.sleep(nanoseconds: 1_000_000_000)
            errorMessage = "暂不支持第三方登录"
            isLoading = false
            return
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

enum LoginError: LocalizedError {
    case unsupportedLoginType
    
    var errorDescription: String? {
        switch self {
        case .unsupportedLoginType:
            return "不支持的登录方式"
        }
    }
}