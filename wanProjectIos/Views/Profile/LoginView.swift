import SwiftUI
import Foundation
struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // Logo 和欢迎文字
                    VStack(spacing: 16) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.blue)
                            .padding(.top, 40)
                        
                        Text(viewModel.isRegistering ? "创建账号" : "欢迎回来")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(viewModel.isRegistering ? "填写信息以创建您的账号" : "登录以继续")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // 输入表单
                    VStack(spacing: 20) {
                        // 用户名
                        VStack(alignment: .leading, spacing: 8) {
                            Text("用户名")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Image(systemName: "person")
                                    .foregroundColor(.gray)
                                TextField("请输入用户名", text: $viewModel.username)
                                    .textContentType(.username)
                                    .autocapitalization(.none)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        }
                        
                        // 密码
                        SecureInputField(
                            title: "密码",
                            placeholder: "请输入密码",
                            text: $viewModel.password
                        )
                        
                        if viewModel.isRegistering {
                            // 确认密码
                            SecureInputField(
                                title: "确认密码",
                                placeholder: "请再次输入密码",
                                text: $viewModel.repassword
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    // 登录/注册按钮
                    Button {
                        Task {
                            if viewModel.isRegistering {
                                await viewModel.register()
                            } else {
                                await viewModel.login()
                            }
                            if viewModel.error == nil {
                                dismiss()
                            }
                        }
                    } label: {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .tint(.white)
                            } else {
                                Image(systemName: viewModel.isRegistering ? "person.badge.plus" : "arrow.right.circle")
                                Text(viewModel.isRegistering ? "注册" : "登录")
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .disabled(viewModel.isLoading)
                    
                    // 切换登录/注册
                    Button {
                        withAnimation {
                            viewModel.isRegistering.toggle()
                            viewModel.error = nil
                            // 清空输入
                            viewModel.password = ""
                            viewModel.repassword = ""
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(viewModel.isRegistering ? "已有账号？" : "没有账号？")
                                .foregroundColor(.secondary)
                            Text(viewModel.isRegistering ? "去登录" : "去注册")
                                .foregroundColor(.blue)
                        }
                        .font(.subheadline)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .alert("错误", isPresented: .init(
                get: { viewModel.error != nil },
                set: { if !$0 { viewModel.error = nil } }
            )) {
                Button("确定", role: .cancel) {}
            } message: {
                if let error = viewModel.error {
                    Text(error.localizedDescription)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.primary)
                    }
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
            LoginView()
                .previewDisplayName("登录状态")
            
            // 加载状态预览
            LoginView()
                .previewDisplayName("加载状态")
                .environmentObject(UserState.shared)
            
            // 错误状态预览
            LoginView()
                .previewDisplayName("错误状态")
                .environmentObject(UserState.shared)
        }
    }
} 


