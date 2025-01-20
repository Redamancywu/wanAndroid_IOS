struct SquareArticle: Identifiable, Codable {
    let id: Int
    let title: String
    let desc: String
    let link: String
    let shareUser: String
    let niceDate: String
    let chapterName: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case desc
        case link
        case shareUser
        case niceDate
        case chapterName
    }
}

struct SquareArticleList: Codable {
    let curPage: Int
    let datas: [SquareArticle]
    let offset: Int
    let over: Bool
    let pageCount: Int
    let size: Int
    let total: Int
} 