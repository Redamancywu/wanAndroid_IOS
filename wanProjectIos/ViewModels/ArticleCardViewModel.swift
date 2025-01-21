import Foundation
import SwiftUI

@MainActor
class ArticleCardViewModel: ObservableObject {
    @Published var isCollected: Bool = false
    @Published var showLoginAlert = false
    
    private let userState = UserState.shared
    
    func toggleCollect(article: Article) async throws {
        try await userState.toggleCollect(article: article)
        isCollected.toggle()
    }
    
    func checkCollectionStatus(article: Article) {
        isCollected = userState.isCollected(articleId: article.id)
    }
} 