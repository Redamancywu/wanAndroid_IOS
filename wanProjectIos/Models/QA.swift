struct QA: Codable, Identifiable {
    let id: Int
    let title: String
    let desc: String
    let author: String
    let niceDate: String
    let zan: Int  // 点赞数
    let chapterName: String
} 