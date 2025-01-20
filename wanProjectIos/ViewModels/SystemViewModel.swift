//
//  SystemViewModel.swift
//  wanProjectIos
//
//  Created by neillwu on 2025/1/17.
//

import Foundation

@MainActor
class SystemViewModel: ObservableObject {
    static let shared = SystemViewModel()
    
    @Published private(set) var categories: [SystemCategory] = []
    @Published var selectedCategory: SystemCategory?
    @Published var selectedChild: SystemCategory?
    @Published var articles: [Article] = []
    @Published private(set) var isLoading = false
    @Published var error: Error?
    @Published var currentPage = 0
    @Published var hasMoreData = true
    
    private let apiService = ApiService.shared
    private var loadingTask: Task<Void, Never>?
    
    deinit {
        loadingTask?.cancel()
    }
    
    private init() {}
    
    func fetchCategories() async {
        loadingTask?.cancel()
        
        loadingTask = Task {
            isLoading = true
            do {
                let response = try await apiService.request(
                    "/tree/json",
                    method: .get,
                    responseType: ApiResponse<[SystemCategory]>.self
                )
                
                if !Task.isCancelled {
                    if response.errorCode == 0 {
                        categories = response.data
                        if let first = response.data.first {
                            self.selectedCategory = first
                            if let firstChild = first.children?.first {
                                self.selectedChild = firstChild
                                await fetchArticles(cid: firstChild.id, page: 0)
                            }
                        }
                        HiLog.i("体系分类获取成功: \(response.data.count) 个")
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
    
    func fetchArticles(cid: Int, page: Int) async {
        if page == 0 {
            isLoading = true
        }
        error = nil
        
        do {
            let response: ApiResponse<ArticleList> = try await withCheckedThrowingContinuation { continuation in
                apiService.fetchSystemArticles(page: page, cid: cid) { result in
                    switch result {
                    case .success(let response):
                        continuation.resume(returning: response)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            }
            
            if response.errorCode == 0 {
                if page == 0 {
                    self.articles = response.data.datas
                } else {
                    self.articles.append(contentsOf: response.data.datas)
                }
                self.currentPage = response.data.curPage
                self.hasMoreData = !response.data.over
                HiLog.i("体系文章获取成功: \(response.data.datas.count) 篇")
            } else {
                self.error = ApiError.message(response.errorMsg)
                HiLog.w("体系文章获取失败: \(response.errorMsg)")
            }
        } catch {
            self.error = error
            HiLog.e("体系文章请求异常: \(error)")
        }
        
        isLoading = false
    }
}