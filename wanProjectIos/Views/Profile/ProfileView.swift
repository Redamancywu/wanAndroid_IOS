import SwiftUI
import SafariServices

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    
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
            FunctionItem(icon: "link.circle.fill", title: "GitHub", color: .black, subtitle: "@Redamancywu"),
            FunctionItem(icon: "info.circle.fill", title: "关于", color: .blue),
            FunctionItem(icon: "questionmark.circle.fill", title: "帮助与反馈", color: .orange)
        ]
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 用户信息卡片
                    userInfoCard
                    
                    // 功能列表
                    ForEach(Array(functionItems.enumerated()), id: \.offset) { _, items in
                        functionGroup(items: items)
                    }
                    
                    // 版本信息
                    versionInfo
                }
                .padding()
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
            .sheet(isPresented: $viewModel.showLoginSheet) {
                LoginView(viewModel: viewModel)
            }
        }
    }
    
    // 用户信息卡片
    private var userInfoCard: some View {
        VStack(spacing: 12) {
            VStack(spacing: 8) {
                Text(viewModel.username)
                    .font(.title2)
                    .fontWeight(.medium)
                
                if viewModel.isLoggedIn {
                    HStack(spacing: 16) {
                        // 积分信息
                        VStack(spacing: 4) {
                            HStack(spacing: 4) {
                                Image(systemName: "dollarsign.circle.fill")
                                    .foregroundColor(.orange)
                                Text("\(viewModel.coinCount)")
                                    .foregroundColor(.primary)
                            }
                            Text("积分")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        // 等级信息
                        VStack(spacing: 4) {
                            Text("Lv.\(viewModel.level)")
                                .foregroundColor(.primary)
                            Text("等级")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        // 排名信息
                        VStack(spacing: 4) {
                            Text(viewModel.rank)
                                .foregroundColor(.primary)
                            Text("排名")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.top, 4)
                }
            }
            
            // 登录/注册按钮
            if !viewModel.isLoggedIn {
                Button {
                    viewModel.showLogin()
                } label: {
                    Text("登录/注册")
                        .foregroundColor(.blue)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(20)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, y: 2)
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
            if item.requiresLogin && !viewModel.isLoggedIn {
                // 需要登录的功能，但未登录时显示按钮
                Button {
                    viewModel.showLogin()
                } label: {
                    functionCellContent(item: item)
                }
            } else {
                // 不需要登录或已登录时显示导航链接
                NavigationLink {
                    switch item.title {
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

// SafariView 用于在应用内打开网页
struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {
        // 不需要更新
    }
}

// 预览
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
} 
