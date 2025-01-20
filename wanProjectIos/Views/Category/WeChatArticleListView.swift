import SwiftUI
import Foundation

struct WeChatArticleListView: View {
    let account: WeChatArticle
    @StateObject private var viewModel = WeChatArticleListViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.articles) { article in
                ArticleRow(article: article)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
            
            // 加载更多
            if !viewModel.articles.isEmpty {
                HStack {
                    Spacer()
                    if viewModel.isLoadingMore {
                        ProgressView()
                    } else if viewModel.hasMoreData {
                        Button("加载更多") {
                            Task {
                                await viewModel.loadMore()
                            }
                        }
                        .foregroundColor(.blue)
                    } else {
                        Text("没有更多了")
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .listRowInsets(EdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0))
            }
        }
        .listStyle(.plain)
        .refreshable {
            await viewModel.refresh()
        }
        .overlay(Group {
            if viewModel.isLoading {
                LoadingView("加载中...")
            } else if viewModel.articles.isEmpty {
                EmptyPlaceholderView(
                    icon: "doc.text",
                    title: "暂无文章",
                    message: "该公众号还没有发布文章"
                )
            }
        })
        .navigationTitle(account.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            HiLog.i("打开公众号文章列表: \(account.name)")
        }
        .task {
            await viewModel.fetchArticles(accountId: account.id)
        }
    }
}

// 预览
struct WeChatArticleListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            WeChatArticleListView(account: PreviewData.weChatArticle)
        }
    }
} 
