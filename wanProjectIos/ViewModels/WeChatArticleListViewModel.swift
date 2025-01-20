import Foundation
import SwiftUI

@MainActor
class WeChatArticleListViewModel: ObservableObject {
    @Published private(set) var articles: [Article] = []
    @Published private(set) var isLoading = false
    @Published private(set) var isLoadingMore = false
    @Published private(set) var hasMoreData = true
    @Published var error: Error?
    
    private let apiService = ApiService.shared
    private var currentPage = 1
    private let pageSize = 20
    private var accountId: Int?
    
    func fetchArticles(accountId: Int) async {
        HiLog.i("开始获取公众号文章列表: ID=\(accountId)")
        self.accountId = accountId
        isLoading = true
        currentPage = 1
        
        do {
            let response = try await apiService.request(
                "/wxarticle/list/\(accountId)/\(currentPage)/json",
                method: .get,
                responseType: ApiResponse<ArticleList>.self
            )
            
            if response.errorCode == 0 {
                HiLog.i("获取公众号文章成功: 共\(response.data.datas.count)篇")
                articles = response.data.datas
                hasMoreData = response.data.datas.count >= pageSize
            } else {
                HiLog.e("获取公众号文章失败: \(response.errorMsg)")
                throw ApiError.message(response.errorMsg)
            }
        } catch {
            HiLog.e("获取公众号文章出错: \(error.localizedDescription)")
            self.error = error
        }
        
        isLoading = false
    }
    
    func loadMore() async {
        guard !isLoadingMore,
              hasMoreData,
              let accountId = accountId else { return }
        
        isLoadingMore = true
        do {
            let nextPage = currentPage + 1
            let response = try await apiService.request(
                "/wxarticle/list/\(accountId)/\(nextPage)/json",
                method: .get,
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
        currentPage = 1
        if let accountId = accountId {
            await fetchArticles(accountId: accountId)
        }
    }
} 
