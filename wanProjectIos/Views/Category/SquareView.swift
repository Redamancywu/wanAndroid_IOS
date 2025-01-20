//
//  SquareView.swift
//  wanProjectIos
//
//  Created by neillwu on 2025/1/17.
//

import SwiftUI

struct SquareView: View {
    @StateObject private var viewModel = SquareViewModel()
    
    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.articles.isEmpty {
                LoadingView("加载中...")
            } else if let error = viewModel.error {
                ErrorView(
                    error: error,
                    retryAction: {
                        Task {
                            await viewModel.fetchSquareArticles(page: 0)
                        }
                    }
                )
            } else if viewModel.articles.isEmpty {
                EmptyPlaceholderView(
                    icon: "square.grid.2x2",
                    title: "暂无广场文章",
                    message: "稍后再来看看吧"
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.articles) { article in
                            SquareArticleCard(article: article)
                                .padding(.horizontal)
                                .onAppear {
                                    if article.id == viewModel.articles.last?.id && viewModel.hasMoreData {
                                        Task {
                                            await viewModel.fetchSquareArticles(page: viewModel.currentPage + 1)
                                        }
                                    }
                                }
                        }
                        
                        if viewModel.isLoading {
                            ProgressView()
                                .padding()
                        }
                    }
                    .padding(.vertical)
                }
                .refreshable {
                    await viewModel.fetchSquareArticles(page: 0)
                }
            }
        }
        .navigationTitle("广场")
        .task {
            if viewModel.articles.isEmpty {
                await viewModel.fetchSquareArticles(page: 0)
            }
        }
    }
}

struct SquareArticleCard: View {
    let article: SquareArticle
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 标题和分享者
            HStack {
                Text(article.title)
                    .font(.headline)
                    .lineLimit(2)
                
                Spacer()
                
                Label(article.shareUser, systemImage: "person.circle")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            
            // 描述
            if !article.desc.isEmpty {
                Text(article.desc)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            
            // 底部信息
            HStack {
                if let chapterName = article.chapterName {
                    Text(chapterName)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(4)
                }
                
                Spacer()
                
                Text(article.niceDate)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
} 