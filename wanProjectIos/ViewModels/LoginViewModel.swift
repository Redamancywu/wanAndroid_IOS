import Foundation
import SwiftUI

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""
    @Published var repassword = ""  // 注册时使用
    @Published var isLoading = false
    @Published var error: Error?
    @Published var isRegistering = false  // 是否处于注册模式
    @Published var showError = false
    
    private let authService = AuthService.shared
    private let userState = UserState.shared
    private let userApiService = UserApiService.shared
    
    init() {}  // 默认初始化方法
    
    // 添加用于预览的初始化方法
    convenience init(isLoading: Bool = false, error: Error? = nil) {
        self.init()
        self.isLoading = isLoading
        self.error = error
    }
    
    func login() async {
        guard !username.isEmpty && !password.isEmpty else {
            error = ApiError.message("请输入用户名和密码")
            return
        }
        
        isLoading = true
        do {
            let response = try await authService.login(
                username: username,
                password: password
            )
            userState.login(user: response)
            HiLog.i("登录成功: \(response.nickname)")
        } catch {
            self.error = error
            HiLog.e("登录失败: \(error.localizedDescription)")
        }
        isLoading = false
    }
    
    func register() async {
        isLoading = true
        error = nil
        
        do {
            print("开始注册，用户名：\(username)") // 调试输出
            let response = try await userApiService.register(
                username: username.trimmingCharacters(in: .whitespaces),
                password: password,
                repassword: repassword
            )
            print("注册成功：\(response)") // 调试输出
            
            // 注册成功后自动登录
            await login()
        } catch {
            print("注册失败：\(error.localizedDescription)") // 调试输出
            self.error = error
            self.showError = true
        }
        
        isLoading = false
    }
    
    func logout() async {
        isLoading = true
        do {
            try await authService.logout()
            userState.logout()
            HiLog.i("登出成功")
        } catch {
            self.error = error
            HiLog.e("登出失败: \(error.localizedDescription)")
        }
        isLoading = false
    }
} 