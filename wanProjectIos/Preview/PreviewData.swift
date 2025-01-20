import Foundation

// 预览数据
struct PreviewData {
    static let weChatArticle = WeChatArticle(
        id: 408,
        name: "鸿洋",
        author: "",
        desc: "",
        courseId: 13,
        cover: "",
        order: 190000,
        parentChapterId: 407,
        type: 0,
        visible: 1,
        children: [],
        articleList: [],
        lisense: "",
        lisenseLink: "",
        userControlSetTop: false
    )
    
    static let article = Article(
        id: 1,
        title: "Android 开发技巧：性能优化实践",
        desc: "本文介绍了 Android 应用性能优化的实用技巧，包括内存优化、布局优化等内容。",
        link: "https://example.com",
        author: "鸿洋",
        shareUser: nil,
        niceDate: "2024-01-20",
        publishTime: 1705545600000,
        collect: false,
        superChapterName: "开发技巧",
        chapterName: "性能优化",
        type: 0,
        fresh: true,
        tags: [],
        envelopePic: nil,
        projectLink: nil,
        apkLink: nil,
        prefix: nil
    )
} 