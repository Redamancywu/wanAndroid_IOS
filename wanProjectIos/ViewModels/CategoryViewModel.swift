//
//  CategoryViewModel.swift
//  wanProjectIos
//
//  Created by neillwu on 2025/1/17.
//

import Foundation

@MainActor
class CategoryViewModel: ObservableObject {
    static let shared = CategoryViewModel()
    
    @Published var selectedAuthor: WeChatAuthor?
    @Published var authors: [WeChatAuthor] = []
    @Published var authorArticles: [Article] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @Published var qaList: [QA] = []
    @Published var columns: [Column] = []
    @Published var routes: [Route] = []
    
    @Published var squareArticles: [SquareArticle] = []
    @Published var currentPage = 0
    @Published var hasMoreData = true
    
    private let apiService = ApiService.shared
    
    private init() {
        // 私有初始化器
    }
    
    func fetchAuthors() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response: ApiResponse<[WeChatAuthor]> = try await withCheckedThrowingContinuation { continuation in
                apiService.fetchWeChatAuthors { result in
                    switch result {
                    case .success(let response):
                        continuation.resume(returning: response)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            }
            
            if response.errorCode == 0 {
                self.authors = response.data
                // 选择第一个作者作为默认选中并加载其文章
                if let firstAuthor = response.data.first {
                    self.selectedAuthor = firstAuthor
                    await fetchAuthorArticles(author: firstAuthor.name, page: 0)
                }
                HiLog.i("公众号作者获取成功: \(response.data.count) 个")
            } else {
                self.errorMessage = response.errorMsg
                HiLog.w("公众号作者获取失败: \(response.errorMsg)")
            }
        } catch {
            self.errorMessage = error.localizedDescription
            HiLog.e("公众号作者请求异常: \(error)")
        }
        
        isLoading = false
    }
    
    func fetchAuthorArticles(author: String, page: Int) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response: ApiResponse<ArticleList> = try await withCheckedThrowingContinuation { continuation in
                apiService.fetchAuthorArticles(author: author, page: page) { result in
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
                    self.authorArticles = response.data.datas
                } else {
                    self.authorArticles.append(contentsOf: response.data.datas)
                }
                HiLog.i("作者文章获取成功: \(response.data.datas.count) 篇")
            } else {
                self.errorMessage = response.errorMsg
                HiLog.w("作者文章获取失败: \(response.errorMsg)")
            }
        } catch {
            self.errorMessage = error.localizedDescription
            HiLog.e("作者文章请求异常: \(error)")
        }
        
        isLoading = false
    }
    
    func fetchQAList() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response: ApiResponse<[QA]> = try await withCheckedThrowingContinuation { continuation in
                apiService.fetchQAList { result in
                    switch result {
                    case .success(let response):
                        continuation.resume(returning: response)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            }
            
            if response.errorCode == 0 {
                self.qaList = response.data
                HiLog.i("问答列表获取成功: \(response.data.count) 个")
            } else {
                self.errorMessage = response.errorMsg
                HiLog.w("问答列表获取失败: \(response.errorMsg)")
            }
        } catch {
            self.errorMessage = error.localizedDescription
            HiLog.e("问答列表请求异常: \(error)")
        }
        
        isLoading = false
    }
    
    func fetchColumns() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response: ApiResponse<[Column]> = try await withCheckedThrowingContinuation { continuation in
                apiService.fetchColumns { result in
                    switch result {
                    case .success(let response):
                        continuation.resume(returning: response)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            }
            
            if response.errorCode == 0 {
                self.columns = response.data
                HiLog.i("专栏列表获取成功: \(response.data.count) 个")
            } else {
                self.errorMessage = response.errorMsg
                HiLog.w("专栏列表获取失败: \(response.errorMsg)")
            }
        } catch {
            self.errorMessage = error.localizedDescription
            HiLog.e("专栏列表请求异常: \(error)")
        }
        
        isLoading = false
    }
    
    func fetchRoutes() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response: ApiResponse<[Route]> = try await withCheckedThrowingContinuation { continuation in
                apiService.fetchRoutes { result in
                    switch result {
                    case .success(let response):
                        continuation.resume(returning: response)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            }
            
            if response.errorCode == 0 {
                self.routes = response.data
                HiLog.i("路线列表获取成功: \(response.data.count) 个")
            } else {
                self.errorMessage = response.errorMsg
                HiLog.w("路线列表获取失败: \(response.errorMsg)")
            }
        } catch {
            self.errorMessage = error.localizedDescription
            HiLog.e("路线列表请求异常: \(error)")
        }
        
        isLoading = false
    }
    
    func fetchSquareArticles(page: Int) async {
        if page == 0 {
            isLoading = true
        }
        errorMessage = nil
        
        do {
            let response: ApiResponse<SquareArticleList> = try await withCheckedThrowingContinuation { continuation in
                apiService.fetchSquareArticles(page: page) { result in
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
                    self.squareArticles = response.data.datas
                } else {
                    self.squareArticles.append(contentsOf: response.data.datas)
                }
                self.currentPage = response.data.curPage
                self.hasMoreData = !response.data.over
                HiLog.i("广场文章获取成功: \(response.data.datas.count) 篇")
            } else {
                self.errorMessage = response.errorMsg
                HiLog.w("广场文章获取失败: \(response.errorMsg)")
            }
        } catch {
            self.errorMessage = error.localizedDescription
            HiLog.e("广场文章请求异常: \(error)")
        }
        
        isLoading = false
    }
} 