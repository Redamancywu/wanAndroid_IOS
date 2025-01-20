struct CoinInfo: Codable {
    let coinCount: Int       // 当前积分
    let level: Int          // 等级
    let rank: String        // 排名
    let userId: Int
    let username: String
}

struct CoinInfoResponse: Codable {
    let data: CoinInfo
    let errorCode: Int
    let errorMsg: String
} 