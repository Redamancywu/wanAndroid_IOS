import Foundation  // 添加这行来使用 TimeInterval

// 收藏文章响应
struct CollectionListResponse: Codable {
    let data: CollectionData
    let errorCode: Int
    let errorMsg: String
}

struct CollectionData: Codable {
    let curPage: Int
    let datas: [CollectionArticle]
    let offset: Int
    let over: Bool
    let pageCount: Int
    let size: Int
    let total: Int
}

struct CollectionArticle: Identifiable, Codable {
    let id: Int
    let title: String
    let link: String?
    let author: String?
    let niceDate: String
    let originId: Int
    let publishTime: TimeInterval
    let desc: String
    let chapterName: String
    let envelopePic: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case link
        case author
        case niceDate
        case originId
        case publishTime
        case desc
        case chapterName
        case envelopePic
    }
    
    // 用于区分是普通文章还是收藏的文章
    var isCollected: Bool {
        true
    }
} 