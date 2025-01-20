import SwiftUI
import Foundation

struct SystemView: View {
    @StateObject private var viewModel = SystemViewModel.shared
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 20, pinnedViews: [.sectionHeaders]) {
                ForEach(viewModel.categories) { category in
                    Section {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(category.children ?? []) { subCategory in
                                CategoryCard(category: subCategory)
                                    .onTapGesture {
                                        viewModel.selectedCategory = category
                                        viewModel.selectedChild = subCategory
                                        Task {
                                            await viewModel.fetchArticles(cid: subCategory.id, page: 0)
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal)
                    } header: {
                        CategoryHeader(category: category)
                    }
                }
            }
            .padding(.vertical)
        }
        .refreshable {
            await viewModel.fetchCategories()
        }
        .overlay {
            if viewModel.isLoading {
                LoadingView("加载中...")
            } else if let error = viewModel.error {
                ErrorView(error: error) {
                    Task {
                        await viewModel.fetchCategories()
                    }
                }
            } else if viewModel.categories.isEmpty {
                EmptyPlaceholderView(
                    icon: "square.grid.2x2",
                    title: "暂无体系",
                    message: "稍后再来看看吧"
                )
            }
        }
        .navigationDestination(isPresented: .init(
            get: { viewModel.selectedChild != nil },
            set: { if !$0 { viewModel.selectedChild = nil } }
        )) {
            if let category = viewModel.selectedCategory,
               let subCategory = viewModel.selectedChild {
                SystemArticleListView(
                    category: category,
                    subCategory: subCategory,
                    articles: viewModel.articles,
                    isLoading: viewModel.isLoading,
                    hasMoreData: viewModel.hasMoreData,
                    loadMore: { await viewModel.fetchArticles(cid: subCategory.id, page: viewModel.currentPage + 1) }
                )
            }
        }
        .task {
            if viewModel.categories.isEmpty {
                await viewModel.fetchCategories()
            }
        }
    }
}

// 分类标题
struct CategoryHeader: View {
    let category: SystemCategory
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.blue)
                    .frame(width: 3, height: 16)
                
                Text(category.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if let count = category.children?.count {
                    Text("(\(count))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            if !category.children.isNilOrEmpty {
                Text(category.children?.map { $0.name }.joined(separator: " · ") ?? "")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

// 分类卡片
struct CategoryCard: View {
    let category: SystemCategory
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(category.name)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if let children = category.children, !children.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "folder")
                        .font(.caption)
                    Text("\(children.count)个子类")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(
                    color: colorScheme == .dark ? Color.clear : Color.black.opacity(0.08),
                    radius: 8,
                    y: 2
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }
}

// 文章列表视图
struct SystemArticleListView: View {
    let category: SystemCategory
    let subCategory: SystemCategory
    let articles: [Article]
    let isLoading: Bool
    let hasMoreData: Bool
    let loadMore: () async -> Void
    
    var body: some View {
        List {
            ForEach(articles) { article in
                ArticleRow(article: article)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
            
            if !articles.isEmpty && hasMoreData {
                Button("加载更多") {
                    Task {
                        await loadMore()
                    }
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(.blue)
                .listRowInsets(EdgeInsets())
            }
        }
        .listStyle(.plain)
        .overlay {
            if isLoading && articles.isEmpty {
                LoadingView("加载中...")
            } else if articles.isEmpty {
                EmptyPlaceholderView(
                    icon: "doc.text",
                    title: "暂无文章",
                    message: "该分类下还没有文章"
                )
            }
        }
        .navigationTitle(subCategory.name)
        .navigationBarTitleDisplayMode(.inline)
    }
} 
