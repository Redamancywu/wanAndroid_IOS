import Foundation

struct WeChatAccount: Identifiable, Codable {
    let id: Int
    let name: String        // 公众号名称
    let desc: String?       // 公众号描述
    let link: String?       // 公众号链接
    let order: Int         // 排序
    let visible: Int       // 是否可见
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case desc
        case link
        case order
        case visible
    }
}

struct WeChatAccountResponse: Codable {
    let data: [WeChatAccount]
    let errorCode: Int
    let errorMsg: String
} 
