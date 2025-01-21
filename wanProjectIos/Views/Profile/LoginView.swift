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
                            .background(
                                Circle()
                                    .fill(Color.blue.opacity(0.1))
                                    .frame(width: 100, height: 100)
                            )
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
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemGray6))
                            )
                        }
                        
                        // 密码输入框美化
                        SecureInputField(
                            title: "密码",
                            placeholder: "请输入密码",
                            text: $viewModel.password
                        )
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))
                        )
                        
                        // 登录按钮
                        Button {
                            Task {
                                await viewModel.login()
                            }
                        } label: {
                            HStack {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("登录")
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.blue)
                                    .shadow(color: .blue.opacity(0.3), radius: 5, y: 2)
                            )
                            .foregroundColor(.white)
                        }
                        .disabled(viewModel.isLoading)
                        .padding(.top, 10)
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
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
        .toast(isShowing: $viewModel.showToast, message: viewModel.toastMessage)
        .onAppear {
            viewModel.dismiss = {
                dismiss()
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


