//
//  ProjectCardView.swift
//  wanProjectIos
//
//  Created by neillwu on 2025/1/17.
//

import SwiftUI
import Foundation

struct ProjectCardView: View {
    let article: Article
    @StateObject private var viewModel = ProjectCardViewModel()
    @EnvironmentObject private var profileViewModel: ProfileViewModel
    @Environment(\.openURL) private var openURL
    
    init(article: Article) {
        self.article = article
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 顶部内容区域（可点击）
            Button {
                // 安全地处理可选的 link
                if let link = article.link,
                   let url = URL(string: link) {
                    openURL(url)
                }
            } label: {
                HStack(alignment: .top, spacing: 12) {
                    // 左侧封面图片
                    if let envelopePic = article.envelopePic, !envelopePic.isEmpty {
                        AsyncImage(url: URL(string: envelopePic)) { phase in
                            switch phase {
                            case .empty:
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            case .failure:
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .overlay(
                                        Image(systemName: "photo")
                                            .foregroundColor(.gray)
                                    )
                            @unknown default:
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                            }
                        }
                        .frame(width: 120, height: 160)
                        .cornerRadius(8)
                        .clipped()
                    }
                    
                    // 右侧内容
                    VStack(alignment: .leading, spacing: 8) {
                        // 标题和时间
                        HStack(alignment: .top) {
                            Text(article.title)
                                .font(.system(size: 16, weight: .medium))
                                .lineLimit(2)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Text(article.niceDate)
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                        
                        // 描述
                        if let desc = article.desc?.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression) {
                            Text(desc)
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                                .lineLimit(3)
                        }
                        
                        Spacer()
                    }
                }
            }
            .buttonStyle(.scale)
            
            // 底部信息栏（独立区域）
            HStack(alignment: .center) {
                // 作者
                if let author = article.author {
                    Label(author, systemImage: "person.circle")
                        .font(.system(size: 12))
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                // 项目链接 - 添加安全检查
                if let projectLink = article.projectLink,
                   !projectLink.isEmpty,  // 添加空字符串检查
                   let url = URL(string: projectLink) {  // URL 创建检查
                    Button {
                        openURL(url)
                    } label: {
                        Image(systemName: "link.circle")
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(.scale)
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
            .padding(.top, 4)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 8, y: 2)
        .onAppear {
            viewModel.checkCollectionStatus(articleId: article.id)
        }
    }
}

// 预览
struct ProjectCardView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // 有图片的文章
            ProjectCardView(article: Article(
                id: 1,
                title: "Flutter 实战：构建跨平台应用",
                desc: "本文介绍了如何使用 Flutter 构建一个跨平台应用，包含完整的示例代码和详细的步骤说明。",
                link: "https://example.com",
                author: "张三",
                shareUser: nil,
                niceDate: "2024-01-18",
                publishTime: 1705545600000,
                collect: false,
                superChapterName: "跨平台",
                chapterName: "Flutter",
                type: 0,
                fresh: true,
                tags: [],
                envelopePic: "https://www.wanandroid.com/blogimgs/89868c9a-e793-46f3-a239-751246951b7f.png",
                projectLink: "https://github.com/example/flutter-demo",
                apkLink: nil,
                prefix: nil
            ))
            
            // 无图片的文章
            ProjectCardView(article: Article(
                id: 3,
                title: "无图片的文章标题",
                desc: "这是一篇没有图片的文章描述，应该显示更多的文本内容。",
                link: "https://example.com",
                author: "作者名",
                shareUser: nil,
                niceDate: "2024-01-18",
                publishTime: 1705545600000,
                collect: false,
                superChapterName: "测试分类",
                chapterName: "子分类",
                type: 0,
                fresh: true,
                tags: [],
                envelopePic: nil,
                projectLink: nil,
                apkLink: nil,
                prefix: nil
            ))
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
} 
