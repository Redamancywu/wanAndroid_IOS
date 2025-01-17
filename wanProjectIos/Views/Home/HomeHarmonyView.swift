//
//  HomeHarmonyView.swift
//  wanProjectIos
//
//  Created by neillwu on 2025/1/17.
//

import SwiftUI

struct HomeHarmonyView: View {
    @EnvironmentObject var viewModel: HomeViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.harmonyArticles) { article in
                    ProjectCardView(article: article)
                        .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .refreshable {
            Task {
                await viewModel.fetchHarmonyArticles()
            }
        }
    }
}

struct HarmonyArticleCard: View {
    let article: Article
    @State private var isLiked: Bool
    
    init(article: Article) {
        self.article = article
        _isLiked = State(initialValue: article.collect)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标题区域
            HStack {
                Text("鸿蒙专栏")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(4)
                
                Spacer()
                
                Button(action: {
                    isLiked.toggle()
                    HiLog.i("文章收藏状态改变: \(article.title), 收藏: \(isLiked)")
                }) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .foregroundColor(isLiked ? .red : .gray)
                }
            }
            
            // 文章标题
            Text(article.title)
                .font(.headline)
                .lineLimit(2)
            
            // 文章描述
            if let desc = article.desc {
                Text(desc)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            
            // 底部信息
            HStack {
                if let author = article.author {
                    Text(author)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text(article.niceDate)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

// 预览
struct HomeHarmonyView_Previews: PreviewProvider {
    static var previews: some View {
        HomeHarmonyView()
            .environmentObject(HomeViewModel())
    }
} 