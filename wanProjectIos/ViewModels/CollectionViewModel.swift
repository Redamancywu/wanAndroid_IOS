import Foundation
import SwiftUI

@MainActor
class CollectionViewModel: ObservableObject {
    @Published var articles: [Article] = []
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var hasMore = true
    @Published var error: Error?
    
    private var currentPage = 0
    private let pageSize = 20
    private let apiService = ApiService.shared
    private let userState = UserState.shared
    
    func loadCollections() async {
        guard !isLoading else { return }
        guard userState.isLoggedIn else {
            HiLog.e("未登录状态")
            articles = []
            error = UserError.needLogin
            return
        }
        
        isLoading = true
        currentPage = 0
        error = nil
        
        // 添加重试机制
        for attempt in 1...3 {
            do {
                HiLog.i("开始加载收藏列表，页码：\(currentPage)，尝试次数：\(attempt)")
                let articleList = try await apiService.fetchCollectedArticles(page: currentPage, pageSize: pageSize)
                articles = articleList.datas
                hasMore = !articleList.over
                HiLog.i("加载收藏列表成功，文章数：\(articles.count)")
                
                if articles.isEmpty {
                    HiLog.i("收藏列表为空")
                } else {
                    // 打印部分文章信息用于调试
                    for (index, article) in articles.prefix(3).enumerated() {
                        HiLog.i("文章[\(index)]: id=\(article.id), title=\(article.title), originId=\(article.originId ?? -1)")
                    }
                }
                break // 成功后跳出重试循环
            } catch {
                HiLog.e("加载收藏列表失败(尝试\(attempt)): \(error)")
                if attempt == 3 {
                    self.error = error
                    articles = []
                    hasMore = false
                } else {
                    try? await Task.sleep(nanoseconds: UInt64(1_000_000_000 * attempt)) // 延迟重试
                    continue
                }
            }
        }
        
        isLoading = false
    }
    
    func loadMore() async {
        guard !isLoadingMore && hasMore else { return }
        isLoadingMore = true
        
        do {
            let nextPage = currentPage + 1
            let articleList = try await apiService.fetchCollectedArticles(page: nextPage, pageSize: pageSize)
            articles.append(contentsOf: articleList.datas)
            hasMore = !articleList.over
            currentPage = nextPage
            error = nil
        } catch {
            self.error = error
            HiLog.e("加载更多收藏失败: \(error)")
        }
        
        isLoadingMore = false
    }
    
    func uncollect(articleId: Int, originId: Int?) async {
        do {
            HiLog.i("开始取消收藏，articleId: \(articleId), originId: \(originId ?? -1)")
            
            // 使用正确的 originId
            try await apiService.uncollectFromMyCollections(articleId, originId: originId ?? -1)
            
            // 先从列表中移除
            withAnimation {
                articles.removeAll { $0.id == articleId }
            }
            
            // 更新 UserState 中的收藏状态
            try? await userState.toggleCollect(articleId: articleId)
            
            HiLog.i("取消收藏成功，剩余文章数：\(articles.count)")
        } catch {
            HiLog.e("取消收藏失败: \(error)")
        }
    }
    
    init() {
        setupNotifications()
    }
    
    private func setupNotifications() {
        // 监听收藏状态变化
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleCollectionChanged),
            name: .articleCollectionChanged,
            object: nil
        )
        
        // 监听登录状态变化
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLoginStatusChanged),
            name: .userLoginStatusChanged,
            object: nil
        )
    }
    
    @objc private func handleCollectionChanged() {
        Task { @MainActor in
            HiLog.i("收到收藏变化通知，重新加载列表")
            // 添加延迟以确保服务器数据已更新
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒延迟
            await loadCollections()
        }
    }
    
    @objc private func handleLoginStatusChanged() {
        Task { @MainActor in
            HiLog.i("收到登录状态变化通知，重新加载列表")
            await loadCollections()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
} 