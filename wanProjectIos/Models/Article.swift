//
//  Article.swift
//  wanProjectIos
//
//  Created by neillwu on 2025/1/17.
//

import Foundation

struct Article: Codable, Identifiable {
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
    let tags: [ArticleTag]?
}

struct ArticleTag: Codable {
    let name: String
    let url: String?
} 