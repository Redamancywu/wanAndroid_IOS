//
//  SquareView.swift
//  wanProjectIos
//
//  Created by neillwu on 2025/1/17.
//

import SwiftUI

struct SquareView: View {
    @StateObject private var viewModel = CategoryViewModel.shared
    
    var body: some View {
        ZStack {
            if viewModel.isLoading && viewModel.squareArticles.isEmpty {
                LoadingIndicator(message: "加载中...")
            } else if let errorMessage = viewModel.errorMessage {
                ErrorView(message: errorMessage) {
                    Task {
                        await viewModel.fetchSquareArticles(page: 0)
                    }
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.squareArticles) { article in
                            SquareArticleCard(article: article)
                                .padding(.horizontal)
                                .onAppear {
                                    // 加载更多
                                    if article.id == viewModel.squareArticles.last?.id && viewModel.hasMoreData {
                                        Task {
                                            await viewModel.fetchSquareArticles(page: viewModel.currentPage + 1)
                                        }
                                    }
                                }
                        }
                        
                        if viewModel.isLoading && !viewModel.squareArticles.isEmpty {
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
        .task {
            if viewModel.squareArticles.isEmpty {
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