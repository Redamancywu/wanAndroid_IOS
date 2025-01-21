//
//  WeChatAccountView.swift
//  wanProjectIos
//
//  Created by neillwu on 2025/1/17.
//

import SwiftUI

extension Array: RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode([Element].self, from: data)
        else {
            return nil
        }
        self = result
    }
    
    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}

struct WeChatAccountView: View {
    @StateObject private var viewModel = WeChatAccountViewModel()
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.accounts) { account in
                    WeChatAccountSection(account: account)
                        .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .refreshable {
            await viewModel.fetchAccounts()
        }
        .overlay {
            if viewModel.isLoading {
                LoadingView("加载中...")
            } else if let error = viewModel.error {
                ErrorView(error: error) {
                    Task {
                        await viewModel.fetchAccounts()
                    }
                }
            } else if viewModel.accounts.isEmpty {
                EmptyPlaceholderView(
                    icon: "person.2.circle",
                    title: "暂无公众号",
                    message: "稍后再来看看吧"
                )
            }
        }
        .task {
            if viewModel.accounts.isEmpty {
                await viewModel.fetchAccounts()
            }
        }
    }
}

// 公众号区块视图
struct WeChatAccountSection: View {
    let account: WeChatArticle
    @StateObject private var viewModel = WeChatAccountSectionViewModel()
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 公众号头部信息
            HStack {
                Label {
                    Text(account.name)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)
                } icon: {
                    Image(systemName: "newspaper.fill")
                        .foregroundColor(.blue)
                        .imageScale(.large)
                }
                
                Spacer()
                
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        isExpanded.toggle()
                        if isExpanded {
                            Task {
                                await viewModel.loadMore()
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(isExpanded ? "收起" : "更多")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.right.circle.fill")
                            .imageScale(.small)
                    }
                    .foregroundColor(.blue)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(20)
                }
                .buttonStyle(ScaleButtonStyle())
            }
            .padding(.horizontal)
            .padding(.top)
            
            // 文章列表
            if let error = viewModel.error {
                ErrorView(error: error) {
                    Task {
                        await viewModel.fetchArticles(accountId: account.id)
                    }
                }
                .padding()
            } else if let articles = viewModel.articles {
                let displayArticles = isExpanded ? articles : Array(articles.prefix(3))
                
                VStack(spacing: 0) {
                    ForEach(displayArticles) { article in
                        ArticleRow(article: article)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: Color.black.opacity(0.03), radius: 3, y: 1)
                            )
                            .padding(.horizontal)
                            .padding(.vertical, 4)
                    }
                }
                
                // 加载更多按钮
                if isExpanded && articles.count >= 10 {
                    if viewModel.hasMoreData {
                        Button {
                            Task {
                                await viewModel.loadMore()
                            }
                        } label: {
                            HStack(spacing: 8) {
                                if viewModel.isLoadingMore {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                    Text("加载中...")
                                        .font(.subheadline)
                                } else {
                                    Text("加载更多")
                                        .font(.subheadline)
                                    Image(systemName: "arrow.down.circle.fill")
                                        .imageScale(.small)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.blue)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.blue.opacity(0.05))
                                    .shadow(color: Color.black.opacity(0.03), radius: 3, y: 1)
                            )
                            .padding(.horizontal)
                            .padding(.top, 8)
                        }
                        .buttonStyle(ScaleButtonStyle())
                        .disabled(viewModel.isLoadingMore)
                    } else {
                        Text("没有更多了")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.systemGray6))
                            )
                            .padding(.horizontal)
                            .padding(.top, 8)
                    }
                }
            }
        }
        .padding(.bottom, 12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(
            color: isExpanded ? Color.blue.opacity(0.1) : Color.black.opacity(0.05),
            radius: isExpanded ? 8 : 5,
            y: isExpanded ? 4 : 2
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isExpanded ? Color.blue.opacity(0.2) : Color.clear, lineWidth: 1)
        )
        .scaleEffect(isExpanded ? 1.01 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isExpanded)
        .task {
            await viewModel.fetchArticles(accountId: account.id)
        }
    }
}

// 预览
struct WeChatAccountView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            WeChatAccountView()
                .navigationTitle("公众号")
                .environmentObject(UserState.shared)
        }
    }
}

// 文章行视图
struct ArticleRow: View {
    let article: Article
    @Environment(\.openURL) private var openURL
    @EnvironmentObject private var profileViewModel: ProfileViewModel
    @StateObject private var viewModel = ArticleRowViewModel()
    @State private var isPressed = false
    @State private var showShareSheet = false
    @AppStorage("ReadArticles") private var readArticles: [Int] = []
    
