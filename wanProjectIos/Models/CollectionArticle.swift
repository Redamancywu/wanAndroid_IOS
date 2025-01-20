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

struct CollectionArticle: Codable, Identifiable {
    let id: Int          // 收藏文章的id
    let originId: Int    // 原始文章的id
    let title: String
    let author: String?  // 修改为可选类型
    let link: String
    let publishTime: Int64
    let desc: String?
    let chapterName: String?
    let niceDate: String
    let envelopePic: String?
    
    // 用于区分是普通文章还是收藏的文章
    var isCollected: Bool {
        true
    }
} 