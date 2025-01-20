//
//  SystemCategory.swift
//  wanProjectIos
//
//  Created by neillwu on 2025/1/17.
//

import Foundation

struct SystemCategory: Codable, Identifiable {
    let id: Int
    let name: String
    let courseId: Int
    let parentChapterId: Int
    let order: Int
    let visible: Int
    let children: [SystemCategory]?
    var articleCount: Int? // 可选的文章数量
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case courseId
        case parentChapterId
        case order
        case visible
        case children
    }
}

