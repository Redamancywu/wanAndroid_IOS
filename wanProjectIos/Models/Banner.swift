//
//  Banner.swift
//  wanProjectIos
//
//  Created by neillwu on 2025/1/17.
//

import Foundation

struct Banner: Codable, Identifiable {
    let id: Int
    let desc: String
    let imagePath: String
    let isVisible: Int
    let order: Int
    let title: String
    let type: Int
    let url: String
} 