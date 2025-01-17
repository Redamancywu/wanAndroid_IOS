//
//  ColumnView.swift
//  wanProjectIos
//
//  Created by neillwu on 2025/1/17.
//

import SwiftUI

struct ColumnView: View {
    @StateObject private var viewModel = CategoryViewModel.shared
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                LoadingIndicator(message: "加载中...")
            } else if let errorMessage = viewModel.errorMessage {
                VStack {
                    Text("加载失败")
                        .font(.headline)
                        .foregroundColor(.red)
                    Text(errorMessage)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Button("重试") {
                        Task {
                            await viewModel.fetchColumns()
                        }
                    }
                    .padding()
                }
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(viewModel.columns) { column in
                            ColumnCardView(column: column)
                        }
                    }
                    .padding()
                }
            }
        }
        .task {
            await viewModel.fetchColumns()
        }
    }
}

struct ColumnCardView: View {
    let column: Column
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 图标
            Image(systemName: "newspaper.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .foregroundColor(.blue)
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
            
            // 标题
            Text(column.name)
                .font(.headline)
                .lineLimit(1)
            
            // 分类标签
            Text("专栏")
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.1))
                .foregroundColor(.blue)
                .cornerRadius(4)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
} 