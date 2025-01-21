import SwiftUI
import Foundation

@MainActor
class HomeRecommendViewModel: ObservableObject {
    @Published var articles: [Article] = []
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var hasMore = true
    @Published var error: Error?
    
    private var currentPage = 0
    private let pageSize = 20
    private let apiService = ApiService.shared
    
    func loadArticles() async {
        guard !isLoading else { return }
        isLoading = true
        
        do {
            let response: ApiResponse<ArticleList> = try await apiService.request(
                "/article/list/0/json",
                method: .get,
                responseType: ApiResponse<ArticleList>.self
            )
            
            if response.errorCode == 0 {
                articles = response.data.datas
                hasMore = !response.data.over
                currentPage = 0
            } else {
                throw ApiError.message(response.errorMsg)
            }
        } catch {
            self.error = error
            HiLog.e("加载推荐文章失败: \(error)")
        }
        
        isLoading = false
    }
    
    func loadMore() async {
        guard !isLoadingMore && hasMore else { return }
        isLoadingMore = true
        
        do {
            let nextPage = currentPage + 1
            let response: ApiResponse<ArticleList> = try await apiService.request(
                "/article/list/\(nextPage)/json",
                method: .get,
                responseType: ApiResponse<ArticleList>.self
            )
            
            if response.errorCode == 0 {
                articles.append(contentsOf: response.data.datas)
                hasMore = !response.data.over
                currentPage = nextPage
            } else {
                throw ApiError.message(response.errorMsg)
            }
        } catch {
            self.error = error
            HiLog.e("加载更多推荐文章失败: \(error)")
        }
        
        isLoadingMore = false
    }
    
    func refresh() async {
        await loadArticles()
    }
} 
