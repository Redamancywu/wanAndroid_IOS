import Foundation

@MainActor
class ProfileViewModel: ObservableObject {
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
    
    private let apiService = ApiService.shared
    private let userState = UserState.shared
    
    var isLoggedIn: Bool {
        userState.isLoggedIn
    }
    
    var username: String {
        userState.username
    }
    
    var coinCount: Int {
        userState.coinCount
    }
    
    var level: Int {
        userState.level
    }
    
    var rank: String {
        userState.rank
    }
    
    func login() async {
        guard !loginUsername.isEmpty && !loginPassword.isEmpty else {
            errorMessage = "请输入用户名和密码"
            return
        }
        
        isLoading = true
        do {
            try await userState.login(username: loginUsername, password: loginPassword)
            showLoginSheet = false
            clearLoginForm()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func register() async {
        guard validateRegisterInput() else { return }
        
        isLoading = true
        do {
            try await userState.register(
                username: registerUsername,
                password: registerPassword,
                repassword: registerConfirmPassword
            )
            // 注册并登录成功后关闭登录表单
            showLoginSheet = false
            // 清空表单数据
            clearRegisterForm()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func logout() async {
        await userState.logout()
    }
    
    func showLogin() {
        showLoginSheet = true
    }
    
    private func clearLoginForm() {
        loginUsername = ""
        loginPassword = ""
    }
    
    private func clearRegisterForm() {
        registerUsername = ""
        registerPassword = ""
        registerConfirmPassword = ""
    }
    
    private func validateRegisterInput() -> Bool {
        guard !registerUsername.isEmpty && !registerPassword.isEmpty else {
            errorMessage = "请输入用户名和密码"
            return false
        }
        
        guard registerPassword == registerConfirmPassword else {
            errorMessage = "两次输入的密码不一致"
            return false
        }
        
        return true
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
            try await userState.login(username: "第三方用户", password: "")
            showLoginSheet = false
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