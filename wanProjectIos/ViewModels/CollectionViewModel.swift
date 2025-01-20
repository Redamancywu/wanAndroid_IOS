import Foundation
import SwiftUI

@MainActor
class CollectionViewModel: ObservableObject {
    @Published private(set) var articles: [CollectionArticle] = []
    @Published private(set) var isLoading = false
    @Published var error: Error?
    
    private let userApiService = UserApiService.shared
    
    func fetchCollectedArticles() async {
        isLoading = true
        do {
            let fetchedArticles = try await userApiService.fetchCollectedArticles()
            // 转换 Article 到 CollectionArticle
            articles = fetchedArticles.map { article in
                CollectionArticle(
                    id: article.id,
                    title: article.title,
                    link: article.link,
                    author: article.author,
                    niceDate: article.niceDate,
                    originId: article.id,  // 使用相同的 id
                    publishTime: TimeInterval(article.publishTime / 1000), // 转换为秒
                    desc: article.desc ?? "",
                    chapterName: article.chapterName ?? "",
                    envelopePic: article.envelopePic ?? ""
                )
            }
        } catch {
            self.error = error
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