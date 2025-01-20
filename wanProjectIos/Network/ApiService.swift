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
        // 构建基础 URL
        guard let url = URL(string: baseURL + path) else {
            throw ApiError.message("Invalid URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.timeoutInterval = 30
        
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
}

// 扩展 URLRequest 以方便打印请求头
extension URLRequest {
    var allHTTPHeaders: [String: String]? {
        allHTTPHeaderFields
    }
}