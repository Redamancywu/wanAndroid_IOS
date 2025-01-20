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
        title: "示例文章标题",
        desc: "这是一篇示例文章的描述内容。",
        link: "https://example.com",
        author: "作者名",
        shareUser: nil,
        niceDate: "2024-01-20",
        publishTime: 1705545600000,
        collect: false,
        superChapterName: "分类",
        chapterName: "子分类",
        type: 0,
        fresh: true,
        tags: [],
        envelopePic: nil,
        projectLink: nil,
        apkLink: nil,
        prefix: nil
    )
    
    static let sharedArticle = Article(
        id: 2,
        title: "分享的文章",
        desc: "这是一篇分享的文章。",
        link: "https://example.com",
        author: nil,
        shareUser: "分享者",
        niceDate: "2024-01-20",
        publishTime: 1705545600000,
        collect: true,
        superChapterName: "分类",
        chapterName: "子分类",
        type: 0,
        fresh: false,
        tags: [],
        envelopePic: nil,
        projectLink: nil,
        apkLink: nil,
        prefix: nil
    )
    
    static let projectArticle = Article(
        id: 3,
        title: "项目文章",
        desc: "这是一个示例项目。",
        link: "https://example.com",
        author: "项目作者",
        shareUser: nil,
        niceDate: "2024-01-20",
        publishTime: 1705545600000,
        collect: false,
        superChapterName: "项目",
        chapterName: "开源项目",
        type: 0,
        fresh: true,
        tags: [],
        envelopePic: "https://example.com/image.jpg",
        projectLink: "https://github.com/example",
        apkLink: nil,
        prefix: nil
    )
    
    static let projectArticleNoImage = Article(
        id: 4,
        title: "无图片项目",
        desc: "这是一个没有封面图片的项目。",
        link: "https://example.com",
        author: "项目作者",
        shareUser: nil,
        niceDate: "2024-01-20",
        publishTime: 1705545600000,
        collect: false,
        superChapterName: "项目",
        chapterName: "开源项目",
        type: 0,
        fresh: false,
        tags: [],
        envelopePic: nil,
        projectLink: "https://github.com/example",
        apkLink: nil,
        prefix: nil
    )
} 