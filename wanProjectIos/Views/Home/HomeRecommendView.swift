//
//  HomeRecommendView.swift
//  wanProjectIos
//
//  Created by neillwu on 2025/1/17.
//

import SwiftUI

struct HomeRecommendView: View {
    @EnvironmentObject var viewModel: HomeViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.recommendArticles) { article in
                    ArticleCardView(article: article)
                        .padding(.horizontal)
                }
                
                // 加载更多指示器
                if !viewModel.recommendArticles.isEmpty {
                    ProgressView()
                        .padding()
                        .onAppear {
                            Task {
                                await viewModel.loadMoreRecommendArticles()
                            }
                        }
                }
            }
            .padding(.vertical)
        }
        .refreshable {
            Task {
                await viewModel.refreshData()
            }
        }
    }
}

struct RecommendArticleCard: View {
    let article: Article
    @State private var isLiked: Bool
    
    init(article: Article) {
        self.article = article
        _isLiked = State(initialValue: article.collect)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标题
            Text(article.title)
                .font(.headline)
                .lineLimit(2)
                .foregroundColor(.primary)
            
            // 描述
            if let desc = article.desc {
                Text(desc)
                    .font(.subheadline)
                    .lineLimit(3)
                    .foregroundColor(.secondary)
            }
            
            // 底部信息
            HStack {
                // 作者/分享者信息
                if let author = article.author, !author.isEmpty {
                    Label(author, systemImage: "person.circle")
                        .foregroundColor(.blue)
                } else if let shareUser = article.shareUser, !shareUser.isEmpty {
                    Label("分享自: \(shareUser)", systemImage: "person.2.circle")
                        .foregroundColor(.green)
                }
                
                Spacer()
                
                // 日期
                Text(article.niceDate)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                // 收藏按钮
                Button(action: {
                    isLiked.toggle()
                    HiLog.i("文章收藏状态改变: \(article.title), 收藏: \(isLiked)")
                }) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .foregroundColor(isLiked ? .red : .gray)
                }
            }
            .font(.caption)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

// 预览
struct HomeRecommendView_Previews: PreviewProvider {
    static var previews: some View {
        HomeRecommendView()
            .environmentObject(HomeViewModel())
            .environmentObject(UserState.shared)
            .environmentObject(ProfileViewModel())
    }
} 
