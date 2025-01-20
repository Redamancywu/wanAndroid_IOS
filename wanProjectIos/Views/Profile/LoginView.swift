import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isRegistering = false
    
    // 第三方登录选项
    private let thirdPartyLogins: [(icon: String, name: String, color: Color)] = [
        ("apple.logo", "Apple", .black),
        ("g.circle.fill", "Google", .red),
        ("message.fill", "WeChat", .green),
        ("bubble.left.fill", "QQ", .blue)
    ]
    
    var body: some View {
        NavigationView {
            Form {
                if !isRegistering {
                    // 登录表单
                    Section(header: Text("登录")) {
                        TextField("用户名", text: $viewModel.loginUsername)
                            .textContentType(.username)
                            .autocapitalization(.none)
                        SecureField("密码", text: $viewModel.loginPassword)
                            .textContentType(.password)
                    }
                    
                    Button("登录") {
                        Task {
                            await viewModel.login()
                        }
                    }
                    .disabled(viewModel.isLoading)
                    
                    // 第三方登录选项
                    Section(header: Text("第三方登录")) {
                        HStack(spacing: 20) {
                            ForEach(thirdPartyLogins, id: \.name) { login in
                                Button {
                                    Task {
                                        await viewModel.thirdPartyLogin(type: login.name)
                                    }
                                } label: {
                                    VStack(spacing: 4) {
                                        Image(systemName: login.icon)
                                            .font(.system(size: 24))
                                            .foregroundColor(login.color)
                                        
                                        Text(login.name)
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                } else {
                    // 注册表单
                    Section(header: Text("注册")) {
                        TextField("用户名", text: $viewModel.registerUsername)
                            .textContentType(.username)
                            .autocapitalization(.none)
                        SecureField("密码", text: $viewModel.registerPassword)
                            .textContentType(.newPassword)
                        SecureField("确认密码", text: $viewModel.registerConfirmPassword)
                            .textContentType(.newPassword)
                    }
                    
                    Button("注册") {
                        Task {
                            await viewModel.register()
                        }
                    }
                    .disabled(viewModel.isLoading)
                }
                
                Button(isRegistering ? "已有账号？去登录" : "没有账号？去注册") {
                    isRegistering.toggle()
                }
            }
            .navigationTitle(isRegistering ? "注册" : "登录")
            .navigationBarItems(leading: Button("取消") {
                dismiss()
            })
            .alert("错误", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("确定") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
            .disabled(viewModel.isLoading)
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
        }
    }
}

// 预览
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // 登录状态预览
            LoginView(viewModel: PreviewProfileViewModel())
                .previewDisplayName("登录状态")
            
            // 加载状态预览
            LoginView(viewModel: PreviewProfileViewModel(isLoading: true))
                .previewDisplayName("加载状态")
            
            // 错误状态预览
            LoginView(viewModel: PreviewProfileViewModel(errorMessage: "用户名或密码错误"))
                .previewDisplayName("错误状态")
        }
    }
}

// 用于预览的 ViewModel
private class PreviewProfileViewModel: ProfileViewModel {
    init(isLoading: Bool = false, errorMessage: String? = nil) {
        super.init()
        self.isLoading = isLoading
        self.errorMessage = errorMessage
        
        // 添加一些示例数据
        self.loginUsername = "demo_user"
        self.loginPassword = "password123"
        self.registerUsername = "new_user"
        self.registerPassword = "newpass123"
        self.registerConfirmPassword = "newpass123"
    }
} 

