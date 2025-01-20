//
//  ApiResponse.swift
//  wanProjectIos
//
//  Created by neillwu on 2025/1/17.
//

import Foundation

// 通用响应结构
struct ApiResponse<T: Codable>: Codable {
    let errorCode: Int
    let errorMsg: String
    let data: T
}

// 文章列表数据结构
struct ArticleList: Codable {
    let curPage: Int
    let datas: [Article]
    let offset: Int
    let over: Bool
    let pageCount: Int
    let size: Int
    let total: Int
}

// 空响应类型
struct EmptyResponse: Codable {}

// API 错误类型
enum ApiError: Error {
    case message(String)
}

extension ApiError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .message(let message):
            return message
        }
    }
}
