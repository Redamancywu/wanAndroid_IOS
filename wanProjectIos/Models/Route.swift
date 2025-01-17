struct Route: Codable, Identifiable {
    let id: Int
    let name: String
    let desc: String
    let author: String
    let cover: String  // 封面图片URL
    let lisense: String
    let lisenseLink: String
    let order: Int
    let type: Int
} 