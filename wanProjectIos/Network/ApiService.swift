//
//  ApiService.swift
//  wanProjectIos
//
//  Created by neillwu on 2025/1/17.
//

import Foundation

// 导入响应类型
typealias BannerResponse = ApiResponse<[Banner]>
typealias ArticleResponse = ApiResponse<ArticleList>
typealias ProjectCategoryResponse = ApiResponse<[ProjectCategory]>
typealias HarmonyResponse = ApiResponse<HarmonyData>

class ApiService {
    static let shared = ApiService()
    private let networkManager = NetworkManager.shared
    
    private init() {}
    
    // MARK: - Home
    func fetchBanners(completion: @escaping (Result<ApiResponse<[Banner]>, NetworkError>) -> Void) {
        networkManager.request("/banner/json", completion: completion)
    }
    
    func fetchArticles(page: Int, completion: @escaping (Result<ApiResponse<ArticleList>, NetworkError>) -> Void) {
        networkManager.request("/article/list/\(page)/json", completion: completion)
    }
    
    func fetchTopArticles(completion: @escaping (Result<ApiResponse<ArticleList>, NetworkError>) -> Void) {
        networkManager.request("/article/top/json", completion: completion)
    }
    
    // MARK: - Project
    func fetchProjectCategories(completion: @escaping (Result<ApiResponse<[ProjectCategory]>, NetworkError>) -> Void) {
        networkManager.request("/project/tree/json", completion: completion)
    }
    
    func fetchProjectList(page: Int, cid: Int, completion: @escaping (Result<ApiResponse<ArticleList>, NetworkError>) -> Void) {
        let parameters = ["cid": cid]
        networkManager.request("/project/list/\(page)/json", parameters: parameters, completion: completion)
    }
    
    // MARK: - Harmony
    func fetchHarmonyArticles(completion: @escaping (Result<ApiResponse<HarmonyData>, NetworkError>) -> Void) {
        networkManager.request("/harmony/index/json", completion: completion)
    }
    
    // MARK: - Category
    func fetchWeChatAuthors(completion: @escaping (Result<ApiResponse<[WeChatAuthor]>, NetworkError>) -> Void) {
        networkManager.request("/wxarticle/chapters/json", completion: completion)
    }
    
    func fetchAuthorArticles(author: String, page: Int, completion: @escaping (Result<ApiResponse<ArticleList>, NetworkError>) -> Void) {
        let parameters = ["author": author]
        networkManager.request("/article/list/\(page)/json", parameters: parameters, completion: completion)
    }
    
    // MARK: - Tutorial
    func fetchTutorials(completion: @escaping (Result<ApiResponse<[Tutorial]>, NetworkError>) -> Void) {
        networkManager.request("/chapter/547/sublist/json", completion: completion)
    }
    
    func fetchQAList(completion: @escaping (Result<ApiResponse<[QA]>, NetworkError>) -> Void) {
        networkManager.request("/popular/wenda/json", completion: completion)
    }
    
    func fetchColumns(completion: @escaping (Result<ApiResponse<[Column]>, NetworkError>) -> Void) {
        networkManager.request("/popular/column/json", completion: completion)
    }
    
    func fetchRoutes(completion: @escaping (Result<ApiResponse<[Route]>, NetworkError>) -> Void) {
        networkManager.request("/popular/route/json", completion: completion)
    }
    
    // MARK: - Square
    func fetchSquareArticles(page: Int, completion: @escaping (Result<ApiResponse<SquareArticleList>, NetworkError>) -> Void) {
        networkManager.request("/user_article/list/\(page)/json", completion: completion)
    }
    
    func fetchUserArticles(userId: Int, page: Int, completion: @escaping (Result<ApiResponse<UserShareInfo>, NetworkError>) -> Void) {
        networkManager.request("/user/\(userId)/share_articles/\(page)/json", completion: completion)
    }
}