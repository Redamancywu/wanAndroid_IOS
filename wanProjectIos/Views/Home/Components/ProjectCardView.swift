//
//  ProjectCardView.swift
//  wanProjectIos
//
//  Created by neillwu on 2025/1/17.
//

import SwiftUI

struct ProjectCardView: View {
    let article: Article
    
    // 从文章描述中提取图片URL
    private var imageUrl: String? {
        if let desc = article.desc,
           let range = desc.range(of: "src=\"(.*?)\"", options: .regularExpression),
           let urlRange = desc[range].range(of: "\"(.*?)\"", options: .regularExpression) {
            let url = desc[urlRange].trimmingCharacters(in: CharacterSet(charactersIn: "\""))
            return url
        }
        return nil
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // 右侧内容
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top, spacing: 12) {
                    // 标题和描述
                    VStack(alignment: .leading, spacing: 8) {
                        Text(article.title)
                            .font(.headline)
                            .lineLimit(2)
                            .foregroundColor(.primary)
                        
                        if let desc = article.desc?.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression) {
                            Text(desc)
                                .font(.subheadline)
                                .lineLimit(imageUrl != nil ? 2 : 3)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // 如果有图片则显示
                    if let imageUrl = imageUrl {
                        AsyncImage(url: URL(string: imageUrl)) { phase in
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
                        .frame(width: 100, height: 90)
                        .cornerRadius(8)
                        .clipped()
                    }
                }
                
                // 底部信息
                HStack {
                    if let author = article.author {
                        Label(author, systemImage: "person.circle.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                    } else if let shareUser = article.shareUser {
                        Label(shareUser, systemImage: "person.circle.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    Text(article.niceDate)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// 预览
struct ProjectCardView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // 有图片的文章
            ProjectCardView(article: MockData.articles[0])
            
            // 无图片的文章
            ProjectCardView(article: Article(
                id: 3,
                title: "无图片的文章标题",
                desc: "这是一篇没有图片的文章描述，应该显示更多的文本内容。这是一篇没有图片的文章描述，应该显示更多的文本内容。",
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
                tags: []
            ))
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
} 
