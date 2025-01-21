import SwiftUI
import Foundation

@MainActor
class ArticleViewModel: ObservableObject {
    @Published var isCollected: Bool = false
    private let userState = UserState.shared
    
    func toggleCollect(article: Article) async throws {
        try await userState.toggleCollect(article: article)
        isCollected.toggle()
    }
    
    func checkCollectionStatus(article: Article) {
        isCollected = userState.isCollected(articleId: article.id)
    }
} 