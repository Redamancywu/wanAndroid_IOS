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
    
    private enum CategoryType {
        case crossPlatform
        case resource
        case project
    }
    
    init() {
        Task {
            await loadCategories()
        }
    }
    
    func loadCategories() async {
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
                await loadCategoryArticles()
                await loadAllProjectArticles()
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
            await loadArticles(for: crossPlatformCategory.id, category: .crossPlatform)
        }
        
        // 获取资源聚合分类ID
        if let resourceCategory = categories.first(where: { $0.name == "资源聚合类" }) {
            await loadArticles(for: resourceCategory.id, category: .resource)
        }
    }
    
    private func loadAllProjectArticles() async {
        for category in categories {
            await loadArticles(for: category.id, category: .project)
        }
    }
    
    private func loadArticles(for categoryId: Int, category: CategoryType) async {
        HiLog.i("开始获取分类 \(categoryId) 的文章列表")
        
        do {
            let response: ApiResponse<ArticleList> = try await withCheckedThrowingContinuation { continuation in
                apiService.fetchProjectList(page: 0, cid: categoryId) { result in
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
                case .resource:
                    self.resourceArticles = response.data.datas
                    HiLog.i("资源聚合文章获取成功: \(response.data.datas.count) 篇")
                case .project:
                    self.projectArticles.append(contentsOf: response.data.datas)
                    HiLog.i("项目文章获取成功: \(response.data.datas.count) 篇")
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
} 