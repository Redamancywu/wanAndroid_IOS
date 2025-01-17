//
//  SystemView.swift
//  wanProjectIos
//
//  Created by neillwu on 2025/1/17.
//

import SwiftUI

struct SystemView: View {
    @StateObject private var viewModel = SystemViewModel.shared
    
    var body: some View {
        HStack(spacing: 0) {
            // 左侧一级分类列表
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    ForEach(viewModel.systemCategories) { category in
                        SystemCategoryButton(
                            title: category.name,
                            isSelected: category.id == viewModel.selectedCategory?.id
                        ) {
                            withAnimation {
                                viewModel.selectedCategory = category
                                if let firstChild = category.children?.first {
                                    viewModel.selectedChild = firstChild
                                    Task {
                                        await viewModel.fetchArticles(cid: firstChild.id, page: 0)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .frame(width: 120)
            .background(Color(.systemBackground))
            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 1, y: 0)
            
            // 右侧内容区域
            if let category = viewModel.selectedCategory {
                ScrollView {
                    VStack(spacing: 16) {
                        // 子分类网格
                        LazyVGrid(
                            columns: [
                                GridItem(.adaptive(minimum: 120, maximum: 180))
                            ],
                            spacing: 16
                        ) {
                            if let children = category.children {
                                ForEach(children) { child in
                                    SystemChildButton(child: child)
                                }
                            }
                        }
                        .padding()
                        
                        // 文章列表
                        if let selectedChild = viewModel.selectedChild {
                            Divider()
                                .padding(.horizontal)
                            
                            HStack {
                                Text(selectedChild.name)
                                    .font(.headline)
                                
                                Spacer()
                                
                                Text("\(viewModel.articles.count) 篇文章")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal)
                            
                            LazyVStack(spacing: 16) {
                                ForEach(viewModel.articles) { article in
                                    ProjectCardView(article: article)
                                        .padding(.horizontal)
                                }
                                
                                if viewModel.hasMoreData {
                                    ProgressView()
                                        .onAppear {
                                            if let child = viewModel.selectedChild {
                                                Task {
                                                    await viewModel.fetchArticles(
                                                        cid: child.id,
                                                        page: viewModel.currentPage + 1
                                                    )
                                                }
                                            }
                                        }
                                }
                            }
                            .padding(.bottom)
                        }
                    }
                }
                .background(Color(.systemBackground))
            } else {
                Text("请选择分类")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color(.systemGroupedBackground))
        .task {
            if viewModel.systemCategories.isEmpty {
                await viewModel.fetchSystemCategories()
            }
        }
    }
}

#Preview("网络数据预览") {
    SystemView()
        .previewDisplayName("实际数据")
}
