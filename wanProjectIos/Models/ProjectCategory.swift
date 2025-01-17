//
//  ProjectCategory.swift
//  wanProjectIos
//
//  Created by neillwu on 2025/1/17.
//

import Foundation

struct ProjectCategory: Codable, Identifiable {
    let id: Int
    let name: String
    let courseId: Int
    let parentChapterId: Int
    let order: Int
    let visible: Int
    let children: [ProjectCategory]?
}