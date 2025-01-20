import Foundation

struct CoinRecord: Identifiable, Codable {
    let id: Int
    let userId: Int
    let userName: String
    let coinCount: Int      // 获得的积分数量
    let desc: String        // 积分描述
    let reason: String      // 获取原因
    let type: Int          // 积分类型
    let date: Int64        // 获取时间
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case userName = "username"
        case coinCount
        case desc
        case reason
        case type
        case date
    }
}

struct CoinRecordResponse: Codable {
    let data: CoinRecordData
    let errorCode: Int
    let errorMsg: String
}

struct CoinRecordData: Codable {
    let curPage: Int
    let datas: [CoinRecord]
    let offset: Int
    let over: Bool
    let pageCount: Int
    let size: Int
    let total: Int
} 