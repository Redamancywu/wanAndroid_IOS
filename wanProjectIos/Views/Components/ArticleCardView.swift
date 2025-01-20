//
//  ArticleCardView.swift
//  wanProjectIos
//
//  Created by neillwu on 2025/1/17.
//

import SwiftUI

struct ArticleCardView: View {
    let article: Article
    @State private var isCollected: Bool
    
    init(article: Article) {
        self.article = article
        _isCollected = State(initialValue: article.collect)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 顶部信息：分类和时间
            HStack {
                if let superChapterName = article.superChapterName,
                   let chapterName = article.chapterName {
                    Text("\(superChapterName)·\(chapterName)")
                        .font(.system(size: 12))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(4)
                }
                
                Spacer()
                
                Text(article.niceDate)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            // 标题
            Text(article.title)
                .font(.system(size: 16, weight: .semibold))
                .lineLimit(2)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // 描述
            if let desc = article.desc?.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression) {
                Text(desc)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 4)
            }
            
            // 分隔线
            Divider()
            
            // 底部信息栏
            HStack(alignment: .center) {
                // 作者/分享者
                if let author = article.author, !author.isEmpty {
                    Label(author, systemImage: "person.circle")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                } else if let shareUser = article.shareUser, !shareUser.isEmpty {
                    Label("分享自: \(shareUser)", systemImage: "person.2.circle")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // 新文章标识
                if article.fresh {
                    Text("新")
                        .font(.system(size: 12, weight: .medium))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(4)
                }
                
                // 收藏按钮
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isCollected.toggle()
                    }
                } label: {
                    Image(systemName: isCollected ? "heart.fill" : "heart")
                        .foregroundColor(isCollected ? .red : .gray)
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 8, y: 2)
    }
}

private struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.8 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// 预览
struct ArticleCardView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            // 普通文章
            ArticleCardView(article: Article(
                id: 1,
                title: "Android开发技巧：性能优化实践",
                desc: "本文介绍了Android应用性能优化的实用技巧，包括内存优化、布局优化等内容。",
                link: "https://example.com",
                author: "张三",
                shareUser: nil,
                niceDate: "2024-01-18",
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
            ))
            
            // 分享的文章
            ArticleCardView(article: Article(
                id: 2,
                title: "iOS开发：SwiftUI实战经验分享",
                desc: "分享一些SwiftUI开发中的实用技巧和注意事项。",
                link: "https://example.com",
                author: "",
                shareUser: "李四",
                niceDate: "2024-01-17",
                publishTime: 1705459200000,
                collect: true,
                superChapterName: "iOS开发",
                chapterName: "SwiftUI",
                type: 0,
                fresh: false,
                tags: [],
                envelopePic: nil,
                projectLink: nil,
                apkLink: nil,
                prefix: nil
            ))
        }
        .padding()
    }
} 