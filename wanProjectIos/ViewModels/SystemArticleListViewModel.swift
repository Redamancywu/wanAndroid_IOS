import SwiftUI
import Foundation

@MainActor
class SystemArticleListViewModel: ObservableObject {
    @Published private(set) var articles: [Article] = []
    @Published private(set) var isLoading = false
    @Published private(set) var isLoadingMore = false
    @Published private(set) var hasMoreData = true
    @Published var error: Error?
    
    private let apiService = ApiService.shared
    private var currentPage = 0
    private let pageSize = 20
    private var categoryId: Int?
    
    func fetchArticles(categoryId: Int) async {
        self.categoryId = categoryId
        isLoading = true
        currentPage = 0
        
        do {
            let response = try await apiService.request(
                "/article/list/\(currentPage)/json",
                method: .get,
                parameters: ["cid": categoryId],
                responseType: ApiResponse<ArticleList>.self
            )
            
            if response.errorCode == 0 {
                articles = response.data.datas
                hasMoreData = response.data.datas.count >= pageSize
            } else {
                throw ApiError.message(response.errorMsg)
            }
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    func loadMore() async {
        guard !isLoadingMore,
              hasMoreData,
              let categoryId = categoryId else { return }
        
        isLoadingMore = true
        do {
            let nextPage = currentPage + 1
            let response = try await apiService.request(
                "/article/list/\(nextPage)/json",
                method: .get,
                parameters: ["cid": categoryId],
                responseType: ApiResponse<ArticleList>.self
            )
            
            if response.errorCode == 0 {
                articles.append(contentsOf: response.data.datas)
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
    
    func refresh() async {
        if let categoryId = categoryId {
            await fetchArticles(categoryId: categoryId)
        }
    }
} 
