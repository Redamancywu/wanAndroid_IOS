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
    
    init() {
        HiLog.i("HomeViewModel initialized")
        Task {
            await loadInitialData()
        }
    }
    
    func loadInitialData() async {
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
    }
    
    func fetchHarmonyArticles() async {
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
                    HiLog.i("推荐文章列表获取成功: 获取到 \(response.data.datas.count) 条数据")
                } else {
                    self.recommendArticles.append(contentsOf: response.data.datas)
                    HiLog.i("加载更多推荐文章成功: 新增 \(response.data.datas.count) 条数据")
                }
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
    }
} 