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

enum ParameterEncoding {
    case json
    case urlEncoded
}

/// 热门搜索关键词
struct HotKey: Codable, Identifiable {
    let id: Int
    let link: String
    let name: String
    let order: Int
    let visible: Int
}

class ApiService {
    static let shared = ApiService()
    private let networkManager = NetworkManager.shared
    private let baseURL = "https://www.wanandroid.com"
    
    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        config.httpCookieStorage = HTTPCookieStorage.shared
        config.httpCookieAcceptPolicy = .always
        return URLSession(configuration: config)
    }()
    
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
    
    // MARK: - System
    func fetchSystemCategories(completion: @escaping (Result<ApiResponse<[SystemCategory]>, NetworkError>) -> Void) {
        networkManager.request("/tree/json", completion: completion)
    }
    
    func fetchSystemArticles(page: Int, cid: Int, completion: @escaping (Result<ApiResponse<ArticleList>, NetworkError>) -> Void) {
        let parameters = ["cid": cid]
        networkManager.request("/article/list/\(page)/json", parameters: parameters, completion: completion)
    }
    
    func request<T: Decodable>(
        _ path: String,
        method: HTTPMethod = .get,
        parameters: [String: Any]? = nil,
        responseType: T.Type,
        encoding: ParameterEncoding = .json
    ) async throws -> T {
        guard let url = URL(string: baseURL + path) else {
            throw ApiError.message("Invalid URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 添加登录 Cookie
        if let cookies = HTTPCookieStorage.shared.cookies(for: url) {
            let cookieHeaders = HTTPCookie.requestHeaderFields(with: cookies)
            for (key, value) in cookieHeaders {
                request.setValue(value, forHTTPHeaderField: key)
            }
            HiLog.i("请求添加的 Cookies: \(cookies)")
        } else {
            HiLog.e("没有找到 Cookie")
        }
        
        // 处理参数
        if let parameters = parameters {
            if method == .post {
                // POST 请求：参数放在 body 中
                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                // 直接使用简单的参数编码
                let formData = parameters.map { "\($0)=\($1)" }.joined(separator: "&")
                request.httpBody = formData.data(using: .utf8)
                
                // 调试输出
                print("发送请求：")
                print("URL: \(url.absoluteString)")
                print("Method: \(method.rawValue)")
                print("Headers: \(request.allHTTPHeaders ?? [:])")
                print("Body: \(formData)")
            } else {
                // GET 请求：参数添加到 URL
                var components = URLComponents(string: url.absoluteString)
                components?.queryItems = parameters.map { URLQueryItem(name: $0, value: "\($1)") }
                if let newURL = components?.url {
                    request.url = newURL
                }
            }
        }
        
        // 发送请求
        let (data, response) = try await session.data(for: request)
        
        // 调试输出
        print("Request URL: \(request.url?.absoluteString ?? "")")
        print("Request Method: \(request.httpMethod ?? "")")
        print("Request Headers: \(request.allHTTPHeaders ?? [:])")
        if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            print("Request Body: \(bodyString)")
        }
        if let responseString = String(data: data, encoding: .utf8) {
            print("Response data: \(responseString)")
        }
        
        // 检查响应状态码
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ApiError.message("Invalid response")
        }
        
        // 保存 Cookie
        if let headerFields = httpResponse.allHeaderFields as? [String: String] {
            let cookies = HTTPCookie.cookies(withResponseHeaderFields: headerFields, for: url)
            HTTPCookieStorage.shared.setCookies(cookies, for: url, mainDocumentURL: nil)
            HiLog.i("响应保存的 Cookies: \(cookies)")
        }
        
        // 检查错误状态码
        if !(200...299).contains(httpResponse.statusCode) {
            // 尝试解析错误消息
            if let errorString = String(data: data, encoding: .utf8) {
                throw ApiError.message("服务器响应异常: \(errorString)")
            } else {
                throw ApiError.message("服务器响应异常(状态码: \(httpResponse.statusCode))")
            }
        }
        
        // 解码响应
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Decoding error: \(error)")
            if let dataString = String(data: data, encoding: .utf8) {
                print("Raw response: \(dataString)")
            }
            throw ApiError.message("数据解析失败: \(error.localizedDescription)")
        }
    }
    
    // 获取公众号列表
    func fetchWeChatArticles(completion: @escaping (Result<ApiResponse<[WeChatArticle]>, NetworkError>) -> Void) {
        networkManager.request("/wxarticle/chapters/json", completion: completion)
    }
    
    // 获取指定公众号的文章列表
    func fetchWeChatArticleList(id: Int, page: Int, completion: @escaping (Result<ApiResponse<ArticleList>, NetworkError>) -> Void) {
        networkManager.request("/wxarticle/list/\(id)/\(page)/json", completion: completion)
    }
    
    // MARK: - 收藏相关接口
    
    /// 获取收藏文章列表
    func fetchCollectedArticles(page: Int = 0, pageSize: Int? = nil) async throws -> ArticleList {
        var url = "/lg/collect/list/\(page)/json"
        if let size = pageSize {
            url += "?page_size=\(max(1, min(40, size)))"
        }
        
        HiLog.i("开始请求收藏列表，URL: \(url)")
        // 打印 Cookie
        if let cookies = HTTPCookieStorage.shared.cookies {
            HiLog.i("当前 Cookies: \(cookies)")
        }
        
        let response: ApiResponse<ArticleList> = try await request(
            url,
            method: .get,
            responseType: ApiResponse<ArticleList>.self
        )
        
        if response.errorCode == 0 {
            HiLog.i("收藏列表请求成功，文章数：\(response.data.datas.count)")
            return response.data
        } else {
            HiLog.e("收藏列表请求失败：\(response.errorMsg)")
            throw ApiError.message(response.errorMsg)
        }
    }
    
    /// 收藏站内文章
    func collectInternalArticle(_ articleId: Int) async throws {
        let response: ApiResponse<EmptyResponse> = try await request(
            "/lg/collect/\(articleId)/json",
            method: .post,
            responseType: ApiResponse<EmptyResponse>.self
        )
        
        if response.errorCode != 0 {
            throw ApiError.message(response.errorMsg)
        }
    }
    
    /// 收藏站外文章
    func collectExternalArticle(title: String, author: String, link: String) async throws {
        let params = [
            "title": title,
            "author": author,
            "link": link
        ]
        
        let response: ApiResponse<EmptyResponse> = try await request(
            "/lg/collect/add/json",
            method: .post,
            parameters: params,
            responseType: ApiResponse<EmptyResponse>.self
        )
        
        if response.errorCode != 0 {
            throw ApiError.message(response.errorMsg)
        }
    }
    
    /// 更新收藏的文章
    func updateCollectedArticle(articleId: Int, title: String, author: String, link: String) async throws {
        let params = [
            "title": title,
            "author": author,
            "link": link
        ]
        
        let response: ApiResponse<EmptyResponse> = try await request(
            "/lg/collect/user_article/update/\(articleId)/json",
            method: .post,
            parameters: params,
            responseType: ApiResponse<EmptyResponse>.self
        )
        
        if response.errorCode != 0 {
            throw ApiError.message(response.errorMsg)
        }
    }
    
    /// 从文章列表取消收藏
    func uncollectFromList(_ articleId: Int) async throws {
        let response: ApiResponse<EmptyResponse> = try await request(
            "/lg/uncollect_originId/\(articleId)/json",
            method: .post,
            responseType: ApiResponse<EmptyResponse>.self
        )
        
        if response.errorCode != 0 {
            throw ApiError.message(response.errorMsg)
        }
    }
    
    /// 从收藏页面取消收藏
    func uncollectFromMyCollections(_ articleId: Int, originId: Int) async throws {
        let params = ["originId": originId]
        
        HiLog.i("取消收藏请求，articleId: \(articleId), originId: \(originId)")
        let response: ApiResponse<EmptyResponse> = try await request(
            "/lg/uncollect/\(articleId)/json",
            method: .post,
            parameters: params,
            responseType: ApiResponse<EmptyResponse>.self
        )
        
        if response.errorCode != 0 {
            HiLog.e("取消收藏失败：\(response.errorMsg)")
            throw ApiError.message(response.errorMsg)
        }
        
        HiLog.i("取消收藏成功")
    }
    
    // MARK: - 用户信息相关接口
    
    /// 获取用户积分信息
    func fetchCoinInfo() async throws -> CoinInfo {
        let response: ApiResponse<CoinInfo> = try await request(
            "/lg/coin/userinfo/json",
            method: .get,
            responseType: ApiResponse<CoinInfo>.self
        )
        
        if response.errorCode == 0 {
            return response.data
        } else {
            throw ApiError.message(response.errorMsg)
        }
    }
    
    /// 搜索文章
    func searchArticles(keyword: String, page: Int = 0, pageSize: Int? = 20) async throws -> ArticleList {
        // 处理多个关键词，用空格分隔
        let processedKeyword = keyword.trimmingCharacters(in: .whitespaces)
        let params = ["k": processedKeyword]
        
        // 构建 URL
        var url = "/article/query/\(page)/json"
        if let size = pageSize {
            url += "?page_size=\(max(1, min(40, size)))"
        }
        
        HiLog.i("开始搜索文章，关键词：\(processedKeyword)，页码：\(page)，每页数量：\(pageSize ?? 20)")
        let response: ApiResponse<ArticleList> = try await request(
            url,
            method: .post,
            parameters: params,
            responseType: ApiResponse<ArticleList>.self
        )
        
        if response.errorCode == 0 {
            HiLog.i("搜索成功，找到文章数：\(response.data.datas.count)")
            return response.data
        } else {
            HiLog.e("搜索失败：\(response.errorMsg)")
            throw ApiError.message(response.errorMsg)
        }
    }
    
    /// 获取搜索热词
    func fetchHotKeys() async throws -> [HotKey] {
        HiLog.i("开始获取搜索热词")
        let response: ApiResponse<[HotKey]> = try await request(
            "/hotkey/json",
            method: .get,
            responseType: ApiResponse<[HotKey]>.self
        )
        
        if response.errorCode == 0 {
            HiLog.i("获取热词成功，数量：\(response.data.count)")
            return response.data
        } else {
            HiLog.e("获取热词失败：\(response.errorMsg)")
            throw ApiError.message(response.errorMsg)
        }
    }
}
// 扩展 URLRequest 以方便打印请求头
extension URLRequest {
    var allHTTPHeaders: [String: String]? {
        allHTTPHeaderFields
    }
}
