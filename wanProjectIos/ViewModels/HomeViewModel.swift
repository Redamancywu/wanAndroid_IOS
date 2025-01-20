//
//  HomeViewModel.swift
//  wanProjectIos
//
//  Created by neillwu on 2025/1/17.
//

import Foundation

@MainActor
class HomeViewModel: ObservableObject {
    @Published private(set) var banners: [Banner] = []
    @Published private(set) var articles: [Article] = []
    @Published var harmonyArticles: [Article] = []
    @Published var recommendArticles: [Article] = []
    @Published private(set) var isLoading = false
    @Published var error: Error?  // 添加错误属性
    @Published var errorMessage: String?
    @Published var tutorials: [Tutorial] = []
    
    private let apiService = ApiService.shared
    
    // 添加数据加载状态标记
    private var hasLoadedBanners = false
    private var hasLoadedArticles = false
    private var hasLoadedHarmonyArticles = false
    private var hasLoadedTutorialArticles = false
    
    // 分页相关属性
    private var currentRecommendPage = 0
    private let pageSize = 10
    private var isLoadingMore = false
    private var hasMoreData = true
    
    // 添加一个标记来追踪是否是首次加载
    private var isInitialLoad = true
    
    init() {
        HiLog.i("HomeViewModel initialized")
        Task {
            await loadInitialData()
        }
    }
    
