//
//  NetworkManager.swift
//  wanProjectIos
//
//  Created by neillwu on 2025/1/17.
//

import Foundation
import Network

// 网络类型枚举
enum NetworkType {
    case wifi
    case cellular
    case vpn
}

// 网络状态枚举
enum NetworkStatus {
    case connected(NetworkType)
    case disconnected
}

// 网络可达性检查
class NetworkReachability {
    static let shared = NetworkReachability()
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkReachability")
    
    private init() {}
    
    func startMonitoring(handler: @escaping (NetworkStatus) -> Void) {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                if path.status == .satisfied {
                    let type: NetworkType
                    if path.usesInterfaceType(.wifi) {
                        type = .wifi
                    } else if path.usesInterfaceType(.cellular) {
                        type = .cellular
                    } else if path.isExpensive {
                        // VPN 通常被标记为 expensive
                        type = .vpn
                    } else {
                        type = .wifi
                    }
                    handler(.connected(type))
                } else {
                    handler(.disconnected)
                }
            }
        }
        monitor.start(queue: queue)
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
}

class NetworkManager {
    static let shared = NetworkManager()
    let baseURL = "https://www.wanandroid.com"
    
    private let session: URLSession
    private let reachability = NetworkReachability.shared
    
    private init() {
        // 创建自定义的URLSessionConfiguration
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        
        // 设置超时时间
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 30
        
        // 允许蜂窝网络访问
        config.allowsCellularAccess = true
        
        // 配置代理设置
        #if DEBUG
        if let proxyHost = UserDefaults.standard.string(forKey: "ProxyHost"),
           let proxyPort = UserDefaults.standard.integer(forKey: "ProxyPort") as Int? {
            config.connectionProxyDictionary = [
                kCFProxyTypeKey: kCFProxyTypeHTTPS,
                kCFStreamPropertyHTTPSProxyHost: proxyHost,
                kCFStreamPropertyHTTPSProxyPort: proxyPort
            ]
            HiLog.i("使用代理服务器: \(proxyHost):\(proxyPort)")
        }
        #endif
        
        // 配置TLS设置
        #if DEBUG
        session = URLSession(configuration: config, delegate: InsecureURLSessionDelegate(), delegateQueue: nil)
        #else
        session = URLSession(configuration: config)
        #endif
        
        // 监听网络状态变化
        setupNetworkMonitoring()
    }
    
    private func setupNetworkMonitoring() {
        reachability.startMonitoring { [weak self] status in
            switch status {
            case .connected(let type):
                HiLog.i("网络已连接: \(type)")
                self?.handleNetworkConnected(type)
            case .disconnected:
                HiLog.w("网络已断开")
            }
        }
    }
    
    private func handleNetworkConnected(_ type: NetworkType) {
        switch type {
        case .wifi:
            // 使用正常网络配置
            resetProxySettings()
        case .cellular:
            // 使用正常网络配置
            resetProxySettings()
        case .vpn:
            // 使用 VPN 配置
            applyVPNSettings()
        }
    }
    
    private func resetProxySettings() {
        #if DEBUG
        UserDefaults.standard.removeObject(forKey: "ProxyHost")
        UserDefaults.standard.removeObject(forKey: "ProxyPort")
        HiLog.i("已重置代理设置")
        #endif
    }
    
    private func applyVPNSettings() {
        #if DEBUG
        // 这里可以根据需要设置 VPN 代理
        UserDefaults.standard.set("127.0.0.1", forKey: "ProxyHost")
        UserDefaults.standard.set(8888, forKey: "ProxyPort")
        HiLog.i("已应用 VPN 代理设置")
        #endif
    }
    
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
        request.timeoutInterval = 15
        
        // 添加通用请求头
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
        
        if let parameters = parameters {
            if method == .get {
                var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
                components?.queryItems = parameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
                request.url = components?.url
            } else {
                request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        }
        
        HiLog.i("发起网络请求: \(request.url?.absoluteString ?? urlString)")
        if let parameters = parameters {
            HiLog.i("请求参数: \(parameters)")
        }
        
        session.dataTask(with: request) { [weak self] data, response, error in
            guard self != nil else { return }
            
            if let error = error {
                HiLog.e("网络请求错误: \(error.localizedDescription)")
                
                let nsError = error as NSError
                switch nsError.code {
                case NSURLErrorNotConnectedToInternet:
                    completion(.failure(.networkNotConnected))
                case NSURLErrorTimedOut:
                    completion(.failure(.timeout))
                case NSURLErrorCannotFindHost:
                    completion(.failure(.hostNotFound))
                case NSURLErrorSecureConnectionFailed:
                    completion(.failure(.secureConnectionFailed))
                default:
                    completion(.failure(.requestFailed(error)))
                }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                HiLog.i("HTTP状态码: \(httpResponse.statusCode)")
                
                // 检查HTTP状态码
                guard (200...299).contains(httpResponse.statusCode) else {
                    completion(.failure(.invalidStatusCode(httpResponse.statusCode)))
                    return
                }
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                HiLog.i("接收到响应数据: \(jsonString)")
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let result = try decoder.decode(T.self, from: data)
                completion(.success(result))
            } catch {
                HiLog.e("解码错误: \(error)")
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

// 用于开发测试的不安全URLSession代理
#if DEBUG
class InsecureURLSessionDelegate: NSObject, URLSessionDelegate {
    func urlSession(_ session: URLSession, 
                   didReceive challenge: URLAuthenticationChallenge,
                   completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            if let serverTrust = challenge.protectionSpace.serverTrust {
                let credential = URLCredential(trust: serverTrust)
                completionHandler(.useCredential, credential)
                return
            }
        }
        completionHandler(.performDefaultHandling, nil)
    }
}
#endif

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
