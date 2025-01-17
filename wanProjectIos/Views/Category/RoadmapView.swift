//
//  RoadmapView.swift
//  wanProjectIos
//
//  Created by neillwu on 2025/1/17.
//

import SwiftUI

struct RoadmapView: View {
    @StateObject private var viewModel = CategoryViewModel.shared
    
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
                            await viewModel.fetchRoutes()
                        }
                    }
                    .padding()
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.routes) { route in
                            RouteCardView(route: route)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
        .task {
            await viewModel.fetchRoutes()
        }
    }
}

struct RouteCardView: View {
    let route: Route
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 封面图片
            AsyncImage(url: URL(string: route.cover)) { phase in
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
                            Image(systemName: "map")
                                .foregroundColor(.gray)
                        )
                @unknown default:
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                }
            }
            .frame(height: 160)
            .clipped()
            .cornerRadius(12)
            
            // 标题
            Text(route.name)
                .font(.headline)
            
            // 作者
            if !route.author.isEmpty {
                Label(route.author, systemImage: "person.circle")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            
            // 描述
            Text(route.desc)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
} 