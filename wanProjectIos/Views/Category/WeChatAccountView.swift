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
                Text(account.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button {
                    HiLog.i("\(isExpanded ? "收起" : "展开")\(account.name)的文章列表")
                    withAnimation {
                        isExpanded.toggle()
                        if isExpanded {
                            // 展开时加载更多文章
                            Task {
                                await viewModel.loadMore()
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(isExpanded ? "收起" : "更多")
                            .font(.subheadline)
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.right")
                            .font(.caption)
                    }
                    .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            .padding(.top)
            
            if let error = viewModel.error {
                ErrorView(error: error) {
                    Task {
                        await viewModel.fetchArticles(accountId: account.id)
                    }
                }
                .padding()
            } else if let articles = viewModel.articles {
                // 文章列表
                ForEach(isExpanded ? articles : Array(articles.prefix(3))) { article in
                    ArticleRow(article: article)
                    
                    if article != (isExpanded ? articles.last : articles.prefix(3).last) {
                        Divider()
                            .padding(.horizontal)
                    }
                }
                
                if isExpanded {
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
                                } else {
                                    Text("加载更多")
                                    Image(systemName: "arrow.down.circle")
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.blue)
                            .padding(.vertical, 8)
                        }
                        .disabled(viewModel.isLoadingMore)
                    } else {
                        Text("没有更多文章了")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 4)
                    }
                    
                    Divider()
                        .padding(.horizontal)
                    
                    // 收起按钮
                    Button {
                        withAnimation(.easeInOut) {
                            isExpanded = false
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text("收起")
                                .font(.subheadline)
                            Image(systemName: "chevron.up")
                                .font(.caption)
                        }
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }
                }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isExpanded)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 8, y: 2)
        .onAppear {
            HiLog.i("加载公众号区块: \(account.name)")
            Task {
                await viewModel.fetchArticles(accountId: account.id)
            }
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
            Button {
                HiLog.i("点击文章: \(article.title)")
                if let link = article.link,
                   let url = URL(string: link) {
                    openURL(url)
                }
                if !readArticles.contains(article.id) {
                    readArticles.append(article.id)
                }
            } label: {
                VStack(alignment: .leading, spacing: 8) {
                    Text(article.title)
                        .font(.system(size: 15))
                        .foregroundColor(readArticles.contains(article.id) ? .gray : .primary)
                        .lineLimit(2)
                    
                    HStack {
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
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.red)
                                .cornerRadius(4)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(isPressed ? Color.gray.opacity(0.1) : Color.clear)
                .animation(.easeOut(duration: 0.2), value: isPressed)
            }
            
            // 收藏按钮
            Button {
                Task {
                    await viewModel.toggleCollect(articleId: article.id)
                }
            } label: {
                Image(systemName: viewModel.isCollected ? "heart.fill" : "heart")
                    .foregroundColor(viewModel.isCollected ? .red : .gray)
                    .frame(width: 44, height: 44)
            }
            .alert("需要登录", isPresented: $viewModel.showLoginAlert) {
                Button("取消", role: .cancel) { }
                Button("去登录") {
                    profileViewModel.showLogin()
                }
            } message: {
                Text("收藏功能需要登录后才能使用")
            }
            
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
        .swipeActions(edge: .trailing) {
            Button {
                Task {
                    await viewModel.toggleCollect(articleId: article.id)
                }
            } label: {
                Label("收藏", systemImage: "heart")
            }
            .tint(.red)
            
            Button {
                showShareSheet = true
            } label: {
                Label("分享", systemImage: "square.and.arrow.up")
            }
            .tint(.blue)
        }
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

// 预览
struct WeChatAccountView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            WeChatAccountView()
                .navigationTitle("公众号")
        }
    }
}

struct WeChatAccountSection_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            WeChatAccountSection(account: PreviewData.weChatArticle)
                .padding()
        }
    }
}

struct ArticleRow_Previews: PreviewProvider {
    static var previews: some View {
        ArticleRow(article: PreviewData.article)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}

