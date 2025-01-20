import Foundation
import SwiftUI

@MainActor
class CoinViewModel: ObservableObject {
    @Published private(set) var records: [CoinRecord] = []
    @Published private(set) var isLoading = false
    @Published private(set) var hasMoreData = true
    @Published var errorMessage: String?
    
    private let apiService = UserApiService.shared
    private var currentPage = 1
    
    var coinInfo: CoinInfo? {
        didSet {
            objectWillChange.send()
        }
    }
    
    func refresh() async {
        currentPage = 1
        records.removeAll()
        hasMoreData = true
        await fetchRecords()
    }
    
    func loadMore() async {
        guard hasMoreData && !isLoading else { return }
        currentPage += 1
        await fetchRecords()
    }
    
    private func fetchRecords() async {
        isLoading = true
        do {
            let newRecords = try await apiService.fetchCoinRecords(page: currentPage)
            if currentPage == 1 {
                records = newRecords
            } else {
                records.append(contentsOf: newRecords)
            }
            hasMoreData = !newRecords.isEmpty
        } catch {
            errorMessage = error.localizedDescription
            hasMoreData = false
        }
        isLoading = false
    }
} 