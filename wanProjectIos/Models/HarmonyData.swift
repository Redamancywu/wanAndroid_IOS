//
//  HarmonyData.swift
//  wanProjectIos
//
//  Created by neillwu on 2025/1/17.
//

import Foundation

struct HarmonyData: Codable {
    let links: HarmonyLinks?
    let openSources: HarmonyCategory?
    let tools: HarmonyCategory?
}

struct HarmonyLinks: Codable {
    let articleList: [Article]
    let author: String
    let children: [String]?
    let courseId: Int
    let cover: String
    let desc: String
    let id: Int
    let name: String
    let order: Int
    let parentChapterId: Int
    let type: Int
    let visible: Int
}

struct HarmonyCategory: Codable {
    let articleList: [Article]
    let author: String
    let children: [String]?
    let courseId: Int
    let cover: String
    let desc: String
    let id: Int
    let name: String
    let order: Int
    let parentChapterId: Int
    let type: Int
    let visible: Int
} 