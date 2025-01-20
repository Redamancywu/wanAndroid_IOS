import Foundation

@MainActor
class ArticleRowViewModel: ObservableObject {
    @Published private(set) var isCollected = false
    @Published var showLoginAlert = false
    
    private let userState = UserState.shared
    private let apiService = ApiService.shared
    
    func checkCollectionStatus(articleId: Int) {
        isCollected = userState.isCollected(articleId: articleId)
    }
    
    func toggleCollect(articleId: Int) async {
        guard userState.isLoggedIn else {
            showLoginAlert = true
            return
        }
        
        do {
            try await userState.toggleCollect(articleId: articleId)
            isCollected.toggle()
            HiLog.i("文章\(articleId)收藏状态更新: \(isCollected)")
        } catch {
            HiLog.e("收藏操作失败: \(error.localizedDescription)")
        }
    }
} 