//
//  ArticleCardView.swift
//  wanProjectIos
//
//  Created by neillwu on 2025/1/17.
//

import SwiftUI

struct ArticleCardView: View {
    let article: Article
    @StateObject private var viewModel = ArticleCardViewModel()
    @EnvironmentObject private var profileViewModel: ProfileViewModel
    @Environment(\.openURL) private var openURL
    
    init(article: Article) {
        self.article = article
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
                    Task {
                        await viewModel.toggleCollect(articleId: article.id)
                    }
                } label: {
                    Image(systemName: viewModel.isCollected ? "heart.fill" : "heart")
                        .foregroundColor(viewModel.isCollected ? .red : .gray)
                }
                .buttonStyle(.scale)
                .alert("需要登录", isPresented: $viewModel.showLoginAlert) {
                    Button("取消", role: .cancel) { }
                    Button("去登录") {
                        profileViewModel.showLogin()
                    }
                } message: {
                    Text("收藏功能需要登录后才能使用")
                }
            }
            
            Button {
                // 安全地处理可选的 link
                if let link = article.link,
                   let url = URL(string: link) {
                    openURL(url)
                }
            } label: {
                // ... 按钮内容 ...
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 8, y: 2)
        .onAppear {
            viewModel.checkCollectionStatus(articleId: article.id)
        }
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