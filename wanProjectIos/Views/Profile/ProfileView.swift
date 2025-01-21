import SwiftUI
import SafariServices

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @EnvironmentObject private var userState: UserState
    @State private var showLoginSheet = false
    
    // 功能列表数据
    let functionItems: [[FunctionItem]] = [
        [
            FunctionItem(icon: "dollarsign.circle.fill", title: "我的积分", color: .orange, requiresLogin: true),
            FunctionItem(icon: "star.fill", title: "我的收藏", color: .yellow, requiresLogin: true),
            FunctionItem(icon: "clock.fill", title: "浏览历史", color: .blue, requiresLogin: true),
            FunctionItem(icon: "square.and.pencil", title: "我的分享", color: .green, requiresLogin: true)
        ],
        [
            FunctionItem(icon: "gear", title: "设置", color: .gray),
            FunctionItem(icon: "person.2.circle.fill", title: "联系", color: .blue),
            FunctionItem(icon: "info.circle.fill", title: "关于", color: .blue),
            FunctionItem(icon: "questionmark.circle.fill", title: "帮助与反馈", color: .orange)
        ],
        [
            FunctionItem(icon: "rectangle.portrait.and.arrow.right", title: "退出登录", color: .red, requiresLogin: true)
        ]
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 用户信息卡片
                    userInfoCard
                        .padding(.horizontal)
                    
                    // 功能列表
                    ForEach(Array(functionItems.enumerated()), id: \.offset) { _, items in
                        functionGroup(items: items)
                            .padding(.horizontal)
                    }
                    
                    // 版本信息
                    versionInfo
                    
                    // 登录按钮
                    if !userState.isLoggedIn {
                        Button {
                            showLoginSheet = true
                        } label: {
                            Text("登录/注册")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.blue)
                                        .shadow(color: .blue.opacity(0.3), radius: 5, y: 2)
                                )
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .alert("需要登录", isPresented: $viewModel.showLoginAlert) {
                Button("取消", role: .cancel) { }
                Button("去登录") {
                    viewModel.showLogin()
                }
            } message: {
                Text("该功能需要登录后才能使用")
            }
            .sheet(isPresented: $showLoginSheet) {
                LoginView()
            }
            .navigationTitle("我的")
        }
    }
    
    // 用户信息卡片
    private var userInfoCard: some View {
        VStack(spacing: 16) {
            // 头像和用户名
            VStack(spacing: 12) {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.blue)
                    .background(
                        Circle()
                            .fill(Color.blue.opacity(0.1))
                            .frame(width: 80, height: 80)
                    )
                
                Text(viewModel.username)
                    .font(.title2)
                    .fontWeight(.medium)
            }
            
            if viewModel.isLoggedIn {
                Divider()
                    .padding(.horizontal)
                
                // 用户数据
                HStack(spacing: 40) {
                    UserDataItem(icon: "dollarsign.circle.fill", value: "\(viewModel.coinCount)", title: "积分", color: .orange)
                    UserDataItem(icon: "chart.line.uptrend.xyaxis", value: "Lv.\(viewModel.level)", title: "等级", color: .blue)
                    UserDataItem(icon: "trophy.fill", value: viewModel.rank, title: "排名", color: .yellow)
                }
                .padding(.top, 8)
            }
        }
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 10, y: 5)
        )
    }
    
    // 功能组
    private func functionGroup(items: [FunctionItem]) -> some View {
        VStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                functionCell(item: item)
                
                if index < items.count - 1 {
                    Divider()
                        .padding(.leading, 56)
                }
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, y: 2)
    }
    
    // 功能单元格
    private func functionCell(item: FunctionItem) -> some View {
        Group {
            if item.title == "退出登录" {
                Button {
                    Task {
                        await viewModel.logout()
                    }
                } label: {
                    functionCellContent(item: item)
                }
            } else if item.requiresLogin && !viewModel.isLoggedIn {
                Button {
                    viewModel.showLogin()
                } label: {
                    functionCellContent(item: item)
                }
            } else {
                NavigationLink {
                    switch item.title {
                    case "联系":
                        ContactView()
                    case "GitHub":
                        if let url = URL(string: "https://github.com/Redamancywu") {
                            SafariView(url: url)
                                .ignoresSafeArea()
                        }
                    case "我的积分":
                        Text("积分页面")
                    case "我的收藏":
                        Text("收藏页面")
                    case "浏览历史":
                        Text("历史页面")
                    case "我的分享":
                        Text("分享页面")
                    case "设置":
                        Text("设置页面")
                    default:
                        Text(item.title)
                    }
                } label: {
                    functionCellContent(item: item)
                }
            }
        }
    }
    
    // 功能单元格内容
    private func functionCellContent(item: FunctionItem) -> some View {
        HStack(spacing: 16) {
            Image(systemName: item.icon)
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(item.color)
                .cornerRadius(8)
            
            Text(item.title)
                .foregroundColor(.primary)
            
            Spacer()
            
            if item.title == "我的积分" {
                Text("\(viewModel.coinCount)")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .padding(.trailing, 4)
            } else if let subtitle = item.subtitle {
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .padding(.trailing, 4)
            }
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.system(size: 14))
        }
        .padding()
        .contentShape(Rectangle())
    }
    
    // 版本信息
    private var versionInfo: some View {
        VStack(spacing: 4) {
            Text("玩Android")
                .font(.headline)
            Text("Version 1.0.0")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical)
    }
}

// 功能项模型
struct FunctionItem: Identifiable, Equatable {
    let id = UUID()
    let icon: String
    let title: String
    let color: Color
    let subtitle: String?
    let requiresLogin: Bool
    
    init(icon: String, title: String, color: Color, subtitle: String? = nil, requiresLogin: Bool = false) {
        self.icon = icon
        self.title = title
        self.color = color
        self.subtitle = subtitle
        self.requiresLogin = requiresLogin
    }
    
    static func == (lhs: FunctionItem, rhs: FunctionItem) -> Bool {
        lhs.title == rhs.title && lhs.icon == rhs.icon
    }
}
// 用户数据项组件
struct UserDataItem: View {
    let icon: String
    let value: String
    let title: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
            Text(value)
                .font(.headline)
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

// 预览
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
} 
