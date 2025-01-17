//
//  WeChatAuthor.swift
//  wanProjectIos
//
//  Created by neillwu on 2025/1/17.
//

import Foundation

struct WeChatAuthor: Codable, Identifiable {
    let id: Int
    let name: String
    let order: Int
    let visible: Int
} 