    var body: some View {
        HStack {
            // 文章内容按钮
            VStack(alignment: .leading, spacing: 8) {
                Text(article.title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(readArticles.contains(article.id) ? .gray : .primary)
                    .lineLimit(2)
                
                HStack(spacing: 8) {
                    if let author = article.author {
                        Label(author, systemImage: "person.circle")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    Text(article.niceDate)
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    if article.fresh {
                        Text("新")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.red.opacity(0.9))
                            .cornerRadius(4)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
            .onTapToOpenWeb(url: article.link ?? "", title: article.title)
            .withTapFeedback()
            
            // 收藏按钮
            Button {
                Task {
                    await viewModel.toggleCollect(articleId: article.id)
                }
            } label: {
                Image(systemName: viewModel.isCollected ? "heart.fill" : "heart")
                    .foregroundColor(viewModel.isCollected ? .red : .gray)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(ScaleButtonStyle())
            
            // 分享按钮
            Button {
                showShareSheet = true
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .foregroundColor(.gray)
                    .frame(width: 44, height: 44)
            }
        }
        .onAppear {
            viewModel.checkCollectionStatus(articleId: article.id)
        }
        .sheet(isPresented: $showShareSheet) {
            if let url = URL(string: article.link ?? "") {
                ShareSheet(activityItems: [url])
            }
        }
        .background(Color(.systemBackground))
    }
}
// 分享sheet
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// 公众号区块的 ViewModel
@MainActor
class WeChatAccountSectionViewModel: ObservableObject {
    @Published private(set) var articles: [Article]?
    @Published private(set) var isLoading = false
    @Published private(set) var isLoadingMore = false
    @Published private(set) var hasMoreData = true
    @Published var error: Error?
    
    private let apiService = ApiService.shared
    private var currentPage = 1
    private let pageSize = 20
    private var accountId: Int?
    private var isLoadingTask: Task<Void, Never>?
    
    deinit {
        isLoadingTask?.cancel()
    }
    
    func fetchArticles(accountId: Int) async {
        // 取消之前的任务
        isLoadingTask?.cancel()
        
        // 创建新任务
        isLoadingTask = Task {
            self.accountId = accountId
            isLoading = true
            currentPage = 1
            
            do {
                let response = try await apiService.request(
                    "/wxarticle/list/\(accountId)/\(currentPage)/json",
                    method: .get,
                    responseType: ApiResponse<ArticleList>.self
                )
                
                if !Task.isCancelled {
                    if response.errorCode == 0 {
                        articles = response.data.datas
                        hasMoreData = response.data.datas.count >= pageSize
                    } else {
                        throw ApiError.message(response.errorMsg)
                    }
                }
            } catch {
                if !Task.isCancelled {
                    self.error = error
                }
            }
            
            if !Task.isCancelled {
                isLoading = false
            }
        }
    }
    
    func loadMore() async {
        guard !isLoadingMore, 
              hasMoreData,
              let accountId = accountId else { return }
        
        isLoadingMore = true
        do {
            let nextPage = currentPage + 1
            let response = try await apiService.request(
                "/wxarticle/list/\(accountId)/\(nextPage)/json",
                method: .get,
                responseType: ApiResponse<ArticleList>.self
            )
            
            if response.errorCode == 0 {
                if var currentArticles = articles {
                    currentArticles.append(contentsOf: response.data.datas)
                    articles = currentArticles
                }
                currentPage = nextPage
                hasMoreData = response.data.datas.count >= pageSize
            } else {
                throw ApiError.message(response.errorMsg)
            }
        } catch {
            self.error = error
        }
        isLoadingMore = false
    }
}

// 区块视图预览
struct WeChatAccountSection_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            WeChatAccountSection(account: PreviewData.weChatArticle)
                .padding()
                .environmentObject(UserState.shared)
                .environmentObject(ProfileViewModel())
        }
    }
}

// 文章行视图预览
struct ArticleRow_Previews: PreviewProvider {
    static var previews: some View {
        ArticleRow(article: PreviewData.article)
            .padding()
            .previewLayout(.sizeThatFits)
            .environmentObject(UserState.shared)
            .environmentObject(ProfileViewModel())
    }
}

// ShareSheet 预览
struct ShareSheet_Previews: PreviewProvider {
    static var previews: some View {
        ShareSheet(activityItems: ["测试分享"])
            .environmentObject(UserState.shared)
            .environmentObject(ProfileViewModel())
    }
}

