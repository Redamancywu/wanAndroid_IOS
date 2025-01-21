import SwiftUI

struct ArticleRow: View {
    let article: Article
    @StateObject private var viewModel = ArticleRowViewModel()
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
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
            .onTapToOpenWeb(url: article.link ?? "", title: article.title)
            
            // 收藏按钮
            Button {
                toggleCollect()
            } label: {
                Image(systemName: viewModel.isCollected ? "heart.fill" : "heart")
                    .foregroundColor(viewModel.isCollected ? .red : .gray)
            }
            .buttonStyle(.scale)
            
            // 分享按钮
            Button {
                showShareSheet = true
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .foregroundColor(.gray)
            }
            .buttonStyle(.scale)
        }
        .onAppear {
            viewModel.checkCollectionStatus(article: article)
        }
        .sheet(isPresented: $showShareSheet) {
            if let url = URL(string: article.link ?? "") {
                ShareSheet(activityItems: [url])
            }
        }
        .background(Color(.systemBackground))
    }
    
    private func toggleCollect() {
        Task {
            do {
                try await viewModel.toggleCollect(article: article)
            } catch {
                print("收藏失败: \(error)")
            }
        }
    }
} 