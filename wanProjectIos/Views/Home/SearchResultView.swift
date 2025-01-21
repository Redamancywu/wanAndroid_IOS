import SwiftUI

struct SearchResultView: View {
    @StateObject private var viewModel = SearchViewModel()
    @Binding var searchText: String
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                LoadingView()
            } else if let error = viewModel.error {
                EmptyPlaceholderView(
                    icon: "exclamationmark.triangle",
                    title: "搜索失败",
                    message: error.localizedDescription
                )
            } else if viewModel.articles.isEmpty {
                if searchText.isEmpty {
                    recentSearchesView
                } else {
                    EmptyPlaceholderView(
                        icon: "magnifyingglass",
                        title: "未找到相关文章",
                        message: "换个关键词试试"
                    )
                }
            } else {
                searchResultList
            }
        }
        .task {
            // 视图加载时获取热词
            await viewModel.loadHotKeys()
        }
        .onChange(of: searchText) { newValue in
            // 当搜索文本变化时，立即搜索
            Task {
                HiLog.i("执行搜索，关键词：\(newValue)")
                viewModel.searchText = newValue
                await viewModel.search(keyword: newValue)
            }
        }
    }
    
    private var recentSearchesView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // 热门搜索
                if !viewModel.hotKeys.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("热门搜索")
                            .font(.headline)
                        
                        FlowLayout(spacing: 8) {
                            ForEach(viewModel.hotKeys) { hotKey in
                                Button {
                                    searchText = hotKey.name
                                } label: {
                                    Text(hotKey.name)
                                        .font(.subheadline)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.blue.opacity(0.1))
                                        .foregroundColor(.blue)
                                        .cornerRadius(16)
                                }
                            }
                        }
                    }
                    
                    Divider()
                }
                
                // 搜索历史
                if !viewModel.recentSearches.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("搜索历史")
                                .font(.headline)
                            Spacer()
                            Button {
                                viewModel.clearRecentSearches()
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        FlowLayout(spacing: 8) {
                            ForEach(viewModel.recentSearches, id: \.self) { keyword in
                                Button {
                                    searchText = keyword
                                } label: {
                                    Text(keyword)
                                        .font(.subheadline)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(16)
                                }
                            }
                        }
                    }
                }
                
                if viewModel.hotKeys.isEmpty && viewModel.recentSearches.isEmpty {
                    EmptyPlaceholderView(
                        icon: "magnifyingglass",
                        title: "输入关键词搜索",
                        message: "试试搜索感兴趣的内容"
                    )
                }
            }
            .padding()
        }
    }
    
    private var searchResultList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.articles) { article in
                    ArticleCard(article: article)
                        .padding(.horizontal)
                }
                
                if viewModel.hasMore {
                    loadMoreButton
                }
            }
            .padding(.vertical)
        }
    }
    
    private var loadMoreButton: some View {
        HStack {
            Spacer()
            Button {
                Task {
                    await viewModel.loadMore(keyword: searchText)
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
