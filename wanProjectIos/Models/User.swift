struct User: Codable {
    let id: Int
    let username: String
    let nickname: String?
    let publicName: String?
    let email: String?
    let token: String?
    let admin: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case nickname
        case publicName
        case email
        case token
        case admin
    }
}

struct LoginResponse: Codable {
    let data: User
    let errorCode: Int
    let errorMsg: String
}

struct BaseResponse: Codable {
    let errorCode: Int
    let errorMsg: String
} 