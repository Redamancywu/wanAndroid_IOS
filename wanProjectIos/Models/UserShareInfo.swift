//
//  UserShareInfo.swift
//  wanProjectIos
//
//  Created by neillwu on 2025/1/17.
//

import Foundation

// 用户分享信息
struct UserShareInfo: Codable {
    let coinInfo: UserCoinInfo
    let shareArticles: SquareArticleList
}

// 用户积分信息
struct UserCoinInfo: Codable {
    let coinCount: Int      // 积分总数
    let rank: Int          // 排名
    let userId: Int
    let username: String
    
    // 提供默认值的初始化器
    static let mock = UserCoinInfo(
        coinCount: 0,
        rank: 0,
        userId: 0,
        username: "游客"
    )
}

extension UserShareInfo {
    // 提供一个模拟数据的静态属性
    static let mock = UserShareInfo(
        coinInfo: UserCoinInfo.mock,
        shareArticles: SquareArticleList(
            curPage: 1,
            datas: [],
            offset: 0,
            over: true,
            pageCount: 1,
            size: 20,
            total: 0
        )
    )
} 