    func loadInitialData() async {
        // 如果不是首次加载且数据已存在，直接返回
        if !isInitialLoad && !banners.isEmpty {
            HiLog.i("数据已加载，跳过重复加载")
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // 使用 TaskGroup 并发加载所有数据
        await withTaskGroup(of: Void.self) { group in
            // Banner数据
            group.addTask {
                await self.fetchBanners()
            }
            
            // 文章列表
            group.addTask {
                await self.fetchArticles(page: 0)
            }
            
            // 推荐文章
            group.addTask {
                await self.fetchRecommendArticles(page: 0)
            }
            
            // 鸿蒙专栏
            group.addTask {
                await self.fetchHarmonyArticles()
            }
            
            // 教程列表
            group.addTask {
                await self.fetchTutorials()
            }
            
            // 等待所有任务完成
            await group.waitForAll()
        }
        
        isLoading = false
        hasLoadedBanners = true
        isInitialLoad = false  // 标记首次加载完成
    }
    
    func fetchBanners() async {
        isLoading = true
        HiLog.i("开始获取Banner数据")
        
        do {
            let response: BannerResponse = try await withCheckedThrowingContinuation { continuation in
                apiService.fetchBanners { result in
                    switch result {
                    case .success(let response):
                        continuation.resume(returning: response)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            }
            
            isLoading = false
            if response.errorCode == 0 {
                self.banners = response.data
                HiLog.i("Banner数据获取成功: 获取到 \(response.data.count) 条数据")
            } else {
                self.errorMessage = response.errorMsg
                HiLog.w("Banner数据获取失败: \(response.errorMsg)")
            }
        } catch {
            isLoading = false
            self.errorMessage = error.localizedDescription
            HiLog.e("Banner请求异常: \(error)")
        }
    }
    
    func fetchArticles(page: Int) async {
        guard !hasLoadedArticles else {
            HiLog.i("文章列表数据已加载，跳过")
            return
        }
        
        HiLog.i("开始获取文章列表，页码: \(page)")
        
        do {
            let response: ArticleResponse = try await withCheckedThrowingContinuation { continuation in
                apiService.fetchArticles(page: page) { result in
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
                    HiLog.i("首页文章列表获取成功: 获取到 \(response.data.datas.count) 条数据")
                } else {
                    self.articles.append(contentsOf: response.data.datas)
                    HiLog.i("加载更多文章成功: 新增 \(response.data.datas.count) 条数据")
                }
            } else {
                self.errorMessage = response.errorMsg
                HiLog.w("文章列表获取失败: \(response.errorMsg)")
            }
        } catch {
            self.errorMessage = error.localizedDescription
            HiLog.e("文章列表请求异常: \(error)")
        }
        hasLoadedArticles = true
    }
    
    func fetchHarmonyArticles() async {
        guard !hasLoadedHarmonyArticles else {
            HiLog.i("鸿蒙专栏数据已加载，跳过")
            return
        }
        
        HiLog.i("开始获取鸿蒙专栏数据")
        
        do {
            let response: HarmonyResponse = try await withCheckedThrowingContinuation { continuation in
                apiService.fetchHarmonyArticles { result in
                    switch result {
                    case .success(let response):
                        continuation.resume(returning: response)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            }
            
            if response.errorCode == 0 {
                if let links = response.data.links {
                    self.harmonyArticles = links.articleList
                    HiLog.i("鸿蒙专栏数据获取成功: \(links.articleList.count) 篇")
                }
            } else {
                self.errorMessage = response.errorMsg
                HiLog.w("鸿蒙专栏数据获取失败: \(response.errorMsg)")
            }
        } catch {
            self.errorMessage = error.localizedDescription
            HiLog.e("鸿蒙专栏请求异常: \(error)")
        }
        hasLoadedHarmonyArticles = true
    }
    
    func fetchRecommendArticles(page: Int) async {
        HiLog.i("开始获取推荐文章列表，页码: \(page)")
        
        do {
            let response: ArticleResponse = try await withCheckedThrowingContinuation { continuation in
                apiService.fetchArticles(page: page) { result in
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
                    self.recommendArticles = response.data.datas
                    currentRecommendPage = 0
                } else {
                    self.recommendArticles.append(contentsOf: response.data.datas)
                }
                hasMoreData = response.data.datas.count >= pageSize
                HiLog.i("推荐文章获取成功: \(response.data.datas.count) 篇，页码: \(page)")
            } else {
                self.errorMessage = response.errorMsg
                HiLog.w("推荐文章列表获取失败: \(response.errorMsg)")
            }
        } catch {
            self.errorMessage = error.localizedDescription
            HiLog.e("推荐文章列表请求异常: \(error)")
        }
    }
    
    func fetchTutorials() async {
        guard !hasLoadedTutorialArticles else {
            HiLog.i("教程数据已加载，跳过")
            return
        }
        
        HiLog.i("开始获取教程列表")
        
        do {
            let response: ApiResponse<[Tutorial]> = try await withCheckedThrowingContinuation { continuation in
                apiService.fetchTutorials { result in
                    switch result {
                    case .success(let response):
                        continuation.resume(returning: response)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            }
            
            if response.errorCode == 0 {
                self.tutorials = response.data
                HiLog.i("教程列表获取成功: \(response.data.count) 个教程")
            } else {
                self.errorMessage = response.errorMsg
                HiLog.w("教程列表获取失败: \(response.errorMsg)")
            }
        } catch {
            self.errorMessage = error.localizedDescription
            HiLog.e("教程列表请求异常: \(error)")
        }
        hasLoadedTutorialArticles = true
    }
    
    // 刷新方法需要重置初始加载标记
    func refreshData() async {
        isLoading = true
        error = nil
        
        do {
            async let bannersResponse = apiService.request(
                "/banner/json",
                method: .get,
                responseType: ApiResponse<[Banner]>.self
            )
            async let articlesResponse = apiService.request(
                "/article/list/0/json",
                method: .get,
                responseType: ApiResponse<ArticleList>.self
            )
            
            let (bannerResult, articleResult) = await (try bannersResponse, try articlesResponse)
            
            if bannerResult.errorCode == 0 {
                banners = bannerResult.data
            } else {
                throw ApiError.message(bannerResult.errorMsg)
            }
            
            if articleResult.errorCode == 0 {
                articles = articleResult.data.datas
            } else {
                throw ApiError.message(articleResult.errorMsg)
            }
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    func refresh() async {
        await refreshData()
    }
    
    // 加载更多推荐文章
    func loadMoreRecommendArticles() async {
        guard !isLoadingMore && hasMoreData else { return }
        
        isLoadingMore = true
        let nextPage = currentRecommendPage + 1
        await fetchRecommendArticles(page: nextPage)
        currentRecommendPage = nextPage
        isLoadingMore = false
    }
} 