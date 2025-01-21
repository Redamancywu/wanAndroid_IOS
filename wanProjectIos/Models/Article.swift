//
//  Article.swift
//  wanProjectIos
//
//  Created by neillwu on 2025/1/17.
//

import Foundation

struct Article: Codable, Identifiable, Equatable {
    let id: Int
    let title: String
    let desc: String?
    let link: String?
    let author: String?
    let shareUser: String?
    let niceDate: String
    let publishTime: Int64
    let collect: Bool
    let superChapterName: String?
    let chapterName: String?
    let type: Int
    let fresh: Bool
    let tags: [ArticleTag]
    let envelopePic: String?    // 项目封面图
    let projectLink: String?    // 项目链接
    let apkLink: String?        // APK下载链接
    let prefix: String?         // 前缀
    let originId: Int?          // 添加 originId 字段
    
    // 实现 Equatable 协议
    static func == (lhs: Article, rhs: Article) -> Bool {
        lhs.id == rhs.id
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case desc
        case link
        case author
        case shareUser
        case niceDate
        case publishTime
        case collect
        case superChapterName
        case chapterName
        case type
        case fresh
        case tags
        case envelopePic
        case projectLink
        case apkLink
        case prefix
        case originId = "originId"
    }
}

struct ArticleTag: Codable, Equatable {
    let name: String
    let url: String?
}

struct ArticleListResponse: Codable {
    let data: ArticleData
    let errorCode: Int
    let errorMsg: String
}

struct ArticleData: Codable {
    let curPage: Int
    let datas: [Article]
    let offset: Int
    let over: Bool
    let pageCount: Int
    let size: Int
    let total: Int
} 