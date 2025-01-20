import Foundation
import SwiftUI

@MainActor
class WeChatAccountViewModel: ObservableObject {
    @Published private(set) var accounts: [WeChatArticle] = []
    @Published private(set) var isLoading = false
    @Published var error: Error?
    
    private let apiService = ApiService.shared
    private var loadingTask: Task<Void, Never>?
    
    deinit {
        loadingTask?.cancel()
    }
    
    func fetchAccounts() async {
        loadingTask?.cancel()
        
        loadingTask = Task {
            isLoading = true
            do {
                let response = try await apiService.request(
                    "/wxarticle/chapters/json",
                    method: .get,
                    responseType: ApiResponse<[WeChatArticle]>.self
                )
                
                if !Task.isCancelled {
                    if response.errorCode == 0 {
                        accounts = response.data
                    } else {
                        throw ApiError.message(response.errorMsg)
                    }
                }
            } catch {
                if !Task.isCancelled {
                    self.error = error
                }
            }
            
            if !Task.isCancelled {
                isLoading = false
            }
        }
    }
} 