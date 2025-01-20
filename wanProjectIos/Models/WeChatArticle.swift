import Foundation

// 公众号文章列表响应
struct WeChatArticleResponse: Codable {
    let data: [WeChatArticle]
    let errorCode: Int
    let errorMsg: String
}

// 公众号文章
struct WeChatArticle: Codable, Identifiable {
    let id: Int
    let name: String        // 公众号名称
    let author: String?     // 作者，可能为空
    let desc: String?       // 描述，可能为空
    let courseId: Int      // 课程ID
    let cover: String?      // 封面，可能为空
    let order: Int         // 排序
    let parentChapterId: Int // 父章节ID
    let type: Int          // 类型
    let visible: Int       // 是否可见
    let children: [WeChatArticle]?  // 子项，可能为空
    let articleList: [Article]?     // 文章列表，可能为空
    let lisense: String?    // 许可证，可能为空
    let lisenseLink: String? // 许可证链接，可能为空
    let userControlSetTop: Bool // 用户是否置顶
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case author
        case desc
        case courseId
        case cover
        case order
        case parentChapterId
        case type
        case visible
        case children
        case articleList
        case lisense
        case lisenseLink
        case userControlSetTop
    }
} 