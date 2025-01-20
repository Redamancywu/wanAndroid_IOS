import Foundation
import SwiftUI

@MainActor
class ProjectCardViewModel: ObservableObject {
    @Published private(set) var isCollected = false
    @Published var showLoginAlert = false
    
    private let userState = UserState.shared
    
    func toggleCollect(articleId: Int) async {
        do {
            try await userState.toggleCollect(articleId: articleId)
            isCollected = userState.isCollected(articleId: articleId)
        } catch UserError.needLogin {
            showLoginAlert = true
        } catch {
            // 处理其他错误
            print("收藏操作失败: \(error)")
        }
    }
    
    func checkCollectionStatus(articleId: Int) {
        isCollected = userState.isCollected(articleId: articleId)
    }
} 