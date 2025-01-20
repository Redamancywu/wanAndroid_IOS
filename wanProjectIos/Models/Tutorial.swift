//
//  Tutorial.swift
//  wanProjectIos
//
//  Created by neillwu on 2025/1/17.
//

import Foundation

struct Tutorial: Codable, Identifiable {
    let id: Int
    let name: String
    let desc: String
    let author: String
    let cover: String
    let lisense: String
    let lisenseLink: String
    let articleList: [Article]?
    let children: [Tutorial]?
    let courseId: Int
    let parentChapterId: Int
    let order: Int
    let type: Int
    let visible: Int
    let link: String?
    let icon: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case desc
        case author
        case cover
        case lisense
        case lisenseLink
        case articleList
        case children
        case courseId
        case parentChapterId
        case order
        case type
        case visible
        case link
        case icon
    }
} 