//
//  NetworkManager.swift
//  wanProjectIos
//
//  Created by neillwu on 2025/1/17.
//

import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    let baseURL = "https://www.wanandroid.com"
    
    private init() {}
    
    func request<T: Codable>(_ path: String,
                            method: HTTPMethod = .get,
                            parameters: [String: Any]? = nil,
                            completion: @escaping (Result<T, NetworkError>) -> Void) {
        let urlString = baseURL + path
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        if let parameters = parameters {
            if method == .get {
                // 处理GET请求参数
                var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
                components?.queryItems = parameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
                request.url = components?.url
            } else {
                // 处理POST请求参数
                request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        }
        
        HiLog.i("发起网络请求: \(request.url?.absoluteString ?? urlString)")
        if let parameters = parameters {
            HiLog.i("请求参数: \(parameters)")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                HiLog.e("网络请求错误: \(error.localizedDescription)")
                completion(.failure(.requestFailed(error)))
                return
            }
            
            if let data = data, let jsonString = String(data: data, encoding: .utf8) {
                HiLog.i("接收到响应数据: \(jsonString)")
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let result = try decoder.decode(T.self, from: data)
                completion(.success(result))
            } catch {
                HiLog.e("Decoding Error: \(error)")
                completion(.failure(.decodingFailed(error)))
            }
        }.resume()
    }
}

// HTTP 方法枚举
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

// 网络错误枚举
enum NetworkError: Error {
    case invalidURL
    case requestFailed(Error)
    case noData
    case decodingFailed(Error)
} 

extension NetworkManager {
    func requestWithRetry<T: Codable>(
        _ path: String,
        method: HTTPMethod = .get,
        parameters: [String: Any]? = nil,
        retryCount: Int = 3,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        func attempt(remainingAttempts: Int) {
            request(path, method: method, parameters: parameters) { (result: Result<T, NetworkError>) in
                switch result {
                case .success:
                    completion(result)
                case .failure(let error):
                    if remainingAttempts > 0 {
                        HiLog.w("请求失败，剩余重试次数: \(remainingAttempts - 1)")
                        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                            attempt(remainingAttempts: remainingAttempts - 1)
                        }
                    } else {
                        completion(.failure(error))
                    }
                }
            }
        }
        
        attempt(remainingAttempts: retryCount)
    }
}