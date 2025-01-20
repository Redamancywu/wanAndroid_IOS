//
//  ProjectViewModel.swift
//  wanProjectIos
//
//  Created by neillwu on 2025/1/17.
//

import Foundation

@MainActor
class ProjectViewModel: ObservableObject {
    @Published var categories: [ProjectCategory] = []
    @Published var crossPlatformArticles: [Article] = []
    @Published var resourceArticles: [Article] = []
    @Published var projectArticles: [Article] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiService = ApiService.shared
    private var hasLoadedCategories = false
    private var hasLoadedCrossPlatform = false
    private var hasLoadedResource = false
    private var hasLoadedProjects = false
    
    // 添加分页相关属性
    private var currentPage = 0
    private let pageSize = 10
    private var isLoadingMore = false
    private var hasMoreData = true
    
    private enum CategoryType {
        case crossPlatform
        case resource
        case project
    }
    
    enum LoadingState {
        case idle
        case loading
        case loaded
        case error(String)
    }
    
    @Published private(set) var loadingState = LoadingState.idle
    
    init() {
        HiLog.i("ProjectViewModel initialized")
        Task {
            await loadInitialData()
        }
    }
    
    // 公开的初始化加载方法
    func loadInitialData() async {
        guard !hasLoadedCategories else {
            HiLog.i("项目分类数据已加载，跳过")
            return
        }
        
        isLoading = true
        await loadCategories()
        isLoading = false
        hasLoadedCategories = true
    }
    
    // 刷新数据的方法
    func refreshData() async {
        // 重置加载状态
        hasLoadedCategories = false
        hasLoadedCrossPlatform = false
        hasLoadedResource = false
        hasLoadedProjects = false
        
        // 清除数据
        categories = []
        crossPlatformArticles = []
        resourceArticles = []
        projectArticles = []
        
        // 重新加载
        await loadInitialData()
    }
    
