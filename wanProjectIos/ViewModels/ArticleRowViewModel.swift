import Foundation

@MainActor
class ArticleRowViewModel: ObservableObject {
    @Published var isCollected: Bool = false
    @Published var showLoginAlert = false
    
    private let userState = UserState.shared
    private let apiService = ApiService.shared
    
    func toggleCollect(article: Article) async throws {
        try await userState.toggleCollect(article: article)
        isCollected.toggle()
    }
    
    func checkCollectionStatus(article: Article) {
        isCollected = userState.isCollected(articleId: article.id)
    }
} 