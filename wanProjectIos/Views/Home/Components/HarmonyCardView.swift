//
//  HarmonyCardView.swift
//  wanProjectIos
//
//  Created by neillwu on 2025/1/17.
//

import SwiftUI

struct HarmonyCardView: View {
    let article: Article
    @State private var isCollected: Bool
    
    init(article: Article) {
        self.article = article
        _isCollected = State(initialValue: article.collect)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标题栏
            HStack {
                Text("鸿蒙专栏")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(4)
                
                Spacer()
                
                Text(article.niceDate)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            // 标题
            Text(article.title)
                .font(.headline)
                .lineLimit(2)
            
            // 描述
            if let desc = article.desc?.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression) {
                Text(desc)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            
            // 底部信息
            HStack {
                if let author = article.author {
                    Label(author, systemImage: "person.circle")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                // 收藏按钮
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isCollected.toggle()
                    }
                } label: {
                    Image(systemName: isCollected ? "heart.fill" : "heart")
                        .foregroundColor(isCollected ? .red : .gray)
                }
                .buttonStyle(.scale)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// 预览
struct HarmonyCardView_Previews: PreviewProvider {
    static var previews: some View {
        HarmonyCardView(article: Article(
            id: 1,
            title: "鸿蒙开发入门：HarmonyOS应用开发基础",
            desc: "本文介绍了HarmonyOS应用开发的基础知识，包括开发环境搭建、基本组件使用等内容。",
            link: "https://example.com",
            author: "华为开发者",
            shareUser: nil,
            niceDate: "2024-01-18",
            publishTime: 1705545600000,
            collect: false,
            superChapterName: "鸿蒙专栏",
            chapterName: "入门教程",
            type: 0,
            fresh: true,
            tags: [],
            envelopePic: nil,
            projectLink: nil,
            apkLink: nil,
            prefix: nil,
            originId: nil
        ))
        .padding()
        .previewLayout(.sizeThatFits)
    }
} 
