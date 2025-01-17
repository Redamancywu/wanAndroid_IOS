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
    let link: String
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
    
    // 实现 Equatable 协议
    static func == (lhs: Article, rhs: Article) -> Bool {
        lhs.id == rhs.id
    }
}

struct ArticleTag: Codable, Equatable {
    let name: String
    let url: String
} 