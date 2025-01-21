import SwiftUI

struct CollectionView: View {
    @StateObject private var viewModel = CollectionViewModel()
    @EnvironmentObject private var userState: UserState
    @Environment(\.dismiss) private var dismiss
    @State private var showShareSheet = false
    @State private var shareURL: URL?
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                LoadingView()
            } else if !userState.isLoggedIn {
                EmptyPlaceholderView(
                    icon: "person.crop.circle.badge.exclamationmark",
                    title: "需要登录",
                    message: "登录后即可查看收藏的文章"
                )
            } else if let error = viewModel.error {
                VStack(spacing: 16) {
                    EmptyPlaceholderView(
                        icon: "exclamationmark.triangle",
                        title: "加载失败",
                        message: error.localizedDescription
                    )
                    
                    Button {
                        Task {
                            await viewModel.loadCollections()
                        }
                    } label: {
                        Text("重试")
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                }
            } else if viewModel.articles.isEmpty {
                EmptyPlaceholderView(
                    icon: "heart.slash",
                    title: "暂无收藏",
                    message: "快去收藏一些感兴趣的文章吧"
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.articles) { article in
                            CollectedArticleCard(
                                article: article,
                                onUncollect: {
                                    Task {
                                        await viewModel.uncollect(
                                            articleId: article.id,
                                            originId: article.originId
                                        )
                                    }
                                },
                                onShare: {
                                    if let url = URL(string: article.link ?? "") {
                                        shareURL = url
                                        showShareSheet = true
                                    }
                                }
                            )
                            .padding(.horizontal)
                        }
                        
                        if viewModel.hasMore {
                            loadMoreButton
                        }
                    }
                    .padding(.vertical)
                }
                .refreshable {
                    await viewModel.loadCollections()
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let url = shareURL {
                ShareSheet(activityItems: [url])
            }
        }
        .alert("错误", isPresented: $showError) {
            Button("确定", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .navigationTitle("我的收藏(\(viewModel.articles.count))")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            HiLog.i("CollectionView appeared, loading collections...")
            await viewModel.loadCollections()
        }
        .onDisappear {
            HiLog.i("CollectionView disappeared")
        }
    }
    
    private var loadMoreButton: some View {
        HStack {
            Spacer()
            Button {
                Task {
                    await viewModel.loadMore()
                }
            } label: {
                if viewModel.isLoadingMore {
                    ProgressView()
                        .frame(height: 40)
                } else {
                    Text(viewModel.hasMore ? "加载更多" : "没有更多了")
                        .foregroundColor(.secondary)
                        .frame(height: 40)
                }
            }
            .disabled(viewModel.isLoadingMore || !viewModel.hasMore)
            Spacer()
        }
        .padding(.top, 8)
    }
}

// 收藏文章卡片
struct CollectedArticleCard: View {
    let article: Article
    let onUncollect: () -> Void
    let onShare: () -> Void
    @AppStorage("ReadArticles") private var readArticles: [Int] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标题
            Text(article.title)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(readArticles.contains(article.id) ? .gray : .primary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            
            // 分割线
            Divider()
                .padding(.vertical, 4)
            
            // 底部信息和操作栏
            HStack(spacing: 12) {
                // 作者
                HStack(spacing: 6) {
                    Image(systemName: "person.circle.fill")
                        .foregroundColor(.blue)
                        .imageScale(.medium)
                    Text(article.author ?? article.shareUser ?? "匿名")
                        .font(.system(size: 13))
                        .foregroundColor(.blue)
                }
                .frame(height: 32)
                
                Spacer()
                
                // 日期
                Text(article.niceDate)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .frame(height: 32)
                
                // 操作按钮组
                HStack(spacing: 16) {
                    // 取消收藏按钮
                    Button(action: onUncollect) {
                        Image(systemName: "heart.slash.fill")
                            .foregroundColor(.red)
                            .imageScale(.medium)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    
                    // 分享按钮
                    Button(action: onShare) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.secondary)
                            .imageScale(.medium)
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
                .frame(height: 32)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(
                    color: Color.black.opacity(0.06),
                    radius: 8,
                    x: 0,
                    y: 2
                )
        )
        .contentShape(Rectangle())
        .onTapToOpenWeb(url: article.link ?? "", title: article.title)
    }
} 
