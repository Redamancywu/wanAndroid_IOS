import Foundation

@MainActor
class SquareViewModel: ObservableObject {
    @Published private(set) var articles: [SquareArticle] = []
    @Published private(set) var isLoading = false
    @Published var error: Error?
    @Published private(set) var hasMoreData = true
    private(set) var currentPage = 0
    
    private let apiService = ApiService.shared
    
    func fetchSquareArticles(page: Int) async {
        if page == 0 {
            articles.removeAll()
            currentPage = 0
            hasMoreData = true
        }
        
        guard hasMoreData && !isLoading else { return }
        isLoading = true
        error = nil
        
        do {
            let response = try await apiService.request(
                "/user_article/list/\(page)/json",
                method: .get,
                responseType: ApiResponse<SquareArticleList>.self
            )
            
            if response.errorCode == 0 {
                let newArticles = response.data.datas
                if page == 0 {
                    articles = newArticles
                } else {
                    articles.append(contentsOf: newArticles)
                }
                currentPage = page
                hasMoreData = !newArticles.isEmpty
            } else {
                throw ApiError.message(response.errorMsg)
            }
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
} 
