//
//  WeChatAccountView.swift
//  wanProjectIos
//
//  Created by neillwu on 2025/1/17.
//

import SwiftUI

struct WeChatAccountView: View {
    @StateObject private var viewModel = CategoryViewModel.shared
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                // 左侧作者列表 - 固定宽度
                authorListView
                    .frame(width: 100)
                    .background(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: 3, x: 1, y: 0)
                
                // 右侧内容区域
                ZStack {
                    if viewModel.isLoading {
                        // 加载中显示加载指示器
                        LoadingIndicator(message: "加载中...")
                    } else if let errorMessage = viewModel.errorMessage {
                        // 错误状态显示错误信息
                        ErrorView(message: errorMessage) {
                            Task {
                                await viewModel.fetchAuthors()
                            }
                        }
                    } else {
                        // 加载完成显示文章列表
                        articleList
                            .transition(.opacity.animation(.easeInOut(duration: 0.3)))
                    }
                }
                .frame(width: geometry.size.width - 100)
            }
        }
        .task {
            // 在视图加载时获取作者列表
            await viewModel.fetchAuthors()
        }
    }
    
    // 左侧作者列表
    private var authorListView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                ForEach(viewModel.authors) { author in
                    AuthorButton(
                        author: author.name,
                        isSelected: author.id == viewModel.selectedAuthor?.id
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.selectedAuthor = author
                        }
                        Task {
                            await viewModel.fetchAuthorArticles(author: author.name, page: 0)
                        }
                    }
                }
            }
        }
    }
    
    // 右侧文章列表
    private var articleList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.authorArticles) { article in
                    ArticleCardView(article: article)
                        .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
    }
    
    private var loadingView: some View {
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(1.2)
            
            Text("加载中...")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.top, 8)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 2)
        )
    }
    
    private func errorView(message: String) -> some View {
        VStack {
            Text("加载失败")
                .font(.headline)
                .foregroundColor(.red)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.gray)
            Button("重试") {
                Task {
                    await viewModel.fetchAuthorArticles(
                        author: viewModel.selectedAuthor?.name ?? "",
                        page: 0
                    )
                }
            }
            .padding()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct AuthorButton: View {
    let author: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(author)
                    .font(.subheadline)
                    .foregroundColor(isSelected ? .blue : .primary)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 8)
                
                Spacer()
                
                if isSelected {
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: 3)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .frame(maxWidth: .infinity)
        .background(
            Color.blue.opacity(isSelected ? 0.1 : 0)
                .animation(.easeInOut(duration: 0.2), value: isSelected)
        )
    }
}

//// 可选：创建一个可重用的加载提示框组件
//struct LoadingIndicator: View {
//    let message: String
//    
//    var body: some View {
//        VStack {
//            ProgressView()
//                .progressViewStyle(CircularProgressViewStyle())
//                .scaleEffect(1.2)
//            
//            Text(message)
//                .font(.subheadline)
//                .foregroundColor(.gray)
//                .padding(.top, 8)
//        }
//        .padding(20)
//        .background(
//            RoundedRectangle(cornerRadius: 12)
//                .fill(Color(.systemBackground))
//                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 2)
//        )
//    }
//}
