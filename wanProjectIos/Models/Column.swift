struct Column: Codable, Identifiable {
    let id: Int
    let name: String
    let chapterId: Int
    let subChapterId: Int
    let columnId: Int
    let userId: Int
} 