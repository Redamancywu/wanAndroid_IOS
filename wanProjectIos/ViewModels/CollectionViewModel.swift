import Foundation
import SwiftUI

@MainActor
class CollectionViewModel: ObservableObject {
    @Published private(set) var articles: [CollectionArticle] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?
    
    private let apiService = UserApiService.shared
    
    func fetchCollections() async {
        isLoading = true
        do {
            articles = try await apiService.fetchCollectedArticles()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

@MainActor
class CollectionArticleViewModel: ObservableObject {
    private let userState = UserState.shared
    
    func uncollect(articleId: Int) async {
        do {
            try await userState.toggleCollect(articleId: articleId)
            // 发送通知，通知收藏列表刷新
            NotificationCenter.default.post(name: .articleCollectionChanged, object: nil)
        } catch {
            print("取消收藏失败: \(error)")
        }
    }
} 