struct SquareArticle: Codable, Identifiable {
    let id: Int
    let title: String
    let desc: String
    let link: String
    let niceDate: String
    let shareUser: String
    let userId: Int
    let author: String?
    let chapterName: String?
    let collect: Bool
    let tags: [ArticleTag]
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