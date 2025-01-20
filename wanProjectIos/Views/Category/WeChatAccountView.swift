//
//  WeChatAccountView.swift
//  wanProjectIos
//
//  Created by neillwu on 2025/1/17.
//

import SwiftUI

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
            
            // 文章列表
            if let articles = viewModel.articles {
                ForEach(isExpanded ? articles : Array(articles.prefix(3))) { article in
                    ArticleRow(article: article)
                    
                    if article != (isExpanded ? articles.last : articles.prefix(3).last) {
                        Divider()
                            .padding(.horizontal)
                    }
                }
                
                if isExpanded {
                    // 加载更多按钮
                    if viewModel.hasMoreData {
                        Button {
                            Task {
                                await viewModel.loadMore()
                            }
                        } label: {
                            HStack {
                                if viewModel.isLoadingMore {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                } else {
                                    Text("加载更多")
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.blue)
                            .padding(.vertical, 8)
                        }
                        .disabled(viewModel.isLoadingMore)
                    }
                    
                    // 收起按钮
                    Button {
                        withAnimation {
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
            } else if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
            }
        }
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
    
    var body: some View {
        Button {
            if let link = article.link,
               let url = URL(string: link) {
                openURL(url)
            }
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                Text(article.title)
                    .font(.system(size: 15))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                HStack {
                    Text(article.niceDate)
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
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
        }
        .buttonStyle(.scale)
    }
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

