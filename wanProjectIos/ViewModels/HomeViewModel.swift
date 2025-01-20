//
//  HomeViewModel.swift
//  wanProjectIos
//
//  Created by neillwu on 2025/1/17.
//

import Foundation

@MainActor
class HomeViewModel: ObservableObject {
    @Published var banners: [Banner] = []
    @Published var articles: [Article] = []
    @Published var harmonyArticles: [Article] = []
    @Published var recommendArticles: [Article] = []
    @Published var isLoading = false
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
    
    init() {
        HiLog.i("HomeViewModel initialized")
        Task {
            await loadInitialData()
        }
    }
    
    func loadInitialData() async {
        guard !hasLoadedBanners else {
            HiLog.i("Banner数据已加载，跳过")
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
    
    // 添加刷新方法
    func refreshData() async {
        // 重置加载状态
        hasLoadedBanners = false
        hasLoadedArticles = false
        hasLoadedHarmonyArticles = false
        hasLoadedTutorialArticles = false
        
        // 重新加载数据
        await loadInitialData()
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