import SwiftUI

struct CollectionView: View {
    @StateObject private var viewModel = CollectionViewModel()
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.articles.isEmpty {
                    EmptyPlaceholderView(
                        icon: "star.fill",
                        title: "暂无收藏",
                        message: "快去收藏感兴趣的文章吧"
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.articles) { article in
                                CollectionArticleCard(article: article)
                                    .onTapGesture {
                                        if let url = URL(string: article.link) {
                                            openURL(url)
                                        }
                                    }
                            }
                        }
                        .padding()
                    }
                    .refreshable {
                        await viewModel.fetchCollections()
                    }
                }
            }
            .navigationTitle("我的收藏")
        }
        .task {
            await viewModel.fetchCollections()
        }
        .onReceive(NotificationCenter.default.publisher(for: .articleCollectionChanged)) { _ in
            Task {
                await viewModel.fetchCollections()
            }
        }
    }
}

// 收藏文章卡片
struct CollectionArticleCard: View {
    let article: CollectionArticle
    @StateObject private var viewModel = CollectionArticleViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标题
            Text(article.title)
                .font(.system(size: 16, weight: .medium))
                .lineLimit(2)
            
            // 描述
            if let desc = article.desc {
                Text(desc)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            
            // 底部信息
            HStack {
                if let author = article.author, !author.isEmpty {
                    Label(author, systemImage: "person.circle")
                        .font(.system(size: 12))
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Text(article.niceDate)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                
                Button {
                    Task {
                        await viewModel.uncollect(articleId: article.originId)
                    }
                } label: {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                }
                .buttonStyle(.scale)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 8, y: 2)
    }
}

// 空状态视图
struct EmptyPlaceholderView: View {
    let icon: String
    let title: String
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(.gray)
            
            Text(title)
                .font(.headline)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
} 