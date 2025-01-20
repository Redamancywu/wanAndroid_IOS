import SwiftUI

struct CollectionView: View {
    @StateObject private var viewModel = CollectionViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.articles) { article in
                CollectionArticleRow(article: article)
            }
        }
        .listStyle(.plain)
        .refreshable {
            await viewModel.fetchCollectedArticles()
        }
        .overlay {
            if viewModel.isLoading {
                LoadingView("加载中...")
            } else if let error = viewModel.error {
                ErrorView(error: error) {
                    Task {
                        await viewModel.fetchCollectedArticles()
                    }
                }
            } else if viewModel.articles.isEmpty {
                EmptyPlaceholderView(
                    icon: "star",
                    title: "暂无收藏",
                    message: "快去收藏一些文章吧"
                )
            }
        }
        .task {
            if viewModel.articles.isEmpty {
                await viewModel.fetchCollectedArticles()
            }
        }
    }
}

struct CollectionArticleRow: View {
    let article: CollectionArticle
    @StateObject private var viewModel = CollectionArticleViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(article.title)
                .font(.system(size: 16))
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
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapToOpenWeb(url: article.link ?? "", title: article.title)
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                Task {
                    await viewModel.uncollect(articleId: article.id)
                }
            } label: {
                Label("取消收藏", systemImage: "star.slash")
            }
        }
    }
}

// 预览
struct CollectionView_Previews: PreviewProvider {
    static var previews: some View {
        CollectionView()
            .environmentObject(UserState.shared)
            .environmentObject(ProfileViewModel())
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