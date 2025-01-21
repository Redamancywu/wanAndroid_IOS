import SwiftUI
import Foundation
@MainActor
class SearchViewModel: ObservableObject {
    @Published var articles: [Article] = []
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var hasMore = true
    @Published var error: Error?
    @Published var hotKeys: [HotKey] = []
    @Published var recentSearches: [String] = []
    @Published var searchText: String = ""
    
    private var currentPage = 0
    private let pageSize = 20
    private let apiService = ApiService.shared
    private let userDefaults = UserDefaults.standard
    private let maxRecentSearches = 8
    
    init() {
        loadRecentSearches()
    }
    
    func search(keyword: String) async {
        guard !keyword.trimmingCharacters(in: .whitespaces).isEmpty else {
            articles = []
            return
        }
        
        guard !isLoading else { return }
        isLoading = true
        currentPage = 0
        error = nil
        
        do {
            HiLog.i("开始搜索，关键词：\(keyword)")
            let articleList = try await apiService.searchArticles(
                keyword: keyword,
                page: currentPage,
                pageSize: pageSize
            )
            articles = articleList.datas
            hasMore = !articleList.over
            HiLog.i("搜索成功，找到文章数：\(articles.count)")
            
            // 保存搜索记录
            addToRecentSearches(keyword)
        } catch {
            self.error = error
            articles = []
            hasMore = false
            HiLog.e("搜索失败: \(error)")
        }
        
        isLoading = false
    }
    
    func loadMore(keyword: String) async {
        guard !isLoadingMore && hasMore && !keyword.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        isLoadingMore = true
        
        do {
            let nextPage = currentPage + 1
            let articleList = try await apiService.searchArticles(
                keyword: keyword,
                page: nextPage,
                pageSize: pageSize
            )
            articles.append(contentsOf: articleList.datas)
            hasMore = !articleList.over
            currentPage = nextPage
            error = nil
        } catch {
            self.error = error
            HiLog.e("加载更多失败: \(error)")
        }
        
        isLoadingMore = false
    }
    
    // MARK: - Recent Searches
    private func loadRecentSearches() {
        if let searches = userDefaults.stringArray(forKey: "RecentSearches") {
            recentSearches = searches
        }
    }
    
    private func addToRecentSearches(_ keyword: String) {
        let trimmed = keyword.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty {
            // 移除已存在的相同关键词
            recentSearches.removeAll { $0 == trimmed }
            // 添加到开头
            recentSearches.insert(trimmed, at: 0)
            // 保持最大数量
            if recentSearches.count > maxRecentSearches {
                recentSearches = Array(recentSearches.prefix(maxRecentSearches))
            }
            // 保存到 UserDefaults
            userDefaults.set(recentSearches, forKey: "RecentSearches")
        }
    }
    
    func clearRecentSearches() {
        recentSearches.removeAll()
        userDefaults.removeObject(forKey: "RecentSearches")
    }
    
    func loadHotKeys() async {
        do {
            HiLog.i("开始加载热词")
            hotKeys = try await apiService.fetchHotKeys()
            HiLog.i("热词加载成功，数量：\(hotKeys.count)")
        } catch {
            HiLog.e("加载热词失败: \(error)")
        }
    }
} 
