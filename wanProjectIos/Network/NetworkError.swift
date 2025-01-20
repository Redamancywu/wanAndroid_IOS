import Foundation

enum NetworkError: Error {
    case invalidURL
    case requestFailed(Error)
    case noData
    case decodingFailed(Error)
    case networkNotConnected
    case timeout
    case hostNotFound
    case secureConnectionFailed
    case invalidStatusCode(Int)
}

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "无效的URL地址"
        case .requestFailed(let error):
            return "请求失败: \(error.localizedDescription)"
        case .noData:
            return "服务器未返回数据"
        case .decodingFailed(let error):
            return "数据解析失败: \(error.localizedDescription)"
        case .networkNotConnected:
            return "网络连接不可用，请检查网络设置"
        case .timeout:
            return "请求超时，请检查网络连接"
        case .hostNotFound:
            return "无法连接到服务器，请检查网络设置"
        case .secureConnectionFailed:
            return "安全连接失败，请检查网络设置"
        case .invalidStatusCode(let code):
            return "服务器响应异常(状态码: \(code))"
        }
    }
} 