    // 公开的刷新方法
    func loadCategories() async {
        projectArticles = []
        
        guard categories.isEmpty else {
            HiLog.i("分类数据已存在，跳过加载")
            return
        }
        
        isLoading = true
        HiLog.i("开始获取项目分类")
        
        do {
            let response: ApiResponse<[ProjectCategory]> = try await withCheckedThrowingContinuation { continuation in
                apiService.fetchProjectCategories { result in
                    switch result {
                    case .success(let response):
                        continuation.resume(returning: response)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            }
            
            if response.errorCode == 0 {
                self.categories = response.data
                HiLog.i("项目分类获取成功: \(response.data.count) 个分类")
                
                // 并发加载所有需要的数据
                await withTaskGroup(of: Void.self) { group in
                    // 加载跨平台和资源聚合的文章
                    group.addTask {
                        await self.loadCategoryArticles()
                    }
                    
                    // 加载所有项目的文章
                    group.addTask {
                        await self.loadAllProjectArticles()
                    }
                    
                    // 等待所有任务完成
                    await group.waitForAll()
                }
            } else {
                self.errorMessage = response.errorMsg
                HiLog.w("项目分类获取失败: \(response.errorMsg)")
            }
        } catch {
            self.errorMessage = error.localizedDescription
            HiLog.e("项目分类请求失败: \(error)")
        }
        
        isLoading = false
    }
    
    private func loadCategoryArticles() async {
        // 获取跨平台应用分类ID
        if let crossPlatformCategory = categories.first(where: { $0.name == "跨平台应用" }) {
            guard !hasLoadedCrossPlatform else {
                HiLog.i("跨平台应用数据已加载，跳过")
                return
            }
            
            await loadArticles(for: crossPlatformCategory.id, category: .crossPlatform)
            hasLoadedCrossPlatform = true
        }
        
        // 获取资源聚合分类ID
        if let resourceCategory = categories.first(where: { $0.name == "资源聚合类" }) {
            guard !hasLoadedResource else {
                HiLog.i("资源聚合数据已加载，跳过")
                return
            }
            
            await loadArticles(for: resourceCategory.id, category: .resource)
            hasLoadedResource = true
        }
    }
    
    private func loadAllProjectArticles() async {
        guard !hasLoadedProjects else {
            HiLog.i("所有项目数据已加载，跳过")
            return
        }
        
        // 重置分页状态
        currentPage = 0
        hasMoreData = true
        projectArticles = []
        
        // 只加载第一页数据
        if let firstCategory = categories.first {
            await loadArticles(for: firstCategory.id, category: .project, page: 0)
        }
        
        hasLoadedProjects = true
    }
    
    // 添加加载更多数据的方法
    func loadMoreProjects() async {
        guard !isLoadingMore && hasMoreData else { return }
        
        isLoadingMore = true
        
        if let firstCategory = categories.first {
            let nextPage = currentPage + 1
            await loadArticles(for: firstCategory.id, category: .project, page: nextPage)
            currentPage = nextPage
        }
        
        isLoadingMore = false
    }
    
    private func loadArticles(for categoryId: Int, category: CategoryType, page: Int = 0) async {
        let url = "/project/list/\(page + 1)/json?cid=\(categoryId)"
        HiLog.i("开始请求分类文章，URL: \(NetworkManager.shared.baseURL)\(url)")
        
        do {
            let response: ApiResponse<ArticleList> = try await withCheckedThrowingContinuation { continuation in
                apiService.fetchProjectList(page: page, cid: categoryId) { result in
                    switch result {
                    case .success(let response):
                        continuation.resume(returning: response)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            }
            
            if response.errorCode == 0 {
                switch category {
                case .crossPlatform:
                    self.crossPlatformArticles = response.data.datas
                    HiLog.i("跨平台应用文章获取成功: \(response.data.datas.count) 篇")
                    // 打印第一篇文章的详细信息作为示例
                    if let firstArticle = response.data.datas.first {
                        HiLog.i("""
                            跨平台应用第一篇文章:
                            标题: \(firstArticle.title)
                            作者: \(firstArticle.author ?? "无")
                            描述: \(firstArticle.desc ?? "无")
                            封面图: \(firstArticle.envelopePic ?? "无")
                            项目链接: \(firstArticle.projectLink ?? "无")
                            """)
                    }
                case .resource:
                    self.resourceArticles = response.data.datas
                    HiLog.i("资源聚合文章获取成功: \(response.data.datas.count) 篇")
                    // 打印第一篇文章的详细信息作为示例
                    if let firstArticle = response.data.datas.first {
                        HiLog.i("""
                            资源聚合第一篇文章:
                            标题: \(firstArticle.title)
                            作者: \(firstArticle.author ?? "无")
                            描述: \(firstArticle.desc ?? "无")
                            封面图: \(firstArticle.envelopePic ?? "无")
                            项目链接: \(firstArticle.projectLink ?? "无")
                            """)
                    }
                case .project:
                    if page == 0 {
                        self.projectArticles = response.data.datas
                    } else {
                        self.projectArticles.append(contentsOf: response.data.datas)
                    }
                    // 检查是否还有更多数据
                    hasMoreData = response.data.datas.count >= pageSize
                    HiLog.i("项目文章获取成功: \(response.data.datas.count) 篇，页码: \(page)")
                }
            } else {
                self.errorMessage = response.errorMsg
                HiLog.w("文章列表获取失败: \(response.errorMsg)")
            }
        } catch {
            self.errorMessage = error.localizedDescription
            HiLog.e("文章列表请求失败: \(error)")
        }
    }
    
    private func handleError(_ error: Error, operation: String) {
        let errorMessage: String
        if let networkError = error as? NetworkError {
            switch networkError {
            case .invalidURL:
                errorMessage = "无效的URL地址"
            case .requestFailed(let error):
                errorMessage = "请求失败: \(error.localizedDescription)"
            case .noData:
                errorMessage = "服务器未返回数据"
            case .decodingFailed(let error):
                errorMessage = "数据解析失败: \(error.localizedDescription)"
            }
        } else {
            errorMessage = error.localizedDescription
        }
        
        HiLog.e("\(operation)失败: \(errorMessage)")
        self.loadingState = .error(errorMessage)
    }
} 