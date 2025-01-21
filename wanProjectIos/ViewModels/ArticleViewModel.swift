import SwiftUI
import Foundation

@MainActor
class ArticleViewModel: ObservableObject {
    @Published var isCollected = false
    private let userState = UserState.shared
    
    func checkCollectionStatus(articleId: Int) {
        isCollected = userState.isCollected(articleId: articleId)
    }
    
    func toggleCollect(articleId: Int) async {
        do {
            try await userState.toggleCollect(articleId: articleId)
            isCollected.toggle()
        } catch {
            HiLog.e("收藏失败: \(error)")
        }
    }
} 