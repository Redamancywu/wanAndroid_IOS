//
//  HomeRecommendView.swift
//  wanProjectIos
//
//  Created by neillwu on 2025/1/17.
//

import SwiftUI

struct HomeRecommendView: View {
    @StateObject private var viewModel = HomeRecommendViewModel()
    @EnvironmentObject private var userState: UserState
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.articles) { article in
                    ArticleCard(article: article)
                        .padding(.horizontal)
                }
                
                // 加载更多
                if !viewModel.articles.isEmpty {
                    loadMoreButton
                }
            }
            .padding(.vertical)
        }
        .refreshable {
            await viewModel.refresh()
        }
        .overlay {
            if viewModel.isLoading {
                LoadingView()
            } else if viewModel.articles.isEmpty {
                EmptyPlaceholderView(
                    icon: "doc.text",
                    title: "暂无推荐",
                    message: "下拉刷新试试"
                )
            }
        }
        .task {
            if viewModel.articles.isEmpty {
                await viewModel.loadArticles()
            }
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

// 文章卡片
struct ArticleCard: View {
    let article: Article
    @EnvironmentObject private var userState: UserState
    @State private var isCollected: Bool
    @State private var showCollectError = false
    @State private var errorMessage = ""
    @State private var showShareSheet = false
    @State private var shareURL: URL?
    
    init(article: Article) {
        self.article = article
        _isCollected = State(initialValue: article.collect)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标题
            Text(article.title)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.primary)
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
                //分类
                if let chapterName = article.chapterName {
                    HStack(spacing:6){
                        Image(systemName: "folder.fill")
                            .foregroundColor(.orange)
                            .imageScale(.medium)
                        Text(chapterName).font(.system(size:13)).foregroundColor(.orange)
                    }
                    .frame(height: 32)
                }
                
                Spacer()
                
                // 日期
                Text(article.niceDate)
                    .font(.system(size: 13))
                    .foregroundColor(.blue)
                    .frame(height: 32)
                    
                
                // 操作按钮组
                HStack(spacing: 16) {
                    // 收藏按钮
                    Button(action: toggleCollect) {
                        Image(systemName: isCollected ? "heart.fill" : "heart")
                            .foregroundColor(isCollected ? .red : .secondary)
                            .imageScale(.medium)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    
                    // 分享按钮
                    Button {
                        if let url = URL(string: article.link ?? "") {
                            shareURL = url
                            showShareSheet = true
                        }
                    } label: {
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
        .alert("收藏失败", isPresented: $showCollectError) {
            Button("确定", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .sheet(isPresented: $showShareSheet) {
            if let url = shareURL {
                ShareSheet(activityItems: [url])
            }
        }
        .onAppear {
            // 更新收藏状态
            isCollected = userState.isCollected(articleId: article.id)
        }
        // 监听收藏状态变化
        .onReceive(NotificationCenter.default.publisher(for: .articleCollectionChanged)) { _ in
            isCollected = userState.isCollected(articleId: article.id)
        }
    }
    
    private func toggleCollect() {
        guard userState.isLoggedIn else {
            errorMessage = "请先登录"
            showCollectError = true
            return
        }
        
        Task {
            do {
                try await userState.toggleCollect(article: article)
                isCollected.toggle()
            } catch {
                errorMessage = error.localizedDescription
                showCollectError = true
            }
        }
    }
}

// 预览
struct HomeRecommendView_Previews: PreviewProvider {
    static var previews: some View {
        HomeRecommendView()
            .environmentObject(UserState.shared)
    }
}
