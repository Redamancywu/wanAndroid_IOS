import Foundation

struct QA: Codable, Identifiable {
    let id: Int
    let title: String
    let desc: String
    let author: String
    let niceDate: String
    let zan: Int
    let chapterName: String
    let adminAdd: Bool
    let apkLink: String
    let audit: Int
    let canEdit: Bool
    let chapterId: Int
    let collect: Bool
    let courseId: Int
    let descMd: String
    let envelopePic: String
    let fresh: Bool
    let host: String
    let isAdminAdd: Bool
    let link: String
    let niceShareDate: String
    let origin: String
    let prefix: String
    let projectLink: String
    let publishTime: Int64
    let realSuperChapterId: Int
    let selfVisible: Int
    let shareDate: Int64
    let shareUser: String
    let superChapterId: Int
    let superChapterName: String
    let tags: [String]
    let type: Int
    let userId: Int
    let visible: Int

    // 如果需要自定义 CodingKeys，可以添加以下代码
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case desc
        case author
        case niceDate
        case zan
        case chapterName
        case adminAdd
        case apkLink
        case audit
        case canEdit
        case chapterId
        case collect
        case courseId
        case descMd
        case envelopePic
        case fresh
        case host
        case isAdminAdd
        case link
        case niceShareDate
        case origin
        case prefix
        case projectLink
        case publishTime
        case realSuperChapterId
        case selfVisible
        case shareDate
        case shareUser
        case superChapterId
        case superChapterName
        case tags
        case type
        case userId
        case visible
    }

    // 添加计算属性来处理描述文本
    var cleanDesc: String {
        desc
            // 移除 HTML 标签
            .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            // 替换 HTML 实体
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#39;", with: "'")
            // 替换换行符
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
            // 移除多余的空白
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
