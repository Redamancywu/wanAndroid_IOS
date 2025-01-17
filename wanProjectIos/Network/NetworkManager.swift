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
        
        HiLog.d("Request URL: \(urlString)")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                HiLog.e("Network Error: \(error.localizedDescription)")
                completion(.failure(.requestFailed(error)))
                return
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