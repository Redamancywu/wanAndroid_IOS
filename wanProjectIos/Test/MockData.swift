//
//  MockData.swift
//  wanProjectIos
//
//  Created by neillwu on 2025/1/17.
//

import Foundation

struct MockData {
    static let banners: [Banner] = [
        Banner(
            id: 1,
            desc: "一起来做个App吧",
            imagePath: "https://www.wanandroid.com/blogimgs/50c115c2-cf6c-4802-aa7b-a4334de444cd.png",
            isVisible: 1,
            order: 1,
            title: "一起来做个App吧",
            type: 0,
            url: "https://www.wanandroid.com/blog/show/2"
        ),
        Banner(
            id: 2,
            desc: "我们新增了一个常用导航Tab~",
            imagePath: "https://www.wanandroid.com/blogimgs/62c1bd68-b5f3-4a3c-a649-7ca8c7dfabe6.png",
            isVisible: 1,
            order: 2,
            title: "我们新增了一个常用导航Tab~",
            type: 0,
            url: "https://www.wanandroid.com/navi"
        )
    ]
    
    static let articles: [Article] = [
        Article(
            id: 1,
            title: "Android Studio 初始化设置",
            desc: "Android Studio 初始化设置，让你的开发更高效",
            link: "https://www.wanandroid.com/blog/show/3352",
            author: "鸿洋",
            shareUser: nil,
            niceDate: "2023-12-25 00:00",
            publishTime: 1703433600000,
            collect: false,
            superChapterName: "开发环境",
            chapterName: "Android Studio相关",
            type: 0,
            fresh: true,
            tags: [],
            envelopePic: "https://www.wanandroid.com/blogimgs/89868c9a-e793-46f3-a239-751246951b7f.png",
            projectLink: "https://github.com/example/demo",
            apkLink: nil,
            prefix: nil,
            originId: nil
        ),
        Article(
            id: 2,
            title: "Kotlin 协程实战",
            desc: "Kotlin 协程使用详解",
            link: "https://www.wanandroid.com/blog/show/3351",
            author: nil,
            shareUser: "张三",
            niceDate: "2023-12-24 10:05",
            publishTime: 1703383500000,
            collect: true,
            superChapterName: "Kotlin",
            chapterName: "协程",
            type: 0,
            fresh: true,
            tags: [
                ArticleTag(name: "教程", url: "https://www.wanandroid.com/blog/show/3351")
            ],
            envelopePic: "https://www.wanandroid.com/blogimgs/89868c9a-e793-46f3-a239-751246951b7f.png",
            projectLink: "https://github.com/example/kotlin-demo",
            apkLink: nil,
            prefix: nil,
            originId: nil
        )
    ]
} 
