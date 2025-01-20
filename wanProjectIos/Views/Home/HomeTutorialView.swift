//
//  HomeTutorialView.swift
//  wanProjectIos
//
//  Created by neillwu on 2025/1/17.
//

import SwiftUI

struct HomeTutorialView: View {
    @EnvironmentObject var viewModel: HomeViewModel
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.tutorials) { tutorial in
                    TutorialCardView(tutorial: tutorial)
                }
            }
            .padding()
        }
        .refreshable {
            Task {
                await viewModel.refreshData()
            }
        }
    }
}

struct TutorialCardView: View {
    let tutorial: Tutorial
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 封面图片
            AsyncImage(url: URL(string: tutorial.cover)) { phase in
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
                            Image(systemName: "book.closed")
                                .foregroundColor(.gray)
                        )
                @unknown default:
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                }
            }
            .frame(height: 120)
            .clipped()
            .cornerRadius(12)
            
            // 标题
            Text(tutorial.name)
                .font(.headline)
                .lineLimit(2)
                .foregroundColor(.primary)
            
            // 作者
            Label(tutorial.author, systemImage: "person.circle.fill")
                .font(.caption)
                .foregroundColor(.blue)
            
            // 描述
            Text(tutorial.desc)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
} 