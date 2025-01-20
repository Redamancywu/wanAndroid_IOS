struct User: Codable {
    let id: Int
    let username: String
    let nickname: String
    let token: String?
    let email: String?
    let icon: String?
    let type: Int
    let admin: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case nickname = "nickname"
        case token
        case email
        case icon
        case type
        case admin
    }
}

struct LoginResponse: Codable {
    let admin: Bool
    let chapterTops: [String]
    let coinCount: Int
    let collectIds: [Int]
    let email: String?
    let icon: String?
    let id: Int
    let nickname: String
    let password: String
    let publicName: String
    let token: String?
    let type: Int
    let username: String
}

struct BaseResponse: Codable {
    let errorCode: Int
    let errorMsg: String
} 